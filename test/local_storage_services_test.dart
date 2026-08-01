import 'package:finanzas_app_mobile/data/models/budget_model.dart';
import 'package:finanzas_app_mobile/data/models/financial_goal_model.dart';
import 'package:finanzas_app_mobile/data/models/reminder_model.dart';
import 'package:finanzas_app_mobile/data/services/budget_storage_service.dart';
import 'package:finanzas_app_mobile/data/services/goal_storage_service.dart';
import 'package:finanzas_app_mobile/data/services/movement_filter_preferences_service.dart';
import 'package:finanzas_app_mobile/data/services/reminder_storage_service.dart';
import 'package:finanzas_app_mobile/data/services/user_scoped_storage_service.dart';
import 'package:finanzas_app_mobile/providers/goal_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('guarda y restaura recordatorios', () async {
    final service = ReminderStorageService();
    final scheduledAt = DateTime(2026, 8, 1, 8, 30);

    await service.saveReminders([
      ReminderModel(
        id: 'reminder-1',
        title: 'Pagar arriendo',
        description: 'Pago mensual',
        type: 'payment',
        frequency: 'monthly',
        scheduledAt: scheduledAt,
      ),
    ]);

    final reminders = await service.loadReminders();

    expect(reminders, hasLength(1));
    expect(reminders.single.title, 'Pagar arriendo');
    expect(reminders.single.scheduledAt, scheduledAt);
    expect(reminders.single.isEnabled, isTrue);
  });

  test('guarda y restaura metas financieras', () async {
    final service = GoalStorageService();
    final targetDate = DateTime(2027, 1, 1);

    await service.saveGoals([
      FinancialGoalModel(
        id: 'goal-1',
        title: 'Fondo de emergencia',
        targetAmount: 5000000,
        currentAmount: 1250000,
        targetDate: targetDate,
      ),
    ]);

    final goals = await service.loadGoals();

    expect(goals, hasLength(1));
    expect(goals.single.title, 'Fondo de emergencia');
    expect(goals.single.targetAmount, 5000000);
    expect(goals.single.currentAmount, 1250000);
    expect(goals.single.targetDate, targetDate);
  });

  test('guarda y restaura presupuestos por categoría', () async {
    final service = BudgetStorageService();

    await service.saveBudgets([
      const BudgetModel(
        id: 'budget-1',
        category: 'Transporte',
        limitAmount: 300000,
        note: 'Presupuesto mensual',
      ),
    ]);

    final budgets = await service.loadBudgets();

    expect(budgets, hasLength(1));
    expect(budgets.single.category, 'Transporte');
    expect(budgets.single.limitAmount, 300000);
    expect(budgets.single.note, 'Presupuesto mensual');
  });

  test('guarda y restaura filtros de movimientos', () async {
    final service = MovementFilterPreferencesService();
    const filters = {'query': 'mercado', 'range': 'month', 'tabIndex': 1};

    await service.save(filters);
    final restored = await service.load();

    expect(restored, filters);
  });

  test('aísla los datos locales entre usuarios', () async {
    final prefs = await SharedPreferences.getInstance();
    final reminderService = ReminderStorageService();
    final goalService = GoalStorageService();
    final budgetService = BudgetStorageService();
    final filterService = MovementFilterPreferencesService();

    await prefs.setInt('userId', 1);
    await reminderService.saveReminders([
      ReminderModel(
        id: 'reminder-user-1',
        title: 'Recordatorio usuario 1',
        type: 'payment',
        frequency: 'monthly',
        scheduledAt: DateTime(2026, 8, 1),
      ),
    ]);
    await goalService.saveGoals([
      FinancialGoalModel(
        id: 'goal-user-1',
        title: 'Meta usuario 1',
        targetAmount: 1000000,
        currentAmount: 0,
        targetDate: DateTime(2027, 1, 1),
      ),
    ]);
    await budgetService.saveBudgets([
      const BudgetModel(
        id: 'budget-user-1',
        category: 'Transporte',
        limitAmount: 200000,
      ),
    ]);
    await filterService.save({'query': 'usuario 1'});

    await prefs.setInt('userId', 2);

    expect(await reminderService.loadReminders(), isEmpty);
    expect(await goalService.loadGoals(), isEmpty);
    expect(await budgetService.loadBudgets(), isEmpty);
    expect(await filterService.load(), isEmpty);

    await prefs.setInt('userId', 1);

    expect(
      (await reminderService.loadReminders()).single.id,
      'reminder-user-1',
    );
    expect((await goalService.loadGoals()).single.id, 'goal-user-1');
    expect((await budgetService.loadBudgets()).single.id, 'budget-user-1');
    expect(await filterService.load(), {'query': 'usuario 1'});
  });

  test('elimina únicamente los datos locales del usuario activo', () async {
    SharedPreferences.setMockInitialValues({
      'userId': 7,
      'reminders_user_7': <String>['recordatorio'],
      'financial_goals_user_7': <String>['meta'],
      'category_budgets_user_7': <String>['presupuesto'],
      'movement_filters_user_7': '{}',
      'read_internal_notifications_user_7': <String>['1'],
      'reminders_user_8': <String>['otro recordatorio'],
      'themeMode': 'dark',
    });

    await UserScopedStorageService.clearCurrentUserData();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('reminders_user_7'), isFalse);
    expect(prefs.containsKey('financial_goals_user_7'), isFalse);
    expect(prefs.containsKey('category_budgets_user_7'), isFalse);
    expect(prefs.containsKey('movement_filters_user_7'), isFalse);
    expect(prefs.containsKey('read_internal_notifications_user_7'), isFalse);
    expect(prefs.getStringList('reminders_user_8'), ['otro recordatorio']);
    expect(prefs.getString('themeMode'), 'dark');
  });

  test('migra los datos legacy únicamente al usuario activo', () async {
    final reminderService = ReminderStorageService();
    final goalService = GoalStorageService();
    final budgetService = BudgetStorageService();
    final filterService = MovementFilterPreferencesService();
    final prefs = await SharedPreferences.getInstance();

    await reminderService.saveReminders([
      ReminderModel(
        id: 'legacy-reminder',
        title: 'Recordatorio existente',
        type: 'payment',
        frequency: 'monthly',
        scheduledAt: DateTime(2026, 8, 1),
      ),
    ]);
    await goalService.saveGoals([
      FinancialGoalModel(
        id: 'legacy-goal',
        title: 'Meta existente',
        targetAmount: 1000000,
        currentAmount: 0,
        targetDate: DateTime(2027, 1, 1),
      ),
    ]);
    await budgetService.saveBudgets([
      const BudgetModel(
        id: 'legacy-budget',
        category: 'Transporte',
        limitAmount: 200000,
      ),
    ]);
    await filterService.save({'query': 'legacy'});

    await prefs.setInt('userId', 7);
    final migratedReminders = await reminderService.loadReminders();
    final migratedGoals = await goalService.loadGoals();
    final migratedBudgets = await budgetService.loadBudgets();
    final migratedFilters = await filterService.load();

    expect(migratedReminders.single.id, 'legacy-reminder');
    expect(migratedGoals.single.id, 'legacy-goal');
    expect(migratedBudgets.single.id, 'legacy-budget');
    expect(migratedFilters, {'query': 'legacy'});
    expect(prefs.containsKey('reminders'), isFalse);
    expect(prefs.containsKey('financial_goals'), isFalse);
    expect(prefs.containsKey('category_budgets'), isFalse);
    expect(prefs.containsKey('movement_filters'), isFalse);
    expect(prefs.containsKey('reminders_user_7'), isTrue);
    expect(prefs.containsKey('financial_goals_user_7'), isTrue);
    expect(prefs.containsKey('category_budgets_user_7'), isTrue);
    expect(prefs.containsKey('movement_filters_user_7'), isTrue);

    await prefs.setInt('userId', 8);
    expect(await reminderService.loadReminders(), isEmpty);
    expect(await goalService.loadGoals(), isEmpty);
    expect(await budgetService.loadBudgets(), isEmpty);
    expect(await filterService.load(), isEmpty);
  });

  test('recarga el provider cuando cambia el usuario activo', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = GoalStorageService();

    await prefs.setInt('userId', 1);
    await service.saveGoals([
      FinancialGoalModel(
        id: 'goal-user-1',
        title: 'Meta usuario 1',
        targetAmount: 1000000,
        currentAmount: 0,
        targetDate: DateTime(2027, 1, 1),
      ),
    ]);

    await prefs.setInt('userId', 2);
    await service.saveGoals([
      FinancialGoalModel(
        id: 'goal-user-2',
        title: 'Meta usuario 2',
        targetAmount: 2000000,
        currentAmount: 0,
        targetDate: DateTime(2027, 1, 1),
      ),
    ]);

    final provider = GoalProvider(storageService: service);

    await prefs.setInt('userId', 1);
    await provider.initialize();
    expect(provider.goals.single.id, 'goal-user-1');

    await prefs.setInt('userId', 2);
    await provider.initialize();
    expect(provider.goals.single.id, 'goal-user-2');
  });
}
