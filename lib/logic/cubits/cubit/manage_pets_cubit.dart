import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/firestore_pet_repository.dart';

part 'manage_pets_state.dart';

class ManagePetsCubit extends Cubit<ManagePetsState> {
  final FirestorePetRepository firestorePetRepository;
  ManagePetsCubit(this.firestorePetRepository) : super(ManagePetsInitial());

  Future<void> getAllPets() async {
    emit(ManagePetsLoading());
    try {
      final pets = await firestorePetRepository.getAllPets();

      emit(ManagePetsSuccess(pets: pets));
    } on Exception {
      emit(ManagePetsError());
    }
  }
}
