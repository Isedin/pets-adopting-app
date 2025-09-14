// lib/widgets/enums/species_enum.dart

enum Species {
  dog,
  cat,
  fish,
  bird,
  other;

  /// Human readable label (localized / display name)
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

  /// Robust factory: prihvati različite input formate (case insensitive),
  /// fallback = other.
  static Species fromString(String raw) {
    final key = raw.trim().toLowerCase();
    // match by enum name (dog/cat/fish/...)
    return Species.values.firstWhere(
      (e) => e.name == key,
      orElse: () => Species.other,
    );
  }

  /// Još jedna (sinonična) metoda ako želiš drugačiji naziv - nije strogo potrebna
  /// ali može biti korisna čitljivosti.
  static Species fromKey(String raw) => fromString(raw);
}
