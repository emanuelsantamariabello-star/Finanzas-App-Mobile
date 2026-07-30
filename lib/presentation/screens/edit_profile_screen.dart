import 'dart:typed_data';

import 'package:finanzas_app_mobile/core/motion/app_motion.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finanzas_app_mobile/core/constants/session_keys.dart';
import 'package:finanzas_app_mobile/core/network/api_exception.dart';
import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/data/services/profile_photo_service.dart';
import 'package:finanzas_app_mobile/data/services/session_storage_service.dart';
import 'package:finanzas_app_mobile/data/services/user_service.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_confirmation_dialog.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_form_components.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_snackbar.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_state_widgets.dart';
import 'package:finanzas_app_mobile/presentation/widgets/profile_avatar.dart';

enum _ProfilePhotoAction { camera, gallery, delete }

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, this.recoverInterruptedSelection = true});

  final bool recoverInterruptedSelection;

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
  bool _photoLoading = false;
  bool _hasProfilePhoto = false;
  bool _lostDataChecked = false;
  Uint8List? _profilePhotoBytes;
  String? _loadError;

  int? _userId;
  final SessionStorageService _sessionStorageService = SessionStorageService();
  final ProfilePhotoService _profilePhotoService = ProfilePhotoService();

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
        _hasProfilePhoto =
            prefs.getBool(SessionKeys.profilePhotoAvailable) ?? false;
        _loading = false;
      });
      await _loadProfilePhoto();
      if (widget.recoverInterruptedSelection) {
        await _recoverLostPhoto();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _recoverLostPhoto() async {
    if (_lostDataChecked || !mounted) return;
    _lostDataChecked = true;
    setState(() => _photoLoading = true);

    try {
      final bytes = await _profilePhotoService.recoverLostUpload();
      if (!mounted) return;
      if (bytes != null) {
        setState(() {
          _profilePhotoBytes = bytes;
          _hasProfilePhoto = true;
        });
        AppSnackbar.success(context, 'Foto recuperada y actualizada');
      }
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.error(
        context,
        apiErrorMessage(
          error,
          fallback: 'No se pudo recuperar la foto seleccionada',
        ),
      );
    } finally {
      if (mounted) setState(() => _photoLoading = false);
    }
  }

  Future<void> _loadProfilePhoto() async {
    if (!_hasProfilePhoto || !mounted) return;
    setState(() => _photoLoading = true);

    try {
      final snapshot = await _profilePhotoService.load();
      if (!mounted) return;
      setState(() {
        _hasProfilePhoto = snapshot.available;
        _profilePhotoBytes = snapshot.bytes;
        _photoLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _photoLoading = false);
    }
  }

  String _userInitial() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) return name[0].toUpperCase();
    final email = _emailController.text.trim();
    if (email.isNotEmpty) return email[0].toUpperCase();
    return '?';
  }

  Future<void> _showPhotoActions() async {
    if (_photoLoading) return;
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    final action = await showModalBottomSheet<_ProfilePhotoAction>(
      context: context,
      sheetAnimationStyle: AppMotion.modalStyle(context),
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        Widget actionTile({
          required String title,
          required String subtitle,
          required IconData icon,
          required Color color,
          required _ProfilePhotoAction action,
        }) {
          return ListTile(
            onTap: () => Navigator.pop(sheetContext, action),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            title: Text(
              title,
              style: TextStyle(color: onSurface, fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(color: onSurface.withValues(alpha: 0.68)),
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: onSurface.withValues(alpha: 0.45),
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            6,
            16,
            16 + MediaQuery.viewPaddingOf(sheetContext).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Foto de perfil',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              actionTile(
                title: 'Tomar una foto',
                subtitle: 'Usa la cámara de tu dispositivo',
                icon: Icons.photo_camera_outlined,
                color: AppTheme.corporateGreen,
                action: _ProfilePhotoAction.camera,
              ),
              actionTile(
                title: 'Elegir de la galería',
                subtitle: 'Selecciona una imagen existente',
                icon: Icons.photo_library_outlined,
                color: AppTheme.corporateBlue,
                action: _ProfilePhotoAction.gallery,
              ),
              if (_hasProfilePhoto)
                actionTile(
                  title: 'Eliminar foto',
                  subtitle: 'Volver a mostrar tus iniciales',
                  icon: Icons.delete_outline_rounded,
                  color: AppTheme.corporateRed,
                  action: _ProfilePhotoAction.delete,
                ),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) return;
    switch (action) {
      case _ProfilePhotoAction.camera:
        await _selectAndUploadPhoto(ImageSource.camera);
        break;
      case _ProfilePhotoAction.gallery:
        await _selectAndUploadPhoto(ImageSource.gallery);
        break;
      case _ProfilePhotoAction.delete:
        await _deleteProfilePhoto();
        break;
    }
  }

  Future<void> _selectAndUploadPhoto(ImageSource source) async {
    setState(() => _photoLoading = true);
    try {
      final bytes = await _profilePhotoService.selectAndUpload(source);
      if (!mounted) return;
      if (bytes == null) {
        setState(() => _photoLoading = false);
        return;
      }

      setState(() {
        _profilePhotoBytes = bytes;
        _hasProfilePhoto = true;
        _photoLoading = false;
      });
      AppSnackbar.success(context, 'Foto de perfil actualizada');
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.error(
        context,
        apiErrorMessage(
          error,
          fallback: 'No se pudo actualizar la foto de perfil',
        ),
      );
    } finally {
      if (mounted && _photoLoading) {
        setState(() => _photoLoading = false);
      }
    }
  }

  Future<void> _deleteProfilePhoto() async {
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Eliminar foto',
      message: 'Volverás a ver tus iniciales en el perfil.',
      confirmLabel: 'Eliminar',
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;

    setState(() => _photoLoading = true);
    try {
      await _profilePhotoService.delete();
      if (!mounted) return;
      setState(() {
        _profilePhotoBytes = null;
        _hasProfilePhoto = false;
        _photoLoading = false;
      });
      AppSnackbar.success(context, 'Foto de perfil eliminada');
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.error(
        context,
        apiErrorMessage(
          error,
          fallback: 'No se pudo eliminar la foto de perfil',
        ),
      );
    } finally {
      if (mounted && _photoLoading) {
        setState(() => _photoLoading = false);
      }
    }
  }

  Future<void> _save() async {
    if (_saving || _photoLoading) return;
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
          : AppFormScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSurfaceCard(
                    child: Center(
                      child: Column(
                        children: [
                          ProfileAvatar(
                            fallbackText: _userInitial(),
                            imageBytes: _profilePhotoBytes,
                            size: 96,
                            isLoading: _photoLoading,
                            onEdit: _showPhotoActions,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Foto de perfil',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Toca la cámara para cambiarla',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: onSurface.withValues(alpha: 0.62),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [AutofillHints.name],
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
                          autofillHints: const [AutofillHints.email],
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
                          textCapitalization: TextCapitalization.sentences,
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
                    onPressed: _photoLoading ? null : _save,
                  ),
                ],
              ),
            ),
    );
  }
}
