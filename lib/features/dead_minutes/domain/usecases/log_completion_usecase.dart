import '../entities/activity_result.dart';
import '../entities/micro_progress.dart';
import '../repositories/progress_repository.dart';

/// Use case: Log completion of a micro-activity.
///
/// Creates a MicroProgress entry in local storage.
/// No rewards, no streaks - just a simple log.
class LogCompletionUseCase {
  LogCompletionUseCase(this._repository);

  final ProgressRepository _repository;

  /// Log an activity result.
  Future<void> call(ActivityResult result) async {
    final progress = MicroProgress(
      activityId: result.activityId,
      completedAt: result.timestamp,
      durationSeconds: result.actualDuration.inSeconds,
      resultType: result.type,
    );

    await _repository.logProgress(progress);
  }
}
