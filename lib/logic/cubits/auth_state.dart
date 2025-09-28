// lib/logic/cubits/auth_state.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthState {
  final User? user;
  final bool loading;
  final String? error;
  final String? message;

  const AuthState({this.user, this.loading = false, this.error, this.message});

  AuthState copyWith({
    User? user,
    bool? loading,
    String? error,
    String? message,
  }) {
    return AuthState(
      user: user ?? this.user,
      loading: loading ?? this.loading,
      error: error,
      message: message ?? this.message,
    );
  }

  factory AuthState.initial() => const AuthState(user: null, loading: true);
}
