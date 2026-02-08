import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../home/task_detail_screen.dart';
import 'widgets/goal_overview.dart';
import 'widgets/timeline_section.dart';

/// Plan screen showing the learning roadmap.
///
/// Read-only, flexible, and reassuring.
class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  void _openTaskDetail(BuildContext context, Map<String, String> task) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => TaskDetailScreen(
          task: TaskDetail(
            id: task['id']!,
            title: task['title']!,
            duration: task['duration']!,
            tag: task['tag'],
            description: task['curr_desc'],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const goalTitle = 'Master Flutter Animations';
    const goalDeadline = 'Nov 20, 2026';
    const goalDescription =
        'Build complex, buttery-smooth UIs using implicit animations, '
        'explicit controllers, and custom painters.';

    final sections = <Map<String, dynamic>>[
      {
        'title': 'This Week',
        'tasks': [
          {
            'id': 'p1',
            'title': 'Implicit Animations Basics',
            'duration': '45 min',
            'tag': 'Concept',
            'curr_desc': 'Learn AnimatedContainer and AnimatedOpacity.',
          },
          {
            'id': 'p2',
            'title': 'Build a Shape-Shifting Button',
            'duration': '60 min',
            'tag': 'Practice',
            'curr_desc': 'Create a button that morphs into a loader.',
          },
        ],
      },
      {
        'title': 'Next Week',
        'tasks': [
          {
            'id': 'p3',
            'title': 'Animation Controllers Deep Dive',
            'duration': '90 min',
            'tag': 'Concept',
            'curr_desc': 'Understanding TickerProviders and Curves.',
          },
          {
            'id': 'p4',
            'title': 'Staggered List Animations',
            'duration': '60 min',
            'tag': 'Practice',
            'curr_desc': 'Animate list items entering the screen.',
          },
        ],
      },
      {
        'title': 'Later',
        'tasks': [
          {
            'id': 'p5',
            'title': 'Hero Animations',
            'duration': '45 min',
            'tag': 'Visuals',
            'curr_desc': 'Seamless transitions between screens.',
          },
          {
            'id': 'p6',
            'title': 'Custom Painters & Physics',
            'duration': '2 hrs',
            'tag': 'Advanced',
            'curr_desc': 'Drawing custom geometries and physics simulations.',
          },
        ],
      },
    ];

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Screen Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your learning timeline',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Goal Overview
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: GoalOverview(
                  title: goalTitle,
                  deadline: goalDeadline,
                  description: goalDescription,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Timeline Sections
            SliverList.separated(
              itemCount: sections.length,
              separatorBuilder: (context, index) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                final section = sections[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TimelineSection(
                    title: section['title'] as String,
                    tasks: (section['tasks'] as List)
                        .map((t) => Map<String, String>.from(t as Map))
                        .toList(),
                    onTaskTap: (task) => _openTaskDetail(context, task),
                  ),
                );
              },
            ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
