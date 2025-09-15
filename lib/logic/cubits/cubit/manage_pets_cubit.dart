import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/pet_repository.dart';

part 'manage_pets_state.dart';

class ManagePetsCubit extends Cubit<ManagePetsState> {
  final PetRepository repo;
  StreamSubscription<List<Pet>>? _petsSubscription;
  StreamSubscription<List<Pet>>? _adoptedSubscription;

  ManagePetsCubit(this.repo) : super(const ManagePetsState()) {
    _subscribeToPets();
    _subscribeToAdoptedPets();
    emit(state.copyWith(status: ManagePetsStatus.loading));
  }

  void _subscribeToPets() {
    /// cancel previous subscription if exists
    _petsSubscription?.cancel();

    /// Subscribe to new pet updates from Firestore
    _petsSubscription = repo.watchAllPets().listen(
      (pets) {
        /// when pets are updated emitting new state
        emit(state.copyWith(status: ManagePetsStatus.success, pets: pets));
      },
      onError: (error) {
        emit(state.copyWith(status: ManagePetsStatus.error, errorMessage: error.toString()));
      },
    );
  }

  void _subscribeToAdoptedPets() {
    _adoptedSubscription?.cancel();
    _adoptedSubscription = repo.watchAdoptedPets().listen(
      (adopted) {
        emit(state.copyWith(status: ManagePetsStatus.success, adoptedPets: adopted));
      },
      onError: (error) {
        emit(state.copyWith(status: ManagePetsStatus.error, errorMessage: error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _petsSubscription?.cancel();
    _adoptedSubscription?.cancel();
    return super.close();
  }
}
