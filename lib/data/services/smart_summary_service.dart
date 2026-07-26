import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/data/models/reminder_model.dart';
import 'package:finanzas_app_mobile/data/models/smart_summary_model.dart';
import 'package:flutter/material.dart';

class SmartSummaryService {
  static SmartSummaryModel build({
    required Map<String, dynamic> dashboardData,
    required List<ReminderModel> reminders,
    required DateTime now,
  }) {
    final totalIncome = _toDouble(dashboardData['total_income']);
    final totalExpense = _toDouble(dashboardData['total_expense']);
    final balance = _toDouble(dashboardData['balance']);
    final monthIncome = _toDouble(dashboardData['month_income']);
    final monthExpense = _toDouble(dashboardData['month_expense']);
    final incomeCount = _toInt(dashboardData['income_count']);
    final expenseCount = _toInt(dashboardData['expense_count']);
    final activeReminders = reminders.where((item) => item.isEnabled).length;
    final totalMovements = incomeCount + expenseCount;
    final periodLabel = now.weekday == DateTime.monday
        ? 'inicio de semana'
        : 'día';

    if (totalMovements == 0) {
      return SmartSummaryModel(
        title: 'Comienza tu $periodLabel financiero',
        message:
            'Aún no hay movimientos registrados. Tu panel está listo para empezar a construir historial y hábitos.',
        highlight: activeReminders > 0
            ? 'Tienes $activeReminders recordatorios activos para arrancar con orden.'
            : 'Registra tu primer ingreso o gasto para generar análisis.',
        icon: Icons.auto_graph_rounded,
        color: AppTheme.corporateBlue,
        chips: [
          'Sin movimientos',
          if (activeReminders > 0) '$activeReminders recordatorios activos',
        ],
      );
    }

    final netMonth = monthIncome - monthExpense;
    final expenseRatio = monthIncome > 0 ? monthExpense / monthIncome : 0.0;

    if (monthIncome > 0 && expenseRatio >= 0.9) {
      return SmartSummaryModel(
        title: 'Atención con tu ritmo de gasto',
        message:
            'En este $periodLabel ya consumiste casi todo lo que ha ingresado este mes. Conviene revisar gastos variables.',
        highlight: netMonth >= 0
            ? 'Aún conservas un margen positivo de ${_moneyText(netMonth)}.'
            : 'El balance mensual ya va en rojo por ${_moneyText(netMonth.abs())}.',
        icon: Icons.warning_amber_rounded,
        color: AppTheme.corporateRed,
        chips: [
          '${(expenseRatio * 100).round()}% del ingreso consumido',
          '$expenseCount gastos registrados',
          if (activeReminders > 0) '$activeReminders recordatorios activos',
        ],
      );
    }

    if (balance > 0 && monthIncome > monthExpense) {
      return SmartSummaryModel(
        title: 'Vas cerrando un $periodLabel saludable',
        message:
            'Tus ingresos superan a los gastos y el balance acumulado se mantiene en terreno positivo.',
        highlight:
            'Tu margen actual es de ${_moneyText(balance)} y este mes retienes ${_moneyText(netMonth)}.',
        icon: Icons.trending_up_rounded,
        color: AppTheme.corporateGreen,
        chips: [
          '$incomeCount ingresos registrados',
          '$expenseCount gastos registrados',
          if (activeReminders > 0) '$activeReminders recordatorios activos',
        ],
      );
    }

    if (expenseCount > incomeCount && totalExpense > totalIncome) {
      return SmartSummaryModel(
        title: 'Tu flujo necesita revisión',
        message:
            'El volumen de gastos y el total egresado ya superan a los ingresos acumulados.',
        highlight:
            'Recorta presión por ${_moneyText((totalExpense - totalIncome).abs())} para estabilizar el balance.',
        icon: Icons.insights_rounded,
        color: AppTheme.corporateRed,
        chips: [
          '$expenseCount gastos vs $incomeCount ingresos',
          'Balance ${balance >= 0 ? 'positivo' : 'negativo'}',
          if (activeReminders > 0) '$activeReminders recordatorios activos',
        ],
      );
    }

    return SmartSummaryModel(
      title: 'Tu $periodLabel financiero sigue activo',
      message:
          'Ya hay movimiento suficiente para seguir detectando patrones y preparar mejores recomendaciones.',
      highlight: activeReminders > 0
          ? 'Mantienes $activeReminders recordatorios activos y un balance de ${_moneyText(balance)}.'
          : 'El balance actual es de ${_moneyText(balance)}.',
      icon: Icons.lightbulb_outline_rounded,
      color: AppTheme.corporateBlue,
      chips: [
        '$totalMovements movimientos',
        'Mes: ${_moneyText(monthIncome)} / ${_moneyText(monthExpense)}',
      ],
    );
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
