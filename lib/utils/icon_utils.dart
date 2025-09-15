import 'package:flutter/material.dart';
import 'package:pummel_the_fish/widgets/enums/species_enum.dart';

/// Central place for getting icons and colors for species.
class IconUtils {
  /// Primary icon for species.
  static IconData iconFor(Species s) {
    switch (s) {
      case Species.dog:
        return Icons.pets;
      case Species.cat:
        return Icons.pets;
      case Species.fish:
        return Icons.set_meal;
      case Species.bird:
        return Icons.travel_explore;
      case Species.other:
        return Icons.interests;
    }
  }

  static Color colorFor(Species s, ThemeData theme) {
    switch (s) {
      case Species.dog:
        return Colors.brown.shade400;
      case Species.cat:
        return Colors.deepPurple.shade300;
      case Species.fish:
        return Colors.blueAccent;
      case Species.bird:
        return Colors.green.shade600;
      case Species.other:
        return theme.colorScheme.primary;
    }
  }

  static String labelFor(Species s) => s.displayName;
}
