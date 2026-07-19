import 'package:flutter/material.dart';
import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/presentation/screens/income_create_screen.dart';
import 'package:finanzas_app_mobile/presentation/screens/expense_list_screen.dart';
import 'package:finanzas_app_mobile/presentation/screens/income_list_screen.dart';

class MovementsScreen extends StatefulWidget {
  const MovementsScreen({super.key});

  @override
  State<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends State<MovementsScreen> {
  final searchController = TextEditingController();
  String searchQuery = '';
  String quickFilter = 'Todos';

  final GlobalKey _incomeListKey = GlobalKey();
  final GlobalKey _expenseListKey = GlobalKey();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
        },
        selectedColor: AppTheme.corporateGreen,
        backgroundColor: theme.cardColor,
        labelStyle: TextStyle(
          color: selected
              ? Colors.black
              : theme.colorScheme.onSurface.withValues(alpha: 0.75),
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Movimientos'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(146),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: [
                  TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() => searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar por nota, tipo, monto o fecha',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: searchQuery.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                searchController.clear();
                                setState(() => searchQuery = '');
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 38,
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
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TabBar(
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: AppTheme.corporateGreen,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(14),
                        ),
                      ),
                      labelColor: Colors.black,
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
          children: [
            IncomeListScreen(
              key: _incomeListKey,
              embeddedMode: true,
              searchQuery: searchQuery,
              quickFilter: quickFilter,
            ),
            ExpenseListScreen(
              key: _expenseListKey,
              embeddedMode: true,
              searchQuery: searchQuery,
              quickFilter: quickFilter,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showMovementActionsSheet,
          backgroundColor: AppTheme.corporateGreen,
          foregroundColor: Colors.black,
          elevation: 6,
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }
}
