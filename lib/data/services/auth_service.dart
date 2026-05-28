import 'dart:convert';
import 'package:finanzas_app_mobile/core/network/http_client.dart';

class AuthService {
  // LOGIN
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await ApiClient.post(
      'login.php',
      body: {'email': email, 'password': password},
    );

    return jsonDecode(response.body);
  }

  // REGISTER
  static Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    final response = await ApiClient.postRaw(
      'register.php',
      body: {
        'username': username,
        'name': username,
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return {
        'success': false,
        'message': 'HTTP ${response.statusCode}',
      };
    }

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {
        'success': false,
        'message': 'Respuesta inválida del servidor',
      };
    }
  }

  // DASHBOARD
  static Future<Map<String, dynamic>> getDashboard(int userId) async {
    final response = await ApiClient.post(
      'dashboard.php',
      body: {'user_id': userId.toString()},
    );

    return jsonDecode(response.body);
  }
}
