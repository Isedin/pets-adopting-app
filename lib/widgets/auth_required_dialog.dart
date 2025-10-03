import 'package:flutter/material.dart';
import 'package:pummel_the_fish/screens/auth/auth_gate.dart';

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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // close dialog
            // Hard reset to AuthGate — AuthGate Login/Home decides next step
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AuthGate()),
              (route) => false,
            );
          },
          child: const Text('Login / Register'),
        ),
      ],
    ),
  );
}
