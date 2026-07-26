import 'package:flutter/material.dart';
import 'package:finanzas_app_mobile/core/constants/session_keys.dart';
import 'package:finanzas_app_mobile/core/network/api_exception.dart';
import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finanzas_app_mobile/data/services/expense_service.dart';
import 'package:finanzas_app_mobile/providers/dashboard_provider.dart';
import 'expense_create_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_confirmation_dialog.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_snackbar.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_state_widgets.dart';

class ExpenseListScreen extends StatefulWidget {
  final bool embeddedMode;
  final String searchQuery;
  final String quickFilter;
  final DateTime? startDate;
  final DateTime? endDate;

  const ExpenseListScreen({
    super.key,
    this.embeddedMode = false,
    this.searchQuery = '',
    this.quickFilter = 'Todos',
    this.startDate,
    this.endDate,
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

  List<Map<String, dynamic>> _getFilteredExpenses() {
    return expenses
        .where((expense) {
          return _matchesQuickFilter(expense) && _matchesSearch(expense);
        })
        .cast<Map<String, dynamic>>()
        .toList();
  }

  List<List<String>> getExportRows() {
    return _getFilteredExpenses().map((expense) {
      return [
        (expense['type'] ?? 'Gasto').toString(),
        (expense['note'] ?? 'Sin nota').toString(),
        formatDate(expense['expense_date']),
        formatAmount(expense['amount']),
      ];
    }).toList();
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
    startDate = widget.startDate;
    endDate = widget.endDate;
    loadExpenses();
  }

  @override
  void didUpdateWidget(covariant ExpenseListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final dateRangeChanged =
        oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate;

    if (dateRangeChanged) {
      startDate = widget.startDate;
      endDate = widget.endDate;
      isLoading = true;
      loadExpenses();
    }
  }

  void loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(SessionKeys.userId);

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
    final userId = prefs.getInt(SessionKeys.userId);

    if (userId == null) return;

    if (!mounted) return;

    final confirm = await showAppConfirmationDialog(
      context,
      title: 'Eliminar gasto',
      message: 'Esta acción eliminará el movimiento permanentemente.',
      confirmLabel: 'Eliminar',
      icon: Icons.delete_outline_rounded,
    );

    if (!confirm) return;

    try {
      final response = await ExpenseService.deleteExpense(
        id: expenseId,
        userId: userId,
      );

      if (!mounted) return;

      if (response['success']) {
        AppSnackbar.success(context, 'Gasto eliminado');
        context.read<DashboardProvider>().refreshDashboard(userId);
        loadExpenses();
      } else {
        AppSnackbar.error(
          context,
          response['message']?.toString() ?? 'No se pudo eliminar el gasto',
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(
        context,
        apiErrorMessage(e, fallback: 'Error al eliminar el gasto'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = _getFilteredExpenses();
    final theme = Theme.of(context);
    final secondaryTextColor = theme.colorScheme.onSurface.withValues(
      alpha: 0.72,
    );
    final tertiaryTextColor = theme.colorScheme.onSurface.withValues(
      alpha: 0.55,
    );

    return Scaffold(
      appBar: widget.embeddedMode ? null : AppBar(title: const Text("Gastos")),

      floatingActionButton: widget.embeddedMode
          ? null
          : FloatingActionButton(
              onPressed: openCreateExpense,
              child: const Icon(Icons.add),
            ),

      body: isLoading
          ? const AppLoadingState(message: 'Cargando gastos…')
          : error != null
          ? AppErrorState(message: error!, onRetry: loadExpenses)
          : expenses.isEmpty
          ? AppEmptyState(
              icon: Icons.trending_down_rounded,
              title: 'A\u00fan no tienes gastos',
              message:
                  'Registra tu primer gasto para entender\nmejor en qu\u00e9 se va tu dinero.',
              accentColor: AppTheme.corporateRed,
              actionLabel: 'Agregar gasto',
              onAction: openCreateExpense,
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
                        style: TextStyle(color: secondaryTextColor),
                      ),
                    ],

                    const SizedBox(height: 8),
                  ],

                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: filteredExpenses.isEmpty
                          ? const AppEmptyState(
                              icon: Icons.search_off_rounded,
                              title: 'Sin resultados',
                              message:
                                  'No se encontraron gastos\ncon los filtros seleccionados.',
                              compact: true,
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (expense['type'] ?? 'Gasto')
                                              .toString()
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          (expense['note'] ?? 'Sin descripción')
                                              .toString(),
                                          style: TextStyle(
                                            color: secondaryTextColor,
                                            height: 1.35,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today_outlined,
                                              size: 14,
                                              color: tertiaryTextColor,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              formatDate(
                                                expense['expense_date'],
                                              ),
                                              style: TextStyle(
                                                color: tertiaryTextColor,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              formatAmount(expense['amount']),
                                              style: const TextStyle(
                                                color: AppTheme.corporateRed,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 19,
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    color:
                                                        AppTheme.corporateBlue,
                                                  ),
                                                  iconSize: 20,
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(
                                                        minWidth: 36,
                                                        minHeight: 36,
                                                      ),
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  onPressed: () async {
                                                    await openCreateExpense(
                                                      expense: expense,
                                                    );
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color:
                                                        AppTheme.corporateRed,
                                                  ),
                                                  iconSize: 20,
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(
                                                        minWidth: 36,
                                                        minHeight: 36,
                                                      ),
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  onPressed: () =>
                                                      deleteExpense(
                                                        expense['id'],
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
