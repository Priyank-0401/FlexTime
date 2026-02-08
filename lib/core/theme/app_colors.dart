import 'package:flutter/material.dart';

/// Calm Operational UI color palette for FlexTime.
///
/// White-dominant with a single soft sage accent.
/// Light mode only. No gamification or urgency colors.
abstract final class AppColors {
  // Base - White dominant canvas
  static const backgroundPrimary = Color(0xFFFFFFFF);
  static const backgroundSecondary = Color(0xFFF7F6F3); // cream/off-white
  static const divider = Color(0xFFE6E6E3);

  // Accent - Soft sage / light green family
  // Used ONLY for: selected energy, primary CTA, active tab
  static const accentPrimary = Color(0xFF9DB8A0);
  static const accentSoft = Color(0xFFE7EFE8);

  // Text
  static const textPrimary = Color(0xFF1F2933);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);

  // On accent (for text on accent backgrounds)
  static const onAccent = Color(0xFFFFFFFF);
}
