import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pummel_the_fish/data/models/app_species.dart';
import 'package:pummel_the_fish/data/repositories/species_repository.dart';

part 'species_state.dart';

class SpeciesCubit extends Cubit<SpeciesState> {
  final SpeciesRepository repo;
  SpeciesCubit(this.repo) : super(const SpeciesState.loading()) {
    repo.watchAll().listen(
      (list) => emit(SpeciesState.loaded(list)),
      onError: (e) => emit(SpeciesState.error(e.toString())),
    );
  }

  Future<void> addIfMissing(String key, String label) => repo.addIfMissing(key: key, label: label);
}
