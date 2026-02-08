import 'dart:async';

import 'package:flutter/foundation.dart';

/// Global error handling utilities for FlexTime.
///
/// Provides centralized error handling, logging, and user-friendly
/// error message generation. Integrates with crash reporting in production.
class ErrorHandler {
  ErrorHandler._();

  /// Handle Flutter framework errors.
  static void handleFlutterError(FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      _logError(details.exception, details.stack);
    }
  }

  /// Handle errors in async zones.
  static void handleZoneError(Object error, StackTrace stack) {
    if (kDebugMode) {
      debugPrint('Zone Error: $error');
      debugPrint('Stack: $stack');
    } else {
      _logError(error, stack);
    }
  }

  /// Log an error for analysis.
  static void _logError(Object error, StackTrace? stack) {
    debugPrint('Error logged: $error');
    if (stack != null) {
      debugPrint('Stack: $stack');
    }
  }

  /// Get a user-friendly error message.
  static String getUserMessage(Object error) {
    if (error is TimeoutException) {
      return 'The operation timed out. Please try again.';
    }
    if (error is FormatException) {
      return 'There was a problem with the data format.';
    }
    return 'Something went wrong. Please try again.';
  }

  /// Report an error with additional context.
  static void reportError(
    Object error, {
    StackTrace? stack,
    Map<String, dynamic>? context,
  }) {
    if (kDebugMode) {
      debugPrint('Reported Error: $error');
      if (context != null) {
        debugPrint('Context: $context');
      }
    }
    _logError(error, stack);
  }
}
