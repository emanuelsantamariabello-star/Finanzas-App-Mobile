import 'package:finanzas_app_mobile/data/models/budget_model.dart';
import 'package:finanzas_app_mobile/data/models/financial_goal_model.dart';
import 'package:finanzas_app_mobile/data/models/reminder_model.dart';
import 'package:finanzas_app_mobile/data/services/budget_storage_service.dart';
import 'package:finanzas_app_mobile/data/services/goal_storage_service.dart';
import 'package:finanzas_app_mobile/data/services/movement_filter_preferences_service.dart';
import 'package:finanzas_app_mobile/data/services/reminder_storage_service.dart';
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
}
