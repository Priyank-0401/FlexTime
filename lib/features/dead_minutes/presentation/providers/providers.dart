/// Presentation providers for dead minutes feature.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/database_service.dart';
import '../../activities/breathing_activity.dart';
import '../../activities/trivia_activity.dart';
import '../../data/datasources/micro_activity_local_datasource.dart';
import '../../data/datasources/progress_local_datasource.dart';
import '../../data/repositories/micro_activity_repository_impl.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../domain/repositories/micro_activity_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/usecases/log_completion_usecase.dart';
import '../../domain/usecases/suggest_activities_usecase.dart';
import '../../engine/activity_registry.dart';
import '../../engine/lifecycle_manager.dart';

/// Provider for the micro-activity data source.
final microActivityDataSourceProvider = Provider<MicroActivityLocalDataSource>(
  (ref) => MicroActivityLocalDataSource(DatabaseService.instance),
);

/// Provider for the micro-activity repository.
final microActivityRepositoryProvider = Provider<MicroActivityRepository>(
  (ref) =>
      MicroActivityRepositoryImpl(ref.watch(microActivityDataSourceProvider)),
);

/// Provider for the suggest activities use case.
final suggestActivitiesUseCaseProvider = Provider<SuggestActivitiesUseCase>(
  (ref) => SuggestActivitiesUseCase(ref.watch(microActivityRepositoryProvider)),
);

/// Provider for progress data source.
final progressDataSourceProvider = Provider<ProgressLocalDataSource>(
  (ref) => ProgressLocalDataSource(DatabaseService.instance),
);

/// Provider for progress repository.
final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepositoryImpl(ref.watch(progressDataSourceProvider)),
);

/// Provider for log completion use case.
final logCompletionUseCaseProvider = Provider<LogCompletionUseCase>(
  (ref) => LogCompletionUseCase(ref.watch(progressRepositoryProvider)),
);

/// Provider for activity registry with pre-registered activities.
final activityRegistryProvider = Provider<ActivityRegistry>((ref) {
  final registry = ActivityRegistry.instance;

  // Register sample activities (in production, load from config/database)
  if (registry.activities.isEmpty) {
    registry.registerAll([
      TriviaActivity(
        question: 'What is the capital of France?',
        answer: 'Paris',
      ),
      TriviaActivity(
        question: 'What year did World War II end?',
        answer: '1945',
      ),
      TriviaActivity(
        question: 'What is the largest planet in our solar system?',
        answer: 'Jupiter',
      ),
      BreathingActivity(),
      BreathingActivity(
        inhaleSeconds: 5,
        holdSeconds: 5,
        exhaleSeconds: 5,
        cycles: 4,
      ),
    ]);
  }

  return registry;
});

/// Provider for lifecycle manager with logger injected.
final lifecycleManagerProvider = Provider<LifecycleManager>(
  (ref) =>
      LifecycleManager.instance
        ..completionLogger = ref.watch(logCompletionUseCaseProvider),
);

/// Provider for today's completed activity count.
final todayProgressCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(progressRepositoryProvider);
  return repo.getTodayCount();
});
