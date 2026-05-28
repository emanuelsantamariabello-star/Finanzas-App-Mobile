import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finanzas_app_mobile/data/services/expense_service.dart';
import 'package:finanzas_app_mobile/providers/dashboard_provider.dart';
import 'expense_create_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_snackbar.dart';

class ExpenseListScreen extends StatefulWidget {
  final bool embeddedMode;
  final String searchQuery;
  final String quickFilter;

  const ExpenseListScreen({
    super.key,
    this.embeddedMode = false,
    this.searchQuery = '',
    this.quickFilter = 'Todos',
  });

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List expenses = [];
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

  DateTime? _extractDate(Map expense) {
    final rawDate = expense['expense_date'];
    final value = rawDate?.toString().trim() ?? '';
    if (value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  bool _matchesQuickFilter(Map expense) {
    if (widget.quickFilter == 'Todos') return true;

    final date = _extractDate(expense);
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

  bool _matchesSearch(Map expense) {
    final query = widget.searchQuery.trim().toLowerCase();
    if (query.isEmpty) return true;

    final note = (expense['note'] ?? '').toString().toLowerCase();
    final type = (expense['type'] ?? 'gasto').toString().toLowerCase();
    final amount = (expense['amount'] ?? '').toString().toLowerCase();
    final formattedDate = formatDate(expense['expense_date']).toLowerCase();

    return note.contains(query) ||
        type.contains(query) ||
        amount.contains(query) ||
        formattedDate.contains(query);
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = const Color(0xFFEF5350),
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
      loadExpenses();
    }
  }

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  void loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      setState(() {
        error = "Usuario no encontrado";
        isLoading = false;
      });
      return;
    }

    try {
      final response = await ExpenseService.getExpenses(
        userId,
        startDate: startDate != null ? _formatApiDate(startDate!) : null,
        endDate: endDate != null ? _formatApiDate(endDate!) : null,
      );

      if (response['success']) {
        setState(() {
          expenses = response['data'];
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

  Future<void> openCreateExpense({Map<String, dynamic>? expense}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ExpenseCreateScreen(expense: expense)),
    );

    if (result == true) {
      loadExpenses();
    }
  }

  Future<void> deleteExpense(int expenseId) async {
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
              "Eliminar gasto",
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
      final response = await ExpenseService.deleteExpense(
        id: expenseId,
        userId: userId,
      );

      if (response['success']) {
        if (!mounted) return;
        AppSnackbar.success(context, 'Gasto eliminado');
        context.read<DashboardProvider>().refreshDashboard(userId);
        loadExpenses();
      } else {
        if (!mounted) return;
        AppSnackbar.error(
          context,
          response['message']?.toString() ?? 'No se pudo eliminar el gasto',
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Error al eliminar el gasto');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = expenses.where((expense) {
      return _matchesQuickFilter(expense) && _matchesSearch(expense);
    }).toList();

    return Scaffold(
      appBar: widget.embeddedMode ? null : AppBar(title: const Text("Gastos")),

      floatingActionButton: widget.embeddedMode
          ? null
          : FloatingActionButton(
              onPressed: openCreateExpense,
              child: const Icon(Icons.add),
            ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text("Error: $error"))
          : expenses.isEmpty
          ? _buildEmptyState(
              icon: Icons.trending_down_rounded,
              title: 'Aún no tienes gastos',
              subtitle:
                  'Registra tu primer gasto para entender\nmejor en qué se va tu dinero.',
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (!widget.embeddedMode) ...[
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
                              loadExpenses();
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
                      child: filteredExpenses.isEmpty
                          ? _buildEmptyState(
                              icon: Icons.search_off_rounded,
                              title: 'Sin resultados',
                              subtitle:
                                  'No se encontraron gastos\ncon los filtros seleccionados.',
                              iconColor: Colors.white70,
                            )
                          : ListView.builder(
                              key: ValueKey(
                                '${widget.searchQuery}-${widget.quickFilter}-${filteredExpenses.length}',
                              ),
                              itemCount: filteredExpenses.length,
                              itemBuilder: (context, index) {
                                final expense = filteredExpenses[index];

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    title: Text(expense['type'] ?? "Gasto"),
                                    subtitle: Text(
                                      "${expense['note'] ?? 'Sin descripción'}\n${formatDate(expense['expense_date'])}",
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          formatAmount(expense['amount']),
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () async {
                                            await openCreateExpense(
                                              expense: expense,
                                            );
                                          },
                                        ),

                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () =>
                                              deleteExpense(expense['id']),
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
