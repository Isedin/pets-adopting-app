import 'package:flutter/material.dart';

class VaccinationSection extends StatelessWidget {
  final bool vaccinated;
  final List<String> vaccines;
  final ValueChanged<bool> onVaccinatedChanged;
  final ValueChanged<List<String>> onVaccinesChanged;

  const VaccinationSection({
    super.key,
    required this.vaccinated,
    required this.vaccines,
    required this.onVaccinatedChanged,
    required this.onVaccinesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(title: const Text('Geimpft'), value: vaccinated, onChanged: onVaccinatedChanged),
        if (vaccinated) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: vaccines
                .map(
                  (v) => Chip(
                    label: Text(v),
                    onDeleted: () {
                      final next = [...vaccines]..remove(v);
                      onVaccinesChanged(next);
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          _AddVaccineField(
            onAdd: (label) {
              if (label.trim().isEmpty) return;
              final next = {...vaccines, label.trim()}.toList();
              onVaccinesChanged(next);
            },
          ),
        ],
      ],
    );
  }
}

class _AddVaccineField extends StatefulWidget {
  final ValueChanged<String> onAdd;
  const _AddVaccineField({required this.onAdd});

  @override
  State<_AddVaccineField> createState() => _AddVaccineFieldState();
}

class _AddVaccineFieldState extends State<_AddVaccineField> {
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
            decoration: const InputDecoration(labelText: 'Impfung hinzufügen (z. B. Tollwut)'),
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
