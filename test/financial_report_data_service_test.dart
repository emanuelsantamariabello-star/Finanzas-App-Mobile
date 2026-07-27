import 'package:finanzas_app_mobile/data/models/financial_report_data.dart';
import 'package:finanzas_app_mobile/data/models/financial_report_period.dart';
import 'package:finanzas_app_mobile/data/services/financial_report_data_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FinancialReportPeriod', () {
    test('resuelve el mes actual y anterior incluso al cambiar de año', () {
      final now = DateTime(2026, 1, 15);
      final current = FinancialReportPeriod.currentMonth(now);
      final previous = FinancialReportPeriod.previousMonth(now);

      expect(current.apiStartDate, '2026-01-01');
      expect(current.apiEndDate, '2026-01-15');
      expect(previous.apiStartDate, '2025-12-01');
      expect(previous.apiEndDate, '2025-12-31');
    });

    test('normaliza el período personalizado y conserva el historial', () {
      final custom = FinancialReportPeriod.custom(
        DateTime(2026, 7, 2, 18),
        DateTime(2026, 7, 26, 22),
      );
      const history = FinancialReportPeriod.history();

      expect(custom.apiStartDate, '2026-07-02');
      expect(custom.apiEndDate, '2026-07-26');
      expect(history.apiStartDate, isNull);
      expect(history.apiEndDate, isNull);
    });
  });

  test('construye totales, clasificación y movimientos ordenados', () {
    final service = FinancialReportDataService();
    final report = service.buildReport(
      userName: ' Emanuel ',
      period: FinancialReportPeriod.custom(
        DateTime(2026, 7, 1),
        DateTime(2026, 7, 31),
      ),
      generatedAt: DateTime(2026, 7, 26, 14),
      incomes: [
        {
          'amount': '2000000.00',
          'type': 'Quincenal',
          'note': 'Salario',
          'income_date': '2026-07-15',
        },
      ],
      expenses: [
        {
          'amount': '300000.00',
          'income_type': 'Quincenal',
          'note': 'Cena',
          'expense_date': '2026-07-20',
          'reflection_type': 'gusto',
        },
        {
          'amount': '200000.00',
          'income_type': 'Quincenal',
          'note': 'Mercado',
          'expense_date': '2026-07-18',
          'reflection_type': 'necesario',
        },
      ],
    );

    expect(report.userName, 'Emanuel');
    expect(report.totalIncome, 2000000);
    expect(report.totalExpense, 500000);
    expect(report.balance, 1500000);
    expect(report.expenseCount, 2);
    expect(report.necessaryExpense, 200000);
    expect(report.tasteExpense, 300000);
    expect(report.necessaryPercentage, 40);
    expect(report.tastePercentage, 60);
    expect(report.financialStatus, 'Saludable');
    expect(report.coachMessage, contains('mitad de tus gastos'));
    expect(report.movements, hasLength(3));
    expect(report.movements.first.description, 'Cena');
    expect(report.movements.first.type, FinancialMovementType.expense);
    expect(report.movements.last.description, 'Salario');
  });

  test('marca en riesgo los gastos sin ingresos en el período', () {
    final report = FinancialReportData(
      periodLabel: 'Prueba',
      generatedAt: DateTime(2026),
      totalIncome: 0,
      totalExpense: 100,
      balance: -100,
    );

    expect(report.financialStatus, 'En riesgo');
  });
}
