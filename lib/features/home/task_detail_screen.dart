import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Task detail screen showing full task information.
///
/// Calm Operational UI: White background, calm title, sage accent CTA.
/// No focus-mode visuals, no isolation styling, no emotional cues.
class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({required this.task, super.key});

  final TaskDetail task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Task Title - large, calm (22-24, semi-bold)
                    Text(
                      task.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 16),

                    // Task Metadata Row
                    Row(
                      children: [
                        // Duration
                        _MetadataChip(
                          icon: Icons.schedule_outlined,
                          label: task.duration,
                        ),

                        // Optional tag
                        if (task.tag != null) ...[
                          const SizedBox(width: 12),
                          _MetadataChip(label: task.tag!),
                        ],
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Task Description
                    if (task.description != null) ...[
                      Text(
                        'About this task',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        task.description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.6,
                        ),
                      ),
                    ],

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),

            // Action buttons - pinned to bottom
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: BoxDecoration(
                color: AppColors.backgroundPrimary,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Primary action - Start (accent color)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        // UI-only placeholder
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accentPrimary,
                        foregroundColor: AppColors.onAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Start',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.onAccent,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Secondary action - Do later (text only)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Do later',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Metadata chip for duration and tags.
class _MetadataChip extends StatelessWidget {
  const _MetadataChip({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.textTertiary),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Task detail model for UI display.
class TaskDetail {
  const TaskDetail({
    required this.id,
    required this.title,
    required this.duration,
    this.tag,
    this.description,
  });

  final String id;
  final String title;
  final String duration;
  final String? tag;
  final String? description;
}
