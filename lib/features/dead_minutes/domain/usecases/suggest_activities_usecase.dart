import '../entities/micro_activity.dart';
import '../repositories/micro_activity_repository.dart';

/// Use case: Suggest micro activities based on available time and energy.
///
/// This is the core business logic for finding activities that fit
/// within detected "dead minutes" and match the user's energy state.
class SuggestActivitiesUseCase {
  SuggestActivitiesUseCase(this._repository);

  final MicroActivityRepository _repository;

  /// Suggest activities for available time and energy level.
  ///
  /// [availableMinutes] - The detected dead time window
  /// [energyLevel] - User's current energy (optional)
  /// [limit] - Maximum suggestions to return
  Future<List<MicroActivity>> call({
    required int availableMinutes,
    EnergyLevel? energyLevel,
    int limit = 5,
  }) async {
    List<MicroActivity> candidates;

    if (energyLevel != null) {
      candidates = await _repository.getActivitiesByEnergyLevel(energyLevel);
      candidates = candidates
          .where((a) => a.durationMinutes <= availableMinutes)
          .where((a) => !a.isCompleted)
          .toList();
    } else {
      candidates = await _repository.getActivitiesForDuration(availableMinutes);
      candidates = candidates.where((a) => !a.isCompleted).toList();
    }

    candidates.sort((a, b) {
      final aFit = a.durationMinutes / availableMinutes;
      final bFit = b.durationMinutes / availableMinutes;
      return bFit.compareTo(aFit);
    });

    return candidates.take(limit).toList();
  }
}
