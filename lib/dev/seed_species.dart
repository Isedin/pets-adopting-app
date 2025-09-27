import 'package:pummel_the_fish/data/repositories/species_repository.dart';

Future<void> seedBuiltInSpecies(SpeciesRepository repo) async {
  final builtins = const {
    'dog': 'Hund',
    'cat': 'Katze',
    'fish': 'Fisch',
    'bird': 'Vogel',
  };

  for (final entry in builtins.entries) {
    await repo.addIfMissing(key: entry.key, label: entry.value);
  }
}
