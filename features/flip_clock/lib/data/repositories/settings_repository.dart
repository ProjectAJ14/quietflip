import 'package:flip_clock/data/models/clock_settings.dart';

/// Local persistence for the clock's preferences and the countdown snapshot.
abstract interface class SettingsRepository {
  /// Saved settings, or defaults when nothing (or nothing valid) is stored.
  Future<ClockSettings> load();

  /// Saves [settings], replacing the previous value.
  Future<void> save(ClockSettings settings);

  /// The saved countdown snapshot, or null when absent or corrupt.
  Future<Map<String, Object?>?> loadCountdown();

  /// Saves a countdown snapshot (`Countdown.toJson()`).
  Future<void> saveCountdown(Map<String, Object?> snapshot);
}
