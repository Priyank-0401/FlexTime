import '../../domain/entities/activity_result.dart';
import '../../domain/entities/micro_progress.dart';

/// Data model for MicroProgress with SQLite serialization.
class MicroProgressModel {
  const MicroProgressModel({
    required this.activityId,
    required this.completedAt,
    required this.durationSeconds,
    required this.resultType,
    this.id,
  });

  factory MicroProgressModel.fromMap(Map<String, dynamic> map) =>
      MicroProgressModel(
        id: map['id'] as int?,
        activityId: map['activity_id'] as String,
        completedAt: DateTime.parse(map['completed_at'] as String),
        durationSeconds: map['duration_seconds'] as int,
        resultType: ActivityResultType.values.firstWhere(
          (e) => e.name == map['result_type'],
          orElse: () => ActivityResultType.completed,
        ),
      );

  factory MicroProgressModel.fromEntity(MicroProgress entity) =>
      MicroProgressModel(
        id: entity.id,
        activityId: entity.activityId,
        completedAt: entity.completedAt,
        durationSeconds: entity.durationSeconds,
        resultType: entity.resultType,
      );

  final int? id;
  final String activityId;
  final DateTime completedAt;
  final int durationSeconds;
  final ActivityResultType resultType;

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'activity_id': activityId,
    'completed_at': completedAt.toIso8601String(),
    'duration_seconds': durationSeconds,
    'result_type': resultType.name,
  };

  MicroProgress toEntity() => MicroProgress(
    id: id,
    activityId: activityId,
    completedAt: completedAt,
    durationSeconds: durationSeconds,
    resultType: resultType,
  );
}
