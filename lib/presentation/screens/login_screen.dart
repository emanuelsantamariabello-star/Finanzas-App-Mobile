import 'package:flutter/material.dart';
import 'package:finanzas_app_mobile/core/constants/session_keys.dart';
import 'package:finanzas_app_mobile/data/services/auth_service.dart';
import 'package:finanzas_app_mobile/data/services/session_storage_service.dart';
import 'package:finanzas_app_mobile/presentation/screens/main_navigation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finanzas_app_mobile/presentation/screens/register_screen.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_snackbar.dart';
import 'package:finanzas_app_mobile/providers/budget_provider.dart';
import 'package:finanzas_app_mobile/providers/goal_provider.dart';
import 'package:finanzas_app_mobile/providers/reminder_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _rememberCredentials = true;
  bool _showPassword = false;

  final SessionStorageService _sessionStorageService = SessionStorageService();

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(SessionKeys.rememberCredentials) ?? true;
    final rememberedEmail = prefs.getString(SessionKeys.rememberedEmail) ?? '';

    if (!mounted) return;
    setState(() {
      _rememberCredentials = enabled;
      if (enabled && rememberedEmail.isNotEmpty) {
        emailController.text = rememberedEmail;
      }
    });
  }

  Future<void> _persistRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SessionKeys.rememberCredentials, _rememberCredentials);

    if (_rememberCredentials) {
      await prefs.setString(
        SessionKeys.rememberedEmail,
        emailController.text.trim(),
      );
    } else {
      await prefs.remove(SessionKeys.rememberedEmail);
    }
  }

  InputDecoration _decoration({
    required BuildContext context,
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  bool _isSuccessResponse(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' ||
          normalized == '1' ||
          normalized == 'success' ||
          normalized == 'ok';
    }
    return false;
  }

  void handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage('Todos los campos son obligatorios', isError: true);
      return;
    }

    if (!email.contains('@')) {
      showMessage('Correo inválido', isError: true);
      return;
    }

    try {
      final response = await AuthService.login(email, password);
      final isSuccess = _isSuccessResponse(response['success']);
      final message = response['message']?.toString();

      if (isSuccess) {
        final user = response['user'];
        final userId = user is Map
            ? int.tryParse(user['id']?.toString() ?? '')
            : null;
        final userName = user is Map
            ? user['name']?.toString().trim() ?? ''
            : '';
        final occupation = user is Map
            ? (user['occupation'] ?? user['user_occupation'])?.toString()
            : null;

        if (userId == null || userName.isEmpty) {
          showMessage('Respuesta de sesión inválida', isError: true);
          return;
        }

        await _sessionStorageService.saveAuthenticatedUser(
          userId: userId,
          userName: userName,
          userEmail: email,
          occupation: occupation,
        );

        await _persistRememberedCredentials();

        if (!mounted) return;
        await Future.wait([
          context.read<BudgetProvider>().initialize(),
          context.read<GoalProvider>().initialize(),
          context.read<ReminderProvider>().initialize(),
        ]);

        if (!mounted) return;
        showMessage('Bienvenido nuevamente');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      } else {
        showMessage(message ?? 'Credenciales incorrectas', isError: true);
      }
    } catch (e) {
      showMessage('Error de conexión con el servidor', isError: true);
    }
  }

  void showMessage(String message, {bool isError = false}) {
    if (isError) {
      AppSnackbar.error(context, message);
    } else {
      AppSnackbar.success(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),
              const Text(
                'Bienvenido',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Ingresa para continuar',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _decoration(
                        context: context,
                        label: 'Correo',
                        icon: Icons.email_outlined,
                      ),
                      onChanged: (_) {
                        if (_rememberCredentials) {
                          _persistRememberedCredentials();
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: !_showPassword,
                      decoration: _decoration(
                        context: context,
                        label: 'Contraseña',
                        icon: Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() => _showPassword = !_showPassword);
                          },
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Switch.adaptive(
                          value: _rememberCredentials,
                          activeThumbColor: theme.colorScheme.surface,
                          activeTrackColor: const Color(
                            0xFF00C853,
                          ).withValues(alpha: 0.45),
                          inactiveThumbColor: theme.colorScheme.surface,
                          inactiveTrackColor: theme.dividerColor.withValues(
                            alpha: 0.65,
                          ),
                          onChanged: (v) async {
                            setState(() => _rememberCredentials = v);
                            await _persistRememberedCredentials();
                          },
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Recordar credenciales',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C853),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Iniciar sesión'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text('¿No tienes cuenta? Regístrate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
