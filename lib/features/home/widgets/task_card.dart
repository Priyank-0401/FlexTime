import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Task card displaying a single task item.
///
/// Calm Operational UI: Border-based, flat design.
/// Cards feel like polite list items, not designed components.
///
/// Interaction: Subtle, barely-there feedback (no heavy ripple).
class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.title,
    required this.duration,
    super.key,
    this.tag,
    this.isPrimary = false,
    this.onTap,
  });

  final String title;
  final String duration;
  final String? tag;
  final bool isPrimary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.backgroundPrimary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        // Subtle feedback configuration
        splashColor: AppColors.textSecondary.withAlpha(10), // Very faint splash
        highlightColor: AppColors.textSecondary.withAlpha(
          5,
        ), // Barely visible highlight
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox placeholder - subtle circle
              Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.divider, width: 1.5),
                ),
              ),
              const SizedBox(width: 14),

              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Duration + Tag
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
                          ),
                        ),

                        if (tag != null) ...[
                          const SizedBox(width: 10),
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
            ],
          ),
        ),
      ),
    );
  }
}
