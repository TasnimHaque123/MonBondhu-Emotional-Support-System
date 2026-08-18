import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isLoading = true;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');

    if (userJson != null) {
      _currentUser = User.fromMap(jsonDecode(userJson));
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', jsonEncode(user.toMap()));
    _currentUser = user;
    notifyListeners();
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    _currentUser = null;
    notifyListeners();
  }

  // ✅ FIXED LOGIN METHOD
  Future<String?> login(String username, String password) async {
    try {
      final user = await _authService.login(username, password);

      if (user != null) {
        await _saveSession(user);
        return null; // Success
      }
      return "Invalid username or password.";
    } catch (e) {
      debugPrint("Login error: $e");
      return "An error occurred during login. Please try again.";
    }
  }

  // ✅ FIXED REGISTER METHOD
  Future<String?> register(String username, String password) async {
    try {
      final user = await _authService.register(username, password);
      if (user != null) {
        await _saveSession(user);
        return null;
      }
      return "Unknown error occurred.";
    } catch (e) {
      // Check if it's our specific "User Exists" error
      if (e.toString().contains("USER_EXISTS")) {
        return "Username already exists. Please choose another name.";
      }
      // Otherwise, show the actual technical error (for debugging)
      debugPrint("Register error: $e");
      return "Database error: ${e.toString()}";
    }
  }

  Future<void> loginAnonymous() async {
    final user = await _authService.loginAnonymous();
    await _saveSession(user);
  }

  Future<void> updateProfile({
    String? username,
    String? profilePicture,
    String? condition,
  }) async {
    if (_currentUser == null) return;

    final updatedUser = User(
      id: _currentUser!.id,
      username: username ?? _currentUser!.username,
      password: _currentUser!.password,
      profilePicture: profilePicture ?? _currentUser!.profilePicture,
      condition: condition ?? _currentUser!.condition,
      createdAt: _currentUser!.createdAt,
    );

    await _saveSession(updatedUser);
  }

  Future<void> logout() async {
    await _clearSession();
  }
}
