import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // The Web client ID from your Firebase project used to request ID tokens on Android/iOS
  static const String _webClientId = '366208969986-d8oj48pd5vics14ihs4mrho6hintjvet.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: _webClientId,
    scopes: ['email', 'profile'],
  );

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in isn\'t enabled for this project yet.';
      case 'network-request-failed':
        return 'No internet connection. Check your network and try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Something went wrong ($code). Please try again.';
    }
  }

  Future<User> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      print('[FirebaseAuth] signIn error code: ${e.code} — ${e.message}');
      throw AuthException(_mapError(e.code));
    }
  }

  Future<User> registerWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      print('[FirebaseAuth] register error code: ${e.code} — ${e.message}');
      throw AuthException(_mapError(e.code));
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web uses popup flow
        final GoogleAuthProvider authProvider = GoogleAuthProvider();
        final userCredential = await _auth.signInWithPopup(authProvider);
        return userCredential.user;
      } else {
        // Mobile uses native Google Play Services flow
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null; // User cancelled

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
    } on FirebaseAuthException catch (e) {
      print('[FirebaseAuth] google sign-in error code: ${e.code} — ${e.message}');
      throw AuthException(_mapError(e.code));
    } catch (e) {
      print('[FirebaseAuth] google sign-in error: $e');
      throw AuthException(e.toString());
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      print('[FirebaseAuth] reset error code: ${e.code} — ${e.message}');
      throw AuthException(_mapError(e.code));
    }
  }

  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
    } catch (_) {}
    await _auth.signOut();
  }

  Future<String?> getIdToken() async {
    return _auth.currentUser?.getIdToken();
  }
}