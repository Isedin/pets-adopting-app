import 'package:flutter/material.dart';

class AddDiseaseField extends StatefulWidget {
  final ValueChanged<String> onAdd;
  const AddDiseaseField({super.key, required this.onAdd});

  @override
  State<AddDiseaseField> createState() => _AddDiseaseFieldState();
}

class _AddDiseaseFieldState extends State<AddDiseaseField> {
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
            decoration: const InputDecoration(labelText: 'Krankheit hinzufügen (z. B. Allergie)'),
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(onPressed: _submit, child: const Text('Hinzufügen')),
      ],
    );
  }
}
