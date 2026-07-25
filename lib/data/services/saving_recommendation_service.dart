import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/data/models/reminder_model.dart';
import 'package:finanzas_app_mobile/data/models/saving_recommendation_model.dart';
import 'package:flutter/material.dart';

class SavingRecommendationService {
  static List<SavingRecommendationModel> build({
    required Map<String, dynamic> dashboardData,
    required List<ReminderModel> reminders,
  }) {
    final recommendations = <SavingRecommendationModel>[];
    final totalIncome = _toDouble(dashboardData['total_income']);
    final totalExpense = _toDouble(dashboardData['total_expense']);
    final balance = _toDouble(dashboardData['balance']);
    final monthIncome = _toDouble(dashboardData['month_income']);
    final monthExpense = _toDouble(dashboardData['month_expense']);
    final incomeCount = _toInt(dashboardData['income_count']);
    final expenseCount = _toInt(dashboardData['expense_count']);
    final activeReminders = reminders.where((item) => item.isEnabled).length;

    if (monthIncome > 0 && monthExpense >= monthIncome * 0.85) {
      recommendations.add(
        SavingRecommendationModel(
          title: 'Reduce la presión del mes',
          message:
              'Tus gastos ya consumen gran parte del ingreso mensual. Intenta reservar al menos ${_moneyText(monthIncome * 0.1)} antes de cerrar el mes.',
          icon: Icons.shield_outlined,
          color: AppTheme.corporateRed,
        ),
      );
    }

    if (monthIncome > monthExpense && monthIncome > 0) {
      recommendations.add(
        SavingRecommendationModel(
          title: 'Convierte tu margen en ahorro',
          message:
              'Vas dejando ${_moneyText(monthIncome - monthExpense)} libres este mes. Puedes mover una parte a una meta o fondo de respaldo.',
          icon: Icons.savings_outlined,
          color: AppTheme.corporateGreen,
        ),
      );
    }

    if (balance > 0 && totalIncome > 0 && totalExpense > 0) {
      recommendations.add(
        SavingRecommendationModel(
          title: 'Protege tu balance positivo',
          message:
              'Tu saldo acumulado es de ${_moneyText(balance)}. Mantener un colchón equivalente a 1 o 2 ciclos de gasto te daría mayor estabilidad.',
          icon: Icons.account_balance_wallet_outlined,
          color: AppTheme.corporateBlue,
        ),
      );
    }

    if (activeReminders == 0 && (incomeCount + expenseCount) >= 3) {
      recommendations.add(
        const SavingRecommendationModel(
          title: 'Programa tus compromisos',
          message:
              'Activa recordatorios para evitar pagos tardíos y tener mejor control de gastos fijos o metas.',
          icon: Icons.notifications_outlined,
          color: AppTheme.corporateBlue,
        ),
      );
    }

    if (expenseCount > incomeCount && totalExpense > totalIncome) {
      recommendations.add(
        SavingRecommendationModel(
          title: 'Prioriza frenar salidas variables',
          message:
              'Tu flujo actual muestra más egresos que ingresos. Conviene revisar primero gastos ajustables antes de asumir nuevos compromisos.',
          icon: Icons.trending_down_rounded,
          color: AppTheme.corporateRed,
        ),
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add(
        const SavingRecommendationModel(
          title: 'Sigue alimentando tu historial',
          message:
              'Con más movimientos registrados podremos detectar mejores oportunidades de ahorro y patrones más útiles.',
          icon: Icons.auto_awesome_outlined,
          color: AppTheme.corporateBlue,
        ),
      );
    }

    return recommendations.take(3).toList();
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
