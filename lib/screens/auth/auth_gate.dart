import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pummel_the_fish/logic/cubits/auth_cubit.dart';
import 'package:pummel_the_fish/logic/cubits/auth_state.dart';
import 'package:pummel_the_fish/screens/auth/login_register_screen.dart';
import 'package:pummel_the_fish/screens/home_screen.dart';

/// Gate that decides whether to show LoginScreen or HomeScreen
/// based on authentication state.
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
        if (state.user != null) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
