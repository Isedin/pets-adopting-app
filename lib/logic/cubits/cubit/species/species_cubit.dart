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

  Future<bool> addIfMissing(String key, String label) async {
    // local change – no repo hit if already exists
    final exists = state.items.any((s) => s.key == key);
    if (exists) return false;

    try {
      // repo call; we suppose the repo itself handles race conditions on the server
      await repo.addIfMissing(key: key, label: label);

      // we do not force a reload – we are subscribed to watchAll(), so the state will come by itself
      return true;
    } catch (_) {
      // no throwing – UI does not crash
      return false;
    }
  }
}
