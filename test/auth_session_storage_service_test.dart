import 'package:finanzas_app_mobile/data/services/auth_session_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('guarda y recupera una sesión vigente', () async {
    final service = AuthSessionStorageService();
    final token = List.filled(64, 'a').join();
    final expiresAt = DateTime.now().toUtc().add(const Duration(days: 1));

    await service.save(token: token, expiresAt: expiresAt);

    final session = await service.read();
    expect(session, isNotNull);
    expect(session!.token, token);
    expect(session.expiresAt, expiresAt);
  });

  test('elimina una sesión expirada', () async {
    FlutterSecureStorage.setMockInitialValues({
      'auth_session_token': List.filled(64, 'b').join(),
      'auth_session_token_expires_at': DateTime.now()
          .toUtc()
          .subtract(const Duration(minutes: 1))
          .toIso8601String(),
    });
    final service = AuthSessionStorageService();

    expect(await service.read(), isNull);
    expect(await service.readToken(), isNull);
  });

  test('rechaza tokens con formato inválido', () async {
    final service = AuthSessionStorageService();

    expect(
      () => service.save(
        token: 'token-inseguro',
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      ),
      throwsA(isA<FormatException>()),
    );
  });
}
