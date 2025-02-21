import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _storage = FlutterSecureStorage();
  final String _baseUrl = 'https://dummyjson.com/auth/login';

  Future<String?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['accessToken'] != null) {
        await _storage.write(key: 'token', value: data['accessToken']);
        return null; // No error, login successful
      } else if (data['message'] != null) {
        return data['message']; // Return error message if available
      } else {
        return "Unknown error occurred.";
      }
    } catch (e) {
      return "Failed to connect to server.";
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
  }

  Future<bool> isLoggedIn() async {
    String? token = await _storage.read(key: 'token');
    return token != null;
  }

  final String _profileUrl = 'https://dummyjson.com/auth/me';

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      String? token = await _storage.read(key: 'token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(_profileUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
