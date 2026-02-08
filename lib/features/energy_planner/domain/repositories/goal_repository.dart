import '../entities/learning_goal.dart';

/// Repository interface for learning goal persistence.
abstract class GoalRepository {
  /// Get all learning goals.
  Future<List<LearningGoal>> getAllGoals();

  /// Get all active learning goals.
  Future<List<LearningGoal>> getActiveGoals();

  /// Get a specific goal by ID.
  Future<LearningGoal?> getGoal(String id);

  /// Create a new learning goal.
  Future<void> createGoal(LearningGoal goal);

  /// Update an existing goal.
  Future<void> updateGoal(LearningGoal goal);

  /// Delete a goal and its associated tasks/timeline.
  Future<void> deleteGoal(String id);
}
