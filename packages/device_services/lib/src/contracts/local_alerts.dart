/// System notifications for a finished countdown.
///
/// Implementations log and return gracefully (never throw) when the platform
/// is unsupported or permission is denied, so timers stay usable.
abstract interface class LocalAlerts {
  /// Asks for notification permission; true when granted.
  Future<bool> requestPermission();

  /// Schedules a notification [id] at wall-clock [at]. No-op on web (the app
  /// calls [showNow] while the tab is open).
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
  });

  /// Cancels a scheduled notification; no-op when none is pending.
  Future<void> cancel(int id);

  /// Shows a notification immediately.
  Future<void> showNow({required String title, required String body});
}
