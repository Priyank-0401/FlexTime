import 'package:flutter/material.dart';

import 'core/navigation/main_navigation.dart';
import 'core/theme/app_theme.dart';
import 'features/dead_minutes/engine/activity_launcher.dart';

/// Root widget for FlexTime application.
///
/// Light mode only - no dark theme.
class FlexTimeApp extends StatelessWidget {
  const FlexTimeApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: navigatorKey,
    title: 'FlexTime',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    // No darkTheme - light mode only per Calm Operational UI spec
    home: const MainNavigation(),
  );
}
