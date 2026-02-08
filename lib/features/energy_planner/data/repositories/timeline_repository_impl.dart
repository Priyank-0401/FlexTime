import '../../domain/entities/daily_plan.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/timeline.dart';
import '../../domain/repositories/timeline_repository.dart';
import '../datasources/timeline_local_datasource.dart';
import '../models/task_model.dart';

/// SQLite implementation of [TimelineRepository].
class TimelineRepositoryImpl implements TimelineRepository {
  TimelineRepositoryImpl(this._dataSource);

  final TimelineLocalDataSource _dataSource;

  @override
  Future<Timeline?> getTimeline(String goalId) async {
    final taskModels = await _dataSource.getTasksForGoal(goalId);
    if (taskModels.isEmpty) return null;

    // Group tasks by day index
    final tasksByDay = <int, List<Task>>{};
    for (final model in taskModels) {
      final dayIndex = model.currentDayIndex ?? model.originalDayIndex;
      tasksByDay.putIfAbsent(dayIndex, () => []).add(model.toEntity());
    }

    // Build daily plans
    final dailyPlans = <DailyPlan>[];
    final sortedDays = tasksByDay.keys.toList()..sort();

    for (final dayIndex in sortedDays) {
      final tasks = tasksByDay[dayIndex]!;
      // Use today as base date - in production, we'd store/retrieve this
      final date = DateTime.now().add(Duration(days: dayIndex));
      dailyPlans.add(
        DailyPlan(date: date, dayIndex: dayIndex, scheduledTasks: tasks),
      );
    }

    return Timeline(
      goalId: goalId,
      dailyPlans: dailyPlans,
      generatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> saveTimeline(Timeline timeline) async {
    // Extract all tasks from daily plans
    final tasks = <TaskModel>[];
    for (final day in timeline.dailyPlans) {
      for (final task in day.scheduledTasks) {
        tasks.add(TaskModel.fromEntity(task));
      }
    }
    await _dataSource.saveTasksBatch(tasks);
    await _dataSource.saveSnapshot(timeline);
  }

  @override
  Future<DailyPlan?> getTodaysPlan(String goalId) async {
    final timeline = await getTimeline(goalId);
    return timeline?.getTodaysPlan();
  }

  @override
  Future<void> updateDailyPlan(String goalId, DailyPlan plan) async {
    // Save each task in the plan
    for (final task in plan.scheduledTasks) {
      final model = TaskModel.fromEntity(task);
      await _dataSource.saveTask(model);
    }
  }

  @override
  Future<void> logEnergySelection(
    String goalId,
    DateTime date,
    EnergyState energy,
  ) async {
    await _dataSource.logEnergy(goalId, date, energy);
  }

  @override
  Future<Map<DateTime, EnergyState>> getEnergyHistory(String goalId) =>
      _dataSource.getEnergyHistory(goalId);

  @override
  Future<void> saveSnapshot(Timeline timeline) =>
      _dataSource.saveSnapshot(timeline);
}
