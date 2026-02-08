import '../activities/base_activity.dart';
import '../domain/entities/activity_result.dart';
import '../domain/usecases/log_completion_usecase.dart';

/// Activity lifecycle states.
enum ActivityState { idle, running, completed, aborted }

/// Manages the lifecycle of a micro-activity.
///
/// Enforces the Start → Running → Complete/Abort state machine.
class LifecycleManager {
  LifecycleManager._();

  static final LifecycleManager instance = LifecycleManager._();

  ActivityState _state = ActivityState.idle;
  BaseActivity? _currentActivity;
  DateTime? _startTime;

  /// Current lifecycle state.
  ActivityState get state => _state;

  /// Currently running activity.
  BaseActivity? get currentActivity => _currentActivity;

  /// Whether an activity is currently running.
  bool get isRunning => _state == ActivityState.running;

  /// The completion logger (optional, set by provider).
  LogCompletionUseCase? completionLogger;

  /// Start a new activity.
  ///
  /// Throws if already running.
  void startActivity(BaseActivity activity) {
    if (_state == ActivityState.running) {
      throw StateError('Cannot start activity while another is running');
    }

    _currentActivity = activity;
    _startTime = DateTime.now();
    _state = ActivityState.running;
  }

  /// Complete the current activity.
  void completeActivity() {
    if (_state != ActivityState.running) {
      return; // Silently ignore if not running
    }

    final duration = DateTime.now().difference(_startTime!);
    _state = ActivityState.completed;

    _logResult(ActivityResultType.completed, duration);
    _reset();
  }

  /// Abort the current activity.
  void abortActivity() {
    if (_state != ActivityState.running) {
      return;
    }

    final duration = DateTime.now().difference(_startTime!);
    _state = ActivityState.aborted;

    _logResult(ActivityResultType.aborted, duration);
    _reset();
  }

  /// Handle timeout (timer expired).
  void timeoutActivity() {
    if (_state != ActivityState.running) {
      return;
    }

    final duration = Duration(seconds: _currentActivity!.durationSeconds);
    _state = ActivityState.completed;

    _logResult(ActivityResultType.timedOut, duration);
    _reset();
  }

  void _logResult(ActivityResultType type, Duration duration) {
    if (_currentActivity == null) return;

    final result = ActivityResult(
      activityId: _currentActivity!.id,
      type: type,
      actualDuration: duration,
      timestamp: DateTime.now(),
    );

    // Log asynchronously, don't block
    completionLogger?.call(result);
  }

  void _reset() {
    _currentActivity = null;
    _startTime = null;
    _state = ActivityState.idle;
  }
}
