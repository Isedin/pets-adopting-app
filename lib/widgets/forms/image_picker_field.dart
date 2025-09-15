import 'dart:io';
import 'package:flutter/material.dart';

class ImagePickerField extends StatelessWidget {
  final File? file;
  final String? networkUrl;
  final VoidCallback onPick;

  const ImagePickerField({super.key, this.file, this.networkUrl, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final preview = file != null
        ? Image.file(file!, height: 200, fit: BoxFit.cover)
        : (networkUrl != null ? Image.network(networkUrl!, height: 200, fit: BoxFit.cover) : const SizedBox.shrink());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (file != null || networkUrl != null) preview,
        const SizedBox(height: 8),
        FilledButton.tonal(onPressed: onPick, child: const Text('Bild auswählen')),
      ],
    );
  }
}
