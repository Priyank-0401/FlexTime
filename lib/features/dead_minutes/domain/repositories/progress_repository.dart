import '../entities/micro_progress.dart';

/// Repository interface for micro-progress logging.
abstract class ProgressRepository {
  /// Log a new progress entry.
  Future<void> logProgress(MicroProgress progress);

  /// Get recent progress entries.
  Future<List<MicroProgress>> getRecentProgress({int limit = 20});

  /// Get progress count for today.
  Future<int> getTodayCount();

  /// Get all progress for a specific activity.
  Future<List<MicroProgress>> getProgressForActivity(String activityId);
}
