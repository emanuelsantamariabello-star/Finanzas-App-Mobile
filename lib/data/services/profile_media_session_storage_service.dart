import 'package:finanzas_app_mobile/data/models/profile_media_session.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileMediaSessionStorageService {
  ProfileMediaSessionStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _tokenKey = 'profile_media_token';
  static const String _expiresAtKey = 'profile_media_token_expires_at';

  final FlutterSecureStorage _storage;

  Future<void> save({
    required String token,
    required DateTime expiresAt,
  }) async {
    final normalizedToken = token.trim().toLowerCase();
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(normalizedToken) ||
        !expiresAt.isAfter(DateTime.now())) {
      await clear();
      return;
    }

    await _storage.write(key: _tokenKey, value: normalizedToken);
    await _storage.write(
      key: _expiresAtKey,
      value: expiresAt.toUtc().toIso8601String(),
    );
  }

  Future<ProfileMediaSession?> read() async {
    final token = (await _storage.read(key: _tokenKey))?.trim() ?? '';
    final rawExpiresAt = await _storage.read(key: _expiresAtKey);
    final expiresAt = DateTime.tryParse(rawExpiresAt ?? '');

    if (!RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(token) || expiresAt == null) {
      await clear();
      return null;
    }

    final session = ProfileMediaSession(token: token, expiresAt: expiresAt);
    if (session.isExpired) {
      await clear();
      return null;
    }

    return session;
  }

  Future<String?> readToken() async => (await read())?.token;

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _expiresAtKey);
  }
}
