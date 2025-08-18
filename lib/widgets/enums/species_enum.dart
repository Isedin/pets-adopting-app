enum Species { dog, cat, fish, bird }

extension SpeciesX on Species {
  static Species fromString(String value) {
    switch (value.toLowerCase()) {
      case "dog":
        return Species.dog;
      case "cat":
        return Species.cat;
      case "fish":
        return Species.fish;
      case "bird":
        return Species.bird;
      default:
        throw Exception("Unknown species: $value");
    }
  }

  String toShortString() {
    return toString().split('.').last;
  }
}
