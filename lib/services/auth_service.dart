import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

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
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'emailVerified': user.emailVerified,
      }, SetOptions(merge: true));
    }
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
    final userRef = _db.collection('users').doc(user.uid);
    final doc = await userRef.get();
    if (!doc.exists) {
      await userRef.set({
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'emailVerified': user.emailVerified,
      });
      final createdDoc = await userRef.get();
      return AppUser.fromFirestore(createdDoc);
    }
    await userRef.set({'emailVerified': user.emailVerified}, SetOptions(merge: true));
    final updatedDoc = await userRef.get();
    return AppUser.fromFirestore(updatedDoc);
  }
}
