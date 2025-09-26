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
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // authStateChanges listener će emitirati success state
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(loading: false, error: e.message ?? e.code));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> register(String email, String password) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // listener odradi dalje
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
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
