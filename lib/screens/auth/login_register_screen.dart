import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pummel_the_fish/logic/cubits/auth_cubit.dart';
import 'package:pummel_the_fish/logic/cubits/auth_state.dart';

/// Simple login/register screen with email+password + forgot password.
/// Has a dev-only anonymous sign-in button in the AppBar.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailCtrl.text.trim();
    final pass = _passwordCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password.')),
      );
      return;
    }

    final cubit = context.read<AuthCubit>();
    if (_isLogin) {
      cubit.signIn(email, pass);
    } else {
      cubit.register(email, pass);
      // FYI: We already send verification email in the Cubit (optional).
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created. Check your email for verification.')),
      );
    }
  }

  void _forgotPassword() {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email first.')),
      );
      return;
    }
    context.read<AuthCubit>().sendPasswordReset(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Register'),
        actions: [
          if (kDebugMode)
            IconButton(
              tooltip: 'Anonymous sign-in (dev)',
              icon: const Icon(Icons.lock_open),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signInAnonymously();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Anonymous sign-in failed: $e')),
                  );
                }
              },
            ),
        ],
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          // Show errors
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
          // Show success toast after password reset request
          if (!state.loading && state.error == null) {
            // Heuristic: if we just called sendPasswordReset, state.loading toggled.
            // We won't differentiate here to keep it simple.
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 20),

                // Submit
                ElevatedButton(
                  onPressed: state.loading ? null : _submit,
                  child: Text(
                    state.loading
                        ? 'Loading...'
                        : (_isLogin ? 'Login' : 'Register'),
                  ),
                ),

                // Toggle
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin
                        ? 'Need an account? Register'
                        : 'Already have an account? Login',
                  ),
                ),

                // Forgot password (only visible on Login mode)
                if (_isLogin)
                  TextButton(
                    onPressed: state.loading ? null : _forgotPassword,
                    child: const Text('Forgot password?'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
