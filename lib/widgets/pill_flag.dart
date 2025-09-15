import 'package:flutter/material.dart';

class PillFlag extends StatelessWidget {
  final bool active;
  final String trueText;
  final String falseText;
  const PillFlag({super.key, required this.active, required this.trueText, required this.falseText});

  @override
  Widget build(BuildContext context) {
    final txt = active ? trueText : falseText;
    final bg = active ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
      child: Text(txt, style: const TextStyle(color: Colors.white)),
    );
  }
}
