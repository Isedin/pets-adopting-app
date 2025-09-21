import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Immutable state for [AuthCubit].
/// - [user]: current Firebase user (or null if signed out)
/// - [loading]: true while an auth operation is in-flight or initial load
/// - [error]: last error message (if any), UI may show a snackbar/toast
class AuthState extends Equatable {
  final User? user;
  final bool loading;
  final String? error;

  const AuthState({
    required this.user,
    required this.loading,
    this.error,
  });

  const AuthState.loading() : this(user: null, loading: true);

  AuthState copyWith({
    User? user,
    bool? loading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [user?.uid, loading, error];
}
