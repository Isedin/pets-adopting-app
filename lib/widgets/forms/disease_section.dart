import 'package:flutter/material.dart';
import 'package:pummel_the_fish/widgets/forms/add_disease_field.dart';

class DiseaseSection extends StatelessWidget {
  final bool hasDiseases;
  final List<String> diseases;
  final ValueChanged<bool> onHasDiseasesChanged;
  final ValueChanged<List<String>> onDiseasesChanged;

  const DiseaseSection({
    super.key,
    required this.hasDiseases,
    required this.diseases,
    required this.onHasDiseasesChanged,
    required this.onDiseasesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(title: const Text('Krankheiten vorhanden'), value: hasDiseases, onChanged: onHasDiseasesChanged),
        if (hasDiseases) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: diseases
                .map(
                  (d) => Chip(
                    label: Text(d),
                    onDeleted: () {
                      final next = [...diseases]..remove(d);
                      onDiseasesChanged(next);
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          AddDiseaseField(
            onAdd: (label) {
              if (label.trim().isEmpty) return;
              final next = {...diseases, label.trim()}.toList();
              onDiseasesChanged(next);
            },
          ),
        ],
      ],
    );
  }
}
