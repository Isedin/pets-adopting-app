import 'package:flutter/material.dart';
import 'package:pummel_the_fish/widgets/forms/add_vaccine_field.dart';

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
          AddVaccineField(
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
