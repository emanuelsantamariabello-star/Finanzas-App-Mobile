import 'package:finanzas_app_mobile/data/models/financial_goal_model.dart';
import 'package:finanzas_app_mobile/data/services/goal_storage_service.dart';
import 'package:flutter/material.dart';

class GoalProvider extends ChangeNotifier {
  GoalProvider({GoalStorageService? storageService})
    : _storageService = storageService ?? GoalStorageService();

  final GoalStorageService _storageService;

  List<FinancialGoalModel> _goals = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  List<FinancialGoalModel> get goals => List.unmodifiable(_goals);
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  List<FinancialGoalModel> get activeGoals =>
      _goals.where((item) => !item.isCompleted).toList();

  Future<void> initialize() async {
    if (_isInitialized) return;
    await loadGoals();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> loadGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _goals = await _storageService.loadGoals();
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveGoal(FinancialGoalModel goal) async {
    final index = _goals.indexWhere((item) => item.id == goal.id);
    final nextGoal = goal.copyWith(
      createdAt: goal.createdAt ?? DateTime.now(),
      isCompleted: goal.currentAmount >= goal.targetAmount,
    );

    if (index >= 0) {
      _goals[index] = nextGoal;
    } else {
      _goals = [..._goals, nextGoal];
    }

    await _persistGoals();
  }

  Future<void> updateGoalProgress(String goalId, double currentAmount) async {
    final index = _goals.indexWhere((item) => item.id == goalId);
    if (index < 0) return;

    final currentGoal = _goals[index];
    _goals[index] = currentGoal.copyWith(
      currentAmount: currentAmount,
      isCompleted: currentAmount >= currentGoal.targetAmount,
    );

    await _persistGoals();
  }

  Future<void> deleteGoal(String goalId) async {
    _goals = _goals.where((item) => item.id != goalId).toList();
    await _persistGoals();
  }

  Future<void> _persistGoals() async {
    _error = null;

    try {
      await _storageService.saveGoals(_goals);
    } catch (error) {
      _error = error.toString();
    }

    notifyListeners();
  }
}
