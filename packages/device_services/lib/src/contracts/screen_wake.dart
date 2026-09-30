/// Keeps the screen from sleeping while enabled.
abstract interface class ScreenWake {
  /// Enables or releases the wake lock. Never throws when unsupported.
  Future<void> setEnabled(bool on);
}
