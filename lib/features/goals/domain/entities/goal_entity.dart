enum GoalType { savings, budget }

class GoalEntity {
  final String id;
  final String userId;
  final String title;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final GoalType type;
  final DateTime? deadline;
  final DateTime createdAt;

  GoalEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.type,
    this.deadline,
    required this.createdAt,
  });

  double get progress => (currentAmount / targetAmount).clamp(0.0, 1.0);
}
