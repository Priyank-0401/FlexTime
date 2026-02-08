import '../../domain/entities/learning_goal.dart';
import '../../domain/entities/task.dart';

/// Data model for LearningGoal with SQLite serialization.
class LearningGoalModel extends LearningGoal {
  const LearningGoalModel({
    required super.id,
    required super.title,
    required super.deadline,
    required super.totalEstimatedEffort,
    required super.createdAt,
    super.targetOutcome,
    super.status,
  });

  /// Create from domain entity.
  factory LearningGoalModel.fromEntity(LearningGoal entity) =>
      LearningGoalModel(
        id: entity.id,
        title: entity.title,
        targetOutcome: entity.targetOutcome,
        deadline: entity.deadline,
        totalEstimatedEffort: entity.totalEstimatedEffort,
        createdAt: entity.createdAt,
        status: entity.status,
      );

  /// Create from SQLite map.
  factory LearningGoalModel.fromMap(Map<String, dynamic> map) =>
      LearningGoalModel(
        id: map['id'] as String,
        title: map['title'] as String,
        targetOutcome: map['target_outcome'] as String?,
        deadline: DateTime.parse(map['deadline'] as String),
        totalEstimatedEffort: Duration(
          minutes: map['total_effort_minutes'] as int,
        ),
        createdAt: DateTime.parse(map['created_at'] as String),
        status: GoalStatus.values.firstWhere(
          (s) => s.name == map['status'],
          orElse: () => GoalStatus.active,
        ),
      );

  /// Convert to SQLite map.
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'target_outcome': targetOutcome,
    'deadline': deadline.toIso8601String(),
    'total_effort_minutes': totalEstimatedEffort.inMinutes,
    'created_at': createdAt.toIso8601String(),
    'status': status.name,
  };

  /// Convert to domain entity.
  LearningGoal toEntity() => LearningGoal(
    id: id,
    title: title,
    targetOutcome: targetOutcome,
    deadline: deadline,
    totalEstimatedEffort: totalEstimatedEffort,
    createdAt: createdAt,
    status: status,
  );
}
