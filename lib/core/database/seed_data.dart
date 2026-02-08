import 'dart:math';

import 'package:sqflite/sqflite.dart';

import '../../core/enums/energy_level.dart';
import '../../core/enums/energy_requirement.dart';
import '../../features/energy_planner/data/models/learning_goal_model.dart';
import '../../features/energy_planner/data/models/task_model.dart';

import '../../features/energy_planner/domain/entities/timeline_bucket.dart';
import 'app_database.dart';

/// Seeds the database with initial mock data if empty.
class SeedData {
  SeedData._();

  static String _generateId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return '$now-$random';
  }

  static Future<void> plant() async {
    final db = await AppDatabase.instance.database;

    // Check if goals exist
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM learning_goals'),
    );

    if (count != null && count > 0) return;

    // Seed Data
    final goalId = _generateId();
    final now = DateTime.now();

    final goal = LearningGoalModel(
      id: goalId,
      title: 'Master Flutter Animations',
      targetOutcome: 'Build complex, buttery-smooth UIs.',
      deadline: now.add(const Duration(days: 30)),
      totalEstimatedEffort: const Duration(hours: 40),
      createdAt: now,
    );

    await db.insert('learning_goals', goal.toMap());

    // Tasks and buckets would be added here via repositories or raw SQL
    // leaving tasks empty for now unless requested,
    // but the prompt said "Provide mock seed data on first launch".

    // Let's seed the mocks from the UI plan_screen.dart
    await _seedTasks(db, goalId);
  }

  static Future<void> _seedTasks(Database db, String goalId) async {
    final tasks = [
      _createTask(
        goalId,
        'Implicit Animations Basics',
        'Learn AnimatedContainer.',
        45,
        EnergyLevel.low,
      ),
      _createTask(
        goalId,
        'Build a Shape-Shifting Button',
        'Create a button that morphs.',
        60,
        EnergyLevel.medium,
      ),
      _createTask(
        goalId,
        'Animation Controllers Deep Dive',
        'Understanding TickerProviders.',
        90,
        EnergyLevel.high,
      ),
    ];

    for (final task in tasks) {
      await db.insert('planner_tasks', task.toMap());
    }

    // Create buckets
    final bucketNow = _createBucket(goalId, 'This Week', 0);
    final bucketNext = _createBucket(goalId, 'Next Week', 1);
    final bucketLater = _createBucket(goalId, 'Later', 2);

    await db.insert('timeline_buckets', {
      'id': bucketNow.id,
      'goal_id': bucketNow.goalId,
      'label': bucketNow.label,
      'order_index': bucketNow.orderIndex,
    });

    await db.insert('timeline_buckets', {
      'id': bucketNext.id,
      'goal_id': bucketNext.goalId,
      'label': bucketNext.label,
      'order_index': bucketNext.orderIndex,
    });

    await db.insert('timeline_buckets', {
      'id': bucketLater.id,
      'goal_id': bucketLater.goalId,
      'label': bucketLater.label,
      'order_index': bucketLater.orderIndex,
    });

    // Map tasks to buckets
    await _mapTask(db, tasks[0].id, bucketNow.id, 0);
    await _mapTask(db, tasks[1].id, bucketNow.id, 1);
    await _mapTask(db, tasks[2].id, bucketNext.id, 0);
  }

  static TaskModel _createTask(
    String goalId,
    String title,
    String desc,
    int minutes,
    EnergyLevel energyLevel,
  ) {
    // Map EnergyLevel enum to EnergyRequirement enum from task logic if needed
    // But TaskModel expects EnergyRequirement.
    // Wait, the seed data previously used EnergyRequirement which was implicitly imported or something?
    // Let's check imports. TaskModel uses EnergyRequirement.
    // The previous code used EnergyRequirement which might be in task.dart context?
    // Actually Task entity defines EnergyRequirement enum usually?
    // Let's use EnergyRequirement from Task entity.

    EnergyRequirement req;
    switch (energyLevel) {
      case EnergyLevel.low:
        req = EnergyRequirement.low;
        break;
      case EnergyLevel.medium:
        req = EnergyRequirement.medium;
        break;
      case EnergyLevel.high:
        req = EnergyRequirement.high;
        break;
    }

    return TaskModel(
      id: _generateId(),
      goalId: goalId,
      title: title,
      description: desc,
      estimatedDuration: Duration(minutes: minutes),
      energyRequirement: req,
      createdAt: DateTime.now(),
      originalDayIndex: 0,
    );
  }

  static TimelineBucket _createBucket(String goalId, String label, int index) =>
      TimelineBucket(
        id: _generateId(),
        goalId: goalId,
        label: label,
        orderIndex: index,
      );

  static Future<void> _mapTask(
    Database db,
    String taskId,
    String bucketId,
    int index,
  ) async {
    await db.insert('task_timeline_mappings', {
      'task_id': taskId,
      'bucket_id': bucketId,
      'position_index': index,
    });
  }
}
