import 'package:finanzas_app_mobile/core/constants/session_keys.dart';
import 'package:finanzas_app_mobile/core/network/api_exception.dart';
import 'package:finanzas_app_mobile/data/models/profile_photo_snapshot.dart';
import 'package:finanzas_app_mobile/data/services/profile_media_session_storage_service.dart';
import 'package:finanzas_app_mobile/data/services/session_storage_service.dart';
import 'package:finanzas_app_mobile/data/services/user_service.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePhotoService {
  ProfilePhotoService({
    ImagePicker? imagePicker,
    ProfileMediaSessionStorageService? mediaSessionStorage,
    SessionStorageService? sessionStorage,
  }) : _imagePicker = imagePicker ?? ImagePicker(),
       _mediaSessionStorage =
           mediaSessionStorage ?? ProfileMediaSessionStorageService(),
       _sessionStorage = sessionStorage ?? SessionStorageService();

  final ImagePicker _imagePicker;
  final ProfileMediaSessionStorageService _mediaSessionStorage;
  final SessionStorageService _sessionStorage;

  Future<ProfilePhotoSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();
    final available = prefs.getBool(SessionKeys.profilePhotoAvailable) ?? false;
    if (!available) {
      return const ProfilePhotoSnapshot(available: false);
    }

    final token = await _requireToken();
    try {
      final bytes = await UserService.getProfilePhoto(token: token);
      return ProfilePhotoSnapshot(available: true, bytes: bytes);
    } on ApiException catch (error) {
      if (error.statusCode == 404) {
        await _sessionStorage.updateProfilePhotoMetadata(available: false);
        return const ProfilePhotoSnapshot(available: false);
      }
      rethrow;
    }
  }

  Future<Uint8List?> selectAndUpload(ImageSource source) async {
    final token = await _requireToken();
    late final XFile? selectedImage;
    try {
      selectedImage = await _imagePicker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
        requestFullMetadata: false,
      );
    } on PlatformException catch (error) {
      throw profilePhotoPickerException(error);
    }
    if (selectedImage == null) return null;

    return _uploadImage(selectedImage, token);
  }

  Future<Uint8List?> recoverLostUpload() async {
    late final LostDataResponse response;
    try {
      response = await _imagePicker.retrieveLostData();
    } on MissingPluginException {
      return null;
    } on PlatformException catch (error) {
      throw profilePhotoPickerException(error);
    }

    if (response.isEmpty) return null;
    final pickerError = response.exception;
    if (pickerError != null) {
      throw profilePhotoPickerException(pickerError);
    }

    final recoveredFiles = response.files;
    final recoveredImage = recoveredFiles != null && recoveredFiles.isNotEmpty
        ? recoveredFiles.last
        : response.file;
    if (recoveredImage == null) return null;

    final token = await _requireToken();
    return _uploadImage(recoveredImage, token);
  }

  Future<Uint8List> _uploadImage(XFile image, String token) async {
    final selectedBytes = await image.readAsBytes();
    final response = await UserService.uploadProfilePhoto(
      bytes: selectedBytes,
      filename: image.name.isEmpty ? 'profile.jpg' : image.name,
      token: token,
    );

    if (response['success'] != true) {
      throw ApiException(
        type: ApiErrorType.http,
        message:
            response['message']?.toString() ??
            'No se pudo actualizar la foto de perfil',
      );
    }

    final updatedAt = DateTime.tryParse(
      response['profile_photo_updated_at']?.toString() ?? '',
    );
    await _sessionStorage.updateProfilePhotoMetadata(
      available: true,
      updatedAt: updatedAt,
    );

    try {
      return await UserService.getProfilePhoto(token: token);
    } catch (_) {
      return selectedBytes;
    }
  }

  Future<void> delete() async {
    final token = await _requireToken();
    final response = await UserService.deleteProfilePhoto(token: token);
    if (response['success'] != true) {
      throw ApiException(
        type: ApiErrorType.http,
        message:
            response['message']?.toString() ??
            'No se pudo eliminar la foto de perfil',
      );
    }

    await _sessionStorage.updateProfilePhotoMetadata(available: false);
  }

  Future<String> _requireToken() async {
    final token = await _mediaSessionStorage.readToken();
    if (token != null) return token;

    throw const ApiException(
      type: ApiErrorType.http,
      statusCode: 401,
      message: 'Tu sesión de perfil venció. Inicia sesión nuevamente.',
    );
  }
}

ApiException profilePhotoPickerException(PlatformException error) {
  final message = switch (error.code) {
    'camera_access_denied' =>
      'Permite el acceso a la cámara para tomar tu foto de perfil.',
    'photo_access_denied' =>
      'Permite el acceso a tus fotos para elegir una imagen.',
    'no_available_camera' =>
      'No hay una cámara disponible en este dispositivo.',
    'already_active' => 'El selector de imágenes ya está abierto.',
    _ => 'No se pudo abrir el selector de imágenes.',
  };

  return ApiException(type: ApiErrorType.http, message: message);
}
