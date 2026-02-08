import 'task.dart';

/// Energy state selected by user before each study session.
///
/// This is the user's self-reported energy level, distinct from
/// [EnergyRequirement] which is the task's inherent complexity.
enum EnergyState {
  /// User feels tired, distracted, or has low focus capacity.
  low,

  /// User feels normal, able to handle standard cognitive load.
  medium,

  /// User feels energized, focused, ready for complex work.
  high,
}

/// A single day's workload.
///
/// DailyPlan is immutable; reshaping creates new instances.
class DailyPlan {
  const DailyPlan({
    required this.date,
    required this.dayIndex,
    this.scheduledTasks = const [],
    this.actualEnergy,
  });

  /// The calendar date for this plan.
  final DateTime date;

  /// 0-based offset from the goal's start date.
  final int dayIndex;

  /// Tasks scheduled for this day.
  final List<Task> scheduledTasks;

  /// User's reported energy when they started the session.
  /// Null if the user hasn't started studying this day yet.
  final EnergyState? actualEnergy;

  /// Total planned duration for this day.
  Duration get totalPlannedDuration => scheduledTasks.fold(
    Duration.zero,
    (sum, task) => sum + task.estimatedDuration,
  );

  /// Number of pending tasks.
  int get pendingCount =>
      scheduledTasks.where((t) => t.status == TaskStatus.pending).length;

  /// Number of completed tasks.
  int get completedCount =>
      scheduledTasks.where((t) => t.status == TaskStatus.completed).length;

  /// Whether this day has any work scheduled.
  bool get isEmpty => scheduledTasks.isEmpty;

  /// Whether all tasks for this day are completed.
  bool get isComplete =>
      scheduledTasks.isNotEmpty &&
      scheduledTasks.every((t) => t.status == TaskStatus.completed);

  /// Create a copy with updated fields.
  DailyPlan copyWith({
    DateTime? date,
    int? dayIndex,
    List<Task>? scheduledTasks,
    EnergyState? actualEnergy,
  }) => DailyPlan(
    date: date ?? this.date,
    dayIndex: dayIndex ?? this.dayIndex,
    scheduledTasks: scheduledTasks ?? this.scheduledTasks,
    actualEnergy: actualEnergy ?? this.actualEnergy,
  );

  /// Add a task to this day's schedule.
  DailyPlan addTask(Task task) =>
      copyWith(scheduledTasks: [...scheduledTasks, task]);

  /// Remove a task from this day's schedule.
  DailyPlan removeTask(String taskId) => copyWith(
    scheduledTasks: scheduledTasks.where((t) => t.id != taskId).toList(),
  );

  /// Replace a task in this day's schedule.
  DailyPlan replaceTask(Task oldTask, Task newTask) => copyWith(
    scheduledTasks: scheduledTasks
        .map((t) => t.id == oldTask.id ? newTask : t)
        .toList(),
  );

  /// Set the user's reported energy for this day.
  DailyPlan withEnergy(EnergyState energy) => copyWith(actualEnergy: energy);

  @override
  String toString() =>
      'DailyPlan(day $dayIndex, ${scheduledTasks.length} tasks, $totalPlannedDuration)';
}
