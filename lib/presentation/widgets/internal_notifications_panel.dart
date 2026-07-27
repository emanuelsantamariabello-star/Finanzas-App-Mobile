import 'dart:async';
import 'dart:math' as math;

import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/core/motion/app_motion.dart';
import 'package:finanzas_app_mobile/data/models/internal_notification_model.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_state_widgets.dart';
import 'package:finanzas_app_mobile/providers/internal_notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class InternalNotificationAction extends StatelessWidget {
  const InternalNotificationAction({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InternalNotificationProvider>();
    final unreadCount = provider.unreadCount;
    final badgeLabel = unreadCount > 99 ? '99+' : unreadCount.toString();

    return IconButton(
      tooltip: 'Notificaciones',
      onPressed: () {
        unawaited(_showInternalNotificationsPanel(context));
        if (!provider.isInitialized) {
          unawaited(provider.initialize());
        }
      },
      icon: Semantics(
        label: unreadCount == 0
            ? 'Notificaciones, ninguna pendiente'
            : 'Notificaciones, $unreadCount pendientes',
        excludeSemantics: true,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_none_rounded),
            if (unreadCount > 0)
              Positioned(
                top: -7,
                right: -9,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 17,
                    minHeight: 17,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.corporateRed,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    badgeLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      height: 1,
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

Future<void> _showInternalNotificationsPanel(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    sheetAnimationStyle: AppMotion.modalStyle(context),
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      final height = math.min(
        MediaQuery.sizeOf(sheetContext).height * 0.78,
        680.0,
      );

      return SizedBox(
        height: height,
        child: const _InternalNotificationsPanel(),
      );
    },
  );
}

class _InternalNotificationsPanel extends StatelessWidget {
  const _InternalNotificationsPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<InternalNotificationProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notificaciones',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          provider.unreadCount == 0
                              ? 'Todo está al día'
                              : '${provider.unreadCount} sin leer',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (provider.unreadCount > 0)
                    TextButton(
                      onPressed: provider.markAllAsRead,
                      child: const Text('Marcar leídas'),
                    ),
                  IconButton(
                    tooltip: 'Actualizar notificaciones',
                    onPressed: provider.isLoading ? null : provider.refresh,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.dividerColor),
            Expanded(child: _buildContent(context, provider)),
          ],
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    InternalNotificationProvider provider,
  ) {
    if (provider.isLoading && provider.notifications.isEmpty) {
      return const AppLoadingState(
        message: 'Buscando notificaciones…',
        compact: true,
      ).withStateTransition('loading');
    }

    if (provider.error != null && provider.notifications.isEmpty) {
      return AppErrorState(
        title: 'No pudimos cargar tus notificaciones',
        message: provider.error!,
        onRetry: provider.refresh,
        compact: true,
      ).withStateTransition('error');
    }

    if (provider.notifications.isEmpty) {
      return AppEmptyState(
        icon: Icons.notifications_none_rounded,
        title: 'Todo está al día',
        message: 'No tienes notificaciones activas por ahora.',
        accentColor: AppTheme.corporateBlue,
        compact: true,
      ).withStateTransition('empty');
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          16 + MediaQuery.viewPaddingOf(context).bottom,
        ),
        itemCount: provider.notifications.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final notification = provider.notifications[index];
          return _NotificationCard(
            notification: notification,
            isRead: provider.isRead(notification.id),
          );
        },
      ),
    ).withStateTransition('content');
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.isRead});

  final InternalNotificationModel notification;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _accentColor(notification.type);

    return Semantics(
      label:
          '${isRead ? "Leída" : "Sin leer"}. ${notification.title}. ${notification.message}',
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: isRead ? 0.72 : 1,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isRead
                ? theme.colorScheme.surface
                : accent.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isRead
                  ? theme.dividerColor.withValues(alpha: 0.55)
                  : accent.withValues(alpha: 0.24),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_icon(notification.type), color: accent, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notification.message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      _metadataLabel(notification),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _metadataLabel(InternalNotificationModel notification) {
    final sourceLabel = notification.source == 'finance'
        ? 'Finanzas'
        : 'Sistema';
    if (notification.daysUntil == 0) return '$sourceLabel · Hoy';
    if (notification.daysUntil != null) {
      return '$sourceLabel · En ${notification.daysUntil} días';
    }
    if (notification.createdAt != null) {
      return '$sourceLabel · ${DateFormat('dd/MM/yyyy').format(notification.createdAt!)}';
    }
    return sourceLabel;
  }

  Color _accentColor(InternalNotificationType type) {
    switch (type) {
      case InternalNotificationType.success:
        return AppTheme.corporateGreen;
      case InternalNotificationType.warning:
        return Colors.orange;
      case InternalNotificationType.danger:
        return AppTheme.corporateRed;
      case InternalNotificationType.info:
        return AppTheme.corporateBlue;
    }
  }

  IconData _icon(InternalNotificationType type) {
    switch (type) {
      case InternalNotificationType.success:
        return Icons.check_circle_outline_rounded;
      case InternalNotificationType.warning:
        return Icons.warning_amber_rounded;
      case InternalNotificationType.danger:
        return Icons.error_outline_rounded;
      case InternalNotificationType.info:
        return Icons.notifications_active_outlined;
    }
  }
}
