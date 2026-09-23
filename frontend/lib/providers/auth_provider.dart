import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frontend/models/auth_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  static const String _tokenKey = 'estudai_auth_token';
  static const String _userKey = 'estudai_user_data';

  bool _isLoading = true;
  bool _isAuthenticated = false;
  User? _currentUser;
  String? _token;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  String? get token => _token;
  String? get errorMessage => _errorMessage;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_tokenKey);
      final savedUserStr = prefs.getString(_userKey);

      if (savedToken != null && savedToken.isNotEmpty) {
        ApiService.setToken(savedToken);
        _token = savedToken;

        if (savedUserStr != null) {
          try {
            _currentUser = User.fromJson(jsonDecode(savedUserStr));
          } catch (_) {}
        }

        // Validate token with backend
        try {
          final user = await ApiService.getMe();
          _currentUser = user;
          _isAuthenticated = true;
          await prefs.setString(_userKey, jsonEncode(user.toJson()));
        } catch (_) {
          // If token verification fails, clear session
          await logout();
          return;
        }
      } else {
        _isAuthenticated = false;
      }
    } catch (e) {
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String login, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.login(login, password);
      _token = response.token;
      _currentUser = response.user;
      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, response.token);
      await prefs.setString(_userKey, jsonEncode(response.user.toJson()));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String username,
    required String email,
    String? phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = {
        'name': name,
        'username': username,
        'email': email,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        'password': password,
      };

      final response = await ApiService.register(data);
      _token = response.token;
      _currentUser = response.user;
      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, response.token);
      await prefs.setString(_userKey, jsonEncode(response.user.toJson()));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (_) {}

    ApiService.setToken(null);
    _token = null;
    _currentUser = null;
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
