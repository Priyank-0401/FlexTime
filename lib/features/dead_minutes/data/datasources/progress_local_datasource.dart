import '../../../../core/services/database_service.dart';
import '../models/micro_progress_model.dart';

/// Local data source for micro-progress logging.
class ProgressLocalDataSource {
  ProgressLocalDataSource(this._database);

  final DatabaseService _database;

  /// Insert a new progress entry.
  Future<int> insertProgress(MicroProgressModel progress) async {
    final db = await _database.database;
    return db.insert('micro_progress', progress.toMap());
  }

  /// Get recent progress entries.
  Future<List<MicroProgressModel>> getRecentProgress({int limit = 20}) async {
    final db = await _database.database;
    final results = await db.query(
      'micro_progress',
      orderBy: 'completed_at DESC',
      limit: limit,
    );
    return results.map(MicroProgressModel.fromMap).toList();
  }

  /// Get progress count for today.
  Future<int> getTodayCount() async {
    final db = await _database.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM micro_progress WHERE completed_at >= ?',
      [startOfDay.toIso8601String()],
    );

    return (result.first['count'] as int?) ?? 0;
  }

  /// Get progress for specific activity.
  Future<List<MicroProgressModel>> getProgressForActivity(
    String activityId,
  ) async {
    final db = await _database.database;
    final results = await db.query(
      'micro_progress',
      where: 'activity_id = ?',
      whereArgs: [activityId],
      orderBy: 'completed_at DESC',
    );
    return results.map(MicroProgressModel.fromMap).toList();
  }
}
