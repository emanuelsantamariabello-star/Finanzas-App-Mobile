class FinancialGoalModel {
  const FinancialGoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    this.note,
    this.isCompleted = false,
    this.createdAt,
  });

  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final String? note;
  final bool isCompleted;
  final DateTime? createdAt;

  double get progress {
    if (targetAmount <= 0) return 0;
    final value = currentAmount / targetAmount;
    if (value < 0) return 0;
    if (value > 1) return 1;
    return value;
  }

  double get remainingAmount {
    final remaining = targetAmount - currentAmount;
    return remaining > 0 ? remaining : 0;
  }

  FinancialGoalModel copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? note,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return FinancialGoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      note: note ?? this.note,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
      'note': note,
      'isCompleted': isCompleted,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory FinancialGoalModel.fromJson(Map<String, dynamic> json) {
    return FinancialGoalModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      targetAmount: double.tryParse(json['targetAmount'].toString()) ?? 0,
      currentAmount: double.tryParse(json['currentAmount'].toString()) ?? 0,
      targetDate:
          DateTime.tryParse(json['targetDate']?.toString() ?? '') ??
          DateTime.now(),
      note: json['note']?.toString(),
      isCompleted: json['isCompleted'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}
