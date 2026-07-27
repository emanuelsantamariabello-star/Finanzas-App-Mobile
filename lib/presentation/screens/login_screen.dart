import 'dart:async';

import 'package:flutter/material.dart';
import 'package:finanzas_app_mobile/core/motion/app_page_route.dart';
import 'package:finanzas_app_mobile/core/constants/session_keys.dart';
import 'package:finanzas_app_mobile/core/network/api_exception.dart';
import 'package:finanzas_app_mobile/data/services/auth_service.dart';
import 'package:finanzas_app_mobile/data/services/session_storage_service.dart';
import 'package:finanzas_app_mobile/presentation/screens/main_navigation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finanzas_app_mobile/presentation/screens/register_screen.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_form_components.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_snackbar.dart';
import 'package:finanzas_app_mobile/providers/budget_provider.dart';
import 'package:finanzas_app_mobile/providers/goal_provider.dart';
import 'package:finanzas_app_mobile/providers/internal_notification_provider.dart';
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
  bool _isSubmitting = false;

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
    if (_isSubmitting) return;

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

    setState(() => _isSubmitting = true);

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
        unawaited(
          context.read<InternalNotificationProvider>().initialize(
            forceRefresh: true,
          ),
        );
        showMessage('Bienvenido nuevamente');

        Navigator.pushReplacement(
          context,
          AppPageRoute.build(
            context,
            builder: (context) => const MainNavigationScreen(),
          ),
        );
      } else {
        showMessage(message ?? 'Credenciales incorrectas', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      showMessage(
        apiErrorMessage(
          e,
          fallback: 'No se pudo completar el inicio de sesión',
        ),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
        child: AppFormScrollView(
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
              AppSurfaceCard(
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: AppFormDecoration.input(
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
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: AppFormDecoration.input(
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
                      onSubmitted: (_) => handleLogin(),
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
                    AppPrimaryButton(
                      label: 'Iniciar sesión',
                      loadingLabel: 'Iniciando sesión…',
                      isLoading: _isSubmitting,
                      onPressed: handleLogin,
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
                      AppPageRoute.build(
                        context,
                        builder: (_) => const RegisterScreen(),
                      ),
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
