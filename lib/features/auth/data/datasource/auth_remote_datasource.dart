import 'package:birth_certify/features/auth/domain/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<UserModel?> fetchCurrentUserDetails() async {
  try {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      print('Error: No user is currently signed in.');
      return null;
    }

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!doc.exists) {
      print('Error: No user document found for uid: $uid');
      return null;
    }

    return UserModel.fromJson(doc.data()!);
  } catch (e, stackTrace) {
    print('Exception occurred while fetching user details: $e');
    print('StackTrace: $stackTrace');
    return null;
  }
}

}
