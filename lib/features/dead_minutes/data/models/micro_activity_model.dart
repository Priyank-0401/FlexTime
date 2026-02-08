import '../../domain/entities/micro_activity.dart';

/// Data model for micro activities with SQLite serialization.
class MicroActivityModel {
  const MicroActivityModel({
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

  /// Create from SQLite map.
  factory MicroActivityModel.fromMap(Map<String, dynamic> map) =>
      MicroActivityModel(
        id: map['id'] as int?,
        title: map['title'] as String,
        description: map['description'] as String?,
        durationMinutes: map['duration_minutes'] as int,
        energyLevel: map['energy_level'] as String,
        category: map['category'] as String,
        isCompleted: (map['is_completed'] as int) == 1,
        createdAt: DateTime.parse(map['created_at'] as String),
        completedAt: map['completed_at'] != null
            ? DateTime.parse(map['completed_at'] as String)
            : null,
      );

  /// Create from domain entity.
  factory MicroActivityModel.fromEntity(MicroActivity entity) =>
      MicroActivityModel(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        durationMinutes: entity.durationMinutes,
        energyLevel: entity.energyLevel.name,
        category: entity.category,
        isCompleted: entity.isCompleted,
        createdAt: entity.createdAt,
        completedAt: entity.completedAt,
      );

  final int? id;
  final String title;
  final String? description;
  final int durationMinutes;
  final String energyLevel;
  final String category;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  /// Convert to SQLite map.
  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'description': description,
    'duration_minutes': durationMinutes,
    'energy_level': energyLevel,
    'category': category,
    'is_completed': isCompleted ? 1 : 0,
    'created_at': createdAt.toIso8601String(),
    'completed_at': completedAt?.toIso8601String(),
  };

  /// Convert to domain entity.
  MicroActivity toEntity() => MicroActivity(
    id: id,
    title: title,
    description: description,
    durationMinutes: durationMinutes,
    energyLevel: EnergyLevel.values.firstWhere(
      (e) => e.name == energyLevel,
      orElse: () => EnergyLevel.medium,
    ),
    category: category,
    isCompleted: isCompleted,
    createdAt: createdAt,
    completedAt: completedAt,
  );
}
