import '../domain/entities/learning_goal.dart';
import '../domain/entities/planner_config.dart';
import '../domain/entities/timeline.dart';

/// Exception thrown when a planner invariant is violated.
class InvariantViolationException implements Exception {
  const InvariantViolationException(this.message);

  final String message;

  @override
  String toString() => 'InvariantViolationException: $message';
}

/// Validates planner invariants.
///
/// Ensures the four core invariants are never broken:
/// 1. Deadline Invariant: Goal deadline is never violated
/// 2. Effort Conservation: Total work remains constant
/// 3. No Guilt Invariant: Enforced by TaskStatus enum design
/// 4. Cognitive Load Invariant: Daily plans don't exceed limits
abstract final class InvariantValidator {
  InvariantValidator._();

  /// Validate all invariants. Throws [InvariantViolationException] on failure.
  static void validate(LearningGoal goal, Timeline timeline) {
    validateDeadline(goal, timeline);
    validateEffortConservation(goal, timeline);
    validateCognitiveLoad(timeline);
  }

  /// Validate that the timeline respects the goal's deadline.
  static void validateDeadline(LearningGoal goal, Timeline timeline) {
    if (timeline.dailyPlans.isEmpty) return;

    final lastDay = timeline.dailyPlans.last.date;
    final deadlineNormalized = DateTime(
      goal.deadline.year,
      goal.deadline.month,
      goal.deadline.day,
    );
    final lastDayNormalized = DateTime(
      lastDay.year,
      lastDay.month,
      lastDay.day,
    );

    if (lastDayNormalized.isAfter(deadlineNormalized)) {
      throw InvariantViolationException(
        'Deadline violated: Last planned day $lastDayNormalized exceeds deadline $deadlineNormalized',
      );
    }
  }

  /// Validate that total effort is conserved.
  static void validateEffortConservation(LearningGoal goal, Timeline timeline) {
    final totalScheduled = timeline.totalScheduledEffort;
    final expected = goal.totalEstimatedEffort;

    // Allow small tolerance for rounding
    final difference = (totalScheduled.inMinutes - expected.inMinutes).abs();
    if (difference > 1) {
      throw InvariantViolationException(
        'Effort conservation violated: Scheduled $totalScheduled vs expected $expected',
      );
    }
  }

  /// Validate that no day exceeds cognitive load limits.
  ///
  /// Note: During compression, we allow up to 25% overflow to preserve deadline.
  static void validateCognitiveLoad(Timeline timeline) {
    final maxAllowed = Duration(
      milliseconds: (PlannerConfig.maxDailyEffort.inMilliseconds * 1.25)
          .round(),
    );

    for (final day in timeline.dailyPlans) {
      if (day.totalPlannedDuration > maxAllowed) {
        throw InvariantViolationException(
          'Cognitive load exceeded on ${day.date}: ${day.totalPlannedDuration} (max: $maxAllowed)',
        );
      }
    }
  }

  /// Validate a single day's cognitive load (soft validation, returns bool).
  static bool isDayWithinLimits(Duration dayDuration) =>
      dayDuration <= PlannerConfig.maxDailyEffort;
}
