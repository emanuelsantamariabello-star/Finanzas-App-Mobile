import 'dart:convert';
import 'package:finanzas_app_mobile/core/network/http_client.dart';

class UserService {
  static Future<Map<String, dynamic>> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await ApiClient.post(
      'change_password.php',
      body: {
        'user_id': userId.toString(),
        'current_password': currentPassword,
        'new_password': newPassword,
        'password_current': currentPassword,
        'password_new': newPassword,
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String name,
    required String email,
    required String occupation,
  }) async {
    final response = await ApiClient.post(
      'update_profile.php',
      body: {
        'user_id': userId.toString(),
        'name': name,
        'username': name,
        'email': email,
        'occupation': occupation,
        'job': occupation,
      },
    );

    return jsonDecode(response.body);
  }
}
