import '../../domain/entities/goal_entity.dart';

class GoalModel extends GoalEntity {
  GoalModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.description,
    required super.targetAmount,
    super.currentAmount,
    required super.type,
    super.deadline,
    required super.createdAt,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      targetAmount: double.tryParse(json['target_amount']?.toString() ?? '0') ?? 0.0,
      currentAmount: double.tryParse(json['current_amount']?.toString() ?? '0') ?? 0.0,
      type: _parseGoalType(json['type']?.toString()),
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static GoalType _parseGoalType(String? value) {
    switch (value?.toLowerCase()) {
      case 'savings':
        return GoalType.savings;
      case 'budget':
        return GoalType.budget;
      default:
        return GoalType.savings;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'type': type.name,
      'deadline': deadline?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
