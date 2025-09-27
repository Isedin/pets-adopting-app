import 'package:flutter/material.dart';

class InfoTile extends StatelessWidget {
  final IconData leading;
  final String title;
  final String value;
  const InfoTile({
    super.key,
    required this.leading,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(leading),
      title: Text(title),
      subtitle: Text(value),
      dense: true,
    );
  }
}
