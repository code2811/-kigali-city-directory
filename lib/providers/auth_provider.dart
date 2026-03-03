import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _firebaseUser;
  AppUser? _profile;
  bool _isLoading = false;
  String? _error;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  User? get firebaseUser => _firebaseUser;
  AppUser? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> signUp(String email, String password) async {
    _setLoading(true);
    try {
      _error = null;
      final user = await _authService.signUp(email, password);
      _firebaseUser = user;
      await _loadProfile();
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      _error = null;
      final user = await _authService.signIn(email, password);
      _firebaseUser = user;
      await _loadProfile();
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _firebaseUser = null;
    _profile = null;
    notifyListeners();
  }

  Future<void> reloadUser() async {
    await _authService.reloadUser();
    _firebaseUser = _authService.currentUser;
    await _loadProfile();
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    if (_firebaseUser != null) {
      _profile = await _authService.getCurrentUserProfile();
    }
    notifyListeners();
  }

  void _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    await _loadProfile();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
