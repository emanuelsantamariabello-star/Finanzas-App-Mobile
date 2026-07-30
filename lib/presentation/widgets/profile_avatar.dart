import 'dart:typed_data';

import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.fallbackText,
    this.imageBytes,
    this.size = 76,
    this.isLoading = false,
    this.onEdit,
  });

  final String fallbackText;
  final Uint8List? imageBytes;
  final double size;
  final bool isLoading;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeSize = size * 0.34;
    const editTapTargetSize = 48.0;
    const overflowSpace = 12.0;
    final fallback = _fallback(theme);

    return Semantics(
      image: true,
      label: imageBytes == null ? 'Avatar de usuario' : 'Foto de perfil',
      child: SizedBox(
        width: size + overflowSpace,
        height: size + overflowSpace,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppTheme.corporateGreen, Color(0xFF00E676)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.corporateGreen.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(
                child: imageBytes == null
                    ? fallback
                    : Image.memory(
                        imageBytes!,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        errorBuilder: (_, _, _) => fallback,
                      ),
              ),
            ),
            if (isLoading)
              Positioned(
                top: 0,
                left: 0,
                width: size,
                height: size,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.42),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: size * 0.28,
                      height: size * 0.28,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            if (onEdit != null)
              Positioned(
                right: 0,
                bottom: 0,
                child: Semantics(
                  container: true,
                  button: true,
                  enabled: !isLoading,
                  label: 'Cambiar foto de perfil',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isLoading ? null : onEdit,
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: editTapTargetSize,
                        height: editTapTargetSize,
                        child: Center(
                          child: Container(
                            width: badgeSize,
                            height: badgeSize,
                            decoration: BoxDecoration(
                              color: AppTheme.corporateGreen,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.photo_camera_rounded,
                                size: badgeSize * 0.52,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fallback(ThemeData theme) {
    return Center(
      child: Text(
        fallbackText,
        style: TextStyle(
          fontSize: size * 0.42,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }
}
