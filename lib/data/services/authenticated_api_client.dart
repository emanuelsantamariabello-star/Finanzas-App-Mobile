import 'package:finanzas_app_mobile/core/network/api_exception.dart';
import 'package:finanzas_app_mobile/core/network/http_client.dart';
import 'package:finanzas_app_mobile/data/services/auth_session_storage_service.dart';

class AuthenticatedApiClient {
  static final AuthSessionStorageService _sessionStorage =
      AuthSessionStorageService();

  static Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, String>? body,
  }) async {
    return ApiClient.postJson(
      path,
      body: body,
      headers: await _authorizationHeaders(),
    );
  }

  static Future<Map<String, String>> _authorizationHeaders() async {
    final token = await _sessionStorage.readToken();
    if (token == null) {
      throw const ApiException(
        type: ApiErrorType.http,
        statusCode: 401,
        message: 'La sesión expiró. Inicia sesión nuevamente',
      );
    }

    return {'Authorization': 'Bearer $token'};
  }
}
