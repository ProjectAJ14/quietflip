/// Short UI sounds bundled with this package (`assets/sounds/`).
abstract interface class SoundPlayer {
  /// Plays the soft flip click once.
  Future<void> playFlip();

  /// Loops the completion chime until [stopAlarm] or 60 seconds.
  Future<void> playAlarm();

  /// Stops the chime; no-op when silent.
  Future<void> stopAlarm();
}
