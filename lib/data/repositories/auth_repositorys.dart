import 'package:firebase_auth/firebase_auth.dart';

/// Repository layer for authentication.
/// Wraps FirebaseAuth into clean methods used by Cubit/UI.
class AuthRepository {
  final FirebaseAuth _auth;
  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  /// Stream of authentication state (user signed in/out).
  Stream<User?> authState() => _auth.authStateChanges();

  /// Register new user with email + password.
  Future<UserCredential> registerWithEmail(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  /// Sign in existing user with email + password.
  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Sign out current user.
  Future<void> signOut() => _auth.signOut();

  User? get currentUser => _auth.currentUser;
}
