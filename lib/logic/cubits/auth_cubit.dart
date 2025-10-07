import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_state.dart';

/// Simple & stable AuthCubit:
/// - Listener is "dumb": just emits the user (no signOut/verify logic).
/// - register/signIn send verification email and sign out if needed.
/// - UI get clear messages over state.message/state.error.
class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth;
  StreamSubscription<User?>? _sub;

  AuthCubit({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance,
        super(AuthState.initial()) {
    _sub = _auth.authStateChanges().listen(
      (u) {
        // Listener not make side-effects (nema await, nema signOut).
        emit(state.copyWith(
          user: u,
          loading: false,
          error: null,
          message: null,
        ));
        if (u != null) {
          Future.microtask(() async {
            try {
              await u.reload();
            } on FirebaseAuthException catch (e) {
              // if account is invalid → sign out locally
              if (e.code == 'user-not-found' || e.code == 'user-disabled') {
                try { await _auth.signOut(); } catch (_) {}
                emit(state.copyWith(user: null, loading: false, error: null, message: null));
                return;
              }
            } catch (_) {
              // ignore others
            }
          });
        }
      },
    );
  }

  /// Email/password sign-in:
  /// - if not verified: send verify mail, inform via message, signOut.
  Future<void> signIn(String email, String password) async {
    emit(state.copyWith(loading: true, error: null, message: null));
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final u = cred.user;
      if (u == null) {
        emit(state.copyWith(loading: false, error: 'Sign in failed.'));
        return;
      }

      await u.reload(); // refresh emailVerified
      if (!u.emailVerified) {
        try {
          await u.sendEmailVerification();
        } catch (e) {
          // if sending fails, show the reason.
          emit(state.copyWith(loading: false, error: 'Failed to send verification email: $e'));
          // Stay logged in but AuthGate will return to Login when you log out/refresh?
          // For consistency: sign out to stay on the Login screen
          try { await _auth.signOut(); } catch (_) {}
          return;
        }
        // Inform user, sign out to stay on the Login screen
        try { await _auth.signOut(); } catch (_) {}

        emit(state.copyWith(
          loading: false,
          message: 'Verification email sent. Please verify your email before logging in.',
        ));
        try { await _auth.signOut(); } catch (_) {}
        return;
      }

      // Verified → over
      emit(state.copyWith(loading: false));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(loading: false, error: _friendlyError(e)));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  /// Register → send verify email → inform → signOut.
  Future<void> register(String email, String password) async {
    emit(state.copyWith(loading: true, error: null, message: null));
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final u = cred.user;
      if (u == null) {
        emit(state.copyWith(loading: false, error: 'Registration failed.'));
        return;
      }

      try {
        await u.sendEmailVerification();
      } catch (e) {
        emit(state.copyWith(loading: false, error: 'Failed to send verification email: $e'));
        try { await _auth.signOut(); } catch (_) {}
        return;
      }

      try { await _auth.signOut(); } catch (_) {}

      emit(state.copyWith(
        loading: false,
        message: 'We sent you a verification email. Please verify and then log in.',
      ));

      try { await _auth.signOut(); } catch (_) {}
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

  void clearBanners() {
    emit(state.copyWith(error: null, message: null));
  }

  String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-not-found':
        return 'No user found with that email. Please register first.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'Email already in use.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
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
