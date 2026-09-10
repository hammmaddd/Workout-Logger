import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/firebase_auth_service.dart';
import '../../core/services/backend_api_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final BackendApiService _backendApi = BackendApiService();

  StreamSubscription<User?>? _authSubscription;
  User? _user;
  bool _isLoading = false;
  bool _isCheckingSession = true;
  String? _errorMessage;

  User? get user => _user;
  bool get isSignedIn => _user != null;
  bool get isLoading => _isLoading;
  bool get isCheckingSession => _isCheckingSession;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _authSubscription = _authService.authStateChanges.listen((user) {
      _user = user;
      _isCheckingSession = false;
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.signInWithEmail(email, password);
      await _syncWithBackend();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.registerWithEmail(email, password);
      await _syncWithBackend();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await _authService.signInWithGoogle();
      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      await _syncWithBackend();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  Future<void> _syncWithBackend() async {
    try {
      final token = await _authService.getIdToken();
      if (token == null) return;
      await _backendApi.syncProfile(
        idToken: token,
        email: _authService.currentUser?.email,
        displayName: _authService.currentUser?.displayName,
      );
    } catch (_) {
      // Backend may be offline — Firebase sign-in already succeeded,
      // so we never block the user on this.
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}