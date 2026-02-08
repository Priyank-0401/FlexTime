import '../entities/task.dart';

/// Repository interface for task management.
abstract class TaskRepository {
  /// Get all tasks for a goal.
  Future<List<Task>> getTasksForGoal(String goalId);

  /// Get a specific task by ID.
  Future<Task?> getTask(String id);

  /// Create a new task.
  Future<void> createTask(Task task);

  /// Update an existing task.
  Future<void> updateTask(Task task);

  /// Delete a task.
  Future<void> deleteTask(String id);

  /// Get tasks due for today (or a specific bucket).
  /// This might be part of TimelineRepository, but direct task access is useful.
}
