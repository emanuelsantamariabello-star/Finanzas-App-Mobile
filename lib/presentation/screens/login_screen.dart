import 'package:flutter/material.dart';
import 'package:finanzas_app_mobile/data/services/auth_service.dart';
import 'package:finanzas_app_mobile/presentation/screens/main_navigation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finanzas_app_mobile/presentation/screens/register_screen.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_snackbar.dart';

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

  static const _rememberEmailKey = 'rememberedEmail';
  static const _rememberEnabledKey = 'rememberCredentials';

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
    final enabled = prefs.getBool(_rememberEnabledKey) ?? true;
    final rememberedEmail = prefs.getString(_rememberEmailKey) ?? '';

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
    await prefs.setBool(_rememberEnabledKey, _rememberCredentials);

    if (_rememberCredentials) {
      await prefs.setString(_rememberEmailKey, emailController.text.trim());
    } else {
      await prefs.remove(_rememberEmailKey);
    }
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFF161B22),
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
        final prefs = await SharedPreferences.getInstance();

        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userEmail', email);
        await prefs.setString('userName', response['user']['name']);
        await prefs.setInt('userId', response['user']['id']);

        await _persistRememberedCredentials();

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
              const Text(
                'Ingresa para continuar',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _decoration(
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
                          activeThumbColor: const Color(0xFF00C853),
                          activeTrackColor: const Color(0xFF00C853),
                          onChanged: (v) async {
                            setState(() => _rememberCredentials = v);
                            await _persistRememberedCredentials();
                          },
                        ),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'Recordar credenciales',
                            style: TextStyle(color: Colors.white70),
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
