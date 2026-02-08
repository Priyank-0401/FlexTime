import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Read-only task item for the Plan screen.
///
/// Simpler than TaskCard (no checkbox placeholder).
/// Visualizes a step in the journey.
class PlanTaskItem extends StatelessWidget {
  const PlanTaskItem({
    required this.title,
    required this.duration,
    super.key,
    this.tag,
    this.onTap,
  });

  final String title;
  final String duration;
  final String? tag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Reusing TaskCard logic but wrapping/modifying if needed later.
    // For now, reuse TaskCard but we might want a visually "lighter" version.
    // Given the spec "reuse task card styles", we'll adapt TaskCard.
    // However, TaskCard uses a checkbox placeholder which Plan doesn't need.
    // Let's build a specific simplified card.

    final theme = Theme.of(context);

    return Material(
      color: AppColors.backgroundPrimary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.textSecondary.withAlpha(10),
        highlightColor: AppColors.textSecondary.withAlpha(5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 15, // Slightly smaller than Today tasks
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 13,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    duration,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                  if (tag != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.textTertiary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
