import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/presentation/screens/login_screen.dart';
import 'package:finanzas_app_mobile/providers/dashboard_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String name = '';
  final currency = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  int? userId;

  void loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getInt('userId');

    setState(() {
      name = prefs.getString('userName') ?? '';
      userId = storedUserId;
    });

    if (storedUserId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<DashboardProvider>().refreshDashboard(storedUserId);
      });
    }
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();

    const keysToRemove = [
      'isLoggedIn',
      'userEmail',
      'userName',
      'userId',
      'occupation',
      'userOccupation',
    ];

    for (final key in keysToRemove) {
      await prefs.remove(key);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  String formatAmount(dynamic amount) {
    final value = double.tryParse(amount.toString()) ?? 0;
    final formatted = currency.format(value).replaceAll('\$', '').trim();
    return '\$ $formatted';
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required dynamic amount,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.75),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatAmount(amount),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    BuildContext context, {
    required String label,
    required dynamic value,
    required IconData icon,
    required Color accentColor,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accentColor.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1,
                letterSpacing: 0.2,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withOpacity(0.75),
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.55),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildDashboardEmptyBanner(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.corporateGreen.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.rocket_launch_rounded,
              color: AppTheme.corporateGreen,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu dashboard está listo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Aún no hay movimientos. Registra tu primer ingreso o gasto para empezar a ver estadísticas y balance.',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withOpacity(0.72),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final dashboardData = dashboardProvider.data;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanzas App'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
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
                        'Bienvenido $name',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Así se mueve tu dinero hoy',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.72),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if ((dashboardData['income_count'] ?? 0) == 0 &&
                          (dashboardData['expense_count'] ?? 0) == 0) ...[
                        _buildDashboardEmptyBanner(context),
                        const SizedBox(height: 12),
                      ],
                      _buildSummaryCard(
                        context,
                        title: 'Total ingresos',
                        amount: dashboardData['total_income'],
                        color: Colors.green,
                        icon: Icons.arrow_downward_rounded,
                      ),
                      _buildSummaryCard(
                        context,
                        title: 'Total gastos',
                        amount: dashboardData['total_expense'],
                        color: Colors.red,
                        icon: Icons.arrow_upward_rounded,
                      ),
                      _buildSummaryCard(
                        context,
                        title: 'Balance',
                        amount: dashboardData['balance'],
                        color: Colors.blue,
                        icon: Icons.account_balance_wallet_rounded,
                      ),
                      const SizedBox(height: 10),
                      _buildSectionCard(
                        context,
                        title: 'Resumen del mes',
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.green.withOpacity(0.22),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(
                                                0.16,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.arrow_downward_rounded,
                                              color: Colors.green,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Ingresos del mes',
                                              style: TextStyle(
                                                color: theme.colorScheme.onSurface.withOpacity(0.75),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        formatAmount(
                                          dashboardData['month_income'],
                                        ),
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.22),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(
                                                0.16,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.arrow_upward_rounded,
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Gastos del mes',
                                              style: TextStyle(
                                                color: theme.colorScheme.onSurface.withOpacity(0.75),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        formatAmount(
                                          dashboardData['month_expense'],
                                        ),
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildMiniStat(
                            context,
                            label: 'Cantidad de ingresos',
                            value: dashboardData['income_count'] ?? 0,
                            icon: Icons.trending_up_rounded,
                            accentColor: Colors.green,
                            description: 'Ingresos registrados',
                          ),
                          const SizedBox(width: 12),
                          _buildMiniStat(
                            context,
                            label: 'Cantidad de gastos',
                            value: dashboardData['expense_count'] ?? 0,
                            icon: Icons.trending_down_rounded,
                            accentColor: Colors.red,
                            description: 'Gastos registrados',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}
