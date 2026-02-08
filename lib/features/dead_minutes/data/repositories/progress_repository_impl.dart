import '../../domain/entities/micro_progress.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_local_datasource.dart';
import '../models/micro_progress_model.dart';

/// Implementation of ProgressRepository using local SQLite storage.
class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl(this._localDataSource);

  final ProgressLocalDataSource _localDataSource;

  @override
  Future<void> logProgress(MicroProgress progress) async {
    final model = MicroProgressModel.fromEntity(progress);
    await _localDataSource.insertProgress(model);
  }

  @override
  Future<List<MicroProgress>> getRecentProgress({int limit = 20}) async {
    final models = await _localDataSource.getRecentProgress(limit: limit);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<int> getTodayCount() => _localDataSource.getTodayCount();

  @override
  Future<List<MicroProgress>> getProgressForActivity(String activityId) async {
    final models = await _localDataSource.getProgressForActivity(activityId);
    return models.map((m) => m.toEntity()).toList();
  }
}
