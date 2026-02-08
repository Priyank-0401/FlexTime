import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_motion.dart';
import 'app_typography.dart';

/// FlexTime app theme configuration.
///
/// Light mode only. Calm, operational design with
/// white-dominant canvas and soft sage accent.
class AppTheme {
  AppTheme._();

  /// Light theme for FlexTime (the only theme).
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundPrimary,
    colorScheme: const ColorScheme.light(
      primary: AppColors.accentPrimary,
      primaryContainer: AppColors.accentSoft,
      onPrimaryContainer: AppColors.accentPrimary,
      secondary: AppColors.accentPrimary,
      onSecondary: AppColors.onAccent,
      secondaryContainer: AppColors.accentSoft,
      onSecondaryContainer: AppColors.accentPrimary,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      surfaceContainerLowest: AppColors.backgroundPrimary,
      surfaceContainerLow: AppColors.backgroundPrimary,
      surfaceContainer: AppColors.backgroundSecondary,
      surfaceContainerHigh: AppColors.backgroundSecondary,
      surfaceContainerHighest: AppColors.backgroundSecondary,
      outline: AppColors.divider,
      outlineVariant: AppColors.divider,
    ),
    textTheme: AppTypography.textTheme,
    // Page Transitions: Standard, subtle (Zoom for Android, slide for iOS)
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(
          allowEnterRouteSnapshotting: false,
        ),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.backgroundPrimary,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.backgroundPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.divider),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.accentPrimary,
        foregroundColor: AppColors.onAccent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // Immediate reaction
        splashFactory: InkRipple.splashFactory,
        animationDuration: AppMotion.durationShort,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accentPrimary,
        foregroundColor: AppColors.onAccent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        splashFactory: InkRipple.splashFactory,
        animationDuration: AppMotion.durationShort,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        splashFactory: InkRipple.splashFactory,
        animationDuration: AppMotion.durationShort,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: AppColors.backgroundPrimary,
      indicatorColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTypography.textTheme.labelSmall?.copyWith(
            color: AppColors.accentPrimary,
            fontWeight: FontWeight.w600,
          );
        }
        return AppTypography.textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.accentPrimary);
        }
        return const IconThemeData(color: AppColors.textSecondary);
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.backgroundSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}
