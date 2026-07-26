import 'package:finanzas_app_mobile/data/models/budget_model.dart';
import 'package:finanzas_app_mobile/data/models/reminder_model.dart';
import 'package:finanzas_app_mobile/data/services/saving_recommendation_service.dart';
import 'package:finanzas_app_mobile/data/services/smart_insight_service.dart';
import 'package:finanzas_app_mobile/data/services/smart_summary_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 7, 25, 9);

  Map<String, dynamic> dashboard({
    num totalIncome = 0,
    num totalExpense = 0,
    num balance = 0,
    num monthIncome = 0,
    num monthExpense = 0,
    int incomeCount = 0,
    int expenseCount = 0,
  }) {
    return {
      'total_income': totalIncome,
      'total_expense': totalExpense,
      'balance': balance,
      'month_income': monthIncome,
      'month_expense': monthExpense,
      'income_count': incomeCount,
      'expense_count': expenseCount,
    };
  }

  ReminderModel reminder({
    required DateTime scheduledAt,
    bool isEnabled = true,
  }) {
    return ReminderModel(
      id: 'reminder-1',
      title: 'Pago mensual',
      type: 'payment',
      frequency: 'monthly',
      scheduledAt: scheduledAt,
      isEnabled: isEnabled,
    );
  }

  group('SmartSummaryService', () {
    test('orienta al usuario cuando todavía no hay movimientos', () {
      final summary = SmartSummaryService.build(
        dashboardData: dashboard(),
        reminders: [reminder(scheduledAt: now.add(const Duration(days: 2)))],
        now: now,
      );

      expect(summary.title, contains('Comienza'));
      expect(summary.message, contains('Aún no hay movimientos'));
      expect(summary.highlight, contains('1 recordatorios activos'));
    });

    test('advierte cuando el gasto consume casi todo el ingreso mensual', () {
      final summary = SmartSummaryService.build(
        dashboardData: dashboard(
          totalIncome: 1000,
          totalExpense: 950,
          balance: 50,
          monthIncome: 1000,
          monthExpense: 950,
          incomeCount: 1,
          expenseCount: 2,
        ),
        reminders: const [],
        now: now,
      );

      expect(summary.title, 'Atención con tu ritmo de gasto');
      expect(summary.chips, contains('95% del ingreso consumido'));
    });
  });

  group('SmartInsightService', () {
    test('detecta recordatorios próximos y presupuestos excedidos', () {
      final insights = SmartInsightService.build(
        dashboardData: dashboard(),
        reminders: [reminder(scheduledAt: now.add(const Duration(days: 3)))],
        now: now,
        budgets: const [
          BudgetModel(
            id: 'budget-1',
            category: 'Alimentación',
            limitAmount: 500,
          ),
        ],
        monthlySpentByCategory: const {'Alimentación': 650},
      );

      expect(
        insights.map((item) => item.title),
        containsAll(['Recordatorios próximos', 'Presupuestos excedidos']),
      );
    });
  });

  group('SavingRecommendationService', () {
    test('recomienda reservar margen cuando ingresos superan gastos', () {
      final recommendations = SavingRecommendationService.build(
        dashboardData: dashboard(
          totalIncome: 2000,
          totalExpense: 1000,
          balance: 1000,
          monthIncome: 1200,
          monthExpense: 700,
          incomeCount: 2,
          expenseCount: 2,
        ),
        reminders: const [],
      );

      expect(
        recommendations.map((item) => item.title),
        contains('Convierte tu margen en ahorro'),
      );
    });

    test('advierte cuando el gasto mensual supera el umbral seguro', () {
      final recommendations = SavingRecommendationService.build(
        dashboardData: dashboard(
          totalIncome: 1000,
          totalExpense: 900,
          balance: 100,
          monthIncome: 1000,
          monthExpense: 900,
          incomeCount: 1,
          expenseCount: 3,
        ),
        reminders: const [],
      );

      expect(
        recommendations.map((item) => item.title),
        contains('Reduce la presión del mes'),
      );
    });
  });
}
