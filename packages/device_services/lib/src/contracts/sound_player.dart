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
  /// Plays [sound] once. Switching to a different sound stops the previous
  /// one first, so two ticks never layer.
  Future<void> playTick(TickSound sound);

  /// Loads [sound] ahead of its first [playTick] so that tick has no load
  /// delay. Plays nothing.
  Future<void> warmTick(TickSound sound);

  /// Loops [sound] until [stopAlarm] or 60 seconds. A new call while one
  /// loops switches to [sound]; two alarms never play at once. Stops any
  /// [previewAlarm] first: the real alarm always wins.
  Future<void> playAlarm(AlarmSound sound);

  /// Stops the alarm; no-op when silent. Never touches a preview.
  Future<void> stopAlarm();

  /// Loops [sound] as a settings preview, on its own player, until
  /// [stopPreview] or 60 seconds. A new call switches the preview. Does
  /// nothing while a [playAlarm] alarm rings, so a preview never replaces
  /// or silences it.
  Future<void> previewAlarm(AlarmSound sound);

  /// Stops the preview; no-op when silent. Never touches the alarm.
  Future<void> stopPreview();
}
