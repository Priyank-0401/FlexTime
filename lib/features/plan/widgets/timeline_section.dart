import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'plan_task_item.dart';

/// Timeline section grouping tasks by time bucket.
class TimelineSection extends StatelessWidget {
  const TimelineSection({
    required this.title,
    required this.tasks,
    required this.onTaskTap,
    super.key,
  });

  final String title;
  final List<Map<String, String>> tasks;
  final ValueChanged<Map<String, String>> onTaskTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Divider
        const Divider(color: AppColors.divider, height: 32),

        // Section Title
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Tasks
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return PlanTaskItem(
              title: task['title']!,
              duration: task['duration']!,
              tag: task['tag'],
              onTap: () => onTaskTap(task),
            );
          },
        ),
      ],
    );
  }
}
