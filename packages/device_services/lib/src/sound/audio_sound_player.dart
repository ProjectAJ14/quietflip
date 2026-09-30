import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:core/core.dart';
import 'package:device_services/src/contracts/index.dart';
import 'package:device_services/src/guarded.dart';

/// [SoundPlayer] over two `audioplayers` players and this package's
/// `assets/sounds/`.
class AudioSoundPlayer implements SoundPlayer {
  AudioSoundPlayer({
    required AudioPlayer flip,
    required AudioPlayer alarm,
    required Logger logger,
    this.alarmLimit = const Duration(seconds: 60),
  }) : _flip = flip,
       _alarm = alarm,
       _logger = logger {
    final cache = AudioCache(prefix: 'packages/device_services/assets/sounds/');
    flip.audioCache = cache;
    alarm.audioCache = cache;
  }

  final AudioPlayer _flip;
  final AudioPlayer _alarm;
  final Logger _logger;

  /// The chime stops by itself after this long.
  final Duration alarmLimit;
  Timer? _limit;

  @override
  Future<void> playFlip() => guarded(
    _logger,
    'flip sound',
    () => _flip.play(AssetSource('flip.wav')),
    null,
  );

  @override
  Future<void> playAlarm() async {
    _limit?.cancel();
    _limit = Timer(alarmLimit, stopAlarm);
    await guarded(_logger, 'alarm sound', () async {
      await _alarm.setReleaseMode(ReleaseMode.loop);
      await _alarm.play(AssetSource('alarm.wav'));
    }, null);
  }

  @override
  Future<void> stopAlarm() {
    _limit?.cancel();
    _limit = null;
    return guarded(_logger, 'stop alarm', _alarm.stop, null);
  }

  Future<void> dispose() async {
    _limit?.cancel();
    await guarded(_logger, 'dispose players', () async {
      await _flip.dispose();
      await _alarm.dispose();
    }, null);
  }
}
