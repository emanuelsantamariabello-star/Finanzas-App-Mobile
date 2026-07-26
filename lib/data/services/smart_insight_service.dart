import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/data/models/budget_model.dart';
import 'package:finanzas_app_mobile/data/models/reminder_model.dart';
import 'package:finanzas_app_mobile/data/models/smart_insight_model.dart';
import 'package:flutter/material.dart';

class SmartInsightService {
  static List<SmartInsightModel> build({
    required Map<String, dynamic> dashboardData,
    required List<ReminderModel> reminders,
    required DateTime now,
    List<BudgetModel> budgets = const [],
    Map<String, double> monthlySpentByCategory = const {},
  }) {
    final insights = <SmartInsightModel>[];
    final totalIncome = _toDouble(dashboardData['total_income']);
    final totalExpense = _toDouble(dashboardData['total_expense']);
    final balance = _toDouble(dashboardData['balance']);
    final monthIncome = _toDouble(dashboardData['month_income']);
    final monthExpense = _toDouble(dashboardData['month_expense']);
    final incomeCount = _toInt(dashboardData['income_count']);
    final expenseCount = _toInt(dashboardData['expense_count']);
    final activeReminders = reminders.where((item) => item.isEnabled).toList();
    final dueSoon = activeReminders
        .where((item) => _isDueSoon(item.scheduledAt, now))
        .length;
    final exceededBudgets = budgets.where((budget) {
      return (monthlySpentByCategory[budget.category] ?? 0) >
          budget.limitAmount;
    }).length;

    if (monthIncome > 0 && monthExpense > monthIncome) {
      insights.add(
        SmartInsightModel(
          title: 'Gasto del mes por encima del ingreso',
          message:
              'Este mes estás gastando ${_moneyText(monthExpense - monthIncome)} por encima de lo que ingresó.',
          icon: Icons.trending_down_rounded,
          color: AppTheme.corporateRed,
        ),
      );
    } else if (monthIncome > 0 && monthExpense <= monthIncome * 0.6) {
      insights.add(
        SmartInsightModel(
          title: 'Buen margen de ahorro mensual',
          message:
              'Tus gastos del mes siguen contenidos y dejas un margen libre de ${_moneyText(monthIncome - monthExpense)}.',
          icon: Icons.savings_rounded,
          color: AppTheme.corporateGreen,
        ),
      );
    }

    if (dueSoon > 0) {
      insights.add(
        SmartInsightModel(
          title: 'Recordatorios próximos',
          message:
              'Tienes $dueSoon recordatorio${dueSoon == 1 ? '' : 's'} activo${dueSoon == 1 ? '' : 's'} para los próximos 7 días.',
          icon: Icons.notifications_active_rounded,
          color: AppTheme.corporateBlue,
        ),
      );
    } else if (activeReminders.isEmpty && (incomeCount + expenseCount) > 0) {
      insights.add(
        SmartInsightModel(
          title: 'Aún no usas recordatorios',
          message:
              'Ya tienes movimientos registrados. Activa recordatorios para pagos, gastos fijos o metas.',
          icon: Icons.notification_add_rounded,
          color: AppTheme.corporateBlue,
        ),
      );
    }

    if (expenseCount > incomeCount && totalExpense > totalIncome) {
      insights.add(
        SmartInsightModel(
          title: 'Mayor presión en salidas',
          message:
              'Llevas más gastos que ingresos y el balance acumulado cae ${_moneyText((totalExpense - totalIncome).abs())}.',
          icon: Icons.warning_rounded,
          color: AppTheme.corporateRed,
        ),
      );
    } else if (balance > 0 && totalIncome > totalExpense) {
      insights.add(
        SmartInsightModel(
          title: 'Balance acumulado favorable',
          message:
              'Tu historial mantiene un saldo positivo de ${_moneyText(balance)}.',
          icon: Icons.account_balance_wallet_rounded,
          color: AppTheme.corporateGreen,
        ),
      );
    }

    if (exceededBudgets > 0) {
      insights.add(
        SmartInsightModel(
          title: 'Presupuestos excedidos',
          message:
              'Tienes $exceededBudgets categoría(s) por encima del límite mensual configurado.',
          icon: Icons.pie_chart_rounded,
          color: AppTheme.corporateRed,
        ),
      );
    }

    if (insights.isEmpty) {
      insights.add(
        const SmartInsightModel(
          title: 'Más datos, mejores alertas',
          message:
              'Sigue registrando movimientos para detectar patrones de gasto, ahorro y próximos compromisos.',
          icon: Icons.insights_rounded,
          color: AppTheme.corporateBlue,
        ),
      );
    }

    return insights.take(3).toList();
  }

  static bool _isDueSoon(DateTime scheduledAt, DateTime now) {
    final difference = scheduledAt.difference(now).inDays;
    return difference >= 0 && difference <= 7;
  }

  static double _toDouble(dynamic value) {
    return double.tryParse(value.toString()) ?? 0;
  }

  static int _toInt(dynamic value) {
    return int.tryParse(value.toString()) ?? 0;
  }

  static String _moneyText(double value) {
    final digits = value.abs().toStringAsFixed(0);
    final reversed = digits.split('').reversed.toList();
    final parts = <String>[];

    for (var index = 0; index < reversed.length; index += 3) {
      final end = (index + 3 < reversed.length) ? index + 3 : reversed.length;
      parts.add(reversed.sublist(index, end).reversed.join());
    }

    final formatted = parts.reversed.join('.');
    return '${value < 0 ? '-\$' : '\$'} $formatted';
  }
}
