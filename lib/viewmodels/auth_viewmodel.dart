/*
 * Student Numbers: 224081110, 222001607, 222000452, 224065010, 221024286, 224067603, 224054263, 221046289, 222088478, 224013987
 * Student Names: M Lesenyeho, M Machedi, Z Sidamba, B Nakupi, H Sekethwayo, J O Molaba, K Semela, N Gumede, T Mjiyakho, K D Selebalo
 * Question: Auth ViewModel (MVVM - ViewModel Layer)
 */

import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';

enum AuthState { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();

  AuthState _state = AuthState.idle;
  UserProfile? _currentProfile;
  String? _errorMessage;

  AuthState get state => _state;
  UserProfile? get currentProfile => _currentProfile;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentProfile != null;

  // Call this on app start (SplashScreen)
  Future<void> checkSession() async {
    final user = _authRepo.currentUser;
    if (user != null) {
      _currentProfile = await _authRepo.getUserProfile(user.id);
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepo.signIn(email, password);
      if (response.user != null) {
        _currentProfile = await _authRepo.getUserProfile(response.user!.id);
        _state = AuthState.success;
        notifyListeners();
        return true;
      }
      _state = AuthState.error;
      _errorMessage = 'Login failed. Please check your credentials.';
      notifyListeners();
      return false;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepo.signOut();
    _currentProfile = null;
    _state = AuthState.idle;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _state = AuthState.idle;
    notifyListeners();
  }
}
