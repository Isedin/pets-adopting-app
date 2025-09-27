import 'package:flutter/material.dart';

class GenderCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const GenderCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text('Weiblich?', style: Theme.of(context).textTheme.bodyLarge),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      value: value,
      onChanged: (v) => onChanged(v ?? false),
    );
  }
}
