/// The tick sounds bundled in `assets/sounds/`, played once per [SoundPlayer.playTick].
enum TickSound {
  classic('flip.wav'),
  splitFlap('tick_split_flap.wav'),
  clockwork('tick_clockwork.wav'),
  woodblock('tick_woodblock.wav'),
  digital('tick_digital.wav');

  const TickSound(this.file);

  /// The file name under `assets/sounds/`.
  final String file;
}

/// The alarm sounds bundled in `assets/sounds/`, looped by [SoundPlayer.playAlarm].
enum AlarmSound {
  chime('alarm.wav'),
  bell('alarm_bell.wav'),
  beeps('alarm_beeps.wav'),
  rising('alarm_rising.wav'),
  ring('alarm_ring.wav');

  const AlarmSound(this.file);

  /// The file name under `assets/sounds/`.
  final String file;
}

/// Short UI sounds bundled with this package (`assets/sounds/`).
abstract interface class SoundPlayer {
  /// Plays [sound] once.
  Future<void> playTick(TickSound sound);

  /// Loops [sound] until [stopAlarm] or 60 seconds. A new call while one
  /// loops switches to [sound]; two alarms never play at once.
  Future<void> playAlarm(AlarmSound sound);

  /// Stops the alarm; no-op when silent.
  Future<void> stopAlarm();
}
