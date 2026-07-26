import 'package:flutter/material.dart';
import 'package:finanzas_app_mobile/core/constants/session_keys.dart';
import 'package:finanzas_app_mobile/core/network/api_exception.dart';
import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finanzas_app_mobile/data/services/income_service.dart';
import 'package:finanzas_app_mobile/providers/dashboard_provider.dart';
import 'income_create_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_confirmation_dialog.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_snackbar.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_state_widgets.dart';

class IncomeListScreen extends StatefulWidget {
  final bool embeddedMode;
  final String searchQuery;
  final String quickFilter;
  final DateTime? startDate;
  final DateTime? endDate;

  const IncomeListScreen({
    super.key,
    this.embeddedMode = false,
    this.searchQuery = '',
    this.quickFilter = 'Todos',
    this.startDate,
    this.endDate,
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

  List<Map<String, dynamic>> _getFilteredIncomes() {
    return incomes
        .where((income) {
          return _matchesQuickFilter(income) && _matchesSearch(income);
        })
        .cast<Map<String, dynamic>>()
        .toList();
  }

  List<List<String>> getExportRows() {
    return _getFilteredIncomes().map((income) {
      return [
        (income['type'] ?? 'Ingreso').toString(),
        (income['note'] ?? 'Sin nota').toString(),
        formatDate(income['income_date'] ?? income['date']),
        formatAmount(income['amount']),
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
      loadIncomes();
    }
  }

  @override
  void initState() {
    super.initState();
    startDate = widget.startDate;
    endDate = widget.endDate;
    loadIncomes();
  }

  @override
  void didUpdateWidget(covariant IncomeListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final dateRangeChanged =
        oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate;

    if (dateRangeChanged) {
      startDate = widget.startDate;
      endDate = widget.endDate;
      isLoading = true;
      loadIncomes();
    }
  }

  void loadIncomes() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(SessionKeys.userId);

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
    final userId = prefs.getInt(SessionKeys.userId);

    if (userId == null) return;

    if (!mounted) return;

    final confirm = await showAppConfirmationDialog(
      context,
      title: 'Eliminar ingreso',
      message: 'Esta acción eliminará el movimiento permanentemente.',
      confirmLabel: 'Eliminar',
      icon: Icons.delete_outline_rounded,
    );

    if (!confirm) return;

    try {
      final response = await IncomeService.deleteIncome(
        id: incomeId,
        userId: userId,
      );

      if (!mounted) return;

      if (response['success']) {
        AppSnackbar.success(context, 'Ingreso eliminado');

        context.read<DashboardProvider>().refreshDashboard(userId);
        loadIncomes();
      } else {
        AppSnackbar.error(
          context,
          response['message']?.toString() ?? 'No se pudo eliminar el ingreso',
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(
        context,
        apiErrorMessage(e, fallback: 'Error al eliminar el ingreso'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredIncomes = _getFilteredIncomes();
    final theme = Theme.of(context);
    final secondaryTextColor = theme.colorScheme.onSurface.withValues(
      alpha: 0.72,
    );
    final tertiaryTextColor = theme.colorScheme.onSurface.withValues(
      alpha: 0.55,
    );

    return Scaffold(
      appBar: widget.embeddedMode
          ? null
          : AppBar(title: const Text("Ingresos")),

      // Boton flotante
      floatingActionButton: widget.embeddedMode
          ? null
          : FloatingActionButton(
              onPressed: openCreateIncome,
              child: const Icon(Icons.add),
            ),

      body: isLoading
          ? const AppLoadingState(message: 'Cargando ingresos…')
          : error != null
          ? AppErrorState(message: error!, onRetry: loadIncomes)
          : incomes.isEmpty
          ? AppEmptyState(
              icon: Icons.trending_up_rounded,
              title: 'A\u00fan no tienes ingresos',
              message:
                  'Agrega tu primer ingreso para ver aqu\u00ed tu historial y tu progreso financiero.',
              accentColor: AppTheme.corporateGreen,
              actionLabel: 'Agregar ingreso',
              onAction: openCreateIncome,
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
                        style: TextStyle(color: secondaryTextColor),
                      ),
                    ],

                    const SizedBox(height: 8),
                  ],

                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: filteredIncomes.isEmpty
                          ? const AppEmptyState(
                              icon: Icons.search_off_rounded,
                              title: 'Sin resultados',
                              message:
                                  'No se encontraron ingresos con los filtros seleccionados.',
                              compact: true,
                            )
                          : ListView.builder(
                              key: ValueKey(
                                '${widget.searchQuery}-${widget.quickFilter}-${filteredIncomes.length}',
                              ),
                              itemCount: filteredIncomes.length,
                              itemBuilder: (context, index) {
                                final income = filteredIncomes[index];
                                final type = (income['type'] ?? 'Ingreso')
                                    .toString()
                                    .toUpperCase();
                                final note = (income['note'] ?? 'Sin nota')
                                    .toString();
                                final amount = formatAmount(income['amount']);
                                final date = formatDate(
                                  income['income_date'] ?? income['date'],
                                );

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          type,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          note,
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
                                              date,
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
                                              amount,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.corporateGreen,
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
                                                    await openCreateIncome(
                                                      income: income,
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
                                                  onPressed: () => deleteIncome(
                                                    income['id'],
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
