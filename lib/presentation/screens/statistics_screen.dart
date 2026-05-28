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
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
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

    // Decide decimal separator based on the last occurring symbol.
    if (lastComma != -1 && lastDot != -1) {
      if (lastComma > lastDot) {
        // 1.234,56 -> 1234.56
        final normalized = cleaned.replaceAll('.', '').replaceAll(',', '.');
        return double.tryParse(normalized) ?? 0;
      } else {
        // 1,234.56 -> 1234.56
        final normalized = cleaned.replaceAll(',', '');
        return double.tryParse(normalized) ?? 0;
      }
    }

    if (lastComma != -1) {
      // 1234,56 -> 1234.56
      return double.tryParse(cleaned.replaceAll(',', '.')) ?? 0;
    }

    // 1234.56 or 1234
    return double.tryParse(cleaned) ?? 0;
  }

  double _readNumber(Map<String, dynamic> item, List<String> keys) {
    for (final key in keys) {
      if (!item.containsKey(key)) continue;
      final v = item[key];
      if (v == null) continue;
      final parsed = _toDouble(v);
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

    for (final c in candidates) {
      final s = c?.toString().trim();
      if (s == null || s.isEmpty) continue;
      return s;
    }

    // Fallback: if API returns separate year/month fields.
    final year = item['year']?.toString().trim();
    final month = item['month_num']?.toString().trim();
    if (year != null && year.isNotEmpty && month != null && month.isNotEmpty) {
      final m = int.tryParse(month);
      if (m != null && m >= 1 && m <= 12) {
        return '$year-${m.toString().padLeft(2, '0')}';
      }
    }

    return '';
  }

  int _extractYmSortable(Map<String, dynamic> item) {
    final raw = _extractMonthRaw(item);
    if (raw.isEmpty) return -1;

    // Expected formats: YYYY-MM, YYYY-M, YYYY/MM, MM-YYYY, etc.
    final normalized = raw.replaceAll('/', '-');
    final parts = normalized.split('-').where((p) => p.trim().isNotEmpty).toList();

    if (parts.length >= 2) {
      final a = int.tryParse(parts[0]);
      final b = int.tryParse(parts[1]);
      if (a != null && b != null) {
        // If first part looks like year.
        if (a >= 1900) return a * 100 + b;
        // If second part looks like year (MM-YYYY).
        if (b >= 1900) return b * 100 + a;
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
              .map((e) => e.cast<String, dynamic>())
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
              response['message']?.toString() ?? 'Error al cargar estadísticas';
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

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPremiumEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Color accent = const Color(0xFF00C853),
    double height = 240,
  }) {
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white54,
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

  // ── Gráfica existente: Ingresos vs Gastos ──
  Widget _buildIncomeVsExpenseChart(Map<String, dynamic> dashboardData) {
    final chartData =
        (dashboardData['chart'] as Map?)?.cast<String, dynamic>() ?? {};
    final incomeValue =
        double.tryParse((chartData['income'] ?? 0).toString()) ?? 0;
    final expenseValue =
        double.tryParse((chartData['expense'] ?? 0).toString()) ?? 0;
    final maxValue = [incomeValue, expenseValue, 1.0].reduce(
      (a, b) => a > b ? a : b,
    );

    final leftInterval = maxValue <= 1 ? 1.0 : maxValue / 4;

    return _buildSectionCard(
      title: "Ingresos vs Gastos",
      children: [
        (incomeValue == 0 && expenseValue == 0)
            ? _buildPremiumEmptyState(
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
                        color: Colors.white10,
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
                                  style: const TextStyle(
                                    color: Colors.white54,
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
                                return const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Ingresos',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              case 1:
                                return const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Gastos',
                                    style: TextStyle(
                                      color: Colors.white70,
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
                        getTooltipColor: (_) => const Color(0xFF0D1117),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final label = group.x == 0 ? 'Ingresos' : 'Gastos';
                          return BarTooltipItem(
                            '$label\n${_formatAmount(rod.toY)}',
                            const TextStyle(
                              color: Colors.white,
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
                            color: Colors.green,
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
                            color: Colors.red,
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

  // ── Nueva gráfica: Evolución mensual ──
  Widget _buildMonthlyEvolutionChart() {
    if (_monthlyLoading) {
      return _buildSectionCard(
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
        title: 'Evolución Mensual',
        children: [
          SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.white38, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    _monthlyError!,
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
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
        title: 'Evolución Mensual',
        children: [
          _buildPremiumEmptyState(
            icon: Icons.show_chart_rounded,
            title: 'Sin suficientes movimientos',
            subtitle:
                'No hay suficientes movimientos para generar\nestadísticas mensuales todavía.',
            accent: const Color(0xFF42A5F5),
            height: 200,
          ),
        ],
      );
    }

    // Preparar spots para las líneas
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
      final balRaw = _readNumber(item, [
        'balance',
        'net',
        'net_balance',
      ]);
      final bal = balRaw != 0 ? balRaw : (inc - exp);

      incomeSpots.add(FlSpot(i.toDouble(), inc));
      expenseSpots.add(FlSpot(i.toDouble(), exp));
      balanceSpots.add(FlSpot(i.toDouble(), bal));

      final localMax = [inc, exp, bal.abs()].reduce((a, b) => a > b ? a : b);
      if (localMax > globalMax) globalMax = localMax;
    }

    final yInterval = globalMax <= 1 ? 1.0 : globalMax / 4;

    return _buildSectionCard(
      title: 'Evolución Mensual',
      children: [
        // Leyenda
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            _legendDot(const Color(0xFF4CAF50), 'Ingresos'),
            _legendDot(const Color(0xFFEF5350), 'Gastos'),
            _legendDot(const Color(0xFF42A5F5), 'Balance'),
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
                  color: Colors.white10,
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
                            style: const TextStyle(
                              color: Colors.white54,
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
                          style: const TextStyle(
                            color: Colors.white70,
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
                  getTooltipColor: (_) => const Color(0xFF0D1117),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      String label;
                      Color color;
                      switch (spot.barIndex) {
                        case 0:
                          label = 'Ingresos';
                          color = const Color(0xFF4CAF50);
                          break;
                        case 1:
                          label = 'Gastos';
                          color = const Color(0xFFEF5350);
                          break;
                        case 2:
                          label = 'Balance';
                          color = const Color(0xFF42A5F5);
                          break;
                        default:
                          label = '';
                          color = Colors.white;
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
                // Ingresos
                LineChartBarData(
                  spots: incomeSpots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: const Color(0xFF4CAF50),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                      radius: 3.5,
                      color: const Color(0xFF4CAF50),
                      strokeWidth: 1.5,
                      strokeColor: Colors.white24,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
                  ),
                ),
                // Gastos
                LineChartBarData(
                  spots: expenseSpots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: const Color(0xFFEF5350),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                      radius: 3.5,
                      color: const Color(0xFFEF5350),
                      strokeWidth: 1.5,
                      strokeColor: Colors.white24,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xFFEF5350).withValues(alpha: 0.08),
                  ),
                ),
                // Balance
                LineChartBarData(
                  spots: balanceSpots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: const Color(0xFF42A5F5),
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dashArray: [6, 4],
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                      radius: 3,
                      color: const Color(0xFF42A5F5),
                      strokeWidth: 1.5,
                      strokeColor: Colors.white24,
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

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final dashboardData = dashboardProvider.data;

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: dashboardProvider.isLoading && dashboardData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : dashboardProvider.error != null && dashboardData.isEmpty
              ? Center(child: Text("Error: ${dashboardProvider.error}"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📈 Ingresos vs Gastos',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildIncomeVsExpenseChart(dashboardData),
                      const SizedBox(height: 28),
                      const Text(
                        '📊 Evolución Mensual',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildMonthlyEvolutionChart(),
                    ],
                  ),
                ),
    );
  }
}
