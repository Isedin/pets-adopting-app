import 'package:flutter/material.dart';
import 'package:pummel_the_fish/widgets/enums/species_enum.dart';
import 'package:pummel_the_fish/utils/icon_utils.dart';

/// Reusable badge widget za prikaz ikone i naziva vrste (Species).
class SpeciesBadge extends StatelessWidget {
  final Species species;
  final String? customLabel;
  final bool withLabel;
  final double size;

  const SpeciesBadge({super.key, required this.species, this.customLabel, this.withLabel = true, this.size = 20});

  @override
  Widget build(BuildContext context) {
    final icon = IconUtils.iconFor(species);
    final color = IconUtils.colorFor(species, Theme.of(context));
    final label = species == Species.other
        ? (customLabel?.trim().isNotEmpty == true ? customLabel! : species.displayName)
        : species.displayName;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: size),
          if (withLabel) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}
