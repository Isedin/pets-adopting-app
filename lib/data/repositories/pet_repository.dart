import 'dart:io';

import 'package:pummel_the_fish/data/models/pet.dart';
import 'dart:async';

abstract class PetRepository {
  Stream<Pet?> getPetById(String id);
  FutureOr<List<Pet>> getAllPets();
  FutureOr<void> addPet(Pet pet, {File? imageFile});
  FutureOr<void> deletePetById(String id);
  FutureOr<void> updatePet(Pet pet, {File? imageFile}) {
    // Default implementation can be empty or throw an error
    throw UnimplementedError("updatePet method is not implemented");
  }
}
