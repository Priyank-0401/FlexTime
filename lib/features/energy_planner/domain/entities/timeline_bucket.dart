/// Grouping container for tasks in a timeline view (e.g., "This Week", "Next Week").
class TimelineBucket {
  const TimelineBucket({
    required this.id,
    required this.goalId,
    required this.label,
    required this.orderIndex,
  });

  /// Unique identifier for this bucket.
  final String id;

  /// The goal this bucket belongs to.
  final String goalId;

  /// Display label (e.g., "This Week").
  final String label;

  /// Sort order for display.
  final int orderIndex;

  /// Create a copy with updated fields.
  TimelineBucket copyWith({
    String? id,
    String? goalId,
    String? label,
    int? orderIndex,
  }) => TimelineBucket(
    id: id ?? this.id,
    goalId: goalId ?? this.goalId,
    label: label ?? this.label,
    orderIndex: orderIndex ?? this.orderIndex,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimelineBucket &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TimelineBucket($label, order: $orderIndex)';
}
