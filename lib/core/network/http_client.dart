import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:finanzas_app_mobile/core/network/api_exception.dart';
import 'package:http/http.dart' as http;
import 'package:finanzas_app_mobile/core/constants/app_config.dart';

class ApiClient {
  static const Duration timeout = Duration(seconds: 12);

  static Uri buildUri(String path, {String? baseUrl}) {
    final normalizedBaseUrl = (baseUrl ?? AppConfig.apiBaseUrl)
        .trim()
        .replaceFirst(RegExp(r'/+$'), '');
    final normalizedPath = path.trim().replaceFirst(RegExp(r'^/+'), '');

    if (normalizedBaseUrl.isEmpty || normalizedPath.isEmpty) {
      throw const ApiException(
        type: ApiErrorType.configuration,
        message: 'La configuración de la API no es válida',
      );
    }

    final uri = Uri.tryParse('$normalizedBaseUrl/$normalizedPath');
    if (uri == null ||
        !uri.hasScheme ||
        !const {'http', 'https'}.contains(uri.scheme) ||
        uri.host.isEmpty) {
      throw const ApiException(
        type: ApiErrorType.configuration,
        message: 'La configuración de la API no es válida',
      );
    }

    return uri;
  }

  static Future<http.Response> postRaw(
    String path, {
    Map<String, String>? body,
    Map<String, String>? headers,
  }) async {
    final url = buildUri(path);

    try {
      return await http
          .post(url, body: body, headers: headers)
          .timeout(timeout);
    } on TimeoutException {
      throw const ApiException(
        type: ApiErrorType.timeout,
        message: 'El servidor tardó demasiado en responder',
      );
    } on SocketException {
      throw const ApiException(
        type: ApiErrorType.connection,
        message: 'No se pudo conectar con el servidor',
      );
    } on http.ClientException {
      throw const ApiException(
        type: ApiErrorType.connection,
        message: 'No se pudo conectar con el servidor',
      );
    }
  }

  static Future<http.Response> post(
    String path, {
    Map<String, String>? body,
    Map<String, String>? headers,
  }) async {
    final response = await postRaw(path, body: body, headers: headers);
    _ensureSuccessful(response);
    return response;
  }

  static Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, String>? body,
    Map<String, String>? headers,
  }) async {
    final response = await post(path, body: body, headers: headers);
    return decodeJsonMap(response.body);
  }

  static Future<Uint8List> getBytes(
    String path, {
    Map<String, String>? headers,
  }) async {
    final url = buildUri(path);

    try {
      final response = await http.get(url, headers: headers).timeout(timeout);
      _ensureSuccessful(response);
      return response.bodyBytes;
    } on TimeoutException {
      throw const ApiException(
        type: ApiErrorType.timeout,
        message: 'El servidor tardó demasiado en responder',
      );
    } on SocketException {
      throw const ApiException(
        type: ApiErrorType.connection,
        message: 'No se pudo conectar con el servidor',
      );
    } on http.ClientException {
      throw const ApiException(
        type: ApiErrorType.connection,
        message: 'No se pudo conectar con el servidor',
      );
    }
  }

  static Future<Map<String, dynamic>> multipartJson(
    String path, {
    required String fieldName,
    required List<int> bytes,
    required String filename,
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) async {
    final request = http.MultipartRequest('POST', buildUri(path));
    if (headers != null) request.headers.addAll(headers);
    if (fields != null) request.fields.addAll(fields);
    request.files.add(
      http.MultipartFile.fromBytes(fieldName, bytes, filename: filename),
    );

    try {
      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);
      _ensureSuccessful(response);
      return decodeJsonMap(response.body);
    } on TimeoutException {
      throw const ApiException(
        type: ApiErrorType.timeout,
        message: 'El servidor tardó demasiado en responder',
      );
    } on SocketException {
      throw const ApiException(
        type: ApiErrorType.connection,
        message: 'No se pudo conectar con el servidor',
      );
    } on http.ClientException {
      throw const ApiException(
        type: ApiErrorType.connection,
        message: 'No se pudo conectar con el servidor',
      );
    }
  }

  static Map<String, dynamic> decodeJsonMap(String rawBody) {
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      throw const ApiException(
        type: ApiErrorType.invalidResponse,
        message: 'El servidor devolvió una respuesta no válida',
      );
    }

    throw const ApiException(
      type: ApiErrorType.invalidResponse,
      message: 'El servidor devolvió una respuesta no válida',
    );
  }

  static void _ensureSuccessful(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    throw ApiException(
      type: ApiErrorType.http,
      statusCode: response.statusCode,
      message: _httpErrorMessage(response),
    );
  }

  static String _httpErrorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        final backendMessage = decoded['message']?.toString().trim() ?? '';
        if (backendMessage.isNotEmpty) return backendMessage;
      }
    } catch (_) {}

    switch (response.statusCode) {
      case 401:
      case 403:
        return 'La solicitud no está autorizada';
      case 404:
        return 'El servicio solicitado no fue encontrado';
      default:
        if (response.statusCode >= 500) {
          return 'El servidor no está disponible temporalmente';
        }
        return 'El servidor rechazó la solicitud';
    }
  }
}
