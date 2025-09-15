import 'package:pummel_the_fish/widgets/enums/species_enum.dart';
import 'package:pummel_the_fish/data/models/pet.dart';

extension PetX on Pet {
  /// Ljudsko-čitljiv naziv vrste (podržava "other" + custom label).
  String get speciesLabel {
    if (species == Species.other) {
      final s = speciesCustom?.trim();
      return (s == null || s.isEmpty) ? 'Andere' : s;
    }
    // Ako enum već ima displayName, koristi ga; fallback switch ako nema.
    try {
      // ignore: undefined_getter
      return (species as dynamic).displayName as String;
    } catch (_) {
      switch (species) {
        case Species.dog:
          return 'Hund';
        case Species.cat:
          return 'Katze';
        case Species.fish:
          return 'Fisch';
        case Species.bird:
          return 'Vogel';
        case Species.other:
          return 'Andere';
      }
    }
  }
}