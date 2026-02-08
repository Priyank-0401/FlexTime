import 'activity_result.dart';

/// A lightweight log entry for completed micro-activities.
///
/// Intentionally minimal - no scores, streaks, or reward data.
/// Just enough to track activity usage patterns.
class MicroProgress {
  const MicroProgress({
    required this.activityId,
    required this.completedAt,
    required this.durationSeconds,
    required this.resultType,
    this.id,
  });

  /// Database ID (null if not yet persisted).
  final int? id;

  /// ID of the activity that was completed.
  final String activityId;

  /// When the activity was completed.
  final DateTime completedAt;

  /// Actual duration in seconds.
  final int durationSeconds;

  /// How the activity ended.
  final ActivityResultType resultType;
}
