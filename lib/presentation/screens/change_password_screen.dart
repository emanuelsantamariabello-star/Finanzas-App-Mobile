import 'package:flutter/material.dart';
import 'package:finanzas_app_mobile/core/constants/session_keys.dart';
import 'package:finanzas_app_mobile/core/network/api_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finanzas_app_mobile/data/services/user_service.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_form_components.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_snackbar.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_state_widgets.dart';

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
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _userId = prefs.getInt(SessionKeys.userId);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _loading = false;
      });
    }
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
      AppSnackbar.error(
        context,
        apiErrorMessage(e, fallback: 'Error al cambiar la contraseña'),
      );
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
          ? const AppLoadingState(message: 'Preparando la configuración…')
          : _loadError != null
          ? AppErrorState(message: _loadError!, onRetry: _loadUserId)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSurfaceCard(
                    child: Text(
                      'Por seguridad, ingresa tu contraseña actual y define una nueva.',
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.75),
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
                          decoration: AppFormDecoration.input(
                            context: context,
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
                          decoration: AppFormDecoration.input(
                            context: context,
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
                          decoration: AppFormDecoration.input(
                            context: context,
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
                  AppPrimaryButton(
                    label: 'Cambiar contraseña',
                    loadingLabel: 'Guardando…',
                    icon: Icons.save_outlined,
                    isLoading: _saving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
    );
  }
}
