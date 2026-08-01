import 'dart:typed_data';

import 'package:finanzas_app_mobile/core/network/http_client.dart';
import 'package:finanzas_app_mobile/data/services/authenticated_api_client.dart';

class UserService {
  static Map<String, String> _authorization(String token) => {
    'Authorization': 'Bearer ${token.trim()}',
  };

  static Future<Map<String, dynamic>> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    return ApiClient.postJson(
      'change_password.php',
      headers: _authorization(token),
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'password_current': currentPassword,
        'password_new': newPassword,
      },
    );
  }

  static Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String name,
    required String email,
    required String occupation,
  }) async {
    return AuthenticatedApiClient.postJson(
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
  }

  static Future<Map<String, dynamic>> uploadProfilePhoto({
    required List<int> bytes,
    required String filename,
    required String token,
  }) {
    return ApiClient.multipartJson(
      'upload_profile_photo.php',
      fieldName: 'photo',
      bytes: bytes,
      filename: filename,
      headers: _authorization(token),
    );
  }

  static Future<Uint8List> getProfilePhoto({required String token}) {
    return ApiClient.getBytes(
      'profile_photo.php',
      headers: _authorization(token),
    );
  }

  static Future<Map<String, dynamic>> deleteProfilePhoto({
    required String token,
  }) {
    return ApiClient.postJson(
      'delete_profile_photo.php',
      headers: _authorization(token),
    );
  }

  static Future<Map<String, dynamic>> revokeProfileMediaToken({
    required String token,
  }) {
    return ApiClient.postJson(
      'revoke_profile_media_token.php',
      headers: _authorization(token),
    );
  }
}
