import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_state.dart';

/// Cubit that exposes the FirebaseAuth user and auth actions.
/// - supports: email+password (signIn/register), optional anon, optional email-link.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState.loading()) {
    _sub = _auth.authStateChanges().listen(
      (user) => emit(AuthState(user: user, loading: false)),
      onError: (e) => emit(AuthState(user: null, loading: false, error: e.toString())),
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _sub;

  // -----------------------
  // Email + Password flows
  // -----------------------
  Future<void> signIn(String email, String password) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      emit(state.copyWith(loading: false));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(loading: false, error: e.message ?? e.code));
      rethrow;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> register(String email, String password) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      emit(state.copyWith(loading: false));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(loading: false, error: e.message ?? e.code));
      rethrow;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  // -----------------------
  // Optional: anonymous
  // -----------------------
  Future<void> signInAnonymously() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await _auth.signInAnonymously();
      emit(state.copyWith(loading: false));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(loading: false, error: e.message ?? e.code));
      rethrow;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  // -----------------------
  // Optional: email-link (passwordless)
  // (možeš ignorisati ako ne koristiš ovaj flow)
  // -----------------------
  Future<void> sendEmailLink(String email) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final settings = ActionCodeSettings(
        url: 'https://pummelthefish.page.link/emailSignIn',
        handleCodeInApp: true,
        iOSBundleId: 'com.your.bundleid.ios',
        androidPackageName: 'com.your.package',
        androidInstallApp: true,
        androidMinimumVersion: '21',
      );
      await _auth.sendSignInLinkToEmail(email: email, actionCodeSettings: settings);
      emit(state.copyWith(loading: false));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(loading: false, error: e.message ?? e.code));
      rethrow;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  bool isEmailLink(String link) => _auth.isSignInWithEmailLink(link);

  Future<void> signInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await _auth.signInWithEmailLink(email: email, emailLink: emailLink);
      emit(state.copyWith(loading: false));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(loading: false, error: e.message ?? e.code));
      rethrow;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  // -----------------------
  // Sign out
  // -----------------------
  Future<void> signOut() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await _auth.signOut();
      emit(state.copyWith(loading: false));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(loading: false, error: e.message ?? e.code));
      rethrow;
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
