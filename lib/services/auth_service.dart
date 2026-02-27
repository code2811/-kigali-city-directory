import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signUp(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await result.user?.sendEmailVerification();
    await _db.collection('users').doc(result.user?.uid).set({
      'email': email,
      'displayName': '',
      'emailVerified': false,
    });
    return result.user;
  }

  Future<User?> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return result.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  Future<void> updateUserProfile({String? displayName}) async {
    if (displayName != null) {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _db.collection('users').doc(_auth.currentUser?.uid).update({'displayName': displayName});
    }
  }

  Future<AppUser?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }
}
