import 'package:flutter/material.dart';

class AddVaccineField extends StatefulWidget {
  final ValueChanged<String> onAdd;
  const AddVaccineField({super.key, required this.onAdd});

  @override
  State<AddVaccineField> createState() => _AddVaccineFieldState();
}

class _AddVaccineFieldState extends State<AddVaccineField> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onAdd(_ctrl.text);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            decoration: const InputDecoration(
              labelText: 'Impfung hinzufügen (z. B. Tollwut)',
            ),
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(onPressed: _submit, child: const Text('Hinzufügen')),
      ],
    );
  }
}
