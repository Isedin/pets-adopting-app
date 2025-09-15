import 'package:flutter/material.dart';

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
        SwitchListTile(
          title: const Text('Krankheiten vorhanden'),
          value: hasDiseases,
          onChanged: onHasDiseasesChanged,
        ),
        if (hasDiseases) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: diseases
                .map((d) => Chip(
                      label: Text(d),
                      onDeleted: () {
                        final next = [...diseases]..remove(d);
                        onDiseasesChanged(next);
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          _AddDiseaseField(
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

class _AddDiseaseField extends StatefulWidget {
  final ValueChanged<String> onAdd;
  const _AddDiseaseField({required this.onAdd});

  @override
  State<_AddDiseaseField> createState() => _AddDiseaseFieldState();
}

class _AddDiseaseFieldState extends State<_AddDiseaseField> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            decoration: const InputDecoration(
              labelText: 'Krankheit hinzufügen (z. B. Allergie)',
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: () {
            widget.onAdd(_ctrl.text);
            _ctrl.clear();
          },
          child: const Text('Hinzufügen'),
        ),
      ],
    );
  }
}
