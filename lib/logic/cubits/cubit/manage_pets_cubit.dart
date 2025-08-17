import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/firestore_pet_repository.dart';

part 'manage_pets_state.dart';

class ManagePetsCubit extends Cubit<ManagePetsState> {
  final FirestorePetRepository firestorePetRepository;
  ManagePetsCubit(this.firestorePetRepository) : super(const ManagePetsState());

  Future<void> getAllPets() async {
    emit(state.copyWith(status: ManagePetsStatus.loading));
    try {
      final pets = await firestorePetRepository.getAllPets();

      emit(state.copyWith(status: ManagePetsStatus.success, pets: pets));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: ManagePetsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
