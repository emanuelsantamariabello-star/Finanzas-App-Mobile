import 'package:finanzas_app_mobile/core/motion/app_page_route.dart';
import 'package:finanzas_app_mobile/core/network/api_exception.dart';
import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/data/services/notification_service.dart';
import 'package:finanzas_app_mobile/data/services/session_storage_service.dart';
import 'package:finanzas_app_mobile/data/services/user_scoped_storage_service.dart';
import 'package:finanzas_app_mobile/data/services/user_service.dart';
import 'package:finanzas_app_mobile/presentation/screens/login_screen.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_confirmation_dialog.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_form_components.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';

class PrivacyAndDataScreen extends StatefulWidget {
  const PrivacyAndDataScreen({super.key});

  @override
  State<PrivacyAndDataScreen> createState() => _PrivacyAndDataScreenState();
}

class _PrivacyAndDataScreenState extends State<PrivacyAndDataScreen> {
  static const String _confirmationText = 'ELIMINAR';

  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  final _sessionStorage = SessionStorageService();
  bool _showPassword = false;
  bool _deleting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (_deleting || !(_formKey.currentState?.validate() ?? false)) return;

    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Eliminar cuenta definitivamente',
      message:
          'Se eliminarán tu perfil, movimientos y datos financieros. Esta acción no se puede deshacer.',
      confirmLabel: 'Eliminar cuenta',
      icon: Icons.delete_forever_rounded,
    );
    if (!confirmed || !mounted) return;

    setState(() => _deleting = true);
    try {
      final response = await UserService.deleteAccount(
        currentPassword: _passwordController.text,
      );
      if (!mounted) return;

      if (response['success'] != true) {
        AppSnackbar.error(
          context,
          response['message']?.toString() ?? 'No se pudo eliminar la cuenta',
        );
        return;
      }

      await _clearLocalAccountData();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        AppPageRoute.build(context, builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.error(
        context,
        apiErrorMessage(error, fallback: 'No se pudo eliminar la cuenta'),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _clearLocalAccountData() async {
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();
      await notificationService.cancelAllReminders();
    } catch (_) {}

    try {
      await UserScopedStorageService.clearCurrentUserData();
    } catch (_) {}

    try {
      await _sessionStorage.clearDeletedAccountData();
    } catch (_) {}
  }

  Widget _informationItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.corporateGreen, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacidad y datos')),
      body: AppFormScrollView(
        includeKeyboardInset: true,
        includeBottomSafeInset: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Control de tus datos',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Consulta qué información utiliza Finanzas App y administra el ciclo de tu cuenta.',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            AppSurfaceCard(
              child: Column(
                children: [
                  _informationItem(
                    context,
                    icon: Icons.person_outline_rounded,
                    title: 'Datos de perfil',
                    description: 'Nombre, correo, ocupación y foto de perfil.',
                  ),
                  _informationItem(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Información financiera',
                    description:
                        'Ingresos, gastos y datos necesarios para mostrar tus resúmenes.',
                  ),
                  _informationItem(
                    context,
                    icon: Icons.phone_android_rounded,
                    title: 'Datos guardados en el dispositivo',
                    description:
                        'Recordatorios, metas, presupuestos, filtros y preferencias.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Eliminar mi cuenta',
              style: TextStyle(
                color: AppTheme.corporateRed,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'La eliminación borra tu perfil, movimientos, sesiones, foto y datos locales asociados. Los respaldos técnicos se depuran según su periodo de retención.',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    enableSuggestions: false,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    decoration: AppFormDecoration.input(
                      context: context,
                      label: 'Contraseña actual',
                      icon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Ingresa tu contraseña actual'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmationController,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.done,
                    decoration: AppFormDecoration.input(
                      context: context,
                      label: 'Escribe $_confirmationText para confirmar',
                      icon: Icons.warning_amber_rounded,
                    ),
                    validator: (value) =>
                        value?.trim().toUpperCase() != _confirmationText
                        ? 'Escribe $_confirmationText para continuar'
                        : null,
                    onFieldSubmitted: (_) => _deleteAccount(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: _deleting ? null : _deleteAccount,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.corporateRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: _deleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.delete_forever_rounded),
                label: Text(_deleting ? 'Eliminando…' : 'Eliminar mi cuenta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
