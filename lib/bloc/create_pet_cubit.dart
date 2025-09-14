// lib/bloc/create_pet_cubit.dart
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/pet_repository.dart';
import 'package:pummel_the_fish/widgets/enums/species_enum.dart';

part 'create_pet_state.dart';

class CreatePetCubit extends Cubit<CreatePetState> {
  final PetRepository _petRepository;

  CreatePetCubit({required PetRepository petRepository})
      : _petRepository = petRepository,
        super(CreatePetInitial());

  Future<void> addPet({
    required String name,
    required Species species,
    required int age,
    required double height,
    required double weight,
    required bool isFemale,
    File? imageFile,
  }) async {
    try {
      emit(CreatePetLoading());
      final newPet = Pet(
        id: '',
        name: name,
        species: species,
        age: age,
        height: height,
        weight: weight,
        isFemale: isFemale,
      );
      await _petRepository.addPet(newPet, imageFile: imageFile);
      emit(CreatePetSuccess());
    } catch (e) {
      emit(CreatePetFailure(e.toString()));
    }
  }

  Future<void> updatePet({
    required Pet petToUpdate,
    required String name,
    required Species species,
    required int age,
    required double height,
    required double weight,
    required bool isFemale,
    File? imageFile,
  }) async {
    try {
      emit(CreatePetLoading());
      final updatedPet = petToUpdate.copyWith(
        name: name,
        species: species,
        age: age,
        height: height,
        weight: weight,
        isFemale: isFemale,
        imageUrl: petToUpdate.imageUrl,
      );
      await _petRepository.updatePet(updatedPet, imageFile: imageFile);
      emit(CreatePetSuccess());
    } catch (e) {
      emit(CreatePetFailure(e.toString()));
    }
  }
}
