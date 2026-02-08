import 'package:flextime_app/core/enums/energy_requirement.dart';
import '../../domain/entities/task.dart';

/// Data model for Task with SQLite serialization.
class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.goalId,
    required super.title,
    required super.description,
    required super.estimatedDuration,
    required super.energyRequirement,
    required super.createdAt,
    required super.originalDayIndex,
    super.dependsOn,
    super.status,
    super.currentDayIndex,
  });

  /// Create from domain entity.
  factory TaskModel.fromEntity(Task entity) => TaskModel(
    id: entity.id,
    goalId: entity.goalId,
    title: entity.title,
    description: entity.description,
    estimatedDuration: entity.estimatedDuration,
    energyRequirement: entity.energyRequirement,
    createdAt: entity.createdAt,
    dependsOn: entity.dependsOn,
    status: entity.status,
    originalDayIndex: entity.originalDayIndex,
    currentDayIndex: entity.currentDayIndex,
  );

  /// Create from SQLite map.
  factory TaskModel.fromMap(Map<String, dynamic> map) => TaskModel(
    id: map['id'] as String,
    goalId: map['goal_id'] as String,
    title: map['title'] as String? ?? map['description'] as String,
    description: map['description'] as String,
    estimatedDuration: Duration(minutes: map['duration_minutes'] as int),
    energyRequirement: EnergyRequirement.values.firstWhere(
      (e) => e.name == map['energy_requirement'],
      orElse: () => EnergyRequirement.medium,
    ),
    createdAt: map['created_at'] != null
        ? DateTime.parse(map['created_at'] as String)
        : DateTime.now(),
    status: TaskStatus.values.firstWhere(
      (s) => s.name == map['status'],
      orElse: () => TaskStatus.pending,
    ),
    originalDayIndex: map['original_day_index'] as int,
    currentDayIndex: map['current_day_index'] as int?,
    // Dependencies loaded separately via join table
  );

  /// Convert to SQLite map.
  Map<String, dynamic> toMap() => {
    'id': id,
    'goal_id': goalId,
    'title': title,
    'description': description,
    'duration_minutes': estimatedDuration.inMinutes,
    'energy_requirement': energyRequirement.name,
    'created_at': createdAt.toIso8601String(),
    'status': status.name,
    'original_day_index': originalDayIndex,
    'current_day_index': currentDayIndex,
    'updated_at': DateTime.now().toIso8601String(),
  };

  /// Convert to domain entity.
  Task toEntity({List<String>? dependencies}) => Task(
    id: id,
    goalId: goalId,
    title: title,
    description: description,
    estimatedDuration: estimatedDuration,
    energyRequirement: energyRequirement,
    createdAt: createdAt,
    dependsOn: dependencies ?? dependsOn,
    status: status,
    originalDayIndex: originalDayIndex,
    currentDayIndex: currentDayIndex,
  );
}
