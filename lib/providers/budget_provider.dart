import 'package:finanzas_app_mobile/data/models/budget_model.dart';
import 'package:finanzas_app_mobile/data/services/budget_storage_service.dart';
import 'package:finanzas_app_mobile/data/services/category_suggestion_service.dart';
import 'package:finanzas_app_mobile/data/services/expense_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetProvider extends ChangeNotifier {
  BudgetProvider({BudgetStorageService? storageService})
    : _storageService = storageService ?? BudgetStorageService();

  final BudgetStorageService _storageService;
  final Map<String, double> _monthlySpentByCategory = {};

  List<BudgetModel> _budgets = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  List<BudgetModel> get budgets => List.unmodifiable(_budgets);
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  Map<String, double> get monthlySpentByCategory =>
      Map.unmodifiable(_monthlySpentByCategory);

  Future<void> initialize() async {
    if (_isInitialized) return;
    await loadBudgets();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> loadBudgets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _budgets = await _storageService.loadBudgets();
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveBudget(BudgetModel budget) async {
    final index = _budgets.indexWhere((item) => item.id == budget.id);
    final nextBudget = budget.copyWith(
      createdAt: budget.createdAt ?? DateTime.now(),
    );

    if (index >= 0) {
      _budgets[index] = nextBudget;
    } else {
      _budgets = [..._budgets, nextBudget];
    }

    await _persistBudgets();
  }

  Future<void> deleteBudget(String budgetId) async {
    _budgets = _budgets.where((item) => item.id != budgetId).toList();
    await _persistBudgets();
  }

  Future<void> syncUsage(int userId) async {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    final startDate = formatter.format(DateTime(now.year, now.month, 1));
    final endDate = formatter.format(DateTime(now.year, now.month + 1, 0));

    try {
      final response = await ExpenseService.getExpenses(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      if (response['success'] != true) return;

      final data = (response['data'] as List?) ?? const [];
      final spending = <String, double>{};

      for (final rawExpense in data) {
        if (rawExpense is! Map) continue;

        final expense = rawExpense.cast<String, dynamic>();
        final note = expense['note']?.toString() ?? '';
        final amount = double.tryParse(expense['amount'].toString()) ?? 0;
        final categorySuggestion =
            CategorySuggestionService.suggestExpenseCategory(note);
        final category = categorySuggestion?.label ?? 'Sin categoría';

        spending[category] = (spending[category] ?? 0) + amount;
      }

      _monthlySpentByCategory
        ..clear()
        ..addAll(spending);
      notifyListeners();
    } catch (_) {}
  }

  double spentForCategory(String category) {
    return _monthlySpentByCategory[category] ?? 0;
  }

  int get overBudgetCount {
    return _budgets
        .where(
          (budget) => spentForCategory(budget.category) > budget.limitAmount,
        )
        .length;
  }

  Future<void> _persistBudgets() async {
    _error = null;

    try {
      await _storageService.saveBudgets(_budgets);
    } catch (error) {
      _error = error.toString();
    }

    notifyListeners();
  }
}
