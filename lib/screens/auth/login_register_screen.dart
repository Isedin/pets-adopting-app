// lib/screens/auth/login_register_screen.dart
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pummel_the_fish/logic/cubits/auth_cubit.dart';
import 'package:pummel_the_fish/logic/cubits/auth_state.dart';

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
    if (email.isEmpty || pass.isEmpty) return;

    final cubit = context.read<AuthCubit>();
    if (_isLogin) {
      cubit.signIn(email, pass);
    } else {
      cubit.register(email, pass);
    }
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
          if (state.error != null && state.error!.isNotEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
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
                ElevatedButton(
                  onPressed: state.loading ? null : _submit,
                  child: Text(
                    state.loading
                        ? 'Loading...'
                        : (_isLogin ? 'Login' : 'Register'),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin
                        ? 'Need an account? Register'
                        : 'Already have an account? Login',
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: state.loading
                      ? null
                      : () {
                          final email = _emailCtrl.text.trim();
                          if (email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Enter your email first'),
                              ),
                            );
                            return;
                          }
                          FirebaseAuth.instance
                              .sendPasswordResetEmail(email: email)
                              .then((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Password reset email sent.'),
                                  ),
                                );
                              })
                              .catchError((e) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text('$e')));
                              });
                        },
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
