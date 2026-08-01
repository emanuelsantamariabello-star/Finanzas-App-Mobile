import 'package:finanzas_app_mobile/core/constants/session_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserScopedStorageService {
  static const List<String> _accountDataKeys = [
    'reminders',
    'financial_goals',
    'category_budgets',
    'movement_filters',
    'read_internal_notifications',
  ];

  static Future<int?> currentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(SessionKeys.userId);
  }

  static Future<String> resolveStringListKey(
    SharedPreferences prefs,
    String baseKey,
  ) async {
    final scopedKey = _scopedKey(prefs, baseKey);
    if (scopedKey == baseKey || prefs.containsKey(scopedKey)) {
      return scopedKey;
    }

    final legacyValue = prefs.getStringList(baseKey);
    if (legacyValue != null) {
      await prefs.setStringList(scopedKey, legacyValue);
      await prefs.remove(baseKey);
    }

    return scopedKey;
  }

  static Future<String> resolveStringKey(
    SharedPreferences prefs,
    String baseKey,
  ) async {
    final scopedKey = _scopedKey(prefs, baseKey);
    if (scopedKey == baseKey || prefs.containsKey(scopedKey)) {
      return scopedKey;
    }

    final legacyValue = prefs.getString(baseKey);
    if (legacyValue != null) {
      await prefs.setString(scopedKey, legacyValue);
      await prefs.remove(baseKey);
    }

    return scopedKey;
  }

  static Future<void> clearCurrentUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(SessionKeys.userId);

    for (final baseKey in _accountDataKeys) {
      await prefs.remove(userId == null ? baseKey : '${baseKey}_user_$userId');
    }
  }

  static String _scopedKey(SharedPreferences prefs, String baseKey) {
    final userId = prefs.getInt(SessionKeys.userId);
    return userId == null ? baseKey : '${baseKey}_user_$userId';
  }
}
