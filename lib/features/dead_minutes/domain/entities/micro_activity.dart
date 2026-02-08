/// Energy level for activities - maps to user's current energy state.
enum EnergyLevel { low, medium, high }

/// A micro activity that can be done during "dead minutes".
///
/// Domain entity - pure Dart, no Flutter dependencies.
class MicroActivity {
  const MicroActivity({
    required this.title,
    required this.durationMinutes,
    required this.energyLevel,
    required this.category,
    required this.createdAt,
    this.id,
    this.description,
    this.isCompleted = false,
    this.completedAt,
  });

  final int? id;
  final String title;
  final String? description;
  final int durationMinutes;
  final EnergyLevel energyLevel;
  final String category;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  /// Create a copy with updated fields.
  MicroActivity copyWith({
    int? id,
    String? title,
    String? description,
    int? durationMinutes,
    EnergyLevel? energyLevel,
    String? category,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) => MicroActivity(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    energyLevel: energyLevel ?? this.energyLevel,
    category: category ?? this.category,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt ?? this.completedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MicroActivity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}
