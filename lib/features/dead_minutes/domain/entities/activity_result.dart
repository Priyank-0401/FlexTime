/// Activity result types.
enum ActivityResultType {
  /// User completed the activity normally.
  completed,

  /// User exited early by choice.
  aborted,

  /// Timer ran out (auto-complete).
  timedOut,
}

/// Result of a completed micro-activity session.
///
/// Used for logging and analytics. Intentionally minimal
/// to avoid gamification creep.
class ActivityResult {
  const ActivityResult({
    required this.activityId,
    required this.type,
    required this.actualDuration,
    required this.timestamp,
  });

  /// ID of the activity that was run.
  final String activityId;

  /// How the activity ended.
  final ActivityResultType type;

  /// Actual time spent (may differ from planned duration).
  final Duration actualDuration;

  /// When the activity completed.
  final DateTime timestamp;
}
