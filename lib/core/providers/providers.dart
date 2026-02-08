/// Core providers for dependency injection.
///
/// This file contains Riverpod providers for core services
/// that need to be accessible throughout the app.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/energy_planner/data/datasources/goal_local_datasource.dart';
import '../../features/energy_planner/data/datasources/timeline_local_datasource.dart';
import '../../features/energy_planner/data/repositories/goal_repository_impl.dart';
import '../../features/energy_planner/data/repositories/task_repository_impl.dart';
import '../../features/energy_planner/data/repositories/timeline_repository_impl.dart';
import '../../features/energy_planner/domain/repositories/goal_repository.dart';
import '../../features/energy_planner/domain/repositories/task_repository.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

/// Provider for the database service singleton.
final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => DatabaseService.instance,
);

/// Provider for the notification service singleton.
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService.instance,
);

/// Provider for Goal Local DataSource.
final goalLocalDataSourceProvider = Provider<GoalLocalDataSource>(
  (ref) => GoalLocalDataSource(ref.watch(databaseServiceProvider)),
);

/// Provider for Timeline Local DataSource.
final timelineLocalDataSourceProvider = Provider<TimelineLocalDataSource>(
  (ref) => TimelineLocalDataSource(ref.watch(databaseServiceProvider)),
);

/// Provider for Goal Repository.
final goalRepositoryProvider = Provider<GoalRepository>(
  (ref) => GoalRepositoryImpl(ref.watch(goalLocalDataSourceProvider)),
);

/// Provider for Task Repository.
final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepositoryImpl(),
);

/// Provider for Timeline Repository.
final timelineRepositoryProvider = Provider<TimelineRepositoryImpl>(
  (ref) => TimelineRepositoryImpl(ref.watch(timelineLocalDataSourceProvider)),
);
