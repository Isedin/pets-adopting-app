// lib/logic/cubits/auth_state.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthState {
  final User? user;
  final bool loading;
  final String? error;

  const AuthState({this.user, this.loading = false, this.error});

  AuthState copyWith({User? user, bool? loading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  factory AuthState.initial() => const AuthState(user: null, loading: true);
}
