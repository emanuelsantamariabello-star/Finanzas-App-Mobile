import 'package:finanzas_app_mobile/core/network/api_exception.dart';
import 'package:finanzas_app_mobile/core/network/http_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('construye la URL sin barras duplicadas', () {
    final uri = ApiClient.buildUri(
      '/login.php',
      baseUrl: 'http://10.0.2.2/finanzas_app/api/',
    );

    expect(uri.toString(), 'http://10.0.2.2/finanzas_app/api/login.php');
  });

  test('rechaza una configuración de API inválida', () {
    expect(
      () => ApiClient.buildUri('login.php', baseUrl: ''),
      throwsA(
        isA<ApiException>().having(
          (error) => error.type,
          'type',
          ApiErrorType.configuration,
        ),
      ),
    );
  });

  test('decodifica únicamente objetos JSON', () {
    expect(ApiClient.decodeJsonMap('{"success":true,"message":"Correcto"}'), {
      'success': true,
      'message': 'Correcto',
    });
  });

  test('clasifica una respuesta JSON inválida', () {
    for (final body in ['contenido no JSON', '[1,2,3]']) {
      expect(
        () => ApiClient.decodeJsonMap(body),
        throwsA(
          isA<ApiException>().having(
            (error) => error.type,
            'type',
            ApiErrorType.invalidResponse,
          ),
        ),
      );
    }
  });

  test('expone mensajes seguros y conserva un fallback', () {
    const exception = ApiException(
      type: ApiErrorType.timeout,
      message: 'El servidor tardó demasiado en responder',
    );

    expect(
      apiErrorMessage(exception, fallback: 'Error genérico'),
      'El servidor tardó demasiado en responder',
    );
    expect(
      apiErrorMessage(Exception('detalle interno'), fallback: 'Error genérico'),
      'Error genérico',
    );
  });
}
