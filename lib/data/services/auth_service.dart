import 'dart:convert';

import 'package:finanzas_app_mobile/core/network/http_client.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await ApiClient.postRaw(
      'login.php',
      body: {'email': email, 'password': password},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return {'success': false, 'message': 'HTTP ${response.statusCode}'};
    }

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {
        'success': false,
        'message': 'Respuesta inv\u00e1lida del servidor',
      };
    }
  }

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
      return {'success': false, 'message': 'HTTP ${response.statusCode}'};
    }

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {
        'success': false,
        'message': 'Respuesta inv\u00e1lida del servidor',
      };
    }
  }
}
