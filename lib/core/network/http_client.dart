import 'package:http/http.dart' as http;
import 'package:finanzas_app_mobile/core/constants/app_config.dart';

class ApiClient {
  static const Duration timeout = Duration(seconds: 12);

  static Future<http.Response> postRaw(
    String path, {
    Map<String, String>? body,
  }) {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/$path');
    return http.post(url, body: body).timeout(timeout);
  }

  static Future<http.Response> post(
    String path, {
    Map<String, String>? body,
  }) {
    return postRaw(path, body: body).then((response) {
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}');
      }
      return response;
    });
  }
}
