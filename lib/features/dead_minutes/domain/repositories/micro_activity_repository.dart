import '../entities/micro_activity.dart';

/// Repository interface for micro activities.
///
/// Domain layer contract - implementations in data layer.
abstract interface class MicroActivityRepository {
  /// Get all micro activities.
  Future<List<MicroActivity>> getAllActivities();

  /// Get activities matching an energy level.
  Future<List<MicroActivity>> getActivitiesByEnergyLevel(EnergyLevel level);

  /// Get activities that fit within a given duration.
  Future<List<MicroActivity>> getActivitiesForDuration(int maxMinutes);

  /// Add a new micro activity.
  Future<void> addActivity(MicroActivity activity);

  /// Update an existing micro activity.
  Future<void> updateActivity(MicroActivity activity);

  /// Delete a micro activity.
  Future<void> deleteActivity(int id);

  /// Mark an activity as completed.
  Future<void> markCompleted(int id);
}
