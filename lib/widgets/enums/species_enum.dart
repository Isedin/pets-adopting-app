enum Species { dog, cat, fish, bird, other }

extension SpeciesX on Species {
  String get displayName {
    switch (this) {
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

  static Species fromStringSafe(String raw) {
    final k = raw.trim().toLowerCase();
    for (final e in Species.values) {
      if (e.name == k) return e;
    }
    return Species.other;
  }
}

/// Sichere parse string -> enum (fallback: other)
Species speciesFromKey(String? raw) {
  final key = (raw ?? '').trim().toLowerCase();
  for (final s in Species.values) {
    if (s.name == key) return s;
  }
  return Species.other;
}
