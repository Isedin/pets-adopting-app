import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/pet_repository.dart';

const petCollection = "pets";

class FirestorePetRepository implements PetRepository {
  final FirebaseFirestore firestore;

  FirestorePetRepository({required this.firestore});

  @override
  Future<void> addPet(Pet pet) async {
    await firestore.collection(petCollection).add(pet.toMap());

    // Optionally, you can remove petWithId if not used elsewhere
  }

  @override
  FutureOr<void> deletePetById(String id) async {
    // TODO: implement deletePetById
    throw UnimplementedError();
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
  FutureOr<void> updatePet(Pet pet) async {
    // TODO: implement updatePet
    throw UnimplementedError();
  }
}
