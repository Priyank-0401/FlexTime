import 'dart:async';

import 'package:flutter/material.dart';

import '../activities/base_activity.dart';
import '../domain/entities/micro_activity.dart';
import 'activity_registry.dart';
import 'lifecycle_manager.dart';

/// Global navigator key for notification-driven navigation.
///
/// This allows us to navigate without BuildContext,
/// enabling notification taps to bypass the main app shell.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Directly launches a micro-activity, bypassing the main app shell.
///
/// Used by NotificationController when user taps the persistent notification.
class ActivityLauncher {
  ActivityLauncher._();

  static final ActivityLauncher instance = ActivityLauncher._();

  final ActivityRegistry _registry = ActivityRegistry.instance;
  final LifecycleManager _lifecycleManager = LifecycleManager.instance;

  /// Launch a micro-activity directly.
  ///
  /// [energyLevel] - Optional filter for activity selection.
  /// Returns true if activity was launched, false if no activity available.
  Future<bool> launchActivity({EnergyLevel? energyLevel}) async {
    // Select an activity
    final activity = _registry.selectActivity(energyLevel: energyLevel);
    if (activity == null) {
      return false;
    }

    // Start the lifecycle
    _lifecycleManager.startActivity(activity);

    // Navigate directly to activity page (bypasses app shell)
    unawaited(
      navigatorKey.currentState?.push(
        MaterialPageRoute<void>(
          builder: (_) => _ActivityHostPage(
            activity: activity,
            lifecycleManager: _lifecycleManager,
          ),
          fullscreenDialog: true,
        ),
      ),
    );

    return true;
  }
}

/// Internal full-screen host for micro-activities.
///
/// This is a minimal wrapper that delegates to the activity's content.
class _ActivityHostPage extends StatefulWidget {
  const _ActivityHostPage({
    required this.activity,
    required this.lifecycleManager,
  });

  final BaseActivity activity;
  final LifecycleManager lifecycleManager;

  @override
  State<_ActivityHostPage> createState() => _ActivityHostPageState();
}

class _ActivityHostPageState extends State<_ActivityHostPage> {
  @override
  void initState() {
    super.initState();
    widget.activity.onStart();
  }

  void _handleComplete() {
    widget.activity.onComplete();
    widget.lifecycleManager.completeActivity();
    Navigator.of(context).pop();
  }

  void _handleAbort() {
    widget.activity.onAbort();
    widget.lifecycleManager.abortActivity();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Timer bar at top
            _TimerBar(
              durationSeconds: widget.activity.durationSeconds,
              onTimeUp: _handleComplete,
            ),
            // Activity content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: widget.activity.buildContent(
                  onComplete: _handleComplete,
                  onAbort: _handleAbort,
                ),
              ),
            ),
            // Exit button at bottom
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton.icon(
                onPressed: _handleAbort,
                icon: const Icon(Icons.close),
                label: const Text('Exit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Timer bar showing remaining time.
class _TimerBar extends StatefulWidget {
  const _TimerBar({required this.durationSeconds, required this.onTimeUp});

  final int durationSeconds;
  final VoidCallback onTimeUp;

  @override
  State<_TimerBar> createState() => _TimerBarState();
}

class _TimerBarState extends State<_TimerBar> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
            vsync: this,
            duration: Duration(seconds: widget.durationSeconds),
          )
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              widget.onTimeUp();
            }
          })
          ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final remaining = (widget.durationSeconds * (1 - _controller.value))
            .round();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatTime(remaining),
                    style: theme.textTheme.titleMedium,
                  ),
                  Icon(
                    Icons.timer_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            LinearProgressIndicator(
              value: 1 - _controller.value,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ],
        );
      },
    );
  }
}
