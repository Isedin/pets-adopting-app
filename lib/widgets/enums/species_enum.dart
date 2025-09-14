// lib/widgets/enums/species_enum.dart
enum Species { dog, cat, fish, bird, other }

extension SpeciesX on Species {
  String get displayName => switch (this) {
        Species.dog => 'Hund',
        Species.cat => 'Katze',
        Species.fish => 'Fisch',
        Species.bird => 'Vogel',
        Species.other => 'Andere',
      };

  static Species fromString(String raw) {
    final key = raw.trim().toLowerCase();
    // prihvati i legacy varijante
    switch (key) {
      case 'dog':
        return Species.dog;
      case 'cat':
        return Species.cat;
      case 'fish':
        return Species.fish;
      case 'bird':
        return Species.bird;
      case 'other':
        return Species.other;
      default:
        // fallback – skalabilno: ako dođe nešto novo/nepoznato
        return Species.other;
    }
  }
}
