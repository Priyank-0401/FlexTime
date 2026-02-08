import '../../../../core/services/database_service.dart';
import '../models/micro_activity_model.dart';

/// Local data source for micro activities using SQLite.
class MicroActivityLocalDataSource {
  MicroActivityLocalDataSource(this._database);

  final DatabaseService _database;

  /// Get all micro activities from local database.
  Future<List<MicroActivityModel>> getAllActivities() async {
    final db = await _database.database;
    final results = await db.query('micro_activities');
    return results.map(MicroActivityModel.fromMap).toList();
  }

  /// Get activities by energy level.
  Future<List<MicroActivityModel>> getActivitiesByEnergyLevel(
    String energyLevel,
  ) async {
    final db = await _database.database;
    final results = await db.query(
      'micro_activities',
      where: 'energy_level = ?',
      whereArgs: [energyLevel],
    );
    return results.map(MicroActivityModel.fromMap).toList();
  }

  /// Insert a new micro activity.
  Future<int> insertActivity(MicroActivityModel activity) async {
    final db = await _database.database;
    return db.insert('micro_activities', activity.toMap());
  }

  /// Update an existing micro activity.
  Future<void> updateActivity(MicroActivityModel activity) async {
    final db = await _database.database;
    await db.update(
      'micro_activities',
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  /// Delete a micro activity.
  Future<void> deleteActivity(int id) async {
    final db = await _database.database;
    await db.delete('micro_activities', where: 'id = ?', whereArgs: [id]);
  }
}
