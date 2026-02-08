import 'package:flextime_app/core/enums/energy_requirement.dart';

import '../domain/entities/daily_plan.dart';
import '../domain/entities/planner_config.dart';
import '../domain/entities/task.dart';
import '../domain/entities/timeline.dart';

/// Result of a reshaping operation.
class ReshapeResult {
  const ReshapeResult({
    required this.reshapedPlan,
    required this.deferredTasks,
    required this.pulledTasks,
  });

  /// The modified daily plan for today.
  final DailyPlan reshapedPlan;

  /// Tasks that were deferred to future days.
  final List<Task> deferredTasks;

  /// Tasks that were pulled forward from future days.
  final List<Task> pulledTasks;

  /// Whether any changes were made.
  bool get hasChanges => deferredTasks.isNotEmpty || pulledTasks.isNotEmpty;
}

/// Reshapes daily plans based on user's reported energy level.
///
/// Core engine logic:
/// - Low energy: defer demanding tasks, pull in micro-tasks
/// - Medium energy: execute as planned
/// - High energy: pull forward complex tasks from future
class TaskReshapingEngine {
  /// Reshape today's plan based on current energy level.
  ///
  /// Returns a [ReshapeResult] containing the modified plan and
  /// lists of deferred/pulled tasks for the rebalancer.
  ReshapeResult reshape({
    required EnergyState currentEnergy,
    required DailyPlan todayPlan,
    required Timeline timeline,
  }) {
    switch (currentEnergy) {
      case EnergyState.low:
        return _reshapeForLowEnergy(todayPlan, timeline);
      case EnergyState.medium:
        return _reshapeForMediumEnergy(todayPlan);
      case EnergyState.high:
        return _reshapeForHighEnergy(todayPlan, timeline);
    }
  }

  /// Low energy: defer high-energy tasks, pull in micro-tasks.
  ReshapeResult _reshapeForLowEnergy(DailyPlan todayPlan, Timeline timeline) {
    final deferredTasks = <Task>[];
    final keptTasks = <Task>[];
    final pulledTasks = <Task>[];

    // Step 1: Identify tasks too demanding for low energy
    for (final task in todayPlan.scheduledTasks) {
      if (task.energyRequirement == EnergyRequirement.low) {
        keptTasks.add(task);
      } else {
        deferredTasks.add(task.markAsDeferred());
      }
    }

    // Step 2: Calculate remaining capacity
    final currentDuration = keptTasks.fold<Duration>(
      Duration.zero,
      (sum, t) => sum + t.estimatedDuration,
    );
    final remainingCapacity = PlannerConfig.lowEnergyMaxDaily - currentDuration;

    // Step 3: Pull micro-tasks from future days
    if (remainingCapacity > Duration.zero) {
      final microTasks = _findMicroTasks(
        timeline,
        todayPlan.dayIndex,
        remainingCapacity,
        excludeTaskIds: keptTasks.map((t) => t.id).toSet(),
      );
      pulledTasks.addAll(microTasks);
    }

    // Build reshaped plan
    final reshapedPlan = todayPlan.copyWith(
      scheduledTasks: [
        ...keptTasks,
        ...pulledTasks.map((t) => t.markAsPulledForward(todayPlan.dayIndex)),
      ],
      actualEnergy: EnergyState.low,
    );

    return ReshapeResult(
      reshapedPlan: reshapedPlan,
      deferredTasks: deferredTasks,
      pulledTasks: pulledTasks,
    );
  }

  /// Medium energy: execute as planned.
  ReshapeResult _reshapeForMediumEnergy(DailyPlan todayPlan) => ReshapeResult(
    reshapedPlan: todayPlan.copyWith(actualEnergy: EnergyState.medium),
    deferredTasks: const [],
    pulledTasks: const [],
  );

  /// High energy: keep today's tasks, pull forward complex tasks.
  ReshapeResult _reshapeForHighEnergy(DailyPlan todayPlan, Timeline timeline) {
    final pulledTasks = <Task>[];

    // Calculate remaining capacity
    final currentDuration = todayPlan.totalPlannedDuration;
    final remainingCapacity = PlannerConfig.maxDailyEffort - currentDuration;

    // Pull forward high-energy tasks from future
    if (remainingCapacity > Duration.zero) {
      final pullableTasks = _findPullableTasks(
        timeline,
        todayPlan.dayIndex,
        remainingCapacity,
        excludeTaskIds: todayPlan.scheduledTasks.map((t) => t.id).toSet(),
      );
      pulledTasks.addAll(pullableTasks);
    }

    // Build reshaped plan
    final reshapedPlan = todayPlan.copyWith(
      scheduledTasks: [
        ...todayPlan.scheduledTasks,
        ...pulledTasks.map((t) => t.markAsPulledForward(todayPlan.dayIndex)),
      ],
      actualEnergy: EnergyState.high,
    );

    return ReshapeResult(
      reshapedPlan: reshapedPlan,
      deferredTasks: const [],
      pulledTasks: pulledTasks,
    );
  }

  /// Find low-energy micro-tasks from future days.
  List<Task> _findMicroTasks(
    Timeline timeline,
    int currentDayIndex,
    Duration maxDuration, {
    required Set<String> excludeTaskIds,
  }) {
    final candidates =
        timeline
            .futureTasks(currentDayIndex)
            .where((t) => t.energyRequirement == EnergyRequirement.low)
            .where((t) => !excludeTaskIds.contains(t.id))
            .where((t) => t.estimatedDuration <= PlannerConfig.lowEnergyMaxTask)
            .toList()
          ..sort((a, b) {
            // Prefer nearest tasks first
            final dayCompare = (a.currentDayIndex ?? 0).compareTo(
              b.currentDayIndex ?? 0,
            );
            if (dayCompare != 0) return dayCompare;
            // Then by shortest duration
            return a.estimatedDuration.compareTo(b.estimatedDuration);
          });

    return _selectWithinCapacity(candidates, maxDuration);
  }

  /// Find high-energy tasks that can be pulled forward.
  List<Task> _findPullableTasks(
    Timeline timeline,
    int currentDayIndex,
    Duration maxDuration, {
    required Set<String> excludeTaskIds,
  }) {
    final candidates =
        timeline
            .futureTasks(currentDayIndex)
            .where((t) => t.energyRequirement == EnergyRequirement.high)
            .where((t) => !excludeTaskIds.contains(t.id))
            .where(
              (t) => _allDependenciesSatisfied(t, timeline, currentDayIndex),
            )
            .toList()
          // Prefer larger tasks first (more impactful to pull forward)
          ..sort((a, b) => b.estimatedDuration.compareTo(a.estimatedDuration));

    return _selectWithinCapacity(candidates, maxDuration);
  }

  /// Select tasks that fit within capacity.
  List<Task> _selectWithinCapacity(
    List<Task> candidates,
    Duration maxDuration,
  ) {
    final selected = <Task>[];
    var usedDuration = Duration.zero;

    for (final task in candidates) {
      if (usedDuration + task.estimatedDuration <= maxDuration) {
        selected.add(task);
        usedDuration += task.estimatedDuration;
      }
    }

    return selected;
  }

  /// Check if all dependencies are satisfied by today or earlier.
  bool _allDependenciesSatisfied(
    Task task,
    Timeline timeline,
    int currentDayIndex,
  ) {
    if (task.dependsOn.isEmpty) return true;

    final allTasks = timeline.allTasks;
    for (final depId in task.dependsOn) {
      final dep = allTasks.firstWhere(
        (t) => t.id == depId,
        orElse: () => throw StateError('Dependency $depId not found'),
      );
      // Dependency must be completed or scheduled for today or earlier
      if (dep.status != TaskStatus.completed &&
          (dep.currentDayIndex ?? 999) > currentDayIndex) {
        return false;
      }
    }

    return true;
  }
}
