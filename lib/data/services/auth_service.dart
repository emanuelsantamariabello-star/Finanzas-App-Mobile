import 'package:finanzas_app_mobile/core/network/api_exception.dart';
import 'package:finanzas_app_mobile/core/network/http_client.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      return await ApiClient.postJson(
        'login.php',
        body: {'email': email, 'password': password},
      );
    } on ApiException catch (error) {
      return {'success': false, 'message': error.message};
    }
  }

  static Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      return await ApiClient.postJson(
        'register.php',
        body: {
          'username': username,
          'name': username,
          'email': email,
          'password': password,
        },
      );
    } on ApiException catch (error) {
      return {'success': false, 'message': error.message};
    }
  }
}
