import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/presentation/screens/change_password_screen.dart';
import 'package:finanzas_app_mobile/presentation/screens/edit_profile_screen.dart';
import 'package:finanzas_app_mobile/presentation/screens/login_screen.dart';
import 'package:finanzas_app_mobile/providers/dashboard_provider.dart';
import 'package:finanzas_app_mobile/providers/theme_provider.dart';

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
    if (!mounted) return;
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

  Future<void> _openThemeSelector() async {
    final themeProvider = context.read<ThemeProvider>();
    final currentMode = themeProvider.themeMode;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(sheetContext).dividerColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Tema',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(sheetContext).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Selecciona el aspecto visual de la app.',
                style: TextStyle(
                  color: Theme.of(sheetContext).colorScheme.onSurface.withOpacity(0.72),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              _buildThemeOption(
                context: sheetContext,
                label: 'Claro',
                icon: Icons.wb_sunny_outlined,
                isSelected: currentMode == ThemeMode.light,
                onTap: () async {
                  await themeProvider.setThemeMode(ThemeMode.light);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
              const SizedBox(height: 10),
              _buildThemeOption(
                context: sheetContext,
                label: 'Oscuro',
                icon: Icons.nightlight_round,
                isSelected: currentMode == ThemeMode.dark,
                onTap: () async {
                  await themeProvider.setThemeMode(ThemeMode.dark);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
              const SizedBox(height: 10),
              _buildThemeOption(
                context: sheetContext,
                label: 'Sistema',
                icon: Icons.settings_outlined,
                isSelected: currentMode == ThemeMode.system,
                onTap: () async {
                  await themeProvider.setThemeMode(ThemeMode.system);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Cerrar sesión',
          style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
        ),
        content: Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          style: TextStyle(
            color: Theme.of(ctx).colorScheme.onSurface.withOpacity(0.72),
          ),
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

  Widget _buildUserHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppTheme.corporateGreen, Color(0xFF00E676)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.corporateGreen.withOpacity(0.3),
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
          Text(
            _userName.isNotEmpty ? _userName : 'Usuario',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userEmail.isNotEmpty ? _userEmail : '—',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.55),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary(BuildContext context, Map<String, dynamic> dashboardData) {
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
            'Resumen financiero',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildFinancialRow(
            context,
            icon: Icons.arrow_downward_rounded,
            color: AppTheme.corporateGreen,
            label: 'Total ingresos',
            value: dashboardData['total_income'],
          ),
          const Divider(height: 24),
          _buildFinancialRow(
            context,
            icon: Icons.arrow_upward_rounded,
            color: AppTheme.corporateRed,
            label: 'Total gastos',
            value: dashboardData['total_expense'],
          ),
          const Divider(height: 24),
          _buildFinancialRow(
            context,
            icon: Icons.account_balance_wallet_rounded,
            color: AppTheme.corporateBlue,
            label: 'Balance',
            value: dashboardData['balance'],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required dynamic value,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.75),
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

  Widget _buildActionsSection(BuildContext context) {
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
            'Configuración',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context,
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
          Divider(color: theme.dividerColor.withOpacity(0.5), height: 4),
          _buildActionTile(
            context,
            icon: Icons.palette_outlined,
            label: 'Tema',
            subtitle: 'Claro, oscuro o sistema',
            onTap: _openThemeSelector,
          ),
          Divider(color: theme.dividerColor.withOpacity(0.5), height: 4),
          _buildActionTile(
            context,
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
          Divider(color: theme.dividerColor.withOpacity(0.5), height: 4),
          _buildActionTile(
            context,
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

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final tileColor = color ?? theme.colorScheme.onSurface;
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
                color: tileColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: tileColor.withOpacity(0.8), size: 20),
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
                      color: tileColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: tileColor.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurface.withOpacity(0.35),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.corporateGreen.withOpacity(0.12)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.corporateGreen : theme.dividerColor.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.corporateGreen.withOpacity(0.18)
                    : theme.dividerColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.corporateGreen : theme.colorScheme.onSurface.withOpacity(0.75),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.corporateGreen,
                size: 20,
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
            _buildUserHeader(context),
            const SizedBox(height: 16),
            _buildFinancialSummary(context, dashboardData),
            const SizedBox(height: 16),
            _buildActionsSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
