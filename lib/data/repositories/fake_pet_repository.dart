import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
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

  final _listController = StreamController<List<Pet>>.broadcast();
  final _adoptedIds = <String>{};
  final _adoptedController = StreamController<List<Pet>>.broadcast();

  FakePetRepository() {
    _emitList();
    _emitAdopted();
  }

  void _emitList() {
    _pets.sort((a, b) => a.name.compareTo(b.name));
    _listController.add(List.unmodifiable(_pets));
    _emitAdopted();
  }

  void _emitAdopted() {
    final adopted = _pets.where((p) => _adoptedIds.contains(p.id)).toList();
    _adoptedController.add(List.unmodifiable(adopted));
  }

  @override
  Future<void> addPet(Pet pet, {File? imageFile}) async {
    final id = pet.id.isEmpty
        ? DateTime.now().microsecondsSinceEpoch.toString()
        : pet.id;
    _pets.add(pet.copyWith(id: id));
    _emitList();
  }

  @override
  Future<void> updatePet(Pet updatedPet, {File? imageFile, String? id}) async {
    final targetId = id ?? updatedPet.id;
    final index = _pets.indexWhere((p) => p.id == targetId);
    if (index != -1) {
      _pets[index] = updatedPet.copyWith(id: targetId);
      _emitList();
    }
  }

  @override
  Future<void> deletePetById(String id) async {
    _pets.removeWhere((p) => p.id == id);
    _adoptedIds.remove(id);
    _emitList();
  }

  @override
  Stream<Pet?> watchPet(String id) async* {
    yield _pets.firstWhereOrNull((p) => p.id == id);
  }

  @override
  Future<List<Pet>> getAllPets() async {
    _pets.sort((a, b) => a.name.compareTo(b.name));
    return List.unmodifiable(_pets);
  }

  @override
  Stream<List<Pet>> watchAllPets() => _listController.stream;

  @override
  Stream<List<Pet>> watchAdoptedPets() => _adoptedController.stream;

  @override
  Future<bool> adoptPet(String petId) async {
    final added = _adoptedIds.add(petId);
    _emitAdopted();
    return added;
  }

  @override
  Future<void> unadoptPet(String petId) async {
    _adoptedIds.remove(petId);
    _emitAdopted();
  }

  @override
  Stream<bool> watchIsAdopted(String petId) =>
      _adoptedController.stream.map((list) => list.any((p) => p.id == petId));
}
