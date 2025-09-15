import 'package:pummel_the_fish/widgets/enums/species_enum.dart';

class AssetUtils {
  static String speciesAsset(Species s) {
    switch (s) {
      case Species.dog:
        return "assets/images/dog.png";
      case Species.cat:
        return "assets/images/cat.jpg";
      case Species.fish:
        return "assets/images/fish.jpg";
      case Species.bird:
        return "assets/images/bird.jpg";
      case Species.other:
      return "assets/images/fish.jpg";
    }
  }
}
