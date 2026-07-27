enum FinancialMovementType { income, expense }

class FinancialReportMovement {
  final FinancialMovementType type;
  final DateTime date;
  final String description;
  final String category;
  final num amount;
  final String? reflectionType;

  const FinancialReportMovement({
    required this.type,
    required this.date,
    required this.description,
    required this.category,
    required this.amount,
    this.reflectionType,
  });

  String get typeLabel =>
      type == FinancialMovementType.income ? 'Ingreso' : 'Gasto';

  String get reflectionLabel {
    if (type == FinancialMovementType.income) return '—';
    return reflectionType == 'gusto' ? 'Gusto' : 'Necesario';
  }
}

class FinancialReportData {
  final String userName;
  final String periodLabel;
  final DateTime generatedAt;
  final num totalIncome;
  final num totalExpense;
  final num balance;
  final List<FinancialReportMovement> movements;

  const FinancialReportData({
    this.userName = 'Usuario',
    required this.periodLabel,
    required this.generatedAt,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    this.movements = const [],
  });

  int get expenseCount => movements
      .where((movement) => movement.type == FinancialMovementType.expense)
      .length;

  num get necessaryExpense => movements
      .where(
        (movement) =>
            movement.type == FinancialMovementType.expense &&
            movement.reflectionType != 'gusto',
      )
      .fold<num>(0, (total, movement) => total + movement.amount);

  num get tasteExpense => movements
      .where(
        (movement) =>
            movement.type == FinancialMovementType.expense &&
            movement.reflectionType == 'gusto',
      )
      .fold<num>(0, (total, movement) => total + movement.amount);

  double get expenseRatio =>
      totalIncome > 0 ? (totalExpense / totalIncome) * 100 : 0;

  String get expenseRatioSummary {
    if (totalIncome > 0) {
      return 'Los gastos representan ${expenseRatio.toStringAsFixed(1)}% de los ingresos';
    }
    if (totalExpense > 0) {
      return 'Se registraron gastos sin ingresos durante el período';
    }
    return 'No se registraron ingresos ni gastos durante el período';
  }

  double get necessaryPercentage =>
      totalExpense > 0 ? (necessaryExpense / totalExpense) * 100 : 0;

  double get tastePercentage =>
      totalExpense > 0 ? (tasteExpense / totalExpense) * 100 : 0;

  String get financialStatus {
    if (totalIncome <= 0 && totalExpense > 0) return 'En riesgo';
    if (expenseRatio < 70) return 'Saludable';
    if (expenseRatio <= 90) return 'Ajustado';
    return 'En riesgo';
  }

  String? get coachMessage {
    if (totalExpense <= 0) return null;
    if (necessaryPercentage >= 70) {
      return 'Excelente disciplina financiera. Estás priorizando lo importante.';
    }
    if (tastePercentage >= 50) {
      return 'Más de la mitad de tus gastos fueron gustos. Revisa si esto fue intencional.';
    }
    return 'Mantienes una distribución equilibrada entre necesidades y gustos.';
  }
}
