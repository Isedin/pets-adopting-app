enum Species {
  dog,
  cat,
  fish,
  bird;

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
    }
  }

  static Species fromString(String speciesString) {
    switch (speciesString) {
      case 'dog':
        return Species.dog;
      case 'cat':
        return Species.cat;
      case 'fish':
        return Species.fish;
      case 'bird':
        return Species.bird;
      default:
        return Species.dog;
    }
  }
}
