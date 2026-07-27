import 'package:intl/intl.dart';

enum FinancialReportPeriodType { currentMonth, previousMonth, custom, history }

class FinancialReportPeriod {
  final FinancialReportPeriodType type;
  final String label;
  final DateTime? startDate;
  final DateTime? endDate;

  const FinancialReportPeriod({
    required this.type,
    required this.label,
    this.startDate,
    this.endDate,
  });

  factory FinancialReportPeriod.currentMonth(DateTime now) {
    final start = DateTime(now.year, now.month);
    final end = DateTime(now.year, now.month, now.day);
    return FinancialReportPeriod(
      type: FinancialReportPeriodType.currentMonth,
      label: 'Mes actual · ${_formatRange(start, end)}',
      startDate: start,
      endDate: end,
    );
  }

  factory FinancialReportPeriod.previousMonth(DateTime now) {
    final start = DateTime(now.year, now.month - 1);
    final end = DateTime(now.year, now.month, 0);
    return FinancialReportPeriod(
      type: FinancialReportPeriodType.previousMonth,
      label: 'Mes anterior · ${_formatRange(start, end)}',
      startDate: start,
      endDate: end,
    );
  }

  factory FinancialReportPeriod.custom(DateTime start, DateTime end) {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);
    return FinancialReportPeriod(
      type: FinancialReportPeriodType.custom,
      label: 'Personalizado · ${_formatRange(normalizedStart, normalizedEnd)}',
      startDate: normalizedStart,
      endDate: normalizedEnd,
    );
  }

  const FinancialReportPeriod.history()
    : type = FinancialReportPeriodType.history,
      label = 'Historial completo',
      startDate = null,
      endDate = null;

  String? get apiStartDate => _formatApiDate(startDate);
  String? get apiEndDate => _formatApiDate(endDate);

  static String _formatRange(DateTime start, DateTime end) {
    final formatter = DateFormat('dd/MM/yyyy');
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }

  static String? _formatApiDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
