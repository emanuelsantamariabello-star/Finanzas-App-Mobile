import 'package:finanzas_app_mobile/core/constants/session_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionStorageService {
  Future<bool> hasActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(SessionKeys.isLoggedIn) ?? false;
    final userId = prefs.getInt(SessionKeys.userId);

    if (isLoggedIn && userId != null) return true;
    if (isLoggedIn || userId != null) await clearSession();
    return false;
  }

  Future<void> saveAuthenticatedUser({
    required int userId,
    required String userName,
    required String userEmail,
    String? occupation,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final previousUserId = prefs.getInt(SessionKeys.userId);
    final previousOccupation = previousUserId == userId
        ? prefs.getString(SessionKeys.occupation) ??
              prefs.getString(SessionKeys.userOccupation)
        : null;
    await _clearSessionFrom(prefs);

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

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await _clearSessionFrom(prefs);
  }

  Future<void> _clearSessionFrom(SharedPreferences prefs) async {
    for (final key in SessionKeys.sessionKeys) {
      await prefs.remove(key);
    }
  }
}
