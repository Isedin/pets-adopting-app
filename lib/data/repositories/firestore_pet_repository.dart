import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/pet_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Name der Collection in Firestore
const petCollection = "pets";
const statsCollection = "stats";
const adoptionDocId = "adoption_count";
const adoptionsCollection = "adoptions";

/// FirestorePetRepository implements the PetRepository interface
/// to interact with the Firestore database for pet-related operations.
/// It provides methods to add, delete, retrieve, and update pets.
///
class FirestorePetRepository implements PetRepository {
  /// The [firestore] instance used for database operations.
  final FirebaseFirestore firestore;

  /// The [storage] instance used for file uploads.
  final FirebaseStorage storage;

  /// Creates a new instance of [FirestorePetRepository].
  /// Requires a [firestore] instance to interact with the Firestore database.
  FirestorePetRepository({required this.firestore, required this.storage});

  /// Adds a new pet to the Firestore database.
  /// The [pet] parameter is the pet to be added.
  @override
  Future<void> addPet(Pet pet, {File? imageFile}) async {
    // Adding the pet to the firestore to get the id
    final docRef = firestore.collection(petCollection).doc();
    final petWithId = pet.copyWith(id: docRef.id);

    // Upload the pet image to Firebase Storage if an image file is provided
    if (imageFile != null) {
      final storageRef = storage.ref().child("pet_images/${petWithId.id}.jpg");
      await storageRef.putFile(imageFile);
      final downloadUrl = await storageRef.getDownloadURL();

      // Update pet object with image url
      final petWithPhoto = petWithId.copyWith(imageUrl: downloadUrl);

      // Save updated object to firestore
      await docRef.set(petWithPhoto.toMap());
    } else {
      await docRef.set(petWithId.toMap());
    }
  }

  @override
  @override
  FutureOr<void> deletePetById(String id) async {
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
        tx.set(statsRef, {
          'count': FieldValue.increment(-1),
        }, SetOptions(merge: true));
      }
    });
    print("Pet with ID $id deleted from Firestore");
  }

  @override
  Future<List<Pet>> getAllPets() async {
    final petSnapshots = await firestore.collection(petCollection).get();

    final petList = petSnapshots.docs.map((snapshot) {
      return Pet.fromMap(snapshot.data(), snapshot.id);
    }).toList();
    return petList;
  }

  @override
  Stream<Pet?> getPetById(String id) {
    return firestore.collection(petCollection).doc(id).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        return Pet.fromMap(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

  @override
  Future<void> updatePet(
    Pet pet, {
    File? imageFile,
    @visibleForTesting String? id,
  }) async {
    String? imageUrl = pet.imageUrl;
    if (imageFile != null) {
      final storageRef = storage.ref().child("pet_images/${id ?? pet.id}.jpg");
      await storageRef.putFile(imageFile);
      imageUrl = await storageRef.getDownloadURL();
    }
    final updatedPet = pet.copyWith(imageUrl: imageUrl);
    await firestore
        .collection(petCollection)
        .doc(id ?? pet.id)
        .update(updatedPet.toMap());
  }

  Future<List<Pet>> getPetsBySpecies(String species) async {
    final petSnapshots = await firestore
        .collection(petCollection)
        .where("species", isEqualTo: species)
        .get();

    final petList = petSnapshots.docs
        .map((doc) => Pet.fromJson(jsonEncode(doc.data())))
        .toList();
    return petList;
  }

  Future<List<Pet>> getPetsOrderedByHeight() async {
    final petSnapshots = await firestore
        .collection(petCollection)
        .orderBy("height")
        .get();

    final petList = petSnapshots.docs
        .map((doc) => Pet.fromJson(jsonEncode(doc.data())))
        .toList();
    return petList;
  }

  Stream<List<Pet>> getAllPetsAsStream() {
    return firestore.collection(petCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Pet.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> incrementAdoptionCount() async {
    // final docRef = firestore.collection(statsCollection).doc(adoptionDocId);
    // await firestore.runTransaction((transaction) async {
    //   final docSnapshot = await transaction.get(docRef);

    //   if (!docSnapshot.exists) {
    //     transaction.set(docRef, {'count': 1});
    //   } else {
    //     int newCount = (docSnapshot.data()?['count'] ?? 0) + 1;
    //     transaction.update(docRef, {'count': newCount});
    //   }
    // });
  }

  Stream<int> getAdoptionCountAsStream() {
    return firestore
        .collection(statsCollection)
        .doc(adoptionDocId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists) {
            return snapshot.data()?['count'] ?? 0;
          } else {
            return 0; // Default value if the document does not exist
          }
        });
  }

  Future<bool> markAsAdopted(String petId) async {
    return await firestore.runTransaction((tx) async {
      final adoptRef = firestore.collection(adoptionsCollection).doc(petId);
      final statsRef = firestore.collection(statsCollection).doc(adoptionDocId);

      // READS (all before writes)
      final adoptSnap = await tx.get(adoptRef);

      if (adoptSnap.exists) {
        // allready adopted
        return false;
      }

      // WRITES
      tx.set(adoptRef, {
        'petId': petId,
        'adoptedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      tx.set(statsRef, {
        'count': FieldValue.increment(1),
      }, SetOptions(merge: true));

      return true;
    });
  }

  Stream<bool> isAdoptedStream(String petId) {
    return firestore
        .collection(adoptionsCollection)
        .doc(petId)
        .snapshots()
        .map((d) => d.exists);
  }

  Stream<List<Pet>> getAdoptedPetsAsStream() {
    return firestore.collection(adoptionsCollection).snapshots().asyncMap((
      snap,
    ) async {
      final ids = snap.docs.map((d) => (d.data()['petId'] as String)).toList();
      if (ids.isEmpty) return <Pet>[];

      // dohvatimo svaku životinju po id-u
      final futures = ids.map(
        (id) => firestore.collection(petCollection).doc(id).get(),
      );
      final docs = await Future.wait(futures);
      return docs
          .where((d) => d.exists && d.data() != null)
          .map((d) => Pet.fromMap(d.data()!, d.id))
          .toList();
    });
  }

  Future<void> unadoptedPet(String petId) async {
    await firestore.runTransaction((tx) async {
      final adoptRef = firestore.collection(adoptionsCollection).doc(petId);
      final statsRef = firestore.collection(statsCollection).doc(adoptionDocId);

      // Reads
      final adoptSnap = await tx.get(adoptRef);
      if (!adoptSnap.exists) {
        return;
      }

      // Writes
      tx.delete(adoptRef);
      tx.set(statsRef, {
        'count': FieldValue.increment(-1),
      }, SetOptions(merge: true));
    });
  }
}
