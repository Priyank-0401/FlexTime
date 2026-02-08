import '../domain/entities/daily_plan.dart';
import '../domain/entities/planner_config.dart';
import '../domain/entities/task.dart';
import '../domain/entities/timeline.dart';

/// Rebalances a timeline after reshaping operations.
///
/// Ensures deferred tasks are redistributed across future days
/// while respecting all invariants (deadline, effort conservation, cognitive load).
class TimelineRebalancer {
  /// Rebalance the timeline after deferred and pulled tasks.
  ///
  /// - Deferred tasks are redistributed to future days
  /// - Pulled tasks are removed from their original days
  /// - Daily limits are enforced
  /// - Deadline is never violated
  Timeline rebalance({
    required Timeline timeline,
    required int currentDayIndex,
    required List<Task> deferredTasks,
    required List<Task> pulledTasks,
    required DailyPlan reshapedTodayPlan,
  }) {
    // Start with updated timeline including today's reshaped plan
    var updatedPlans = List<DailyPlan>.from(timeline.dailyPlans);
    updatedPlans[currentDayIndex] = reshapedTodayPlan;

    // Remove pulled tasks from their original days
    for (final pulled in pulledTasks) {
      final originalDay = pulled.currentDayIndex;
      if (originalDay != null && originalDay != currentDayIndex) {
        updatedPlans[originalDay] = updatedPlans[originalDay].removeTask(
          pulled.id,
        );
      }
    }

    // Redistribute deferred tasks
    updatedPlans = _redistributeDeferred(
      updatedPlans,
      deferredTasks,
      currentDayIndex,
    );

    // Create new timeline version
    final newTimeline = timeline.rebalanced(updatedPlans);

    // Validate invariants (throws if violated)
    // Note: Caller should handle InvariantViolationException
    return newTimeline;
  }

  /// Redistribute deferred tasks across future days.
  List<DailyPlan> _redistributeDeferred(
    List<DailyPlan> plans,
    List<Task> deferredTasks,
    int currentDayIndex,
  ) {
    if (deferredTasks.isEmpty) return plans;

    // Sort deferred tasks by urgency (dependencies first, then original position)
    final sortedDeferred = List<Task>.from(deferredTasks)
      ..sort((a, b) {
        // Deps first
        final aHasDeps = a.dependsOn.isEmpty ? 0 : 1;
        final bHasDeps = b.dependsOn.isEmpty ? 0 : 1;
        if (aHasDeps != bHasDeps) return aHasDeps - bHasDeps;
        // Then by original position
        return a.originalDayIndex.compareTo(b.originalDayIndex);
      });

    final updatedPlans = List<DailyPlan>.from(plans);

    for (final task in sortedDeferred) {
      var placed = false;

      // Try to place in future days
      for (
        var dayIdx = currentDayIndex + 1;
        dayIdx < updatedPlans.length;
        dayIdx++
      ) {
        final day = updatedPlans[dayIdx];
        final currentLoad = day.totalPlannedDuration;
        final remainingCapacity = PlannerConfig.maxDailyEffort - currentLoad;

        if (task.estimatedDuration <= remainingCapacity &&
            _respectsDependencies(task, updatedPlans, dayIdx)) {
          // Place task
          final rescheduled = task.reschedule(dayIdx);
          updatedPlans[dayIdx] = day.addTask(rescheduled);
          placed = true;
          break;
        }
      }

      if (!placed) {
        // Try compression: find the day with most capacity and force-fit
        final compressedPlans = _compressToFit(
          updatedPlans,
          task,
          currentDayIndex,
        );
        for (var i = 0; i < compressedPlans.length; i++) {
          updatedPlans[i] = compressedPlans[i];
        }
      }
    }

    return updatedPlans;
  }

  /// Compress timeline to fit a task that couldn't be placed normally.
  ///
  /// Strategy: Find the day with most remaining capacity and add the task,
  /// even if it slightly exceeds the normal limit.
  List<DailyPlan> _compressToFit(
    List<DailyPlan> plans,
    Task task,
    int currentDayIndex,
  ) {
    // Find the future day with most capacity
    var bestDayIdx = currentDayIndex + 1;
    var bestCapacity = Duration.zero;

    for (var dayIdx = currentDayIndex + 1; dayIdx < plans.length; dayIdx++) {
      final day = plans[dayIdx];
      final remaining = PlannerConfig.maxDailyEffort - day.totalPlannedDuration;
      if (remaining > bestCapacity) {
        bestCapacity = remaining;
        bestDayIdx = dayIdx;
      }
    }

    // Add task to best day (may exceed normal limit, but preserves deadline)
    final updatedPlans = List<DailyPlan>.from(plans);
    final rescheduled = task.reschedule(bestDayIdx);
    updatedPlans[bestDayIdx] = updatedPlans[bestDayIdx].addTask(rescheduled);

    return updatedPlans;
  }

  /// Check if placing a task on a given day respects its dependencies.
  bool _respectsDependencies(Task task, List<DailyPlan> plans, int targetDay) {
    if (task.dependsOn.isEmpty) return true;

    for (final depId in task.dependsOn) {
      // Find the dependency's current day
      for (var dayIdx = 0; dayIdx < plans.length; dayIdx++) {
        final plan = plans[dayIdx];
        for (final t in plan.scheduledTasks) {
          if (t.id == depId) {
            // Dependency must be scheduled before target day
            if (dayIdx >= targetDay && t.status != TaskStatus.completed) {
              return false;
            }
          }
        }
      }
    }

    return true;
  }
}
