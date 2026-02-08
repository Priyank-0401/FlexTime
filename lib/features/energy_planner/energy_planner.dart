/// Energy-Adaptive Learning Planner feature.
///
/// A rule-based planning and task-reshaping system that:
/// - Preserves long-term deadlines
/// - Dynamically adjusts daily tasks based on self-reported energy
/// - Never "breaks" the plan
/// - Works entirely offline with local persistence
library;

export 'data/data.dart';
export 'domain/domain.dart';
export 'engine/engine.dart';
