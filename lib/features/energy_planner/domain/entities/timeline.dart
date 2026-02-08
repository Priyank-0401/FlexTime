import 'daily_plan.dart';
import 'task.dart';

/// The complete timeline from goal start to deadline.
///
/// Timeline is immutable; rebalancing creates new versions.
class Timeline {
  const Timeline({
    required this.goalId,
    required this.dailyPlans,
    required this.generatedAt,
    this.version = 1,
  });

  /// Reference to the parent learning goal.
  final String goalId;

  /// All daily plans from start to deadline.
  final List<DailyPlan> dailyPlans;

  /// When this timeline was generated or last rebalanced.
  final DateTime generatedAt;

  /// Increments on each rebalance for auditing.
  final int version;

  /// Total number of days in this timeline.
  int get totalDays => dailyPlans.length;

  /// First day of the timeline.
  DateTime get startDate => dailyPlans.first.date;

  /// Last day of the timeline (deadline).
  DateTime get endDate => dailyPlans.last.date;

  /// All tasks across all days.
  List<Task> get allTasks =>
      dailyPlans.expand((day) => day.scheduledTasks).toList();

  /// Total effort scheduled across all days.
  Duration get totalScheduledEffort => dailyPlans.fold(
    Duration.zero,
    (sum, day) => sum + day.totalPlannedDuration,
  );

  /// Tasks from future days (after today).
  List<Task> futureTasks(int currentDayIndex) => dailyPlans
      .where((day) => day.dayIndex > currentDayIndex)
      .expand((day) => day.scheduledTasks)
      .where((task) => task.status == TaskStatus.pending)
      .toList();

  /// Get the daily plan for a specific day index.
  DailyPlan? getPlan(int dayIndex) {
    if (dayIndex < 0 || dayIndex >= dailyPlans.length) return null;
    return dailyPlans[dayIndex];
  }

  /// Get today's plan based on the current date.
  DailyPlan? getTodaysPlan() {
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    return dailyPlans.cast<DailyPlan?>().firstWhere(
      (day) =>
          day!.date.year == todayNormalized.year &&
          day.date.month == todayNormalized.month &&
          day.date.day == todayNormalized.day,
      orElse: () => null,
    );
  }

  /// Create a copy with updated fields.
  Timeline copyWith({
    String? goalId,
    List<DailyPlan>? dailyPlans,
    DateTime? generatedAt,
    int? version,
  }) => Timeline(
    goalId: goalId ?? this.goalId,
    dailyPlans: dailyPlans ?? this.dailyPlans,
    generatedAt: generatedAt ?? this.generatedAt,
    version: version ?? this.version,
  );

  /// Create a new version with updated daily plans.
  Timeline rebalanced(List<DailyPlan> newPlans) => copyWith(
    dailyPlans: newPlans,
    generatedAt: DateTime.now(),
    version: version + 1,
  );

  /// Update a specific day's plan.
  Timeline updateDay(int dayIndex, DailyPlan newPlan) {
    if (dayIndex < 0 || dayIndex >= dailyPlans.length) return this;
    final updated = List<DailyPlan>.from(dailyPlans);
    updated[dayIndex] = newPlan;
    return copyWith(dailyPlans: updated);
  }

  @override
  String toString() =>
      'Timeline($goalId, $totalDays days, v$version, effort: $totalScheduledEffort)';
}
