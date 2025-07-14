import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // For web, we need to configure the client ID from Firebase config
    clientId: kIsWeb ? "1:3037584400:web:cfffd5c8887448d367fe95" : null,
  );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      print('Attempting to sign in with email: $email');
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Sign in successful for user: ${result.user?.uid}');
      return result;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception: ${e.code} - ${e.message}');
      throw _getAuthErrorMessage(e.code);
    } catch (e) {
      print('Unexpected error during sign in: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword(String email, String password) async {
    try {
      print('Attempting to register with email: $email');
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Registration successful for user: ${result.user?.uid}');
      return result;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception: ${e.code} - ${e.message}');
      throw _getAuthErrorMessage(e.code);
    } catch (e) {
      print('Unexpected error during registration: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Attempting Google sign in');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google sign in cancelled by user');
        return null;
      }

      print('Google user selected: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      print('Google sign in successful for user: ${result.user?.uid}');
      return result;
    } catch (e) {
      print('Google sign in error: $e');
      throw 'Google sign-in failed. Please try again.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('Attempting to sign out');
      await _googleSignIn.signOut();
      await _auth.signOut();
      print('Sign out successful');
    } catch (e) {
      print('Sign out error: $e');
      throw 'Sign out failed. Please try again.';
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      print('Attempting to reset password for: $email');
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent successfully');
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception during password reset: ${e.code} - ${e.message}');
      throw _getAuthErrorMessage(e.code);
    } catch (e) {
      print('Unexpected error during password reset: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Get user-friendly error messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
} 