import 'package:finanzas_app_mobile/core/constants/session_keys.dart';
import 'package:finanzas_app_mobile/core/network/api_exception.dart';
import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/data/models/internal_notification_model.dart';
import 'package:finanzas_app_mobile/data/services/internal_notification_service.dart';
import 'package:finanzas_app_mobile/presentation/widgets/internal_notifications_panel.dart';
import 'package:finanzas_app_mobile/providers/internal_notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeInternalNotificationService extends InternalNotificationService {
  _FakeInternalNotificationService({this.items = const [], this.failure});

  List<InternalNotificationModel> items;
  Object? failure;

  @override
  Future<List<InternalNotificationModel>> getNotifications(int userId) async {
    if (failure != null) throw failure!;
    return items;
  }
}

const _systemNotification = InternalNotificationModel(
  id: 'system-1',
  title: 'Mantenimiento programado',
  message: 'El servicio tendrá una actualización.',
  type: InternalNotificationType.warning,
  source: 'system',
);

const _financeNotification = InternalNotificationModel(
  id: 'income-reminder-2026-07-26',
  title: 'Recordatorio financiero',
  message: 'Actualiza tus movimientos de hoy.',
  type: InternalNotificationType.info,
  source: 'finance',
  daysUntil: 0,
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({SessionKeys.userId: 7});
  });

  test('interpreta tipos y campos opcionales de la API', () {
    final notification = InternalNotificationModel.fromJson({
      'id': 'system-8',
      'title': 'Aviso',
      'message': 'Mensaje de prueba',
      'type': 'success',
      'source': 'system',
      'created_at': '2026-07-26 10:30:00',
    });

    expect(notification.type, InternalNotificationType.success);
    expect(notification.createdAt, DateTime(2026, 7, 26, 10, 30));
    expect(notification.source, 'system');
  });

  test('persiste leídos por usuario y conserva el badge pendiente', () async {
    final service = _FakeInternalNotificationService(
      items: const [_systemNotification, _financeNotification],
    );
    final provider = InternalNotificationProvider(notificationService: service);

    await provider.initialize();
    expect(provider.unreadCount, 2);

    await provider.markAllAsRead();
    expect(provider.unreadCount, 0);

    final restoredProvider = InternalNotificationProvider(
      notificationService: service,
    );
    await restoredProvider.initialize();
    expect(restoredProvider.unreadCount, 0);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(SessionKeys.userId, 8);
    await restoredProvider.initialize();
    expect(restoredProvider.unreadCount, 2);
  });

  test('expone un mensaje seguro cuando falla la conexión', () async {
    final provider = InternalNotificationProvider(
      notificationService: _FakeInternalNotificationService(
        failure: const ApiException(
          type: ApiErrorType.connection,
          message: 'No se pudo conectar con el servidor',
        ),
      ),
    );

    await provider.initialize();

    expect(provider.notifications, isEmpty);
    expect(provider.error, 'No se pudo conectar con el servidor');
    expect(provider.isLoading, isFalse);
  });

  testWidgets('abre el panel y permite marcar todo como leído', (tester) async {
    final provider = InternalNotificationProvider(
      notificationService: _FakeInternalNotificationService(
        items: const [_systemNotification],
      ),
    );
    await provider.initialize();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Finanzas App'),
              actions: const [InternalNotificationAction()],
            ),
          ),
        ),
      ),
    );

    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.byTooltip('Notificaciones'));
    await tester.pumpAndSettle();

    expect(find.text('Mantenimiento programado'), findsOneWidget);
    expect(find.text('1 sin leer'), findsOneWidget);

    await tester.tap(find.text('Marcar leídas'));
    await tester.pumpAndSettle();

    expect(provider.unreadCount, 0);
    expect(find.text('Todo está al día'), findsOneWidget);
  });
}
