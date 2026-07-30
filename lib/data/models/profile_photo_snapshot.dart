import 'dart:typed_data';

class ProfilePhotoSnapshot {
  const ProfilePhotoSnapshot({required this.available, this.bytes});

  final bool available;
  final Uint8List? bytes;
}
