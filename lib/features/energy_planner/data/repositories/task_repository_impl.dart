import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';

/// Implementation of TaskRepository using AppDatabase.
class TaskRepositoryImpl implements TaskRepository {
  @override
  Future<List<Task>> getTasksForGoal(String goalId) async {
    final db = await AppDatabase.instance.database;
    final results = await db.query(
      'planner_tasks',
      where: 'goal_id = ?',
      whereArgs: [goalId],
    );
    return results.map((map) => TaskModel.fromMap(map).toEntity()).toList();
  }

  @override
  Future<Task?> getTask(String id) async {
    final db = await AppDatabase.instance.database;
    final results = await db.query(
      'planner_tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return TaskModel.fromMap(results.first).toEntity();
  }

  @override
  Future<void> createTask(Task task) async {
    final db = await AppDatabase.instance.database;
    final model = TaskModel.fromEntity(task);
    await db.insert(
      'planner_tasks',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateTask(Task task) async {
    final db = await AppDatabase.instance.database;
    final model = TaskModel.fromEntity(task);
    await db.update(
      'planner_tasks',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  @override
  Future<void> deleteTask(String id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('planner_tasks', where: 'id = ?', whereArgs: [id]);
  }
}
