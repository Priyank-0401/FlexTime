import '../../../../../core/enums/energy_requirement.dart';

/// Task lifecycle status.
enum TaskStatus {
  /// Task is scheduled but not yet completed.
  pending,

  /// Task has been completed successfully.
  completed,

  /// Task was deferred due to low energy—will be rescheduled.
  deferred,

  /// Task was pulled forward from a future day.
  pulledForward,
}

/// Goal lifecycle status.
enum GoalStatus {
  /// Goal is actively being worked on.
  active,

  /// Goal has been completed successfully.
  completed,

  /// Goal was abandoned by the user.
  abandoned,
}

/// A single unit of work within a learning goal.
///
/// Tasks are immutable value objects. Status changes create new instances.
class Task {
  const Task({
    required this.id,
    required this.goalId,
    required this.title,
    required this.description,
    required this.estimatedDuration,
    required this.energyRequirement,
    required this.createdAt,
    required this.originalDayIndex,
    this.dependsOn = const [],
    this.status = TaskStatus.pending,
    this.currentDayIndex,
  });

  /// Unique identifier for this task.
  final String id;

  /// Reference to the parent learning goal.
  final String goalId;

  /// Short title of the task.
  final String title;

  /// detailed description.
  final String description;

  /// Estimated time to complete.
  final Duration estimatedDuration;

  /// Energy level required.
  final EnergyRequirement energyRequirement;

  /// When created.
  final DateTime createdAt;

  /// IDs of tasks that must be completed before this one.
  final List<String> dependsOn;

  /// Current lifecycle status.
  final TaskStatus status;

  /// Original position in the timeline (0-based day offset from goal start).
  final int originalDayIndex;

  /// Current position in the timeline (null if unscheduled).
  final int? currentDayIndex;

  /// Whether this task has been completed.
  bool get isCompleted => status == TaskStatus.completed;

  /// Whether this task is still pending.
  bool get isPending => status == TaskStatus.pending;

  /// Helper for minutes.
  int get estimatedMinutes => estimatedDuration.inMinutes;

  /// Create a copy with updated fields.
  Task copyWith({
    String? id,
    String? goalId,
    String? title,
    String? description,
    Duration? estimatedDuration,
    EnergyRequirement? energyRequirement,
    DateTime? createdAt,
    List<String>? dependsOn,
    TaskStatus? status,
    int? originalDayIndex,
    int? currentDayIndex,
  }) => Task(
    id: id ?? this.id,
    goalId: goalId ?? this.goalId,
    title: title ?? this.title,
    description: description ?? this.description,
    estimatedDuration: estimatedDuration ?? this.estimatedDuration,
    energyRequirement: energyRequirement ?? this.energyRequirement,
    createdAt: createdAt ?? this.createdAt,
    dependsOn: dependsOn ?? this.dependsOn,
    status: status ?? this.status,
    originalDayIndex: originalDayIndex ?? this.originalDayIndex,
    currentDayIndex: currentDayIndex ?? this.currentDayIndex,
  );

  /// Mark this task as deferred (for low-energy days).
  Task markAsDeferred() => copyWith(status: TaskStatus.deferred);

  /// Mark this task as pulled forward from its original day.
  Task markAsPulledForward(int newDayIndex) =>
      copyWith(status: TaskStatus.pulledForward, currentDayIndex: newDayIndex);

  /// Mark this task as completed.
  Task markAsCompleted() => copyWith(status: TaskStatus.completed);

  /// Reschedule this task to a new day.
  Task reschedule(int newDayIndex) => copyWith(currentDayIndex: newDayIndex);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Task($title, $status)';
}
