import 'package:flutter/material.dart';

/// Central motion configuration for FlexTime.
///
/// Principles:
/// - Fast and subtle (150-250ms)
/// - Confirm intent, don't entertain
/// - No bounce, elastic, or spring effects
abstract final class AppMotion {
  /// Standard duration for micro-interactions (200ms).
  /// Used for: hover states, toggle switches, simple color transitions.
  static const durationShort = Duration(milliseconds: 200);

  /// Standard curve (easeInOut).
  /// Smooth start and end, no bounce.
  static const curveStandard = Curves.easeInOut;

  /// Linear curve for simple color fades where ease is unnecessary.
  static const curveLinear = Curves.linear;
}
