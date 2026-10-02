import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:core/core.dart';
import 'package:device_services/src/contracts/index.dart';
import 'package:device_services/src/guarded.dart';

/// Builds the preloaded pool for one tick file: `AudioPool.createFromAsset`
/// in the app, a fake in tests.
typedef TickPoolFactory =
    Future<AudioPool> Function({
      required String path,
      required int maxPlayers,
      AudioCache? audioCache,
    });

/// [SoundPlayer] over this package's `assets/sounds/`: one preloaded
/// `AudioPool` per tick sound and one `audioplayers` player for the alarm.
class AudioSoundPlayer implements SoundPlayer {
  AudioSoundPlayer({
    required AudioPlayer alarm,
    required Logger logger,
    TickPoolFactory createPool = AudioPool.createFromAsset,
    this.alarmLimit = const Duration(seconds: 60),
  }) : _alarm = alarm,
       _logger = logger,
       _createPool = createPool {
    alarm.audioCache = _cache;
  }

  final AudioPlayer _alarm;
  final Logger _logger;
  final TickPoolFactory _createPool;
  final _cache = AudioCache(prefix: 'packages/device_services/assets/sounds/');

  /// Created on first use of each sound and kept, so a tick never reloads
  /// its file. A failed load is dropped so the next tick retries.
  final Map<TickSound, Future<AudioPool>> _pools = {};

  /// Ticks run one after another, so a quick run of taps plays in order and
  /// a switch always stops the sound it follows.
  Future<void> _ticks = Future.value();
  TickSound? _lastTick;
  StopFunction? _stopLastTick;

  /// The chime stops by itself after this long.
  final Duration alarmLimit;
  Timer? _limit;

  Future<AudioPool> _pool(TickSound sound) async {
    final pool = _pools[sound] ??= _createPool(
      path: sound.file,
      maxPlayers: 2,
      audioCache: _cache,
    );
    try {
      return await pool;
    } on Object {
      if (identical(_pools[sound], pool)) _pools.remove(sound);
      rethrow;
    }
  }

  @override
  Future<void> warmTick(TickSound sound) =>
      guarded(_logger, 'warm tick', () => _pool(sound), null);

  @override
  Future<void> playTick(TickSound sound) => _ticks = _ticks.then(
    (_) => guarded(_logger, 'tick sound', () async {
      final pool = await _pool(sound);
      if (sound != _lastTick) await _stopLastTick?.call();
      _stopLastTick = await pool.start();
      _lastTick = sound;
    }, null),
  );

  @override
  Future<void> playAlarm(AlarmSound sound) async {
    final looping = _limit != null;
    _limit?.cancel();
    _limit = Timer(alarmLimit, stopAlarm);
    await guarded(_logger, 'alarm sound', () async {
      if (looping) await _alarm.stop();
      await _alarm.setReleaseMode(ReleaseMode.loop);
      await _alarm.play(AssetSource(sound.file));
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
      await _alarm.dispose();
      for (final pool in _pools.values) {
        await (await pool).dispose();
      }
    }, null);
  }
}
