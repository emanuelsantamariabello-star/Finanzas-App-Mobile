import 'package:finanzas_app_mobile/data/services/profile_photo_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

class _LostDataImagePicker extends ImagePicker {
  _LostDataImagePicker(this.response);

  final LostDataResponse response;

  @override
  Future<LostDataResponse> retrieveLostData() async => response;
}

void main() {
  test('traduce errores conocidos del selector a mensajes claros', () {
    final cases = {
      'camera_access_denied': 'Permite el acceso a la cámara',
      'photo_access_denied': 'Permite el acceso a tus fotos',
      'no_available_camera': 'No hay una cámara disponible',
      'already_active': 'El selector de imágenes ya está abierto',
      'unexpected': 'No se pudo abrir el selector de imágenes',
    };

    for (final entry in cases.entries) {
      final exception = profilePhotoPickerException(
        PlatformException(code: entry.key),
      );

      expect(exception.message, startsWith(entry.value));
    }
  });

  test('ignora de forma segura una recuperación vacía', () async {
    final service = ProfilePhotoService(
      imagePicker: _LostDataImagePicker(LostDataResponse.empty()),
    );

    expect(await service.recoverLostUpload(), isNull);
  });

  test('traduce el error de una selección interrumpida', () async {
    final service = ProfilePhotoService(
      imagePicker: _LostDataImagePicker(
        LostDataResponse(
          exception: PlatformException(code: 'camera_access_denied'),
        ),
      ),
    );

    expect(
      service.recoverLostUpload(),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'mensaje',
          contains('Permite el acceso a la cámara'),
        ),
      ),
    );
  });
}
