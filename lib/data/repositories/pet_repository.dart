import 'dart:io';

import 'package:pummel_the_fish/data/models/pet.dart';
import 'dart:async';

abstract class PetRepository {
  Stream<List<Pet>> watchAllPets();
  Stream<List<Pet>> watchAdoptedPets();
  Stream<Pet?> watchPet(String id);
  Stream<bool> watchIsAdopted(String petId);

  // Writes
  Future<void> addPet(Pet pet, {File? imageFile});
  Future<void> updatePet(Pet pet, {File? imageFile, String? id});
  Future<void> deletePetById(String id);
  Future<bool> adoptPet(String petId);
  Future<void> unadoptPet(String petId);

  Future<List<Pet>> getAllPets();
}
