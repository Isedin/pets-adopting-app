import 'package:flutter/material.dart';

class BadgeIcon extends StatelessWidget {
  final String tooltip;
  final Widget child;
  final Color color;
  const BadgeIcon({
    super.key,
    required this.tooltip,
    required this.child,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      ),
    );
  }
}
