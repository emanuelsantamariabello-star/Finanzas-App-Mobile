import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finanzas_app_mobile/data/services/income_service.dart';
import 'package:finanzas_app_mobile/providers/dashboard_provider.dart';
import 'income_create_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_snackbar.dart';

class IncomeListScreen extends StatefulWidget {
  final bool embeddedMode;
  final String searchQuery;
  final String quickFilter;

  const IncomeListScreen({
    super.key,
    this.embeddedMode = false,
    this.searchQuery = '',
    this.quickFilter = 'Todos',
  });

  @override
  State<IncomeListScreen> createState() => _IncomeListScreenState();
}

class _IncomeListScreenState extends State<IncomeListScreen> {
  List incomes = [];
  bool isLoading = true;
  String? error;
  DateTime? startDate;
  DateTime? endDate;

  final currency = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '',
    decimalDigits: 0,
  );
  final dateFormatter = DateFormat('dd/MM/yyyy');

  String formatAmount(dynamic amount) {
    final value = double.tryParse(amount.toString()) ?? 0;
    final formatted = currency.format(value).replaceAll('\$', '').trim();
    return '\$ $formatted';
  }

  String formatDate(dynamic rawDate) {
    final value = rawDate?.toString().trim() ?? '';
    if (value.isEmpty) return 'Sin fecha';

    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;

    return dateFormatter.format(parsed);
  }

  DateTime? _extractDate(Map income) {
    final rawDate = income['income_date'] ?? income['date'];
    final value = rawDate?.toString().trim() ?? '';
    if (value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  bool _matchesQuickFilter(Map income) {
    if (widget.quickFilter == 'Todos') return true;

    final date = _extractDate(income);
    if (date == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDay = DateTime(date.year, date.month, date.day);

    switch (widget.quickFilter) {
      case 'Hoy':
        return itemDay == today;
      case 'Semana':
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return !itemDay.isBefore(weekStart) && !itemDay.isAfter(weekEnd);
      case 'Mes':
        return itemDay.year == now.year && itemDay.month == now.month;
      default:
        return true;
    }
  }

  bool _matchesSearch(Map income) {
    final query = widget.searchQuery.trim().toLowerCase();
    if (query.isEmpty) return true;

    final note = (income['note'] ?? '').toString().toLowerCase();
    final type = (income['type'] ?? '').toString().toLowerCase();
    final amount = (income['amount'] ?? '').toString().toLowerCase();
    final formattedDate = formatDate(
      income['income_date'] ?? income['date'],
    ).toLowerCase();

    return note.contains(query) ||
        type.contains(query) ||
        amount.contains(query) ||
        formattedDate.contains(query);
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = const Color(0xFF4CAF50),
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 38,
                color: iconColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white54,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatApiDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _formatRangeLabel() {
    if (startDate == null || endDate == null) return '';
    return "${dateFormatter.format(startDate!)} - ${dateFormatter.format(endDate!)}";
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      loadIncomes();
    }
  }

  @override
  void initState() {
    super.initState();
    loadIncomes();
  }

  void loadIncomes() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      setState(() {
        isLoading = false;
        error = "Usuario no encontrado";
      });
      return;
    }

    try {
      final response = await IncomeService.getIncomes(
        userId,
        startDate: startDate != null ? _formatApiDate(startDate!) : null,
        endDate: endDate != null ? _formatApiDate(endDate!) : null,
      );

      if (response['success']) {
        setState(() {
          incomes = response['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          error = response['message'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> openCreateIncome({Map<String, dynamic>? income}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => IncomeCreateScreen(income: income)),
    );

    if (result == true) {
      loadIncomes();
    }
  }

  Future<void> deleteIncome(int incomeId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),

        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 32,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "Eliminar ingreso",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),

        content: const Text(
          "Esta acción eliminará el movimiento permanentemente.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, height: 1.4),
        ),

        actionsAlignment: MainAxisAlignment.spaceEvenly,

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancelar",
              style: TextStyle(
                color: const Color(0xFF00E676),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),

            onPressed: () => Navigator.pop(context, true),

            child: const Text(
              "Eliminar",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await IncomeService.deleteIncome(
        id: incomeId,
        userId: userId,
      );

      if (response['success']) {
        AppSnackbar.success(context, 'Ingreso eliminado');

        if (mounted) {
          context.read<DashboardProvider>().refreshDashboard(userId);
        }
        loadIncomes();
      } else {
        AppSnackbar.error(
          context,
          response['message']?.toString() ?? 'No se pudo eliminar el ingreso',
        );
      }
    } catch (e) {
      AppSnackbar.error(context, 'Error al eliminar el ingreso');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredIncomes = incomes.where((income) {
      return _matchesQuickFilter(income) && _matchesSearch(income);
    }).toList();

    return Scaffold(
      appBar: widget.embeddedMode
          ? null
          : AppBar(title: const Text("Ingresos")),

      // 🔥 BOTÓN FLOTANTE
      floatingActionButton: widget.embeddedMode
          ? null
          : FloatingActionButton(
              onPressed: openCreateIncome,
              child: const Icon(Icons.add),
            ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text("Error: $error"))
          : incomes.isEmpty
          ? _buildEmptyState(
              icon: Icons.trending_up_rounded,
              title: 'Aún no tienes ingresos',
              subtitle:
                  'Agrega tu primer ingreso para ver aquí\ntu historial y tu progreso financiero.',
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (!widget.embeddedMode) ...[
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _pickDateRange,
                          child: const Text("Filtrar por fecha"),
                        ),
                        const SizedBox(width: 8),
                        if (startDate != null && endDate != null)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                startDate = null;
                                endDate = null;
                              });
                              loadIncomes();
                            },
                            child: const Text("Limpiar filtro"),
                          ),
                      ],
                    ),

                    if (startDate != null && endDate != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _formatRangeLabel(),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],

                    const SizedBox(height: 8),
                  ],

                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: filteredIncomes.isEmpty
                          ? _buildEmptyState(
                              icon: Icons.search_off_rounded,
                              title: 'Sin resultados',
                              subtitle:
                                  'No se encontraron ingresos\ncon los filtros seleccionados.',
                              iconColor: Colors.white70,
                            )
                          : ListView.builder(
                              key: ValueKey(
                                '${widget.searchQuery}-${widget.quickFilter}-${filteredIncomes.length}',
                              ),
                              itemCount: filteredIncomes.length,
                              itemBuilder: (context, index) {
                                final income = filteredIncomes[index];

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                  child: ListTile(
                                    title: Text(
                                      income['type'].toString().toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "${income['note'] ?? ''}\n${formatDate(income['income_date'] ?? income['date'])}",
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          formatAmount(income['amount']),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),

                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () async {
                                            await openCreateIncome(
                                              income: income,
                                            );
                                          },
                                        ),

                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () =>
                                              deleteIncome(income['id']),
                                        ),
                                      ],
                                    ),
                                    isThreeLine: true,
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
