import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/pet_repository.dart';

part 'manage_pets_state.dart';

class ManagePetsCubit extends Cubit<ManagePetsState> {
  final PetRepository repo;
  StreamSubscription<List<Pet>>? _petsSubscription;
  StreamSubscription<List<Pet>>? _adoptedSubscription;

  ManagePetsCubit(this.repo) : super(const ManagePetsState()) {
    emit(state.copyWith(status: ManagePetsStatus.loading));
    _subscribeToPets();
    _subscribeToAdoptedPets();
  }

  void _subscribeToPets() {
    _petsSubscription?.cancel();

    _petsSubscription = repo.watchAllPets().listen(
      (pets) {
        emit(state.copyWith(status: ManagePetsStatus.success, pets: pets));
      },
      onError: (error) {
        emit(state.copyWith(
          status: ManagePetsStatus.error,
          errorMessage: error.toString(),
        ));
      },
    );
  }

  void _subscribeToAdoptedPets() {
    _adoptedSubscription?.cancel();

    final user = FirebaseAuth.instance.currentUser;
    final isGuest = (user == null) || (user.isAnonymous);

    // Guest/anon cannot have adopted pets.
    if (isGuest) {
      emit(state.copyWith(adoptedPets: const []));
      return;
    }

    _adoptedSubscription = repo.watchAdoptedPets().listen(
      (adopted) {
        // Do not modify status; pets stream is the "main" one.
        emit(state.copyWith(adoptedPets: adopted));
      },
      onError: (_) {
        // Permission denied or something else: do not crash the whole screen.
        emit(state.copyWith(adoptedPets: const []));
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
