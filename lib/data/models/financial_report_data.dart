class FinancialReportData {
  final String periodLabel;
  final DateTime generatedAt;
  final num totalIncome;
  final num totalExpense;
  final num balance;

  const FinancialReportData({
    required this.periodLabel,
    required this.generatedAt,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });
}
