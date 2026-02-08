import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Calm goal overview header.
///
/// Anchors the plan without pressure.
/// - Title: Large, clear
/// - Deadline: Secondary text (no countdown)
/// - Description: Body text
class GoalOverview extends StatelessWidget {
  const GoalOverview({
    required this.title,
    required this.deadline,
    required this.description,
    super.key,
  });

  final String title;
  final String deadline;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Target: $deadline',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
