
import 'package:firebase_auth/firebase_auth.dart';

class AuthFirebaseDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (_) {
      return false;
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> logout() async {
    try {
      await _auth.signOut();
      return true;
    } catch (_) {
      return false;
    }
  }
}
