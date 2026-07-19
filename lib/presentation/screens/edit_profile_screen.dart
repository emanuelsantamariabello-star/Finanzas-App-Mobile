import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finanzas_app_mobile/data/services/user_service.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_snackbar.dart';

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
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      setState(() {
        _userId = userId;
        _nameController.text = prefs.getString('userName') ?? '';
        _emailController.text = prefs.getString('userEmail') ?? '';
        _occupationController.text =
            prefs.getString('occupation') ??
            prefs.getString('userOccupation') ??
            '';
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
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
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
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', name);
        await prefs.setString('userEmail', email);
        await prefs.setString('occupation', occupation);
        await prefs.setString('userOccupation', occupation);

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
      AppSnackbar.error(context, 'Error al actualizar el perfil');
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
                          decoration: _decoration(
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
                          decoration: _decoration(
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
                          decoration: _decoration(
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
                      label: Text(_saving ? 'Guardandoâ€¦' : 'Guardar cambios'),
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
