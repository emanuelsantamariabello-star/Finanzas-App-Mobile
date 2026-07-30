import 'package:finanzas_app_mobile/data/services/profile_media_session_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('guarda y recupera una sesión multimedia vigente', () async {
    final service = ProfileMediaSessionStorageService();
    final expiresAt = DateTime.now().add(const Duration(days: 30));
    final token = List.filled(64, 'c').join();

    await service.save(token: token, expiresAt: expiresAt);
    final session = await service.read();

    expect(session, isNotNull);
    expect(session!.token, token);
    expect(session.expiresAt.toUtc(), expiresAt.toUtc());
    expect(session.isExpired, isFalse);
  });

  test('elimina automáticamente una sesión vencida', () async {
    FlutterSecureStorage.setMockInitialValues({
      'profile_media_token': List.filled(64, 'd').join(),
      'profile_media_token_expires_at': DateTime.now()
          .subtract(const Duration(minutes: 1))
          .toUtc()
          .toIso8601String(),
    });
    final service = ProfileMediaSessionStorageService();

    expect(await service.read(), isNull);
    expect(await service.readToken(), isNull);
  });

  test('descarta una sesión incompleta', () async {
    FlutterSecureStorage.setMockInitialValues({
      'profile_media_token': List.filled(64, 'e').join(),
    });
    final service = ProfileMediaSessionStorageService();

    expect(await service.read(), isNull);
  });
}
