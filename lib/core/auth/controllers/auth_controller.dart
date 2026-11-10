import 'package:flutter/material.dart';
import '../../../../services/auth/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthServices _authService = AuthServices();
  
  bool _isAuthenticated = false;
  bool _isCheckingAuth = true;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get isCheckingAuth => _isCheckingAuth;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    _isCheckingAuth = true;
    notifyListeners();

    try {
      // Add your auth check logic here
      // Example: Check if token exists in storage
      final isLoggedIn = await _authService.isUserLoggedIn();
      _isAuthenticated = isLoggedIn;
    } catch (e) {
      _isAuthenticated = false;
      _errorMessage = e.toString();
    } finally {
      _isCheckingAuth = false;
      notifyListeners();
    }
  }

  // Login method
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.login(
        email: email,
        password: password,
      );
      
      if (success) {
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign up method
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.signUp(
        name: name,
        email: email,
        password: password,
      );
      
      if (success) {
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _isAuthenticated = false;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
