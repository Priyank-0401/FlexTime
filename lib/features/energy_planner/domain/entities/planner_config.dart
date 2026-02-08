/// System-wide configuration constants for the planner.
///
/// These values are tunable based on user feedback and research.
/// All durations use Dart's [Duration] for type safety.
abstract final class PlannerConfig {
  /// Maximum productive effort per day (research-backed limit).
  static const Duration maxDailyEffort = Duration(hours: 4);

  /// Maximum task duration for low-energy days.
  static const Duration lowEnergyMaxTask = Duration(minutes: 30);

  /// Maximum task duration for medium-energy days.
  static const Duration mediumEnergyMaxTask = Duration(hours: 2);

  /// Reduced daily capacity for low-energy days.
  static const Duration lowEnergyMaxDaily = Duration(hours: 1, minutes: 30);

  /// Buffer factor for initial timeline generation (15% slack).
  /// Applied to allow absorption of low-energy days without compression.
  static const double bufferFactor = 0.15;

  /// Minimum task duration to avoid micro-fragmentation.
  static const Duration minTaskDuration = Duration(minutes: 10);

  /// Default number of days to generate if not specified.
  static const int defaultTimelineDays = 30;
}
