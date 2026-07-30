import 'dart:typed_data';

import 'package:finanzas_app_mobile/core/constants/session_keys.dart';
import 'package:finanzas_app_mobile/core/network/api_exception.dart';
import 'package:finanzas_app_mobile/data/models/profile_photo_snapshot.dart';
import 'package:finanzas_app_mobile/data/services/profile_media_session_storage_service.dart';
import 'package:finanzas_app_mobile/data/services/session_storage_service.dart';
import 'package:finanzas_app_mobile/data/services/user_service.dart';
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
    final selectedImage = await _imagePicker.pickImage(
      source: source,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 90,
      requestFullMetadata: false,
    );
    if (selectedImage == null) return null;

    final selectedBytes = await selectedImage.readAsBytes();
    final response = await UserService.uploadProfilePhoto(
      bytes: selectedBytes,
      filename: selectedImage.name.isEmpty ? 'profile.jpg' : selectedImage.name,
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
