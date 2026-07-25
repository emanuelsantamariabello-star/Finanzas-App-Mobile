class ReminderModel {
  const ReminderModel({
    required this.id,
    required this.title,
    required this.type,
    required this.frequency,
    required this.scheduledAt,
    this.description,
    this.isEnabled = true,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? description;
  final String type;
  final String frequency;
  final DateTime scheduledAt;
  final bool isEnabled;
  final DateTime? createdAt;

  int get notificationSeed {
    return id.codeUnits.fold<int>(0, (value, char) {
          return (value * 31 + char) & 0x7fffffff;
        }) +
        1000;
  }

  ReminderModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? frequency,
    DateTime? scheduledAt,
    bool? isEnabled,
    DateTime? createdAt,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'frequency': frequency,
      'scheduledAt': scheduledAt.toIso8601String(),
      'isEnabled': isEnabled,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      type: json['type']?.toString() ?? 'general',
      frequency: json['frequency']?.toString() ?? 'monthly',
      scheduledAt:
          DateTime.tryParse(json['scheduledAt']?.toString() ?? '') ??
          DateTime.now(),
      isEnabled: json['isEnabled'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}
