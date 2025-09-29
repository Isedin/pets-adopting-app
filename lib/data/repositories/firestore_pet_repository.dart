import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 👈 NEW
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import 'package:pummel_the_fish/data/mappers/pet_mapper.dart';
import 'package:pummel_the_fish/data/models/owner.dart'; // 👈 NEW
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/pet_repository.dart';

/// Name der Collection in Firestore
const petCollection = "pets";
const statsCollection = "stats";
const adoptionDocId = "adoption_count";
const adoptionsCollection = "adoptions";

class FirestorePetRepository implements PetRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  FirestorePetRepository({required this.firestore, required this.storage});

  // --- helpers --------------------------------------------------------------

  Owner? _ownerFromAuth() {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null || u.isAnonymous) return null;
    final display = (u.displayName?.trim().isNotEmpty ?? false)
        ? u.displayName!.trim()
        : (u.email ?? '');
    return Owner(id: u.uid, name: display);
  }

  // --- pets -----------------------------------------------------------------

  @override
  Future<void> addPet(Pet pet, {File? imageFile}) async {
    // create doc id
    final docRef = firestore.collection(petCollection).doc();
    final petWithId = pet.copyWith(id: docRef.id);

    // enrich with owner from auth (required by rules)
    final owner = _ownerFromAuth();
    if (owner == null) {
      throw StateError('Not authenticated. Please log in to add a pet.');
    }
    final petWithOwner = petWithId.copyWith(owner: owner);

    // optional image upload
    Pet toSave = petWithOwner;
    if (imageFile != null) {
      final storageRef = storage.ref().child("pet_images/${petWithOwner.id}.jpg");
      await storageRef.putFile(imageFile);
      final downloadUrl = await storageRef.getDownloadURL();
      toSave = petWithOwner.copyWith(imageUrl: downloadUrl);
    }

    // write – we use mapper (write ownerId, speciesKey/speciesLabel, etc.)
    await docRef.set(PetMapper.toFirestore(toSave));
  }

  @override
  Future<void> deletePetById(String id) async {
    await firestore.runTransaction((tx) async {
      final petRef = firestore.collection(petCollection).doc(id);
      final adoptRef = firestore.collection(adoptionsCollection).doc(id);
      final statsRef = firestore.collection(statsCollection).doc(adoptionDocId);

      // READS
      final adoptSnap = await tx.get(adoptRef);

      // WRITES
      tx.delete(petRef);

      if (adoptSnap.exists) {
        tx.delete(adoptRef);
        tx.set(statsRef, {'count': FieldValue.increment(-1)}, SetOptions(merge: true));
      }
    });
    if (kDebugMode) print("Pet with ID $id deleted from Firestore");
  }

  @override
  Future<List<Pet>> getAllPets() async {
    final petSnapshots = await firestore.collection(petCollection).get();
    return petSnapshots.docs
        .map((s) => PetMapper.fromFirestore(s.data(), s.id))
        .toList();
  }

  @override
  Stream<Pet?> watchPet(String id) {
    return firestore
        .collection(petCollection)
        .doc(id)
        .snapshots()
        .map((s) => s.exists ? PetMapper.fromFirestore(s.data()!, s.id) : null);
  }

  @override
  Future<void> updatePet(
    Pet pet, {
    File? imageFile,
    @visibleForTesting String? id,
  }) async {
    // (optional) keep owner from auth if missing in model
    final currentOwner = _ownerFromAuth();
    final withOwner = pet.owner == null ? pet.copyWith(owner: currentOwner) : pet;

    String? imageUrl = withOwner.imageUrl;
    if (imageFile != null) {
      final storageRef = storage.ref().child("pet_images/${id ?? withOwner.id}.jpg");
      await storageRef.putFile(imageFile);
      imageUrl = await storageRef.getDownloadURL();
    }
    final updatedPet = withOwner.copyWith(imageUrl: imageUrl);

    await firestore
        .collection(petCollection)
        .doc(id ?? updatedPet.id)
        .update(PetMapper.toFirestore(updatedPet));
  }

  Future<List<Pet>> getPetsBySpecies(String species) async {
    final petSnapshots =
        await firestore.collection(petCollection).where("species", isEqualTo: species).get();

    final petList =
        petSnapshots.docs.map((doc) => PetMapper.fromFirestore(doc.data(), doc.id)).toList();
    return petList;
  }

  Future<List<Pet>> getPetsOrderedByHeight() async {
    final petSnapshots = await firestore.collection(petCollection).orderBy("height").get();

    final petList =
        petSnapshots.docs.map((doc) => PetMapper.fromFirestore(doc.data(), doc.id)).toList();
    return petList;
  }

  @override
  Stream<List<Pet>> watchAllPets() {
    return firestore.collection(petCollection).snapshots().handleError((e, st) {
      debugPrint('watchAllPets FIRESTORE ERROR: $e');
    }).map(
      (snap) => snap.docs.map((d) => PetMapper.fromFirestore(d.data(), d.id)).toList(),
    );
  }

  Future<void> incrementAdoptionCount() async {
    // (currently not used – left empty)
  }

  Stream<int> getAdoptionCountAsStream() {
    return firestore.collection(statsCollection).doc(adoptionDocId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data()?['count'] ?? 0;
      } else {
        return 0;
      }
    });
  }

  // --- adoptions ------------------------------------------------------------

  @override
  Stream<bool> watchIsAdopted(String petId) {
    return firestore.collection(adoptionsCollection).doc(petId).snapshots().map((d) => d.exists);
  }

  @override
  Stream<List<Pet>> watchAdoptedPets() {
    return firestore.collection(adoptionsCollection).snapshots().asyncMap((snap) async {
      final ids = snap.docs.map((d) => (d.data()['petId'] as String)).toList();
      if (ids.isEmpty) return <Pet>[];

      final futures = ids.map((id) => firestore.collection(petCollection).doc(id).get());
      final docs = await Future.wait(futures);
      return docs
          .where((d) => d.exists && d.data() != null)
          .map((d) => PetMapper.fromFirestore(d.data()!, d.id))
          .toList();
    });
  }

  @override
  Future<bool> adoptPet(String petId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      throw StateError('Not authenticated.');
    }

    // client-side guard: omit owner from adopting their own pet
    final petDoc = await firestore.collection(petCollection).doc(petId).get();
    final data = petDoc.data();
    final ownerId = data?['ownerId'] as String?;
    if (ownerId != null && ownerId == user.uid) {
      return false; // owner cannot adopt their own pet
    }

    return await firestore.runTransaction((tx) async {
      final adoptRef = firestore.collection(adoptionsCollection).doc(petId);
      final statsRef = firestore.collection(statsCollection).doc(adoptionDocId);

      final adoptSnap = await tx.get(adoptRef);
      if (adoptSnap.exists) {
        return false; // already adopted
      }

      tx.set(
        adoptRef,
        {
          'petId': petId,
          'userId': user.uid, // important for rules
          'adoptedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      tx.set(statsRef, {'count': FieldValue.increment(1)}, SetOptions(merge: true));

      return true;
    });
  }

  @override
  Future<void> unadoptPet(String petId) async {
    await firestore.runTransaction((tx) async {
      final adoptRef = firestore.collection(adoptionsCollection).doc(petId);
      final statsRef = firestore.collection(statsCollection).doc(adoptionDocId);

      final adoptSnap = await tx.get(adoptRef);
      if (!adoptSnap.exists) {
        return;
      }

      tx.delete(adoptRef);
      tx.set(statsRef, {'count': FieldValue.increment(-1)}, SetOptions(merge: true));
    });
  }
}
