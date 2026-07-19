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

    Color background;
    Color accent;
    IconData icon;

    switch (type) {
      case AppSnackbarType.success:
        accent = const Color(0xFF00C853);
        icon = Icons.check_circle_rounded;
        background = isDark ? const Color(0xFF0D1117) : const Color(0xFF101418);
        break;
      case AppSnackbarType.error:
        accent = const Color(0xFFFF5252);
        icon = Icons.error_rounded;
        background = isDark ? const Color(0xFF0D1117) : const Color(0xFF101418);
        break;
      case AppSnackbarType.info:
        accent = const Color(0xFF42A5F5);
        icon = Icons.info_rounded;
        background = isDark ? const Color(0xFF0D1117) : const Color(0xFF101418);
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
          content: Row(
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
            ],
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
