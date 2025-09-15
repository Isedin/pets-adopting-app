import 'package:flutter/material.dart';
import 'package:pummel_the_fish/data/models/app_species.dart';

class SpeciesChipsDynamic extends StatelessWidget {
  final List<AppSpecies> items;
  final String? selectedKey;
  final ValueChanged<String?> onSelected;

  const SpeciesChipsDynamic({super.key, required this.items, required this.selectedKey, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      ChoiceChip(label: const Text('Alle'), selected: selectedKey == null, onSelected: (_) => onSelected(null)),
      ...items.map(
        (s) => ChoiceChip(label: Text(s.label), selected: selectedKey == s.key, onSelected: (_) => onSelected(s.key)),
      ),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (_, i) => chips[i],
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: chips.length,
      ),
    );
  }
}
