import 'package:flutter/material.dart';

import '../domain/entities/micro_activity.dart';

/// Base contract for all DeadMinutes micro-activities.
///
/// Activities must be:
/// - Stateless or minimally stateful
/// - Non-addictive by design
/// - Completable in 3-4 minutes
/// - Self-contained with explicit start/end
abstract class BaseActivity {
  /// Unique identifier for this activity instance.
  String get id;

  /// Human-readable title shown to user.
  String get title;

  /// Duration in seconds (180-240s recommended).
  int get durationSeconds;

  /// Energy level this activity suits.
  EnergyLevel get suitableEnergy;

  /// Category for filtering (e.g., 'knowledge', 'wellness', 'creativity').
  String get category;

  /// Build the activity's content UI.
  ///
  /// This is the main interactive area of the activity.
  ///
  /// [onComplete] - Call when user completes the activity normally.
  /// [onAbort] - Call if user exits early by choice.
  Widget buildContent({
    required VoidCallback onComplete,
    required VoidCallback onAbort,
  });

  /// Called when activity starts.
  ///
  /// Override for initialization (e.g., loading data, starting timers).
  void onStart() {}

  /// Called when activity completes normally.
  ///
  /// Override for cleanup or state finalization.
  void onComplete() {}

  /// Called when activity is aborted early.
  ///
  /// Override for cleanup without saving progress.
  void onAbort() {}
}
