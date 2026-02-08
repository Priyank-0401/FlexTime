import 'package:flextime_app/core/enums/energy_requirement.dart';
import '../domain/entities/task.dart';

/// Classifies tasks by energy requirement based on heuristics.
///
/// Uses task metadata (duration, complexity keywords) to assign
/// appropriate energy levels. This is a deterministic, rule-based system.
class EnergyClassifier {
  /// Classify a task's energy requirement based on its properties.
  ///
  /// Rules:
  /// - Duration > 90 minutes → High
  /// - Duration > 45 minutes → Medium
  /// - Duration <= 45 minutes → Low
  /// - Keywords can override duration-based classification
  EnergyRequirement classify(String description, Duration duration) {
    // Check for high-energy keywords
    final highEnergyKeywords = [
      'deep dive',
      'architecture',
      'design',
      'implement',
      'build',
      'create',
      'complex',
      'advanced',
      'problem-solving',
      'algorithm',
    ];

    // Check for low-energy keywords
    final lowEnergyKeywords = [
      'review',
      'summary',
      'recap',
      'notes',
      'quiz',
      'flashcard',
      'cheatsheet',
      'overview',
      'passive',
      'watch',
      'listen',
    ];

    final lowerDesc = description.toLowerCase();

    // Keyword-based classification takes precedence
    for (final keyword in highEnergyKeywords) {
      if (lowerDesc.contains(keyword)) {
        return EnergyRequirement.high;
      }
    }

    for (final keyword in lowEnergyKeywords) {
      if (lowerDesc.contains(keyword)) {
        return EnergyRequirement.low;
      }
    }

    // Duration-based fallback
    if (duration.inMinutes > 90) {
      return EnergyRequirement.high;
    } else if (duration.inMinutes > 45) {
      return EnergyRequirement.medium;
    } else {
      return EnergyRequirement.low;
    }
  }

  /// Create a task with auto-classified energy requirement.
  Task createTask({
    required String id,
    required String goalId,
    required String description,
    required Duration estimatedDuration,
    required int originalDayIndex,
    List<String> dependsOn = const [],
    EnergyRequirement? energyOverride,
  }) {
    final energy = energyOverride ?? classify(description, estimatedDuration);

    return Task(
      id: id,
      goalId: goalId,
      title: description, // Use description as title for now
      description: description,
      estimatedDuration: estimatedDuration,
      energyRequirement: energy,
      createdAt: DateTime.now(),
      dependsOn: dependsOn,
      originalDayIndex: originalDayIndex,
    );
  }
}
