import 'package:finanzas_app_mobile/data/services/user_scoped_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InternalNotificationStorageService {
  static const String _readIdsKey = 'read_internal_notifications';

  Future<Set<String>> loadReadIds() async {
    final prefs = await SharedPreferences.getInstance();
    final storageKey = await UserScopedStorageService.resolveStringListKey(
      prefs,
      _readIdsKey,
    );
    return (prefs.getStringList(storageKey) ?? const []).toSet();
  }

  Future<void> saveReadIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final storageKey = await UserScopedStorageService.resolveStringListKey(
      prefs,
      _readIdsKey,
    );
    final sortedIds = ids.toList()..sort();
    await prefs.setStringList(storageKey, sortedIds);
  }
}
