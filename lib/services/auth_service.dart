import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  static const _tokenKey = 'jwt_token';
  static const _userKey = 'current_user';

  // ─── Token management ──────────────────────────────────
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveUser(AuthResponse auth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode({
      'token': auth.token,
      'email': auth.email,
      'fullName': auth.fullName,
      'roles': auth.roles,
      'expiration': auth.expiration.toIso8601String(),
    }));
  }

  static Future<AuthResponse?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    try {
      return AuthResponse.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // ─── API calls ─────────────────────────────────────────
  static Future<AuthResponse?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.authEndpoint}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final auth = AuthResponse.fromJson(jsonDecode(response.body));
        await saveToken(auth.token);
        await saveUser(auth);
        return auth;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    String role = 'User',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.authEndpoint}/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        final auth = AuthResponse.fromJson(jsonDecode(response.body));
        await saveToken(auth.token);
        await saveUser(auth);
        return {'success': true, 'data': auth};
      }

      final body = jsonDecode(response.body);
      return {'success': false, 'message': body['message'] ?? 'Registration failed'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
