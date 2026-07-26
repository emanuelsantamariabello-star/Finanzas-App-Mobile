import 'dart:convert';

import 'package:finanzas_app_mobile/data/models/budget_model.dart';
import 'package:finanzas_app_mobile/data/services/user_scoped_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetStorageService {
  static const String _storageKey = 'category_budgets';

  Future<List<BudgetModel>> loadBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final storageKey = await UserScopedStorageService.resolveStringListKey(
      prefs,
      _storageKey,
    );
    final rawList = prefs.getStringList(storageKey) ?? const [];

    return rawList
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .map(BudgetModel.fromJson)
        .toList();
  }

  Future<void> saveBudgets(List<BudgetModel> budgets) async {
    final prefs = await SharedPreferences.getInstance();
    final storageKey = await UserScopedStorageService.resolveStringListKey(
      prefs,
      _storageKey,
    );
    final encoded = budgets.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(storageKey, encoded);
  }
}
