import '../domain/entities/daily_plan.dart';
import '../domain/entities/learning_goal.dart';
import '../domain/entities/planner_config.dart';
import '../domain/entities/task.dart';
import '../domain/entities/timeline.dart';

/// Generates initial timelines from learning goals.
///
/// Distributes tasks across days without exceeding cognitive load limits.
class TimelineGenerator {
  /// Generate a timeline for a learning goal with provided tasks.
  ///
  /// Tasks are distributed to respect:
  /// - Maximum daily effort (4 hours default)
  /// - Energy requirement ordering (mix across days)
  /// - Buffer factor for low-energy absorption
  Timeline generate({
    required LearningGoal goal,
    required List<Task> tasks,
    DateTime? startDate,
  }) {
    final start = startDate ?? DateTime.now();
    final startNormalized = DateTime(start.year, start.month, start.day);
    final deadlineNormalized = DateTime(
      goal.deadline.year,
      goal.deadline.month,
      goal.deadline.day,
    );

    final totalDays = deadlineNormalized.difference(startNormalized).inDays + 1;
    if (totalDays <= 0) {
      throw ArgumentError('Deadline must be after start date');
    }

    // Calculate effective daily capacity with buffer
    final effectiveMaxDaily = Duration(
      milliseconds:
          (PlannerConfig.maxDailyEffort.inMilliseconds *
                  (1 - PlannerConfig.bufferFactor))
              .round(),
    );

    // Sort tasks by dependencies first, then by energy requirement
    final sortedTasks = _sortByDependencies(tasks);

    // Distribute tasks across days
    final dailyPlans = <DailyPlan>[];
    var currentDayIndex = 0;
    var currentDayTasks = <Task>[];
    var currentDayDuration = Duration.zero;

    for (final task in sortedTasks) {
      // Check if task fits in current day
      if (currentDayDuration + task.estimatedDuration > effectiveMaxDaily &&
          currentDayTasks.isNotEmpty) {
        // Finalize current day and start new day
        dailyPlans.add(
          DailyPlan(
            date: startNormalized.add(Duration(days: currentDayIndex)),
            dayIndex: currentDayIndex,
            scheduledTasks: currentDayTasks,
          ),
        );
        currentDayIndex++;
        currentDayTasks = [];
        currentDayDuration = Duration.zero;
      }

      // Add task to current day
      final scheduledTask = task.copyWith(
        currentDayIndex: currentDayIndex,
        originalDayIndex: currentDayIndex,
      );
      currentDayTasks.add(scheduledTask);
      currentDayDuration += task.estimatedDuration;
    }

    // Finalize last day
    if (currentDayTasks.isNotEmpty) {
      dailyPlans.add(
        DailyPlan(
          date: startNormalized.add(Duration(days: currentDayIndex)),
          dayIndex: currentDayIndex,
          scheduledTasks: currentDayTasks,
        ),
      );
    }

    // Pad remaining days to deadline (allows buffer absorption)
    for (var i = dailyPlans.length; i < totalDays; i++) {
      dailyPlans.add(
        DailyPlan(
          date: startNormalized.add(Duration(days: i)),
          dayIndex: i,
        ),
      );
    }

    return Timeline(
      goalId: goal.id,
      dailyPlans: dailyPlans,
      generatedAt: DateTime.now(),
    );
  }

  /// Sort tasks respecting dependencies using topological sort.
  List<Task> _sortByDependencies(List<Task> tasks) {
    final taskMap = {for (final t in tasks) t.id: t};
    final visited = <String>{};
    final result = <Task>[];

    void visit(Task task) {
      if (visited.contains(task.id)) return;
      visited.add(task.id);

      for (final depId in task.dependsOn) {
        final dep = taskMap[depId];
        if (dep != null) visit(dep);
      }

      result.add(task);
    }

    tasks.forEach(visit);

    return result;
  }
}
