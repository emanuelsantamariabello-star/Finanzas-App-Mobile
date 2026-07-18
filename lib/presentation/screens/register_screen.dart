import 'package:flutter/material.dart';
import 'package:finanzas_app_mobile/data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finanzas_app_mobile/presentation/screens/login_screen.dart';
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

  bool _showPassword = false;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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

  void handleRegister() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      showMessage('Todos los campos son obligatorios');
      return;
    }

    try {
      final response = await AuthService.register(username, email, password);

      if (response['success'] == true) {
        showMessage('Registro exitoso');

        final prefs = await SharedPreferences.getInstance();

        // IMPORTANT: After registering, do NOT reuse any previous session.
        // Return to LoginScreen and keep "remember credentials" keys intact.
        const sessionKeysToRemove = [
          'isLoggedIn',
          'userEmail',
          'userName',
          'userId',
          'occupation',
          'userOccupation',
        ];
        for (final key in sessionKeysToRemove) {
          await prefs.remove(key);
        }

        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        showMessage(response['message']?.toString() ?? 'Error al registrarse');
      }
    } catch (e) {
      showMessage('Error: $e');
    }
  }

  void showMessage(String msg) {
    AppSnackbar.success(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
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
                  controller: usernameController,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(
                    label: 'Nombre',
                    icon: Icons.person_outline_rounded,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(
                    label: 'Correo',
                    icon: Icons.email_outlined,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: !_showPassword,
                  textInputAction: TextInputAction.done,
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
                  onSubmitted: (_) => handleRegister(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Registrarse'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
