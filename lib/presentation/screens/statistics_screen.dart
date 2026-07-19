import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/data/services/statistics_service.dart';
import 'package:finanzas_app_mobile/providers/dashboard_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  static final _currency = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '',
    decimalDigits: 0,
  );

  List<Map<String, dynamic>> _monthlyData = [];
  bool _monthlyLoading = true;
  String? _monthlyError;

  static const _monthLabels = [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ];

  @override
  void initState() {
    super.initState();
    _loadMonthlyStats();
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();

    final raw = value.toString().trim();
    if (raw.isEmpty) return 0;

    final cleaned = raw.replaceAll('\$', '').replaceAll(' ', '');
    final lastComma = cleaned.lastIndexOf(',');
    final lastDot = cleaned.lastIndexOf('.');

    if (lastComma != -1 && lastDot != -1) {
      if (lastComma > lastDot) {
        final normalized = cleaned.replaceAll('.', '').replaceAll(',', '.');
        return double.tryParse(normalized) ?? 0;
      } else {
        final normalized = cleaned.replaceAll(',', '');
        return double.tryParse(normalized) ?? 0;
      }
    }

    if (lastComma != -1) {
      return double.tryParse(cleaned.replaceAll(',', '.')) ?? 0;
    }

    return double.tryParse(cleaned) ?? 0;
  }

  double _readNumber(Map<String, dynamic> item, List<String> keys) {
    for (final key in keys) {
      if (!item.containsKey(key)) continue;
      final value = item[key];
      if (value == null) continue;
      final parsed = _toDouble(value);
      if (parsed != 0) return parsed;
    }
    return 0;
  }

  String _extractMonthRaw(Map<String, dynamic> item) {
    final candidates = [
      item['month'],
      item['period'],
      item['year_month'],
      item['ym'],
      item['date'],
    ];

    for (final candidate in candidates) {
      final value = candidate?.toString().trim();
      if (value == null || value.isEmpty) continue;
      return value;
    }

    final year = item['year']?.toString().trim();
    final month = item['month_num']?.toString().trim();
    if (year != null && year.isNotEmpty && month != null && month.isNotEmpty) {
      final monthValue = int.tryParse(month);
      if (monthValue != null && monthValue >= 1 && monthValue <= 12) {
        return '$year-${monthValue.toString().padLeft(2, '0')}';
      }
    }

    return '';
  }

  int _extractYmSortable(Map<String, dynamic> item) {
    final raw = _extractMonthRaw(item);
    if (raw.isEmpty) return -1;

    final normalized = raw.replaceAll('/', '-');
    final parts = normalized
        .split('-')
        .where((p) => p.trim().isNotEmpty)
        .toList();

    if (parts.length >= 2) {
      final first = int.tryParse(parts[0]);
      final second = int.tryParse(parts[1]);
      if (first != null && second != null) {
        if (first >= 1900) return first * 100 + second;
        if (second >= 1900) return second * 100 + first;
      }
    }

    return -1;
  }

  Future<void> _loadMonthlyStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        setState(() {
          _monthlyError = 'Usuario no identificado';
          _monthlyLoading = false;
        });
        return;
      }

      final response = await StatisticsService.getMonthlyStats(userId);

      if (response['success'] == true) {
        final rawData = response['data'] as List? ?? [];
        setState(() {
          final parsed = rawData
              .whereType<Map>()
              .map((item) => item.cast<String, dynamic>())
              .toList();

          parsed.sort((a, b) {
            final ay = _extractYmSortable(a);
            final by = _extractYmSortable(b);
            if (ay == -1 || by == -1) return 0;
            return ay.compareTo(by);
          });

          _monthlyData = parsed;
          _monthlyLoading = false;
        });
      } else {
        setState(() {
          _monthlyError =
              response['message']?.toString() ?? 'Error al cargar estad?sticas';
          _monthlyLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _monthlyError = e.toString();
        _monthlyLoading = false;
      });
    }
  }

  String _formatAmount(dynamic amount) {
    final value = double.tryParse(amount.toString()) ?? 0;
    final formatted = _currency.format(value).replaceAll('\$', '').trim();
    return '\$ $formatted';
  }

  String _formatCompact(double value) {
    if (value >= 1000000) {
      return '\$ ${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '\$ ${(value / 1000).toStringAsFixed(0)}K';
    }
    return '\$ ${value.toStringAsFixed(0)}';
  }

  String _monthLabel(String monthStr) {
    final parts = monthStr.split('-');
    if (parts.length < 2) return monthStr;
    final monthIndex = int.tryParse(parts[1]);
    if (monthIndex == null || monthIndex < 1 || monthIndex > 12) {
      return monthStr;
    }
    return _monthLabels[monthIndex - 1];
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPremiumEmptyState({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    Color accent = AppTheme.corporateGreen,
    double height = 240,
  }) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 34,
                  color: accent.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeVsExpenseChart(
    BuildContext context,
    Map<String, dynamic> dashboardData,
  ) {
    final theme = Theme.of(context);
    final chartData =
        (dashboardData['chart'] as Map?)?.cast<String, dynamic>() ?? {};
    final incomeValue =
        double.tryParse((chartData['income'] ?? 0).toString()) ?? 0;
    final expenseValue =
        double.tryParse((chartData['expense'] ?? 0).toString()) ?? 0;
    final maxValue = [
      incomeValue,
      expenseValue,
      1.0,
    ].reduce((a, b) => a > b ? a : b);
    final leftInterval = maxValue <= 1 ? 1.0 : maxValue / 4;

    return _buildSectionCard(
      context,
      title: 'Ingresos vs Gastos',
      children: [
        incomeValue == 0 && expenseValue == 0
            ? _buildPremiumEmptyState(
                context: context,
                icon: Icons.insights_rounded,
                title: 'Sin movimientos aún',
                subtitle:
                    'No hay suficientes movimientos para generar\nestadísticas todavía.',
              )
            : SizedBox(
                height: 240,
                child: BarChart(
                  BarChartData(
                    maxY: maxValue * 1.25,
                    alignment: BarChartAlignment.spaceAround,
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: leftInterval,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: theme.dividerColor.withValues(alpha: 0.5),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 76,
                          interval: leftInterval,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  _formatAmount(value),
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.55),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            switch (value.toInt()) {
                              case 0:
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Ingresos',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.75),
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              case 1:
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Gastos',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.75),
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              default:
                                return const SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                    ),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => theme.cardColor,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final label = group.x == 0 ? 'Ingresos' : 'Gastos';
                          return BarTooltipItem(
                            '$label\n${_formatAmount(rod.toY)}',
                            TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: incomeValue,
                            width: 30,
                            borderRadius: BorderRadius.circular(10),
                            color: AppTheme.corporateGreen,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: expenseValue,
                            width: 30,
                            borderRadius: BorderRadius.circular(10),
                            color: AppTheme.corporateRed,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildMonthlyEvolutionChart(BuildContext context) {
    final theme = Theme.of(context);

    if (_monthlyLoading) {
      return _buildSectionCard(
        context,
        title: 'Evolución Mensual',
        children: const [
          SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (_monthlyError != null) {
      return _buildSectionCard(
        context,
        title: 'Evolución Mensual',
        children: [
          SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _monthlyError!,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _monthlyLoading = true;
                        _monthlyError = null;
                      });
                      _loadMonthlyStats();
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_monthlyData.isEmpty) {
      return _buildSectionCard(
        context,
        title: 'Evolución Mensual',
        children: [
          _buildPremiumEmptyState(
            context: context,
            icon: Icons.show_chart_rounded,
            title: 'Sin suficientes movimientos',
            subtitle:
                'No hay suficientes movimientos para generar\nestadísticas todavía.',
            accent: AppTheme.corporateBlue,
            height: 200,
          ),
        ],
      );
    }

    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];
    final balanceSpots = <FlSpot>[];
    double globalMax = 1.0;

    for (int i = 0; i < _monthlyData.length; i++) {
      final item = _monthlyData[i];
      final inc = _readNumber(item, [
        'income',
        'total_income',
        'income_total',
        'month_income',
        'monthly_income',
        'ingresos',
      ]);
      final exp = _readNumber(item, [
        'expense',
        'total_expense',
        'expense_total',
        'month_expense',
        'monthly_expense',
        'gastos',
      ]);
      final balRaw = _readNumber(item, ['balance', 'net', 'net_balance']);
      final bal = balRaw != 0 ? balRaw : (inc - exp);

      incomeSpots.add(FlSpot(i.toDouble(), inc));
      expenseSpots.add(FlSpot(i.toDouble(), exp));
      balanceSpots.add(FlSpot(i.toDouble(), bal));

      final localMax = [inc, exp, bal.abs()].reduce((a, b) => a > b ? a : b);
      if (localMax > globalMax) globalMax = localMax;
    }

    final yInterval = globalMax <= 1 ? 1.0 : globalMax / 4;

    return _buildSectionCard(
      context,
      title: 'Evolución Mensual',
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            _legendDot(AppTheme.corporateGreen, 'Ingresos', theme),
            _legendDot(AppTheme.corporateRed, 'Gastos', theme),
            _legendDot(AppTheme.corporateBlue, 'Balance', theme),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: globalMax * 1.2,
              gridData: FlGridData(
                show: true,
                horizontalInterval: yInterval,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: theme.dividerColor.withValues(alpha: 0.5),
                  strokeWidth: 1,
                ),
                drawVerticalLine: false,
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    interval: yInterval,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            _formatCompact(value),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.55,
                              ),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= _monthlyData.length) {
                        return const SizedBox.shrink();
                      }
                      final monthStr = _extractMonthRaw(_monthlyData[idx]);
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _monthLabel(monthStr),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.75,
                            ),
                            fontSize: 11,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => theme.cardColor,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      String label;
                      Color color;
                      switch (spot.barIndex) {
                        case 0:
                          label = 'Ingresos';
                          color = AppTheme.corporateGreen;
                          break;
                        case 1:
                          label = 'Gastos';
                          color = AppTheme.corporateRed;
                          break;
                        case 2:
                          label = 'Balance';
                          color = AppTheme.corporateBlue;
                          break;
                        default:
                          label = '';
                          color = theme.colorScheme.onSurface;
                      }
                      return LineTooltipItem(
                        '$label\n${_formatAmount(spot.y)}',
                        TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: incomeSpots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: AppTheme.corporateGreen,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                          radius: 3.5,
                          color: AppTheme.corporateGreen,
                          strokeWidth: 1.5,
                          strokeColor: theme.colorScheme.surface,
                        ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.corporateGreen.withValues(alpha: 0.08),
                  ),
                ),
                LineChartBarData(
                  spots: expenseSpots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: AppTheme.corporateRed,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                          radius: 3.5,
                          color: AppTheme.corporateRed,
                          strokeWidth: 1.5,
                          strokeColor: theme.colorScheme.surface,
                        ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.corporateRed.withValues(alpha: 0.08),
                  ),
                ),
                LineChartBarData(
                  spots: balanceSpots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: AppTheme.corporateBlue,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dashArray: [6, 4],
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                          radius: 3,
                          color: AppTheme.corporateBlue,
                          strokeWidth: 1.5,
                          strokeColor: theme.colorScheme.surface,
                        ),
                  ),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final dashboardData = dashboardProvider.data;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: dashboardProvider.isLoading && dashboardData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : dashboardProvider.error != null && dashboardData.isEmpty
          ? Center(child: Text('Error: ${dashboardProvider.error}'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📈 Ingresos vs Gastos',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildIncomeVsExpenseChart(context, dashboardData),
                  const SizedBox(height: 28),
                  Text(
                    '📊 Evolución Mensual',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMonthlyEvolutionChart(context),
                ],
              ),
            ),
    );
  }
}
