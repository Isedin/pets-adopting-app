import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pummel_the_fish/logic/cubits/auth_cubit.dart';
import 'package:pummel_the_fish/logic/cubits/auth_state.dart';
import 'package:pummel_the_fish/screens/auth/login_register_screen.dart';
import 'package:pummel_the_fish/screens/home_screen.dart';

/// AuthGate decides which screen to show:
/// - Shows Login/Register if not authenticated
/// - Allows guests (anonymous) directly to Home
/// - Requires email verification for email/password users
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final u = state.user;
        if (u == null) {
          // Not signed in → show login/register screen
          return const LoginScreen();
        }

        if (u.isAnonymous) {
          // Guest user → allow entry with limited permissions
          return const HomeScreen();
        }

        // Email user must be verified
        if (!(u.emailVerified)) {
          return const LoginScreen();
        }

        return const HomeScreen();
      },
    );
  }
}
