import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class UserService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── Get all users (Admin only) ─────────────────────────
  static Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.usersEndpoint),
        headers: await _authHeaders(),
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => UserModel.fromJson(e)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ─── Get current user profile ──────────────────────────
  static Future<UserModel?> getMe() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.usersEndpoint}/me'),
        headers: await _authHeaders(),
      );
      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ─── Get user by ID ────────────────────────────────────
  static Future<UserModel?> getUserById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.usersEndpoint}/$id'),
        headers: await _authHeaders(),
      );
      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ─── Update user ───────────────────────────────────────
  static Future<Map<String, dynamic>> updateUser(
    String id, {
    required String fullName,
    required String email,
    required bool isActive,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.usersEndpoint}/$id'),
        headers: await _authHeaders(),
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'isActive': isActive,
        }),
      );
      if (response.statusCode == 200) return {'success': true};
      final body = jsonDecode(response.body);
      return {'success': false, 'message': body['message'] ?? 'Update failed'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── Delete user ───────────────────────────────────────
  static Future<bool> deleteUser(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.usersEndpoint}/$id'),
        headers: await _authHeaders(),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─── Change password ───────────────────────────────────
  static Future<Map<String, dynamic>> changePassword(
    String userId, {
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.usersEndpoint}/$userId/change-password'),
        headers: await _authHeaders(),
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );
      if (response.statusCode == 200) return {'success': true};
      final body = jsonDecode(response.body);
      return {'success': false, 'message': body['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ─── Assign role ────────────────────────────────────────
  static Future<bool> assignRole(String userId, String role) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.usersEndpoint}/assign-role'),
        headers: await _authHeaders(),
        body: jsonEncode({'userId': userId, 'role': role}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─── Remove role ────────────────────────────────────────
  static Future<bool> removeRole(String userId, String role) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.usersEndpoint}/remove-role'),
        headers: await _authHeaders(),
        body: jsonEncode({'userId': userId, 'role': role}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
