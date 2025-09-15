import 'package:flutter/material.dart';
import 'package:pummel_the_fish/widgets/enums/species_enum.dart';

class SpeciesSelector extends StatelessWidget {
  final Species? value;
  final ValueChanged<Species?> onChanged;
  final TextEditingController? customController;

  const SpeciesSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.customController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<Species>(
          initialValue: value,
          items: Species.values.map((Species s) {
            return DropdownMenuItem(
              value: s,
              child: Text(s.displayName),
            );
          }).toList(),
          decoration: const InputDecoration(labelText: 'Tierart'),
          onChanged: onChanged,
          validator: (val) => val == null ? 'Bitte Tierart wählen' : null,
        ),
        if (value == Species.other && customController != null) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: customController,
            decoration: const InputDecoration(
              labelText: 'Andere Tierart (z. B. Iguana)',
            ),
            validator: (v) {
              if (value == Species.other) {
                if (v == null || v.trim().isEmpty) {
                  return 'Bitte benutzerdefinierte Tierart eingeben';
                }
              }
              return null;
            },
          ),
        ],
      ],
    );
  }
}
