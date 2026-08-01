import 'package:finanzas_app_mobile/core/constants/session_keys.dart';
import 'package:finanzas_app_mobile/data/services/auth_session_storage_service.dart';
import 'package:finanzas_app_mobile/data/services/profile_media_session_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionStorageService {
  SessionStorageService({
    AuthSessionStorageService? authSessionStorage,
    ProfileMediaSessionStorageService? profileMediaStorage,
  }) : _authSessionStorage = authSessionStorage ?? AuthSessionStorageService(),
       _profileMediaStorage =
           profileMediaStorage ?? ProfileMediaSessionStorageService();

  final AuthSessionStorageService _authSessionStorage;
  final ProfileMediaSessionStorageService _profileMediaStorage;

  Future<bool> hasActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(SessionKeys.isLoggedIn) ?? false;
    final userId = prefs.getInt(SessionKeys.userId);
    final authSession = await _authSessionStorage.read();

    if (isLoggedIn && userId != null && authSession != null) return true;
    if (isLoggedIn || userId != null || authSession != null) {
      await clearSession();
    }
    return false;
  }

  Future<void> saveAuthenticatedUser({
    required int userId,
    required String userName,
    required String userEmail,
    required String authSessionToken,
    required DateTime authSessionTokenExpiresAt,
    String? occupation,
    String? profileMediaToken,
    DateTime? profileMediaTokenExpiresAt,
    bool profilePhotoAvailable = false,
    DateTime? profilePhotoUpdatedAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final previousUserId = prefs.getInt(SessionKeys.userId);
    final previousOccupation = previousUserId == userId
        ? prefs.getString(SessionKeys.occupation) ??
              prefs.getString(SessionKeys.userOccupation)
        : null;
    await _clearSessionFrom(prefs);
    await _authSessionStorage.clear();
    await _profileMediaStorage.clear();

    await prefs.setInt(SessionKeys.userId, userId);
    await prefs.setString(SessionKeys.userName, userName);
    await prefs.setString(SessionKeys.userEmail, userEmail);

    final normalizedOccupation = occupation?.trim() ?? '';
    final effectiveOccupation = normalizedOccupation.isNotEmpty
        ? normalizedOccupation
        : previousOccupation?.trim() ?? '';
    if (effectiveOccupation.isNotEmpty) {
      await prefs.setString(SessionKeys.occupation, effectiveOccupation);
      await prefs.setString(SessionKeys.userOccupation, effectiveOccupation);
    }

    await prefs.setBool(
      SessionKeys.profilePhotoAvailable,
      profilePhotoAvailable,
    );
    if (profilePhotoUpdatedAt != null) {
      await prefs.setString(
        SessionKeys.profilePhotoUpdatedAt,
        profilePhotoUpdatedAt.toUtc().toIso8601String(),
      );
    }

    final normalizedToken = profileMediaToken?.trim() ?? '';
    if (normalizedToken.isNotEmpty && profileMediaTokenExpiresAt != null) {
      await _profileMediaStorage.save(
        token: normalizedToken,
        expiresAt: profileMediaTokenExpiresAt,
      );
    }

    await _authSessionStorage.save(
      token: authSessionToken,
      expiresAt: authSessionTokenExpiresAt,
    );

    await prefs.setBool(SessionKeys.isLoggedIn, true);
  }

  Future<void> updateProfile({
    required String userName,
    required String userEmail,
    required String occupation,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SessionKeys.userName, userName);
    await prefs.setString(SessionKeys.userEmail, userEmail);
    await prefs.setString(SessionKeys.occupation, occupation);
    await prefs.setString(SessionKeys.userOccupation, occupation);
  }

  Future<void> updateProfilePhotoMetadata({
    required bool available,
    DateTime? updatedAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SessionKeys.profilePhotoAvailable, available);

    if (available && updatedAt != null) {
      await prefs.setString(
        SessionKeys.profilePhotoUpdatedAt,
        updatedAt.toUtc().toIso8601String(),
      );
    } else {
      await prefs.remove(SessionKeys.profilePhotoUpdatedAt);
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await _clearSessionFrom(prefs);
    await _authSessionStorage.clear();
    await _profileMediaStorage.clear();
  }

  Future<void> clearDeletedAccountData() async {
    final prefs = await SharedPreferences.getInstance();
    await clearSession();
    await prefs.remove(SessionKeys.rememberedEmail);
    await prefs.setBool(SessionKeys.rememberCredentials, false);
  }

  Future<String?> readAuthToken() => _authSessionStorage.readToken();

  Future<void> _clearSessionFrom(SharedPreferences prefs) async {
    for (final key in SessionKeys.sessionKeys) {
      await prefs.remove(key);
    }
  }
}
