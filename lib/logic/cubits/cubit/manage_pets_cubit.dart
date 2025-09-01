import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/firestore_pet_repository.dart';

part 'manage_pets_state.dart';

class ManagePetsCubit extends Cubit<ManagePetsState> {
  final FirestorePetRepository firestorePetRepository;
  StreamSubscription<List<Pet>>? _petsSubscription;
  StreamSubscription<List<Pet>>? _adoptedSubscription;

  ManagePetsCubit(this.firestorePetRepository)
    : super(const ManagePetsState()) {
    /// Subscribe to pet updates
    _subscribeToPets();
    _subscribeToAdoptedPets();
    loadPets();
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

  void _subscribeToAdoptedPets() {
    _adoptedSubscription?.cancel();
    _adoptedSubscription = firestorePetRepository
        .getAdoptedPetsAsStream()
        .listen(
          (adopted) {
            emit(
              state.copyWith(
                status: ManagePetsStatus.success,
                adoptedPets: adopted,
              ),
            );
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

  Future<void> loadPets() async {
    emit(state.copyWith(status: ManagePetsStatus.loading));
    try {
      // Stream za sve ljubimce
      firestorePetRepository.getAllPetsAsStream().listen((allPets) {
        // Stream za usvojene ljubimce
        firestorePetRepository.getAdoptionCountAsStream().listen((adoptedPets) {
          emit(state.copyWith(status: ManagePetsStatus.success, pets: allPets));
        });
      });
    } catch (e) {
      emit(
        state.copyWith(
          status: ManagePetsStatus.error,
          errorMessage: 'Fehler während des Ladens der Haustiere: $e',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _petsSubscription?.cancel();
    _adoptedSubscription?.cancel();
    return super.close();
  }
}
