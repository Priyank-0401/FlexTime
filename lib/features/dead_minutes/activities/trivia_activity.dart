import 'package:flutter/material.dart';

import '../domain/entities/micro_activity.dart';
import 'base_activity.dart';

/// A simple recall-based trivia micro-activity.
///
/// Shows a question, user taps to reveal answer,
/// then self-reports if they knew it. No scoring, no streaks.
class TriviaActivity extends BaseActivity {
  TriviaActivity({
    required this.question,
    required this.answer,
    String? customId,
  }) : _id = customId ?? 'trivia_${question.hashCode}';

  final String question;
  final String answer;
  final String _id;

  @override
  String get id => _id;

  @override
  String get title => 'Quick Recall';

  @override
  int get durationSeconds => 180; // 3 minutes

  @override
  EnergyLevel get suitableEnergy => EnergyLevel.medium;

  @override
  String get category => 'knowledge';

  @override
  Widget buildContent({
    required VoidCallback onComplete,
    required VoidCallback onAbort,
  }) => _TriviaContent(
    question: question,
    answer: answer,
    onComplete: onComplete,
  );
}

class _TriviaContent extends StatefulWidget {
  const _TriviaContent({
    required this.question,
    required this.answer,
    required this.onComplete,
  });

  final String question;
  final String answer;
  final VoidCallback onComplete;

  @override
  State<_TriviaContent> createState() => _TriviaContentState();
}

class _TriviaContentState extends State<_TriviaContent> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Question',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.question,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 48),
          if (!_revealed)
            ElevatedButton.icon(
              onPressed: () => setState(() => _revealed = true),
              icon: const Icon(Icons.visibility),
              label: const Text('Reveal Answer'),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Answer',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.answer,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Did you know it?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: widget.onComplete,
                  child: const Text("Didn't Know"),
                ),
                const SizedBox(width: 16),
                FilledButton(
                  onPressed: widget.onComplete,
                  child: const Text('Knew It'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
