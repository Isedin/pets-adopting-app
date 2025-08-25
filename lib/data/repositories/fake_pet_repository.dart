import 'dart:io';

import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:collection/collection.dart';
import 'package:pummel_the_fish/data/repositories/pet_repository.dart';
import 'package:pummel_the_fish/widgets/enums/species_enum.dart';

class FakePetRepository implements PetRepository {
  final List<Pet> _pets = [
    Pet(
      id: "1",
      name: "Pummel",
      species: Species.fish,
      age: 2,
      weight: 1.5,
      height: 0.5,
      isFemale: false,
      birthday: DateTime(2021, 5, 20),
    ),
    Pet(
      id: "2",
      name: "Fluffy",
      species: Species.cat,
      age: 3,
      weight: 4.0,
      height: 0.3,
      isFemale: true,
      birthday: DateTime(2020, 3, 15),
    ),
    Pet(
      id: "3",
      name: "Rex",
      species: Species.dog,
      age: 5,
      weight: 20.0,
      height: 0.6,
      isFemale: false,
      birthday: DateTime(2018, 7, 10),
    ),
    Pet(
      id: "4",
      name: "Tweety",
      species: Species.bird,
      age: 1,
      weight: 0.1,
      height: 0.2,
      isFemale: true,
      birthday: DateTime(2022, 11, 5),
    ),
  ];

  FakePetRepository();

  // Fügt ein Pet-Objekt zur Liste hinzu
  @override
  void addPet(Pet pet, {File? imageFile}) {
    _pets.add(pet);
  }

  // Aktualisiert ein Pet-Objekt in der Liste, wenn es existiert
  void updatePet(Pet updatedPet, {File? imageFile}) {
    final index = _pets.indexWhere((pet) => pet.id == updatedPet.id);
    if (index != -1) {
      _pets[index] = updatedPet;
    }
  }

  // Wenn es kein Pet mit der angegebenen ID gibt, wird null zurückgegeben
  @override
  Pet? getPetById(String id) {
    return _pets.firstWhereOrNull((pet) => pet.id == id);
  }

  // Gibt eine sortierte Liste aller Pets zurück
  @override
  List<Pet> getAllPets() {
    // await Future.delayed(const Duration(seconds: 3));
    _sortPetsByName(); // Simulate network delay
    return _pets;
  }

  // Löscht ein Pet-Objekt mit der gewünschten ID aus der Liste
  @override
  void deletePetById(String id) {
    _pets.removeWhere((pet) => pet.id == id);
  }

  // Sortiert die Liste der Pets nach Namen
  void _sortPetsByName() {
    _pets.sort((a, b) => a.name.compareTo(b.name));
  }

  static String makeACoolPetName(
    String nameILike, {
    String? titleOfNobility,
    required Species species,
    String coolAdjective = "cool",
  }) {
    titleOfNobility = titleOfNobility ?? "";
    String coolName =
        "$titleOfNobility $nameILike the $coolAdjective ${species.name}";
    return coolName;
  }
}
