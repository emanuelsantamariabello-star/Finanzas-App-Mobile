import 'package:flutter/material.dart';
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

  Widget _buildQuickFilterChip(String label) {
    final selected = quickFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() => quickFilter = label);
        },
        selectedColor: const Color(0xFF00C853),
        backgroundColor: const Color(0xFF161B22),
        labelStyle: TextStyle(
          color: selected ? Colors.black : Colors.white70,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _openCreateIncome() async {
    final state = _incomeListKey.currentState;
    if (state == null) return;
    await (state as dynamic).openCreateIncome();
  }

  Future<void> _openCreateExpense() async {
    final state = _expenseListKey.currentState;
    if (state == null) return;
    await (state as dynamic).openCreateExpense();
  }

  Future<void> _showMovementActionsSheet() async {
    final theme = Theme.of(context);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        final onSurface = theme.colorScheme.onSurface;

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
                color: accent.withOpacity(0.14),
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
              style: TextStyle(color: onSurface.withOpacity(0.72)),
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: onSurface.withOpacity(0.55),
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
                  ),
                ),
              ),
              const SizedBox(height: 10),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                    theme.brightness == Brightness.dark ? 0.35 : 1,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    buildActionTile(
                      title: 'Agregar ingreso',
                      subtitle: 'Registra una entrada de dinero',
                      icon: Icons.trending_up_rounded,
                      accent: const Color(0xFF00C853),
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        await _openCreateIncome();
                      },
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: onSurface.withOpacity(0.08),
                    ),
                    buildActionTile(
                      title: 'Agregar gasto',
                      subtitle: 'Registra una salida de dinero',
                      icon: Icons.trending_down_rounded,
                      accent: const Color(0xFFFF5252),
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
                        _buildQuickFilterChip('Todos'),
                        _buildQuickFilterChip('Hoy'),
                        _buildQuickFilterChip('Semana'),
                        _buildQuickFilterChip('Mes'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const TabBar(
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: Color(0xFF00C853),
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.white70,
                      tabs: [
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
          backgroundColor: const Color(0xFF00C853),
          foregroundColor: Colors.black,
          elevation: 6,
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }
}
