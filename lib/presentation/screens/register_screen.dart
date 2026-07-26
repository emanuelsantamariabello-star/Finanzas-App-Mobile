import 'package:flutter/material.dart';
import 'package:finanzas_app_mobile/core/network/api_exception.dart';
import 'package:finanzas_app_mobile/data/services/auth_service.dart';
import 'package:finanzas_app_mobile/data/services/session_storage_service.dart';
import 'package:finanzas_app_mobile/presentation/screens/login_screen.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_form_components.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_snackbar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final SessionStorageService _sessionStorageService = SessionStorageService();

  bool _showPassword = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void handleRegister() async {
    if (_isSubmitting) return;

    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      showMessage('Todos los campos son obligatorios', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await AuthService.register(username, email, password);

      if (response['success'] == true) {
        showMessage('Registro exitoso');

        await _sessionStorageService.clearSession();

        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        showMessage(
          response['message']?.toString() ?? 'No se pudo completar el registro',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      showMessage(
        apiErrorMessage(e, fallback: 'No se pudo completar el registro'),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void showMessage(String msg, {bool isError = false}) {
    if (isError) {
      AppSnackbar.error(context, msg);
    } else {
      AppSnackbar.success(context, msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: AppFormScrollView(
          padding: const EdgeInsets.all(24),
          child: AppSurfaceCard(
            child: Column(
              children: [
                TextField(
                  controller: usernameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  decoration: AppFormDecoration.input(
                    context: context,
                    label: 'Nombre',
                    icon: Icons.person_outline_rounded,
                  ),
                ),
                const SizedBox(height: 12),
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
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: !_showPassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
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
                  onSubmitted: (_) => handleRegister(),
                ),
                const SizedBox(height: 16),
                AppPrimaryButton(
                  label: 'Registrarse',
                  loadingLabel: 'Creando cuenta…',
                  isLoading: _isSubmitting,
                  onPressed: handleRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
