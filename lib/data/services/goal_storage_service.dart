import 'dart:convert';

import 'package:finanzas_app_mobile/data/models/financial_goal_model.dart';
import 'package:finanzas_app_mobile/data/services/user_scoped_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalStorageService {
  static const String _storageKey = 'financial_goals';

  Future<List<FinancialGoalModel>> loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final storageKey = await UserScopedStorageService.resolveStringListKey(
      prefs,
      _storageKey,
    );
    final rawList = prefs.getStringList(storageKey) ?? const [];

    return rawList
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .map(FinancialGoalModel.fromJson)
        .toList();
  }

  Future<void> saveGoals(List<FinancialGoalModel> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final storageKey = await UserScopedStorageService.resolveStringListKey(
      prefs,
      _storageKey,
    );
    final encoded = goals.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(storageKey, encoded);
  }
}
