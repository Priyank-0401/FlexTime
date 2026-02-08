import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/seed_data.dart';
import 'core/services/database_service.dart';
import 'core/services/notification_service.dart';
import 'core/utils/error_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize global error handling
  FlutterError.onError = ErrorHandler.handleFlutterError;

  // Initialize platform-specific services (skip on web)
  if (!kIsWeb) {
    await DatabaseService.instance.initialize();
    await SeedData.plant();
    await NotificationService.instance.initialize();
  }

  runApp(const ProviderScope(child: FlexTimeApp()));
}
