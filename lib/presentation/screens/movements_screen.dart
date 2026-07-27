import 'dart:io';

import 'package:flutter/material.dart';
import 'package:finanzas_app_mobile/core/constants/session_keys.dart';
import 'package:finanzas_app_mobile/core/network/api_exception.dart';
import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/data/models/financial_report_period.dart';
import 'package:finanzas_app_mobile/data/services/financial_report_data_service.dart';
import 'package:finanzas_app_mobile/data/services/financial_report_pdf_service.dart';
import 'package:finanzas_app_mobile/data/services/movement_export_service.dart';
import 'package:finanzas_app_mobile/data/services/movement_filter_preferences_service.dart';
import 'package:finanzas_app_mobile/presentation/screens/income_create_screen.dart';
import 'package:finanzas_app_mobile/presentation/screens/expense_list_screen.dart';
import 'package:finanzas_app_mobile/presentation/screens/income_list_screen.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_pressable.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_snackbar.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_state_widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MovementsScreen extends StatefulWidget {
  const MovementsScreen({super.key});

  @override
  State<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends State<MovementsScreen>
    with SingleTickerProviderStateMixin {
  final _preferencesService = MovementFilterPreferencesService();
  final _exportService = MovementExportService();
  final _reportDataService = FinancialReportDataService();
  final _pdfReportService = FinancialReportPdfService();
  final searchController = TextEditingController();
  String searchQuery = '';
  String quickFilter = 'Todos';
  int currentTabIndex = 0;
  DateTime? incomeStartDate;
  DateTime? incomeEndDate;
  DateTime? expenseStartDate;
  DateTime? expenseEndDate;
  bool _isExportingPdf = false;

  final GlobalKey _incomeListKey = GlobalKey();
  final GlobalKey _expenseListKey = GlobalKey();
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _ensureTabController();
    _loadSavedFilters();
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabChange);
    _tabController?.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _ensureTabController() {
    if (_tabController != null) return;

    final controller = TabController(length: 2, vsync: this);
    controller.addListener(_handleTabChange);
    _tabController = controller;
  }

  void _handleTabChange() {
    final controller = _tabController;
    if (controller == null || controller.indexIsChanging) return;
    if (currentTabIndex == controller.index) return;

    setState(() => currentTabIndex = controller.index);
    _saveFilters();
  }

  Future<void> _loadSavedFilters() async {
    final data = await _preferencesService.load();
    if (!mounted) return;

    final restoredTabIndex =
        int.tryParse(data['tabIndex']?.toString() ?? '') ?? 0;
    final safeTabIndex = restoredTabIndex.clamp(0, 1);

    setState(() {
      searchQuery = data['searchQuery']?.toString() ?? '';
      quickFilter = data['quickFilter']?.toString() ?? 'Todos';
      currentTabIndex = safeTabIndex;
      incomeStartDate = _parseDate(data['incomeStartDate']);
      incomeEndDate = _parseDate(data['incomeEndDate']);
      expenseStartDate = _parseDate(data['expenseStartDate']);
      expenseEndDate = _parseDate(data['expenseEndDate']);
      searchController.text = searchQuery;
    });

    _tabController?.index = safeTabIndex;
  }

  Future<void> _saveFilters() async {
    await _preferencesService.save({
      'searchQuery': searchQuery,
      'quickFilter': quickFilter,
      'tabIndex': currentTabIndex,
      'incomeStartDate': incomeStartDate?.toIso8601String(),
      'incomeEndDate': incomeEndDate?.toIso8601String(),
      'expenseStartDate': expenseStartDate?.toIso8601String(),
      'expenseEndDate': expenseEndDate?.toIso8601String(),
    });
  }

  DateTime? _parseDate(dynamic rawValue) {
    final value = rawValue?.toString().trim() ?? '';
    if (value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  String _formatRange(DateTime start, DateTime end) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(start.day)}/${two(start.month)}/${start.year} - ${two(end.day)}/${two(end.month)}/${end.year}';
  }

  ({DateTime? start, DateTime? end}) _currentRange() {
    if (currentTabIndex == 0) {
      return (start: incomeStartDate, end: incomeEndDate);
    }
    return (start: expenseStartDate, end: expenseEndDate);
  }

  bool get _hasActiveRange {
    final range = _currentRange();
    return range.start != null && range.end != null;
  }

  Widget _buildQuickFilterChip(BuildContext context, String label) {
    final theme = Theme.of(context);
    final selected = quickFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() => quickFilter = label);
          _saveFilters();
        },
        selectedColor: AppTheme.corporateGreen,
        backgroundColor: theme.cardColor,
        labelStyle: TextStyle(
          color: selected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface.withValues(alpha: 0.75),
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ).withPressFeedback(),
    );
  }

  Future<void> _openCreateIncome() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const IncomeCreateScreen()),
    );

    if (result == true) {
      final state = _incomeListKey.currentState;
      if (state != null) {
        await (state as dynamic).loadIncomes();
      }
    }
  }

  Future<void> _openCreateExpense() async {
    final state = _expenseListKey.currentState;
    if (state == null) return;
    await (state as dynamic).openCreateExpense();
  }

  Future<void> _showMovementActionsSheet() async {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        Widget buildActionTile({
          required String title,
          required String subtitle,
          required IconData icon,
          required Color accent,
          required VoidCallback onTap,
        }) {
          return ListTile(
            onTap: onTap,
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accent),
            ),
            title: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w700, color: onSurface),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(color: onSurface.withValues(alpha: 0.72)),
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: onSurface.withValues(alpha: 0.55),
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            6,
            16,
            16 + MediaQuery.viewPaddingOf(sheetContext).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Nuevo movimiento',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    buildActionTile(
                      title: 'Agregar ingreso',
                      subtitle: 'Registra una entrada de dinero',
                      icon: Icons.trending_up_rounded,
                      accent: AppTheme.corporateGreen,
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        await _openCreateIncome();
                      },
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: onSurface.withValues(alpha: 0.08),
                    ),
                    buildActionTile(
                      title: 'Agregar gasto',
                      subtitle: 'Registra una salida de dinero',
                      icon: Icons.trending_down_rounded,
                      accent: AppTheme.corporateRed,
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        await _openCreateExpense();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openAdvancedFilters() async {
    final now = DateTime.now();
    final currentRange = _currentRange();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: currentRange.start != null && currentRange.end != null
          ? DateTimeRange(start: currentRange.start!, end: currentRange.end!)
          : null,
      currentDate: now,
      helpText: currentTabIndex == 0
          ? 'Filtrar ingresos por fecha'
          : 'Filtrar gastos por fecha',
    );

    if (!mounted || picked == null) return;

    setState(() {
      if (currentTabIndex == 0) {
        incomeStartDate = picked.start;
        incomeEndDate = picked.end;
      } else {
        expenseStartDate = picked.start;
        expenseEndDate = picked.end;
      }
    });

    await _saveFilters();
  }

  Future<void> _clearAdvancedFilters() async {
    setState(() {
      if (currentTabIndex == 0) {
        incomeStartDate = null;
        incomeEndDate = null;
      } else {
        expenseStartDate = null;
        expenseEndDate = null;
      }
    });

    await _saveFilters();
  }

  Future<void> _showExportOptions() async {
    final theme = Theme.of(context);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          6,
          16,
          16 + MediaQuery.viewPaddingOf(sheetContext).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exportar movimientos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              onTap: () async {
                Navigator.pop(sheetContext);
                await _exportCurrentMovements();
              },
              leading: const Icon(
                Icons.table_view_outlined,
                color: AppTheme.corporateGreen,
              ),
              title: const Text('Archivo CSV'),
              subtitle: const Text('Exporta la pestaña y filtros visibles'),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
            ListTile(
              onTap: () async {
                Navigator.pop(sheetContext);
                await _showPdfPeriodOptions();
              },
              leading: const Icon(
                Icons.picture_as_pdf_outlined,
                color: AppTheme.corporateRed,
              ),
              title: const Text('Reporte financiero PDF'),
              subtitle: const Text('Incluye resumen, análisis y movimientos'),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPdfPeriodOptions() async {
    final now = DateTime.now();
    final theme = Theme.of(context);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        Widget periodTile({
          required String title,
          required String subtitle,
          required IconData icon,
          required Future<void> Function() onSelected,
        }) {
          return ListTile(
            leading: Icon(icon, color: AppTheme.corporateBlue),
            title: Text(title),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () async {
              Navigator.pop(sheetContext);
              await onSelected();
            },
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            6,
            16,
            16 + MediaQuery.viewPaddingOf(sheetContext).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Período del reporte',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              periodTile(
                title: 'Mes actual',
                subtitle: 'Desde el primer día del mes hasta hoy',
                icon: Icons.calendar_view_month_outlined,
                onSelected: () =>
                    _generatePdfReport(FinancialReportPeriod.currentMonth(now)),
              ),
              periodTile(
                title: 'Mes anterior',
                subtitle: 'Todo el mes calendario anterior',
                icon: Icons.history_rounded,
                onSelected: () => _generatePdfReport(
                  FinancialReportPeriod.previousMonth(now),
                ),
              ),
              periodTile(
                title: 'Personalizado',
                subtitle: 'Selecciona una fecha inicial y final',
                icon: Icons.date_range_outlined,
                onSelected: _selectCustomReportPeriod,
              ),
              periodTile(
                title: 'Historial completo',
                subtitle: 'Incluye todos los movimientos registrados',
                icon: Icons.all_inclusive_rounded,
                onSelected: () =>
                    _generatePdfReport(const FinancialReportPeriod.history()),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectCustomReportPeriod() async {
    if (!mounted) return;

    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      currentDate: now,
      initialDateRange: DateTimeRange(
        start: DateTime(now.year, now.month),
        end: DateTime(now.year, now.month, now.day),
      ),
      helpText: 'Período personalizado del reporte',
    );

    if (!mounted || range == null) return;
    await _generatePdfReport(
      FinancialReportPeriod.custom(range.start, range.end),
    );
  }

  Future<void> _generatePdfReport(FinancialReportPeriod period) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(SessionKeys.userId);

    if (!mounted) return;
    if (userId == null) {
      AppSnackbar.error(context, 'Usuario no identificado');
      return;
    }

    setState(() => _isExportingPdf = true);

    try {
      final report = await _reportDataService.loadReport(
        userId: userId,
        userName: prefs.getString(SessionKeys.userName) ?? 'Usuario',
        period: period,
      );
      final file = await _pdfReportService.createPdfFile(report: report);

      if (!mounted) return;
      AppSnackbar.success(context, 'Reporte PDF generado correctamente');

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Reporte generado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.movements.isEmpty
                    ? 'El reporte no contiene movimientos para el período seleccionado.'
                    : 'El reporte incluye ${report.movements.length} movimientos.',
              ),
              const SizedBox(height: 12),
              SelectableText(file.path),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cerrar'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                _sharePdfReport(file);
              },
              icon: const Icon(Icons.share_outlined),
              label: const Text('Compartir PDF'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.error(
        context,
        apiErrorMessage(error, fallback: 'No se pudo generar el reporte PDF'),
      );
    } finally {
      if (mounted) setState(() => _isExportingPdf = false);
    }
  }

  Future<void> _sharePdfReport(File file) async {
    try {
      final result = await _pdfReportService.sharePdf(file);

      if (!mounted) return;
      if (result.status == ShareResultStatus.unavailable) {
        AppSnackbar.info(
          context,
          'No hay aplicaciones disponibles para compartir el reporte',
        );
      }
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.error(context, 'No se pudo compartir el reporte PDF');
    }
  }

  Future<void> _exportCurrentMovements() async {
    try {
      final isIncomeTab = currentTabIndex == 0;
      final state = isIncomeTab
          ? _incomeListKey.currentState
          : _expenseListKey.currentState;

      if (state == null) {
        AppSnackbar.info(context, 'Aún no hay datos listos para exportar');
        return;
      }

      final rows = (state as dynamic).getExportRows() as List<List<String>>;
      if (rows.isEmpty) {
        AppSnackbar.info(
          context,
          isIncomeTab
              ? 'No hay ingresos filtrados para exportar'
              : 'No hay gastos filtrados para exportar',
        );
        return;
      }

      final filePath = await _exportService.exportCsv(
        filePrefix: isIncomeTab ? 'ingresos' : 'gastos',
        headers: const ['Tipo', 'Nota', 'Fecha', 'Monto'],
        rows: rows,
      );

      if (!mounted) return;

      AppSnackbar.success(context, 'CSV exportado correctamente');

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Archivo exportado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'El archivo CSV se generó correctamente. Puedes compartirlo '
                'o guardarlo desde otra aplicación.',
              ),
              const SizedBox(height: 12),
              SelectableText(filePath),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cerrar'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                _shareExportedFile(filePath);
              },
              icon: const Icon(Icons.share_outlined),
              label: const Text('Compartir CSV'),
            ),
          ],
        ),
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.error(context, 'No se pudo exportar el archivo CSV');
    }
  }

  Future<void> _shareExportedFile(String filePath) async {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          subject: 'Movimientos exportados',
          text: 'Archivo CSV exportado desde Finanzas App',
        ),
      );

      if (!mounted) return;

      if (result.status == ShareResultStatus.unavailable) {
        AppSnackbar.info(
          context,
          'No hay aplicaciones disponibles para compartir el archivo',
        );
      }
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.error(context, 'No se pudo compartir el archivo CSV');
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensureTabController();
    final tabController = _tabController;
    final theme = Theme.of(context);
    final activeRange = _currentRange();
    final textScale = MediaQuery.textScalerOf(
      context,
    ).scale(1).clamp(1.0, 1.5).toDouble();
    final responsiveHeight = (textScale - 1) * 36;
    final appBarBottomHeight =
        (_hasActiveRange ? 234.0 : 188.0) + responsiveHeight;
    final quickFilterHeight = 38 + ((textScale - 1) * 18);

    if (tabController == null) {
      return const Scaffold(
        body: AppLoadingState(message: 'Preparando tus movimientos…'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimientos'),
        actions: [
          if (_isExportingPdf)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              onPressed: _showExportOptions,
              tooltip: 'Exportar movimientos',
              icon: const Icon(Icons.file_download_outlined),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(appBarBottomHeight),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() => searchQuery = value);
                          _saveFilters();
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar por nota, tipo, monto o fecha',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: searchQuery.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Limpiar búsqueda',
                                  onPressed: () {
                                    searchController.clear();
                                    setState(() => searchQuery = '');
                                    _saveFilters();
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: _hasActiveRange
                            ? AppTheme.corporateGreen.withValues(alpha: 0.12)
                            : theme.cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _hasActiveRange
                              ? AppTheme.corporateGreen.withValues(alpha: 0.30)
                              : theme.dividerColor.withValues(alpha: 0.45),
                        ),
                      ),
                      child: IconButton(
                        onPressed: _openAdvancedFilters,
                        icon: Icon(
                          Icons.tune_rounded,
                          color: _hasActiveRange
                              ? AppTheme.corporateGreen
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.75,
                                ),
                        ),
                        tooltip: 'Filtros avanzados',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: quickFilterHeight,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildQuickFilterChip(context, 'Todos'),
                      _buildQuickFilterChip(context, 'Hoy'),
                      _buildQuickFilterChip(context, 'Semana'),
                      _buildQuickFilterChip(context, 'Mes'),
                    ],
                  ),
                ),
                if (activeRange.start != null && activeRange.end != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.corporateGreen.withValues(
                              alpha: 0.10,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.date_range_rounded,
                                size: 16,
                                color: AppTheme.corporateGreen,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _formatRange(
                                    activeRange.start!,
                                    activeRange.end!,
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _clearAdvancedFilters,
                        child: const Text('Limpiar'),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: tabController,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: AppTheme.corporateGreen,
                      borderRadius: const BorderRadius.all(Radius.circular(14)),
                    ),
                    labelColor: theme.colorScheme.onPrimary,
                    unselectedLabelColor: theme.colorScheme.onSurface
                        .withValues(alpha: 0.75),
                    tabs: const [
                      Tab(text: 'Ingresos'),
                      Tab(text: 'Gastos'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          IncomeListScreen(
            key: _incomeListKey,
            embeddedMode: true,
            searchQuery: searchQuery,
            quickFilter: quickFilter,
            startDate: incomeStartDate,
            endDate: incomeEndDate,
          ),
          ExpenseListScreen(
            key: _expenseListKey,
            embeddedMode: true,
            searchQuery: searchQuery,
            quickFilter: quickFilter,
            startDate: expenseStartDate,
            endDate: expenseEndDate,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMovementActionsSheet,
        backgroundColor: AppTheme.corporateGreen,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 6,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
