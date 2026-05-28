import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finanzas_app_mobile/presentation/screens/edit_profile_screen.dart';
import 'package:finanzas_app_mobile/presentation/screens/change_password_screen.dart';
import 'package:finanzas_app_mobile/presentation/screens/login_screen.dart';
import 'package:finanzas_app_mobile/providers/dashboard_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static final _currency = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '',
    decimalDigits: 0,
  );

  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? '';
      _userEmail = prefs.getString('userEmail') ?? '';
    });
  }

  String _formatAmount(dynamic amount) {
    final value = double.tryParse(amount.toString()) ?? 0;
    final formatted = _currency.format(value).replaceAll('\$', '').trim();
    return '\$ $formatted';
  }

  String _userInitial() {
    if (_userName.isNotEmpty) return _userName[0].toUpperCase();
    if (_userEmail.isNotEmpty) return _userEmail[0].toUpperCase();
    return '?';
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Cerrar sesión'),
        content: const Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

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

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  // ── Header del usuario ──
  Widget _buildUserHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          // Avatar con inicial
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF00E676)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00C853).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _userInitial(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Nombre
          Text(
            _userName.isNotEmpty ? _userName : 'Usuario',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          // Email
          Text(
            _userEmail.isNotEmpty ? _userEmail : '—',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white54,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Resumen financiero ──
  Widget _buildFinancialSummary(Map<String, dynamic> dashboardData) {
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
          const Text(
            'Resumen financiero',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildFinancialRow(
            icon: Icons.arrow_downward_rounded,
            color: const Color(0xFF4CAF50),
            label: 'Total ingresos',
            value: dashboardData['total_income'],
          ),
          const Divider(color: Colors.white10, height: 24),
          _buildFinancialRow(
            icon: Icons.arrow_upward_rounded,
            color: const Color(0xFFEF5350),
            label: 'Total gastos',
            value: dashboardData['total_expense'],
          ),
          const Divider(color: Colors.white10, height: 24),
          _buildFinancialRow(
            icon: Icons.account_balance_wallet_rounded,
            color: const Color(0xFF42A5F5),
            label: 'Balance',
            value: dashboardData['balance'],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow({
    required IconData icon,
    required Color color,
    required String label,
    required dynamic value,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          _formatAmount(value),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // ── Sección de acciones ──
  Widget _buildActionsSection() {
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
          const Text(
            'Configuración',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            icon: Icons.person_outline_rounded,
            label: 'Editar perfil',
            subtitle: 'Nombre, email y más',
            onTap: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );

              if (updated == true) {
                await _loadUserData();
              }
            },
          ),
          const Divider(color: Colors.white10, height: 4),
          _buildActionTile(
            icon: Icons.lock_outline_rounded,
            label: 'Cambiar contraseña',
            subtitle: 'Actualiza tu contraseña',
            onTap: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );

              if (!mounted) return;
              if (updated == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contraseña actualizada'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          const Divider(color: Colors.white10, height: 4),
          _buildActionTile(
            icon: Icons.logout_rounded,
            label: 'Cerrar sesión',
            subtitle: 'Salir de tu cuenta',
            color: Colors.redAccent,
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color.withValues(alpha: 0.8), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: color.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: color.withValues(alpha: 0.4),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final dashboardData = dashboardProvider.data;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildUserHeader(),
            const SizedBox(height: 16),
            _buildFinancialSummary(dashboardData),
            const SizedBox(height: 16),
            _buildActionsSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
