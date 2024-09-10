import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      if (_user != null) {
        await updateUserData(_user!);
      }
      return _user;
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }

  Future<void> updateUserData(User user) async {
  final firestore = FirebaseFirestore.instance;
  final userRef = firestore.collection('users').doc(user.uid);

  final doc = await userRef.get();
  if (!doc.exists) {
    // If the user document doesn't exist, create it
    userRef.set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'lastSignIn': DateTime.now(),
    });
    print("Created new user document for ${user.uid}");
  } else {
    // Update last sign-in time or other necessary fields
    userRef.update({
      'lastSignIn': DateTime.now(),
    });
    print("Updated existing user document for ${user.uid}");
  }
}

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
}
