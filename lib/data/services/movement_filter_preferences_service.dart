import 'dart:convert';

import 'package:finanzas_app_mobile/data/services/user_scoped_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MovementFilterPreferencesService {
  static const String _storageKey = 'movement_filters';

  Future<Map<String, dynamic>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final storageKey = await UserScopedStorageService.resolveStringKey(
      prefs,
      _storageKey,
    );
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return {};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}

    return {};
  }

  Future<void> save(Map<String, dynamic> filters) async {
    final prefs = await SharedPreferences.getInstance();
    final storageKey = await UserScopedStorageService.resolveStringKey(
      prefs,
      _storageKey,
    );
    await prefs.setString(storageKey, jsonEncode(filters));
  }
}
