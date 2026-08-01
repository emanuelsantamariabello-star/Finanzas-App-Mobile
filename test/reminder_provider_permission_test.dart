import 'package:finanzas_app_mobile/data/services/notification_service.dart';
import 'package:finanzas_app_mobile/providers/reminder_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class _PermissionNotificationService extends NotificationService {
  _PermissionNotificationService(this.result, {this.error});

  final bool result;
  final Object? error;

  @override
  Future<bool> requestPermissions() async {
    if (error != null) throw error!;
    return result;
  }
}

void main() {
  test('conserva el resultado concedido del permiso', () async {
    final provider = ReminderProvider(
      notificationService: _PermissionNotificationService(true),
    );

    expect(await provider.ensurePermission(), isTrue);
  });

  test('conserva el resultado denegado del permiso', () async {
    final provider = ReminderProvider(
      notificationService: _PermissionNotificationService(false),
    );

    expect(await provider.ensurePermission(), isFalse);
  });

  test('un error de permisos nunca habilita notificaciones', () async {
    final provider = ReminderProvider(
      notificationService: _PermissionNotificationService(
        false,
        error: StateError('permission unavailable'),
      ),
    );

    expect(await provider.ensurePermission(), isFalse);
  });
}
