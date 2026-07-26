import 'dart:convert';

import 'package:finanzas_app_mobile/data/models/reminder_model.dart';
import 'package:finanzas_app_mobile/data/services/user_scoped_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderStorageService {
  static const String _storageKey = 'reminders';

  Future<List<ReminderModel>> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final storageKey = await UserScopedStorageService.resolveStringListKey(
      prefs,
      _storageKey,
    );
    final rawList = prefs.getStringList(storageKey) ?? const [];

    return rawList
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .map(ReminderModel.fromJson)
        .toList();
  }

  Future<void> saveReminders(List<ReminderModel> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final storageKey = await UserScopedStorageService.resolveStringListKey(
      prefs,
      _storageKey,
    );
    final encoded = reminders.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(storageKey, encoded);
  }
}
