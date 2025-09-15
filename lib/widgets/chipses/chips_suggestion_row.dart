import 'package:flutter/material.dart';

class ChipsSuggestionRow extends StatelessWidget {
  final String title;
  final List<String> items;
  final List<String> selected;
  final ValueChanged<String> onToggle;

  const ChipsSuggestionRow({
    super.key,
    required this.title,
    required this.items,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((e) {
            final active = selected.contains(e);
            return ChoiceChip(label: Text(e), selected: active, onSelected: (_) => onToggle(e));
          }).toList(),
        ),
      ],
    );
  }
}
