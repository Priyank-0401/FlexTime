import '../../../../core/services/database_service.dart';
import '../models/learning_goal_model.dart';

/// Local data source for learning goals using SQLite.
class GoalLocalDataSource {
  GoalLocalDataSource(this._database);

  final DatabaseService _database;

  /// Get all learning goals.
  Future<List<LearningGoalModel>> getAllGoals() async {
    final db = await _database.database;
    final results = await db.query('learning_goals');
    return results.map(LearningGoalModel.fromMap).toList();
  }

  /// Get all active goals.
  Future<List<LearningGoalModel>> getActiveGoals() async {
    final db = await _database.database;
    final results = await db.query(
      'learning_goals',
      where: 'status = ?',
      whereArgs: ['active'],
    );
    return results.map(LearningGoalModel.fromMap).toList();
  }

  /// Get a goal by ID.
  Future<LearningGoalModel?> getGoal(String id) async {
    final db = await _database.database;
    final results = await db.query(
      'learning_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) return null;
    return LearningGoalModel.fromMap(results.first);
  }

  /// Insert a new goal.
  Future<void> insertGoal(LearningGoalModel goal) async {
    final db = await _database.database;
    await db.insert('learning_goals', goal.toMap());
  }

  /// Update an existing goal.
  Future<void> updateGoal(LearningGoalModel goal) async {
    final db = await _database.database;
    await db.update(
      'learning_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  /// Delete a goal.
  Future<void> deleteGoal(String id) async {
    final db = await _database.database;
    await db.delete('learning_goals', where: 'id = ?', whereArgs: [id]);
  }
}
