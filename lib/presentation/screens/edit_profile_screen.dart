import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finanzas_app_mobile/core/constants/session_keys.dart';
import 'package:finanzas_app_mobile/core/network/api_exception.dart';
import 'package:finanzas_app_mobile/data/services/session_storage_service.dart';
import 'package:finanzas_app_mobile/data/services/user_service.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_form_components.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_snackbar.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_state_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _occupationController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  int? _userId;
  final SessionStorageService _sessionStorageService = SessionStorageService();

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(SessionKeys.userId);

      if (!mounted) return;
      setState(() {
        _userId = userId;
        _nameController.text = prefs.getString(SessionKeys.userName) ?? '';
        _emailController.text = prefs.getString(SessionKeys.userEmail) ?? '';
        _occupationController.text =
            prefs.getString(SessionKeys.occupation) ??
            prefs.getString(SessionKeys.userOccupation) ??
            '';
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

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final occupation = _occupationController.text.trim();

    setState(() => _saving = true);

    try {
      final response = await UserService.updateProfile(
        userId: userId,
        name: name,
        email: email,
        occupation: occupation,
      );

      if (response['success'] == true) {
        await _sessionStorageService.updateProfile(
          userName: name,
          userEmail: email,
          occupation: occupation,
        );

        if (!mounted) return;
        AppSnackbar.success(context, 'Perfil actualizado');
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        AppSnackbar.error(
          context,
          response['message']?.toString() ?? 'No se pudo actualizar el perfil',
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(
        context,
        apiErrorMessage(e, fallback: 'Error al actualizar el perfil'),
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
      appBar: AppBar(title: const Text('Editar perfil')),
      body: _loading
          ? const AppLoadingState(message: 'Cargando tu perfil…')
          : _loadError != null
          ? AppErrorState(message: _loadError!, onRetry: _loadInitial)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSurfaceCard(
                    child: Text(
                      'Actualiza tus datos personales. Esto no afecta tus movimientos ni tu dashboard.',
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
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: AppFormDecoration.input(
                            context: context,
                            label: 'Nombre',
                            icon: Icons.person_outline_rounded,
                            hint: 'Tu nombre',
                          ),
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'Ingresa tu nombre';
                            if (value.length < 2) return 'Nombre muy corto';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: AppFormDecoration.input(
                            context: context,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            hint: 'correo@ejemplo.com',
                          ),
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'Ingresa tu email';
                            if (!value.contains('@')) return 'Email inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _occupationController,
                          textInputAction: TextInputAction.done,
                          decoration: AppFormDecoration.input(
                            context: context,
                            label: 'Ocupación',
                            icon: Icons.work_outline_rounded,
                            hint: 'Ej: Estudiante, Ingeniero…',
                          ),
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'Ingresa tu ocupación';
                            return null;
                          },
                          onFieldSubmitted: (_) => _save(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppPrimaryButton(
                    label: 'Guardar cambios',
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
