enum InternalNotificationType { info, success, warning, danger }

class InternalNotificationModel {
  final String id;
  final String title;
  final String message;
  final InternalNotificationType type;
  final String source;
  final DateTime? createdAt;
  final DateTime? scheduledDate;
  final int? daysUntil;

  const InternalNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.source,
    this.createdAt,
    this.scheduledDate,
    this.daysUntil,
  });

  factory InternalNotificationModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString().trim() ?? '';
    final title = json['title']?.toString().trim() ?? '';
    final message = json['message']?.toString().trim() ?? '';

    if (id.isEmpty || title.isEmpty || message.isEmpty) {
      throw const FormatException('Notificación interna incompleta');
    }

    return InternalNotificationModel(
      id: id,
      title: title,
      message: message,
      type: _parseType(json['type']),
      source: json['source']?.toString().trim() ?? 'system',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      scheduledDate: DateTime.tryParse(json['date']?.toString() ?? ''),
      daysUntil: int.tryParse(json['days_until']?.toString() ?? ''),
    );
  }

  static InternalNotificationType _parseType(dynamic value) {
    switch (value?.toString().trim().toLowerCase()) {
      case 'success':
        return InternalNotificationType.success;
      case 'warning':
        return InternalNotificationType.warning;
      case 'danger':
        return InternalNotificationType.danger;
      default:
        return InternalNotificationType.info;
    }
  }
}
