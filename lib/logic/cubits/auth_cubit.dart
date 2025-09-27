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
      (u) => emit(AuthState(user: u, loading: false)),
      onError: (e) => emit(AuthState(user: null, loading: false, error: '$e')),
    );
  }

  Future<void> signIn(String email, String password) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        emit(state.copyWith(loading: false, error: 'Unknown auth error'));
        return;
      }

      // If not verified – send verification and sign out immediately
      await user.reload();
      if (!(user.emailVerified)) {
        await _safeSendVerification(user);
        await _auth.signOut();
        emit(
          AuthState(
            user: null,
            loading: false,
            error:
                'Verification email sent. Please verify your email address before logging in.',
          ),
        );
        return;
      }

      // Verified: normally, our listener will move us to the logged-in state
      emit(state.copyWith(loading: false));
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
      final user = cred.user;
      if (user != null) {
        await _safeSendVerification(user);
      }
      // Important: sign out immediately – user must not enter before verifying email
      await _auth.signOut();

      emit(
        AuthState(
          user: null,
          loading: false,
          error:
              'Verification email sent. Check your inbox (and spam). You can login after confirming.',
        ),
      );
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(loading: false, error: e.message ?? e.code));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(state.copyWith(error: 'Not signed in'));
      return;
    }
    try {
      await _safeSendVerification(user);
      emit(state.copyWith(error: 'Verification email sent again.'));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(error: e.message ?? e.code));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await _auth.signOut();
      emit(state.copyWith(loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _safeSendVerification(User user) async {
    // (optional) set locale: await _auth.setLanguageCode('de');
    await user.sendEmailVerification();
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
