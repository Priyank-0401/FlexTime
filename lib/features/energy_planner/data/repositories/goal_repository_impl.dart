import '../../domain/entities/learning_goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_local_datasource.dart';
import '../models/learning_goal_model.dart';

/// SQLite implementation of [GoalRepository].
class GoalRepositoryImpl implements GoalRepository {
  GoalRepositoryImpl(this._dataSource);

  final GoalLocalDataSource _dataSource;

  @override
  Future<List<LearningGoal>> getAllGoals() async {
    final models = await _dataSource.getAllGoals();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<LearningGoal>> getActiveGoals() async {
    final models = await _dataSource.getActiveGoals();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<LearningGoal?> getGoal(String id) async {
    final model = await _dataSource.getGoal(id);
    return model?.toEntity();
  }

  @override
  Future<void> createGoal(LearningGoal goal) async {
    final model = LearningGoalModel.fromEntity(goal);
    await _dataSource.insertGoal(model);
  }

  @override
  Future<void> updateGoal(LearningGoal goal) async {
    final model = LearningGoalModel.fromEntity(goal);
    await _dataSource.updateGoal(model);
  }

  @override
  Future<void> deleteGoal(String id) async {
    await _dataSource.deleteGoal(id);
  }
}
