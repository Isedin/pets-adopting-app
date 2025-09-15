import 'package:flutter/material.dart';

class EditableChips extends StatelessWidget {
  final String title;
  final List<String> items;
  final TextEditingController controller;
  final String addLabel;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  const EditableChips({
    super.key,
    required this.title,
    required this.items,
    required this.controller,
    required this.addLabel,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final chips = items
        .map(
          (e) => InputChip(
            label: Text(e),
            onDeleted: () => onRemove(e),
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 8, children: chips),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: addLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => onAdd(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Hinzufügen'),
            ),
          ],
        ),
      ],
    );
  }
}
