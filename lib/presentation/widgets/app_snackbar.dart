import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:flutter/material.dart';

enum AppSnackbarType { success, error, info }

class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    AppSnackbarType type = AppSnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color accent;
    IconData icon;
    final background = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.inverseSurface;
    final foreground = isDark
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onInverseSurface;

    switch (type) {
      case AppSnackbarType.success:
        accent = AppTheme.corporateGreen;
        icon = Icons.check_circle_rounded;
        break;
      case AppSnackbarType.error:
        accent = AppTheme.corporateRed;
        icon = Icons.error_rounded;
        break;
      case AppSnackbarType.info:
        accent = AppTheme.corporateBlue;
        icon = Icons.info_rounded;
        break;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: background,
          elevation: 8,
          duration: duration,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: accent.withValues(alpha: 0.28)),
          ),
          content: Semantics(
            liveRegion: true,
            label: message,
            excludeSemantics: true,
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, type: AppSnackbarType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, type: AppSnackbarType.error);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, type: AppSnackbarType.info);
  }
}
