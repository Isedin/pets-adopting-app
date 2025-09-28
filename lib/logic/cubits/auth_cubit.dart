// lib/logic/cubits/auth_cubit.dart
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
    _sub = _auth.authStateChanges().listen(
      (u) => emit(state.copyWith(user: u, loading: false, error: null, message: null)),
      onError: (e) => emit(state.copyWith(user: null, loading: false, error: '$e')),
    );
  }

  Future<void> signIn(String email, String password) async {
    emit(state.copyWith(loading: true, error: null, message: null));
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
     
      // If email NOT verified — send link, sign out user and show message
      if (!(cred.user?.emailVerified ?? false)) {
        await cred.user?.sendEmailVerification();
        await _auth.signOut();
        emit(state.copyWith(
          loading: false,
          error: null,
          message: 'Verification email sent. Please verify your email before logging in.',
        ));
        return;
      }
      // All good — the stream will emit further
      emit(state.copyWith(loading: false));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(loading: false, error: _friendlyError(e)));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> register(String email, String password) async {
    emit(state.copyWith(loading: true, error: null, message: null));
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await cred.user?.sendEmailVerification();
      await _auth.signOut(); // no access until verified
      emit(state.copyWith(
        loading: false,
        message: 'We sent you a verification email. Please verify and then log in.',
      ));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(loading: false, error: _friendlyError(e)));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    emit(state.copyWith(loading: true, error: null, message: null));
    try {
      await _auth.sendPasswordResetEmail(email: email);
      emit(state.copyWith(loading: false, message: 'Password reset email sent.'));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(loading: false, error: _friendlyError(e)));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(state.copyWith(loading: true, error: null, message: null));
    try {
      await _auth.signOut();
      emit(state.copyWith(loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-not-found':
        return 'No user found with that email. Please register first.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'Email already in use.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return e.message ?? e.code;
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
