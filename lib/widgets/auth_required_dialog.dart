import 'package:flutter/material.dart';

Future<void> showAuthRequiredDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Sign in required'),
      content: const Text(
        'Please log in or create an account to perform this action.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // close
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // close dialog
            Navigator.of(context).pushNamed('/'); // AuthGate → Login
          },
          child: const Text('Login / Register'),
        ),
      ],
    ),
  );
}
