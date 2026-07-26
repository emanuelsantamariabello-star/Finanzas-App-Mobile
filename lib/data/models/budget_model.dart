class BudgetModel {
  const BudgetModel({
    required this.id,
    required this.category,
    required this.limitAmount,
    this.note,
    this.createdAt,
  });

  final String id;
  final String category;
  final double limitAmount;
  final String? note;
  final DateTime? createdAt;

  BudgetModel copyWith({
    String? id,
    String? category,
    double? limitAmount,
    String? note,
    DateTime? createdAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      category: category ?? this.category,
      limitAmount: limitAmount ?? this.limitAmount,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'limitAmount': limitAmount,
      'note': note,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      limitAmount: double.tryParse(json['limitAmount'].toString()) ?? 0,
      note: json['note']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}
