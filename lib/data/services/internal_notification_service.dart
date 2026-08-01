import 'package:finanzas_app_mobile/core/network/api_exception.dart';
import 'package:finanzas_app_mobile/data/models/internal_notification_model.dart';
import 'package:finanzas_app_mobile/data/services/authenticated_api_client.dart';

class InternalNotificationService {
  Future<List<InternalNotificationModel>> getNotifications(int userId) async {
    final response = await AuthenticatedApiClient.postJson(
      'notifications.php',
      body: {'user_id': userId.toString()},
    );

    if (response['success'] != true) {
      throw ApiException(
        type: ApiErrorType.invalidResponse,
        message:
            response['message']?.toString() ??
            'No se pudieron cargar las notificaciones',
      );
    }

    final data = response['data'];
    if (data is! List) {
      throw const ApiException(
        type: ApiErrorType.invalidResponse,
        message: 'El servidor devolvió notificaciones no válidas',
      );
    }

    try {
      return data
          .map((item) {
            if (item is! Map) {
              throw const FormatException('Notificación interna no válida');
            }
            return Map<String, dynamic>.from(item);
          })
          .map(InternalNotificationModel.fromJson)
          .toList();
    } on FormatException {
      throw const ApiException(
        type: ApiErrorType.invalidResponse,
        message: 'El servidor devolvió una notificación incompleta',
      );
    }
  }
}
