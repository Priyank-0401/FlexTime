import '../entities/daily_plan.dart';
import '../entities/timeline.dart';

/// Repository interface for timeline persistence.
abstract class TimelineRepository {
  /// Get the timeline for a specific goal.
  Future<Timeline?> getTimeline(String goalId);

  /// Save or update a timeline.
  Future<void> saveTimeline(Timeline timeline);

  /// Get today's plan for a goal.
  Future<DailyPlan?> getTodaysPlan(String goalId);

  /// Update a specific day's plan.
  Future<void> updateDailyPlan(String goalId, DailyPlan plan);

  /// Log the user's energy selection for a day.
  Future<void> logEnergySelection(
    String goalId,
    DateTime date,
    EnergyState energy,
  );

  /// Get energy history for a goal.
  Future<Map<DateTime, EnergyState>> getEnergyHistory(String goalId);

  /// Save a timeline snapshot for debugging/auditing.
  Future<void> saveSnapshot(Timeline timeline);
}
