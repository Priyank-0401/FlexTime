import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../../core/services/database_service.dart';
import '../../domain/entities/daily_plan.dart';
import '../../domain/entities/timeline.dart';
import '../models/task_model.dart';

/// Local data source for timeline and task persistence.
class TimelineLocalDataSource {
  TimelineLocalDataSource(this._database);

  final DatabaseService _database;

  /// Get all tasks for a goal.
  Future<List<TaskModel>> getTasksForGoal(String goalId) async {
    final db = await _database.database;
    final results = await db.query(
      'planner_tasks',
      where: 'goal_id = ?',
      whereArgs: [goalId],
    );

    // Load dependencies for each task
    final tasks = <TaskModel>[];
    for (final row in results) {
      final taskId = row['id']! as String;
      final deps = await _getDependencies(taskId);
      final model = TaskModel.fromMap(row);
      tasks.add(
        TaskModel(
          id: model.id,
          goalId: model.goalId,
          title: model.title,
          description: model.description,
          estimatedDuration: model.estimatedDuration,
          energyRequirement: model.energyRequirement,
          createdAt: model.createdAt,
          status: model.status,
          originalDayIndex: model.originalDayIndex,
          currentDayIndex: model.currentDayIndex,
          dependsOn: deps,
        ),
      );
    }

    return tasks;
  }

  Future<List<String>> _getDependencies(String taskId) async {
    final db = await _database.database;
    final results = await db.query(
      'task_dependencies',
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
    return results.map((r) => r['depends_on_task_id']! as String).toList();
  }

  /// Save a task.
  Future<void> saveTask(TaskModel task) async {
    final db = await _database.database;
    await db.insert(
      'planner_tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Save dependencies
    await db.delete(
      'task_dependencies',
      where: 'task_id = ?',
      whereArgs: [task.id],
    );
    for (final depId in task.dependsOn) {
      await db.insert('task_dependencies', {
        'task_id': task.id,
        'depends_on_task_id': depId,
      });
    }
  }

  /// Save multiple tasks in a batch.
  Future<void> saveTasksBatch(List<TaskModel> tasks) async {
    final db = await _database.database;
    final batch = db.batch();

    for (final task in tasks) {
      batch.insert(
        'planner_tasks',
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);

    // Save dependencies separately
    for (final task in tasks) {
      await db.delete(
        'task_dependencies',
        where: 'task_id = ?',
        whereArgs: [task.id],
      );
      for (final depId in task.dependsOn) {
        await db.insert('task_dependencies', {
          'task_id': task.id,
          'depends_on_task_id': depId,
        });
      }
    }
  }

  /// Log energy selection for a day.
  Future<void> logEnergy(
    String goalId,
    DateTime date,
    EnergyState energy,
  ) async {
    final db = await _database.database;
    final dateStr = DateTime(date.year, date.month, date.day).toIso8601String();
    await db.insert('daily_energy_logs', {
      'goal_id': goalId,
      'date': dateStr,
      'reported_energy': energy.name,
      'recorded_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get energy history for a goal.
  Future<Map<DateTime, EnergyState>> getEnergyHistory(String goalId) async {
    final db = await _database.database;
    final results = await db.query(
      'daily_energy_logs',
      where: 'goal_id = ?',
      whereArgs: [goalId],
    );

    final history = <DateTime, EnergyState>{};
    for (final row in results) {
      final date = DateTime.parse(row['date']! as String);
      final energy = EnergyState.values.firstWhere(
        (e) => e.name == row['reported_energy'],
        orElse: () => EnergyState.medium,
      );
      history[date] = energy;
    }

    return history;
  }

  /// Save a timeline snapshot.
  Future<void> saveSnapshot(Timeline timeline) async {
    final db = await _database.database;

    // Serialize timeline to JSON
    final snapshot = {
      'goalId': timeline.goalId,
      'version': timeline.version,
      'generatedAt': timeline.generatedAt.toIso8601String(),
      'dailyPlans': timeline.dailyPlans
          .map(
            (day) => {
              'date': day.date.toIso8601String(),
              'dayIndex': day.dayIndex,
              'tasks': day.scheduledTasks.map((t) => t.id).toList(),
            },
          )
          .toList(),
    };

    await db.insert('timeline_snapshots', {
      'goal_id': timeline.goalId,
      'version': timeline.version,
      'snapshot_json': jsonEncode(snapshot),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Delete all tasks for a goal.
  Future<void> deleteTasksForGoal(String goalId) async {
    final db = await _database.database;
    await db.delete('planner_tasks', where: 'goal_id = ?', whereArgs: [goalId]);
  }
}
