import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/activity_launcher.dart';
import '../providers/providers.dart';

/// Main entry page for DeadMinutes feature.
///
/// Shows current status and allows launching a micro-activity.
/// In production, this is typically accessed via the persistent notification.
class DeadMinutesPage extends ConsumerWidget {
  const DeadMinutesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final todayCount = ref.watch(todayProgressCountProvider);

    // Ensure registry and lifecycle manager are initialized
    ref
      ..watch(activityRegistryProvider)
      ..watch(lifecycleManagerProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text('DeadMinutes'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ready for a quick activity?',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '3-4 minutes of meaningful progress',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    todayCount.when(
                      data: (count) => Text(
                        '$count completed today',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Start button
            FilledButton.icon(
              onPressed: () => _launchActivity(context),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Activity'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Available activities preview
            Expanded(child: _AvailableActivitiesSection()),
          ],
        ),
      ),
    );
  }

  void _launchActivity(BuildContext context) {
    ActivityLauncher.instance.launchActivity();
  }
}

class _AvailableActivitiesSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final registry = ref.watch(activityRegistryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Activities',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: registry.activities.length,
            itemBuilder: (context, index) {
              final activity = registry.activities[index];
              return ListTile(
                leading: Icon(
                  _getCategoryIcon(activity.category),
                  color: theme.colorScheme.primary,
                ),
                title: Text(activity.title),
                subtitle: Text('${(activity.durationSeconds / 60).ceil()} min'),
                trailing: Chip(
                  label: Text(activity.suitableEnergy.name),
                  visualDensity: VisualDensity.compact,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) => switch (category) {
    'knowledge' => Icons.lightbulb_outline,
    'wellness' => Icons.self_improvement,
    'creativity' => Icons.brush,
    _ => Icons.star_outline,
  };
}
