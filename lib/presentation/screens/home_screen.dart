import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

    // Preserve "remember credentials" for LoginScreen.
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

  Widget _buildSummaryCard({
    required String title,
    required dynamic amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.35)),
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatAmount(amount),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, dynamic value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildDashboardEmptyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF00C853).withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.rocket_launch_rounded,
              color: Color(0xFF00C853),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu dashboard está listo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Aún no hay movimientos. Registra tu primer ingreso o gasto para empezar a ver estadísticas y balance.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
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
          ? Center(child: Text("Error: ${dashboardProvider.error}"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido $name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Así se mueve tu dinero hoy',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),

                  const SizedBox(height: 24),

                  if ((dashboardData['income_count'] ?? 0) == 0 &&
                      (dashboardData['expense_count'] ?? 0) == 0) ...[
                    _buildDashboardEmptyBanner(),
                    const SizedBox(height: 12),
                  ],

                  _buildSummaryCard(
                    title: "Total ingresos",
                    amount: dashboardData['total_income'],
                    color: Colors.green,
                    icon: Icons.arrow_downward_rounded,
                  ),
                  _buildSummaryCard(
                    title: "Total gastos",
                    amount: dashboardData['total_expense'],
                    color: Colors.red,
                    icon: Icons.arrow_upward_rounded,
                  ),
                  _buildSummaryCard(
                    title: "Balance",
                    amount: dashboardData['balance'],
                    color: Colors.blue,
                    icon: Icons.account_balance_wallet_rounded,
                  ),

                  const SizedBox(height: 10),

                  _buildSectionCard(
                    title: "Resumen del mes",
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Ingresos del mes',
                              style: TextStyle(
                                color: Colors.green.shade300,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            formatAmount(dashboardData['month_income']),
                            style: TextStyle(
                              color: Colors.green.shade300,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Gastos del mes',
                              style: TextStyle(
                                color: Colors.red.shade300,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            formatAmount(dashboardData['month_expense']),
                            style: TextStyle(
                              color: Colors.red.shade300,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
                        "Cantidad de ingresos",
                        dashboardData['income_count'] ?? 0,
                      ),
                      const SizedBox(width: 12),
                      _buildMiniStat(
                        "Cantidad de gastos",
                        dashboardData['expense_count'] ?? 0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
