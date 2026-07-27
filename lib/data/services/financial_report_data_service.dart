import 'package:finanzas_app_mobile/core/network/api_exception.dart';
import 'package:finanzas_app_mobile/data/models/financial_report_data.dart';
import 'package:finanzas_app_mobile/data/models/financial_report_period.dart';
import 'package:finanzas_app_mobile/data/services/expense_service.dart';
import 'package:finanzas_app_mobile/data/services/income_service.dart';

class FinancialReportDataService {
  Future<FinancialReportData> loadReport({
    required int userId,
    required String userName,
    required FinancialReportPeriod period,
    DateTime? generatedAt,
  }) async {
    final responses = await Future.wait([
      IncomeService.getIncomes(
        userId,
        startDate: period.apiStartDate,
        endDate: period.apiEndDate,
      ),
      ExpenseService.getExpenses(
        userId,
        startDate: period.apiStartDate,
        endDate: period.apiEndDate,
      ),
    ]);

    final incomeResponse = responses[0];
    final expenseResponse = responses[1];
    if (incomeResponse['success'] != true ||
        expenseResponse['success'] != true) {
      throw const ApiException(
        type: ApiErrorType.invalidResponse,
        message: 'No se pudieron preparar los datos del reporte',
      );
    }

    return buildReport(
      userName: userName,
      period: period,
      generatedAt: generatedAt ?? DateTime.now(),
      incomes: _extractRows(incomeResponse),
      expenses: _extractRows(expenseResponse),
    );
  }

  FinancialReportData buildReport({
    required String userName,
    required FinancialReportPeriod period,
    required DateTime generatedAt,
    required List<Map<String, dynamic>> incomes,
    required List<Map<String, dynamic>> expenses,
  }) {
    final movements = <FinancialReportMovement>[
      ...incomes.map(_mapIncome),
      ...expenses.map(_mapExpense),
    ]..sort((first, second) => second.date.compareTo(first.date));

    final totalIncome = movements
        .where((movement) => movement.type == FinancialMovementType.income)
        .fold<num>(0, (total, movement) => total + movement.amount);
    final totalExpense = movements
        .where((movement) => movement.type == FinancialMovementType.expense)
        .fold<num>(0, (total, movement) => total + movement.amount);

    return FinancialReportData(
      userName: userName.trim().isEmpty ? 'Usuario' : userName.trim(),
      periodLabel: period.label,
      generatedAt: generatedAt,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalIncome - totalExpense,
      movements: movements,
    );
  }

  List<Map<String, dynamic>> _extractRows(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is! List) {
      throw const ApiException(
        type: ApiErrorType.invalidResponse,
        message: 'El servidor devolvió movimientos no válidos',
      );
    }
    return data.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }

  FinancialReportMovement _mapIncome(Map<String, dynamic> income) {
    return FinancialReportMovement(
      type: FinancialMovementType.income,
      date: _parseDate(income['income_date'] ?? income['date']),
      description: _safeText(income['note'], fallback: 'Sin nota'),
      category: _safeText(income['type'], fallback: 'Ingreso'),
      amount: _parseAmount(income['amount']),
    );
  }

  FinancialReportMovement _mapExpense(Map<String, dynamic> expense) {
    return FinancialReportMovement(
      type: FinancialMovementType.expense,
      date: _parseDate(expense['expense_date']),
      description: _safeText(expense['note'], fallback: 'Sin nota'),
      category: _safeText(
        expense['income_type'] ?? expense['type'],
        fallback: 'Gasto',
      ),
      amount: _parseAmount(expense['amount']),
      reflectionType: expense['reflection_type'] == 'gusto'
          ? 'gusto'
          : 'necesario',
    );
  }

  DateTime _parseDate(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed == null) {
      throw const ApiException(
        type: ApiErrorType.invalidResponse,
        message: 'El servidor devolvió una fecha no válida',
      );
    }
    return parsed;
  }

  num _parseAmount(dynamic value) {
    final parsed = num.tryParse(value?.toString() ?? '');
    if (parsed == null) {
      throw const ApiException(
        type: ApiErrorType.invalidResponse,
        message: 'El servidor devolvió un monto no válido',
      );
    }
    return parsed;
  }

  String _safeText(dynamic value, {required String fallback}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }
}
