import 'package:shared_preferences/shared_preferences.dart';

class UserScopedStorageService {
  static const String _userIdKey = 'userId';

  static Future<int?> currentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
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

  static String _scopedKey(SharedPreferences prefs, String baseKey) {
    final userId = prefs.getInt(_userIdKey);
    return userId == null ? baseKey : '${baseKey}_user_$userId';
  }
}
