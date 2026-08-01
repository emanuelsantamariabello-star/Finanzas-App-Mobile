import 'package:finanzas_app_mobile/core/network/api_exception.dart';
import 'package:finanzas_app_mobile/core/network/http_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

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

  test('clasifica una desconexión sin exponer detalles internos', () async {
    await http.runWithClient(() async {
      await expectLater(
        ApiClient.postRaw('login.php'),
        throwsA(
          isA<ApiException>()
              .having((error) => error.type, 'type', ApiErrorType.connection)
              .having(
                (error) => error.message,
                'message',
                'No se pudo conectar con el servidor',
              ),
        ),
      );
    }, () => MockClient((_) async => throw http.ClientException('secreto')));
  });

  test('conserva el mensaje seguro de un error HTTP', () async {
    await http.runWithClient(
      () async {
        await expectLater(
          ApiClient.post('dashboard.php'),
          throwsA(
            isA<ApiException>()
                .having((error) => error.type, 'type', ApiErrorType.http)
                .having((error) => error.statusCode, 'statusCode', 503)
                .having(
                  (error) => error.message,
                  'message',
                  'Servicio temporalmente no disponible',
                ),
          ),
        );
      },
      () {
        return MockClient((_) async {
          return http.Response(
            '{"success":false,"message":"Servicio temporalmente no disponible"}',
            503,
          );
        });
      },
    );
  });
}
