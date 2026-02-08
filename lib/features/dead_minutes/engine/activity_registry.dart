import 'dart:math';

import '../activities/base_activity.dart';
import '../domain/entities/micro_activity.dart';

/// Registry for all available micro-activities.
///
/// Supports plugin-style registration and weighted random selection.
class ActivityRegistry {
  ActivityRegistry._();

  static final ActivityRegistry instance = ActivityRegistry._();

  final List<BaseActivity> _activities = [];
  final Random _random = Random();

  /// All registered activities.
  List<BaseActivity> get activities => List.unmodifiable(_activities);

  /// Register a new activity.
  void register(BaseActivity activity) {
    _activities.add(activity);
  }

  /// Register multiple activities.
  void registerAll(List<BaseActivity> activities) {
    _activities.addAll(activities);
  }

  /// Clear all registered activities.
  void clear() {
    _activities.clear();
  }

  /// Select an activity based on criteria.
  ///
  /// [energyLevel] - Filter by suitable energy level.
  /// [excludeIds] - Activity IDs to exclude (recently completed).
  ///
  /// Returns null if no suitable activity found.
  BaseActivity? selectActivity({
    EnergyLevel? energyLevel,
    List<String>? excludeIds,
  }) {
    if (_activities.isEmpty) return null;

    var candidates = _activities.toList();

    // Filter by energy level if specified
    if (energyLevel != null) {
      candidates = candidates
          .where((a) => a.suitableEnergy == energyLevel)
          .toList();
    }

    // Exclude recently completed
    if (excludeIds != null && excludeIds.isNotEmpty) {
      candidates = candidates.where((a) => !excludeIds.contains(a.id)).toList();
    }

    // Fall back to all activities if filters too restrictive
    if (candidates.isEmpty) {
      candidates = _activities.toList();
      if (excludeIds != null && excludeIds.isNotEmpty) {
        candidates = candidates
            .where((a) => !excludeIds.contains(a.id))
            .toList();
      }
    }

    if (candidates.isEmpty) return null;

    // Random selection (no weighted preference for now)
    return candidates[_random.nextInt(candidates.length)];
  }

  /// Get activities by category.
  List<BaseActivity> getByCategory(String category) =>
      _activities.where((a) => a.category == category).toList();

  /// Get activities suitable for energy level.
  List<BaseActivity> getByEnergyLevel(EnergyLevel level) =>
      _activities.where((a) => a.suitableEnergy == level).toList();
}
