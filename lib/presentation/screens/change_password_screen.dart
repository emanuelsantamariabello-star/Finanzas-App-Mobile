import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finanzas_app_mobile/data/services/user_service.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_snackbar.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  int? _userId;

  static const int _minPasswordLength = 6;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userId = prefs.getInt('userId');
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loadError = e.toString();
        _loading = false;
      });
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

  Future<void> _save() async {
    if (_saving) return;
    final userId = _userId;
    if (userId == null) {
      AppSnackbar.error(context, 'Usuario no identificado');
      return;
    }

    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;

    final currentPassword = _currentController.text;
    final newPassword = _newController.text;

    setState(() => _saving = true);
    try {
      final response = await UserService.changePassword(
        userId: userId,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        AppSnackbar.success(context, 'Contraseña actualizada');
        Navigator.pop(context, true);
      } else {
        AppSnackbar.error(
          context,
          response['message']?.toString() ?? 'No se pudo cambiar la contraseña',
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Error al cambiar la contraseña');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('Cambiar contraseña')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(child: Text('Error: $_loadError'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1117),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Text(
                          'Por seguridad, ingresa tu contraseña actual y define una nueva.',
                          style: TextStyle(
                            color: onSurface.withOpacity(0.75),
                            height: 1.35,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _currentController,
                              obscureText: !_showCurrent,
                              textInputAction: TextInputAction.next,
                              decoration: _decoration(
                                label: 'Contraseña actual',
                                icon: Icons.lock_outline_rounded,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() => _showCurrent = !_showCurrent);
                                  },
                                  icon: Icon(
                                    _showCurrent
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                  ),
                                ),
                              ),
                              validator: (v) {
                                final value = v ?? '';
                                if (value.trim().isEmpty) {
                                  return 'Ingresa tu contraseña actual';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _newController,
                              obscureText: !_showNew,
                              textInputAction: TextInputAction.next,
                              decoration: _decoration(
                                label: 'Nueva contraseña',
                                icon: Icons.password_rounded,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() => _showNew = !_showNew);
                                  },
                                  icon: Icon(
                                    _showNew
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                  ),
                                ),
                              ),
                              validator: (v) {
                                final value = v ?? '';
                                if (value.trim().isEmpty) {
                                  return 'Ingresa una nueva contraseña';
                                }
                                if (value.length < _minPasswordLength) {
                                  return 'Mínimo $_minPasswordLength caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _confirmController,
                              obscureText: !_showConfirm,
                              textInputAction: TextInputAction.done,
                              decoration: _decoration(
                                label: 'Confirmar nueva contraseña',
                                icon: Icons.password_rounded,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() => _showConfirm = !_showConfirm);
                                  },
                                  icon: Icon(
                                    _showConfirm
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                  ),
                                ),
                              ),
                              validator: (v) {
                                final value = v ?? '';
                                if (value.trim().isEmpty) {
                                  return 'Confirma tu nueva contraseña';
                                }
                                if (value != _newController.text) {
                                  return 'Las contraseñas no coinciden';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _save(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(_saving ? 'Guardando…' : 'Cambiar contraseña'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C853),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
