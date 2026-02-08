import '../../domain/entities/micro_activity.dart';
import '../../domain/repositories/micro_activity_repository.dart';
import '../datasources/micro_activity_local_datasource.dart';
import '../models/micro_activity_model.dart';

/// Implementation of MicroActivityRepository using local SQLite storage.
class MicroActivityRepositoryImpl implements MicroActivityRepository {
  MicroActivityRepositoryImpl(this._localDataSource);

  final MicroActivityLocalDataSource _localDataSource;

  @override
  Future<List<MicroActivity>> getAllActivities() async {
    final models = await _localDataSource.getAllActivities();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<MicroActivity>> getActivitiesByEnergyLevel(
    EnergyLevel energyLevel,
  ) async {
    final models = await _localDataSource.getActivitiesByEnergyLevel(
      energyLevel.name,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<MicroActivity>> getActivitiesForDuration(int maxMinutes) async {
    final allActivities = await getAllActivities();
    return allActivities.where((a) => a.durationMinutes <= maxMinutes).toList();
  }

  @override
  Future<void> addActivity(MicroActivity activity) async {
    final model = MicroActivityModel.fromEntity(activity);
    await _localDataSource.insertActivity(model);
  }

  @override
  Future<void> updateActivity(MicroActivity activity) async {
    final model = MicroActivityModel.fromEntity(activity);
    await _localDataSource.updateActivity(model);
  }

  @override
  Future<void> deleteActivity(int id) async {
    await _localDataSource.deleteActivity(id);
  }

  @override
  Future<void> markCompleted(int id) async {
    final activities = await getAllActivities();
    final activity = activities.firstWhere((a) => a.id == id);
    final updated = MicroActivity(
      id: activity.id,
      title: activity.title,
      description: activity.description,
      durationMinutes: activity.durationMinutes,
      energyLevel: activity.energyLevel,
      category: activity.category,
      isCompleted: true,
      createdAt: activity.createdAt,
      completedAt: DateTime.now(),
    );
    await updateActivity(updated);
  }
}
