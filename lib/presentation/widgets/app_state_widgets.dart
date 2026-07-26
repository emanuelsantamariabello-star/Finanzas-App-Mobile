import 'package:flutter/material.dart';

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({
    super.key,
    this.message = 'Cargando…',
    this.compact = false,
  });

  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      liveRegion: true,
      label: message,
      excludeSemantics: true,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(compact ? 16 : 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(strokeWidth: 3),
              SizedBox(height: compact ? 12 : 18),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.accentColor,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color? accentColor;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = accentColor ?? theme.colorScheme.primary;
    final iconSize = compact ? 30.0 : 40.0;
    final containerSize = compact ? 64.0 : 84.0;

    return Center(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 20 : 32,
          vertical: compact ? 16 : 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(compact ? 20 : 24),
              ),
              child: ExcludeSemantics(
                child: Icon(icon, size: iconSize, color: accent),
              ),
            ),
            SizedBox(height: compact ? 14 : 18),
            Text(
              title,
              style:
                  (compact
                          ? theme.textTheme.titleMedium
                          : theme.textTheme.titleLarge)
                      ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: compact ? 14 : 20),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.message,
    this.title = 'No pudimos cargar la información',
    this.onRetry,
    this.compact = false,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;
    final iconSize = compact ? 30.0 : 40.0;
    final containerSize = compact ? 64.0 : 84.0;

    return Center(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 20 : 32,
          vertical: compact ? 16 : 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                color: errorColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(compact ? 20 : 24),
              ),
              child: ExcludeSemantics(
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: iconSize,
                  color: errorColor,
                ),
              ),
            ),
            SizedBox(height: compact ? 14 : 18),
            Text(
              title,
              style:
                  (compact
                          ? theme.textTheme.titleMedium
                          : theme.textTheme.titleLarge)
                      ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                height: 1.4,
              ),
              maxLines: compact ? 3 : 5,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: compact ? 14 : 20),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
