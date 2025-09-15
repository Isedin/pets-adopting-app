import 'package:flutter/material.dart';
import 'package:pummel_the_fish/widgets/enums/species_enum.dart';

class SpeciesChips extends StatelessWidget {
  final Species? selected;
  final ValueChanged<Species?> onSelected;
  const SpeciesChips({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final items = [null, ...Species.values]; // null = All
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final s = items[i];
          final active = selected == s;
          final label = s == null ? 'Alle' : s.displayName;
          return ChoiceChip(label: Text(label), selected: active, onSelected: (_) => onSelected(s));
        },
      ),
    );
  }
}
