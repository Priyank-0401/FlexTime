import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'task_detail_screen.dart';
import 'widgets/energy_selector.dart';
import 'widgets/greeting_header.dart';
import 'widgets/task_card.dart';

/// Home (Today) screen displaying daily tasks and energy selector.
///
/// Calm Operational UI: List-first, white-dominant, no motivational pressure.
///
/// Layout order (top to bottom):
/// 1. Greeting header with date
/// 2. Energy selector (Low/Medium/High)
/// 3. Today's tasks list
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  EnergyLevel _selectedEnergy = EnergyLevel.medium;

  // Mock data for tasks with descriptions
  static final List<MockTask> _mockTasks = [
    MockTask(
      id: '1',
      title: 'Review Chapter 5: Data Structures',
      duration: '25 min',
      tag: 'Revision',
      isPrimary: true,
      description:
          'Go through the key concepts of arrays, linked lists, and trees. '
          'Focus on understanding time complexity for common operations. '
          'Take notes on anything that feels unclear for follow-up.',
    ),
    MockTask(
      id: '2',
      title: 'Practice coding problems',
      duration: '45 min',
      tag: 'Focus',
      description:
          'Work through 2-3 medium difficulty problems. '
          "Don't worry about speed - focus on understanding the approach.",
    ),
    MockTask(
      id: '3',
      title: 'Watch lecture video',
      duration: '20 min',
      description:
          'Continue with the algorithms course. '
          'Pause and rewind as needed - there is no rush.',
    ),
    MockTask(
      id: '4',
      title: 'Complete quiz questions',
      duration: '15 min',
      tag: 'Review',
      description:
          'Self-assessment quiz from the chapter. '
          'Use it as a learning tool, not a test.',
    ),
  ];

  void _openTaskDetail(MockTask task) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => TaskDetailScreen(
          task: TaskDetail(
            id: task.id,
            title: task.title,
            duration: task.duration,
            tag: task.tag,
            description: task.description,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Greeting Header
            const SliverToBoxAdapter(child: GreetingHeader()),

            // Energy Selector
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: EnergySelector(
                  selectedLevel: _selectedEnergy,
                  onLevelSelected: (level) {
                    setState(() => _selectedEnergy = level);
                  },
                ),
              ),
            ),

            // Section title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text(
                  "Today's Plan",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            // Task list - 12px vertical spacing between cards
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.separated(
                itemCount: _mockTasks.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final task = _mockTasks[index];
                  return TaskCard(
                    title: task.title,
                    duration: task.duration,
                    tag: task.tag,
                    isPrimary: task.isPrimary,
                    onTap: () => _openTaskDetail(task),
                  );
                },
              ),
            ),

            // Bottom padding for scroll
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

/// Mock task data model for UI only.
class MockTask {
  const MockTask({
    required this.id,
    required this.title,
    required this.duration,
    this.tag,
    this.isPrimary = false,
    this.description,
  });

  final String id;
  final String title;
  final String duration;
  final String? tag;
  final bool isPrimary;
  final String? description;
}
