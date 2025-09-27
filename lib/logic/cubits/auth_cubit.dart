import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth;
  StreamSubscription<User?>? _sub;

  AuthCubit({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance,
        super(AuthState.initial()) {
    // Keep state in sync with FirebaseAuth
    _sub = _auth.authStateChanges().listen(
      (u) => emit(state.copyWith(user: u, loading: false, error: null)),
      onError: (e) => emit(state.copyWith(user: null, loading: false, error: '$e')),
    );
  }

  Future<void> signIn(String email, String password) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // authStateChanges listener will emit the new state
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(loading: false, error: e.message ?? e.code));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> register(String email, String password) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Optional: send verification email (non-blocking)
      try {
  await cred.user?.sendEmailVerification();
  print('Verification Email sent!');
} on FirebaseAuthException catch (e) {
  print('Email Verification sending error: ${e.message}');
  // You can show this error to the user if needed
} catch (e) {
  print('Unknown error: $e');
}
      // Listener will update state
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(loading: false, error: e.message ?? e.code));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await _auth.sendPasswordResetEmail(email: email);
      emit(state.copyWith(loading: false)); // success (no error)
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(loading: false, error: e.message ?? e.code));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await _auth.signOut();
      // Listener will emit new state
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
