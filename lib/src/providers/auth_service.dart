import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;

  User? get user => _user;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<User?> signInWithGoogle() async {
    // Use Google provider to sign in with Firebase Auth
    try {
      final googleProvider = GoogleAuthProvider();

      final userCredential = await _auth.signInWithPopup(googleProvider);
      _user = userCredential.user;
      notifyListeners();
      return _user;
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
}
