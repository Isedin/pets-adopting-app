import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  const AuthService();

  Future<bool> signInAnonymously() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) return true;
      await FirebaseAuth.instance.signInAnonymously();
      return true;
    } catch (_) {
      return false;
    }
  }
}
