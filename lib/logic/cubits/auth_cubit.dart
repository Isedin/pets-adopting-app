import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_state.dart';

/// AuthCubit:
/// - Listens to FirebaseAuth state
/// - Enforces email verification (email/password users)
/// - Emits one-time info message after registration / unverified login attempt
class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth;
  StreamSubscription<User?>? _sub;

  /// Prevent spamming the same "verify your email" message on every auth tick.
  bool _warnedUnverifiedOnce = false;

  AuthCubit({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance,
        super(AuthState.initial()) {
    // IMPORTANT:
    // - Do NOT send verification email from this listener.
    //   We only *observe* state here. Sending is handled in signIn/register.
    _sub = _auth.authStateChanges().listen(
      (u) async {
        // default: no blocking UI
        var next = state.copyWith(loading: false, error: null);

        if (u != null && !u.isAnonymous) {
          // Reload to get fresh emailVerified flag
          await u.reload();

          if (!u.emailVerified) {
            // Force sign-out so unverified users cannot enter the app
            await _auth.signOut();

            // Show the info message only once until the user tries again
            if (!_warnedUnverifiedOnce) {
              _warnedUnverifiedOnce = true;
              emit(AuthState(
                user: null,
                loading: false,
                error: null,
                message:
                    'We sent you a verification email. Please confirm, then log in.',
              ));
              return;
            }

            // Already warned → stay signed-out silently
            emit(next.copyWith(user: null, message: null));
            return;
          }
        } else {
          // No user / guest → reset the one-shot flag so we can warn next time again
          _warnedUnverifiedOnce = false;
        }

        // Normal flow: guest or verified user
        emit(next.copyWith(user: u, message: null));
      },
      onError: (e) => emit(
        state.copyWith(user: null, loading: false, error: '$e'),
      ),
    );
  }

  /// Sign in with email & password.
  /// If not verified: send verification, sign out, and show message.
  Future<void> signIn(String email, String password) async {
    emit(state.copyWith(loading: true, error: null, message: null));
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.reload();
      final verified = cred.user?.emailVerified ?? false;

      if (!verified && !(cred.user?.isAnonymous ?? true)) {
        try {
          await cred.user?.sendEmailVerification();
        } catch (_) {}
        await _auth.signOut();
        // Reset one-shot flag so listener doesn't suppress the message next tick
        _warnedUnverifiedOnce = false;
        emit(state.copyWith(
          loading: false,
          message:
              'Verification email sent. Please verify your email before logging in.',
        ));
        return;
      }

      emit(state.copyWith(loading: false));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(loading: false, error: _friendlyError(e)));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  /// Register new user → send verification → sign out → show message.
  Future<void> register(String email, String password) async {
    emit(state.copyWith(loading: true, error: null, message: null));
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      try {
        await cred.user?.sendEmailVerification();
      } catch (_) {}
      await _auth.signOut();
      // Reset one-shot flag so the next auth tick can show the info message if needed
      _warnedUnverifiedOnce = false;

      emit(state.copyWith(
        loading: false,
        message:
            'We sent you a verification email. Please verify and then log in.',
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

  /// UI should call this after showing a snackbar to avoid repeated banners.
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
