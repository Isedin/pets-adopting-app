import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/firestore_pet_repository.dart';

part 'manage_pets_state.dart';

class ManagePetsCubit extends Cubit<ManagePetsState> {
  final FirestorePetRepository firestorePetRepository;
  StreamSubscription<List<Pet>>? _petsSubscription;

  ManagePetsCubit(this.firestorePetRepository)
    : super(const ManagePetsState()) {
    /// Subscribe to pet updates
    _subscribeToPets();
  }

  void _subscribeToPets() {
    /// cancel previous subscription if exists
    _petsSubscription?.cancel();

    /// Subscribe to new pet updates from Firestore
    _petsSubscription = firestorePetRepository.getAllPetsAsStream().listen(
      (pets) {
        /// when pets are updated emitting new state
        emit(state.copyWith(status: ManagePetsStatus.success, pets: pets));
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: ManagePetsStatus.error,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }
}
