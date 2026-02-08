import 'task.dart';

/// The user's learning commitment.
///
/// A learning goal defines what the user wants to achieve, by when,
/// and how much effort is estimated. Once created, goals are immutable
/// except for status changes.
class LearningGoal {
  const LearningGoal({
    required this.id,
    required this.title,
    required this.deadline,
    required this.totalEstimatedEffort,
    required this.createdAt,
    this.targetOutcome,
    this.status = GoalStatus.active,
  });

  /// Unique identifier for this goal.
  final String id;

  /// User-friendly title (e.g., "Master Flutter State Management").
  final String title;

  /// Optional description of what success looks like.
  final String? targetOutcome;

  /// Alias for targetOutcome to satisfy new requirements.
  String? get description => targetOutcome;

  /// The date by which all tasks must be completed.
  final DateTime deadline;

  /// Total estimated effort to complete all tasks.
  final Duration totalEstimatedEffort;

  /// When this goal was created.
  final DateTime createdAt;

  /// Current lifecycle status.
  final GoalStatus status;

  /// Whether this goal is still active.
  bool get isActive => status == GoalStatus.active;

  /// Whether this goal has been completed.
  bool get isCompleted => status == GoalStatus.completed;

  /// Number of days remaining until deadline.
  int get daysRemaining => deadline.difference(DateTime.now()).inDays;

  /// Create a copy with updated fields.
  LearningGoal copyWith({
    String? id,
    String? title,
    String? targetOutcome,
    DateTime? deadline,
    Duration? totalEstimatedEffort,
    DateTime? createdAt,
    GoalStatus? status,
  }) => LearningGoal(
    id: id ?? this.id,
    title: title ?? this.title,
    targetOutcome: targetOutcome ?? this.targetOutcome,
    deadline: deadline ?? this.deadline,
    totalEstimatedEffort: totalEstimatedEffort ?? this.totalEstimatedEffort,
    createdAt: createdAt ?? this.createdAt,
    status: status ?? this.status,
  );

  /// Mark this goal as completed.
  LearningGoal markAsCompleted() => copyWith(status: GoalStatus.completed);

  /// Mark this goal as abandoned.
  LearningGoal markAsAbandoned() => copyWith(status: GoalStatus.abandoned);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningGoal &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'LearningGoal($title, deadline: $deadline, status: $status)';
}
