import 'dart:async';

import 'package:flutter/material.dart';

import '../domain/entities/micro_activity.dart';
import 'base_activity.dart';

/// A guided breathing micro-activity.
///
/// Simple inhale-hold-exhale pattern with visual guidance.
/// Low-energy, calming activity suitable for any moment.
class BreathingActivity extends BaseActivity {
  BreathingActivity({
    this.inhaleSeconds = 4,
    this.holdSeconds = 4,
    this.exhaleSeconds = 4,
    this.cycles = 6,
  });

  final int inhaleSeconds;
  final int holdSeconds;
  final int exhaleSeconds;
  final int cycles;

  @override
  String get id => 'breathing_$inhaleSeconds$holdSeconds$exhaleSeconds';

  @override
  String get title => 'Calm Breathing';

  @override
  int get durationSeconds =>
      (inhaleSeconds + holdSeconds + exhaleSeconds) * cycles;

  @override
  EnergyLevel get suitableEnergy => EnergyLevel.low;

  @override
  String get category => 'wellness';

  @override
  Widget buildContent({
    required VoidCallback onComplete,
    required VoidCallback onAbort,
  }) => _BreathingContent(
    inhaleSeconds: inhaleSeconds,
    holdSeconds: holdSeconds,
    exhaleSeconds: exhaleSeconds,
    cycles: cycles,
    onComplete: onComplete,
  );
}

enum _BreathPhase { inhale, hold, exhale }

class _BreathingContent extends StatefulWidget {
  const _BreathingContent({
    required this.inhaleSeconds,
    required this.holdSeconds,
    required this.exhaleSeconds,
    required this.cycles,
    required this.onComplete,
  });

  final int inhaleSeconds;
  final int holdSeconds;
  final int exhaleSeconds;
  final int cycles;
  final VoidCallback onComplete;

  @override
  State<_BreathingContent> createState() => _BreathingContentState();
}

class _BreathingContentState extends State<_BreathingContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  _BreathPhase _phase = _BreathPhase.inhale;
  int _currentCycle = 1;
  Timer? _phaseTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _startPhase(_BreathPhase.inhale);
  }

  @override
  void dispose() {
    _controller.dispose();
    _phaseTimer?.cancel();
    super.dispose();
  }

  void _startPhase(_BreathPhase phase) {
    setState(() => _phase = phase);

    final duration = switch (phase) {
      _BreathPhase.inhale => widget.inhaleSeconds,
      _BreathPhase.hold => widget.holdSeconds,
      _BreathPhase.exhale => widget.exhaleSeconds,
    };

    _controller.duration = Duration(seconds: duration);

    if (phase == _BreathPhase.inhale) {
      _controller.forward(from: 0);
    } else if (phase == _BreathPhase.exhale) {
      _controller.reverse(from: 1);
    }

    _phaseTimer = Timer(Duration(seconds: duration), _nextPhase);
  }

  void _nextPhase() {
    switch (_phase) {
      case _BreathPhase.inhale:
        _startPhase(_BreathPhase.hold);
      case _BreathPhase.hold:
        _startPhase(_BreathPhase.exhale);
      case _BreathPhase.exhale:
        if (_currentCycle >= widget.cycles) {
          widget.onComplete();
        } else {
          _currentCycle++;
          _startPhase(_BreathPhase.inhale);
        }
    }
  }

  String get _phaseText => switch (_phase) {
    _BreathPhase.inhale => 'Breathe In',
    _BreathPhase.hold => 'Hold',
    _BreathPhase.exhale => 'Breathe Out',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Cycle $_currentCycle of ${widget.cycles}',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 48),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final scale = 0.5 + (_controller.value * 0.5);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _phaseText,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 48),
          Text(
            'Follow the circle',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
