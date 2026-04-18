import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  User? _user;
  UserModel? _userProfile;
  bool _isLoading = false;
  bool _isProfileLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  UserModel? get userProfile => _userProfile;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  bool get isProfileLoading => _isProfileLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        await loadUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  /// Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

      _user = userCredential?.user;

      if (_user != null) {
        await _userService.createUserProfile(
          uid: _user!.uid,
          email: email,
          displayName: displayName,
        );
        await _userService.createDefaultFarm(
          uid: _user!.uid,
          farmName: '$displayName Farm',
        );
        await loadUserProfile();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code, e.message);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error during registration. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in user
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      _user = userCredential?.user;
      if (_user != null) {
        await loadUserProfile();
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code, e.message);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error during sign-in. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _userProfile = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Load user profile from Firestore
  Future<void> loadUserProfile() async {
    if (_user == null) {
      _userProfile = null;
      return;
    }

    _isProfileLoading = true;
    notifyListeners();

    try {
      _userProfile = await _userService.getUserProfile(_user!.uid);
    } catch (e) {
      _errorMessage = 'Failed to load profile: $e';
    } finally {
      _isProfileLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile in Firestore
  Future<bool> updateProfile({
    required String displayName,
    String? phoneNumber,
    String? farmName,
    String? location,
  }) async {
    if (_user == null) {
      _errorMessage = 'No authenticated user found.';
      notifyListeners();
      return false;
    }

    _isProfileLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userService.updateUserProfile(
        uid: _user!.uid,
        displayName: displayName,
        phoneNumber: phoneNumber,
        farmName: farmName,
        location: location,
      );

      await _authService.updateUserProfile(displayName: displayName);
      await loadUserProfile();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
      return false;
    } finally {
      _isProfileLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get user-friendly error message
  String _getErrorMessage(String code, [String? message]) {
    switch (code) {
      case 'weak-password':
        return 'Password is too weak. Use 6+ characters.';
      case 'email-already-in-use':
        return 'Email is already registered.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Invalid email or password.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection and try again.';
      case 'account-exists-with-different-credential':
        return 'Account exists with different login method.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is disabled in Firebase project settings.';
      default:
        if (message != null && message.isNotEmpty) {
          return message;
        }
        return 'Authentication error ($code). Please try again.';
    }
  }
}
