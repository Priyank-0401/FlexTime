import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'activity_launcher.dart';

/// Controls the persistent DeadMinutes notification.
///
/// Registers a foreground-style notification that users can tap
/// to instantly launch a micro-activity without opening the main app.
class DeadMinutesNotificationController {
  DeadMinutesNotificationController._();

  static final DeadMinutesNotificationController instance =
      DeadMinutesNotificationController._();

  static const String _channelId = 'dead_minutes_persistent';
  static const String _channelName = 'DeadMinutes Quick Start';
  static const int _notificationId = 42;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _isShowing = false;

  /// Whether the persistent notification is currently showing.
  bool get isShowing => _isShowing;

  /// Initialize the notification controller.
  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Show the persistent notification.
  Future<void> showPersistentNotification() async {
    if (!_isInitialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Tap to start a quick micro-activity',
      importance: Importance.low, // Persistent but not intrusive
      priority: Priority.low,
      ongoing: true, // Cannot be dismissed
      autoCancel: false,
      showWhen: false,
      playSound: false,
      enableVibration: false,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      _notificationId,
      'DeadMinutes Ready',
      'Tap to start a 3-minute activity',
      details,
    );

    _isShowing = true;
  }

  /// Hide the persistent notification.
  Future<void> hidePersistentNotification() async {
    await _notifications.cancel(_notificationId);
    _isShowing = false;
  }

  /// Toggle the persistent notification.
  Future<void> toggleNotification() async {
    if (_isShowing) {
      await hidePersistentNotification();
    } else {
      await showPersistentNotification();
    }
  }

  /// Handle notification tap - launches activity directly.
  static void _onNotificationTapped(NotificationResponse response) {
    // Launch activity directly, bypassing main app shell
    ActivityLauncher.instance.launchActivity();
  }
}
