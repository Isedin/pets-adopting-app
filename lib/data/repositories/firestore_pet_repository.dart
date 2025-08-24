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

/// FirestorePetRepository implements the PetRepository interface
/// to interact with the Firestore database for pet-related operations.
/// It provides methods to add, delete, retrieve, and update pets.
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
    await firestore.collection(petCollection).add(pet.toMap());

    // Optionally, you can remove petWithId if not used elsewhere
  }

  @override
  FutureOr<void> deletePetById(String id) async {
    await firestore.collection(petCollection).doc(id).delete();
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
  FutureOr<Pet?> getPetById(String id) async {
    // TODO: implement getPetById
    throw UnimplementedError();
  }

  @override
  Future<void> updatePet(Pet pet, {@visibleForTesting String? id}) async {
    await firestore
        .collection(petCollection)
        .doc(id ?? pet.id)
        .update(pet.toMap());
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
    final docRef = firestore.collection(statsCollection).doc(adoptionDocId);
    await firestore.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(docRef);

      if (!docSnapshot.exists) {
        transaction.set(docRef, {'count': 1});
      } else {
        int newCount = (docSnapshot.data()?['count'] ?? 0) + 1;
        transaction.update(docRef, {'count': newCount});
      }
    });
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
}
