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
/// `AudioPool` per tick sound, one `audioplayers` player for the alarm and
/// another for settings previews, so a preview can never stop the alarm.
class AudioSoundPlayer implements SoundPlayer {
  AudioSoundPlayer({
    required AudioPlayer alarm,
    required AudioPlayer preview,
    required Logger logger,
    TickPoolFactory createPool = AudioPool.createFromAsset,
    this.alarmLimit = const Duration(seconds: 60),
  }) : _logger = logger,
       _createPool = createPool {
    _alarm = _Loop(alarm, 'alarm', this);
    _preview = _Loop(preview, 'preview', this);
  }

  late final _Loop _alarm;
  late final _Loop _preview;
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

  /// The alarm and a preview each stop by themselves after this long.
  final Duration alarmLimit;

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
    await _preview.stop();
    await _alarm.play(sound);
  }

  @override
  Future<void> stopAlarm() => _alarm.stop();

  @override
  Future<void> previewAlarm(AlarmSound sound) async {
    if (_alarm.looping) return;
    await _preview.play(sound);
  }

  @override
  Future<void> stopPreview() => _preview.stop();

  Future<void> dispose() async {
    await _alarm.dispose();
    await _preview.dispose();
    await guarded(_logger, 'dispose tick pools', () async {
      for (final pool in _pools.values) {
        await (await pool).dispose();
      }
    }, null);
  }
}

/// One looping player that stops by itself after [AudioSoundPlayer.alarmLimit].
class _Loop {
  _Loop(this._player, this._name, this._owner) {
    _player.audioCache = _owner._cache;
  }

  final AudioPlayer _player;
  final String _name;
  final AudioSoundPlayer _owner;
  Timer? _limit;

  /// Whether a [play] has not yet been stopped or timed out.
  bool get looping => _limit != null;

  Future<void> play(AlarmSound sound) async {
    final wasLooping = looping;
    _limit?.cancel();
    _limit = Timer(_owner.alarmLimit, stop);
    await guarded(_owner._logger, '$_name sound', () async {
      if (wasLooping) await _player.stop();
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource(sound.file));
    }, null);
  }

  Future<void> stop() {
    _limit?.cancel();
    _limit = null;
    return guarded(_owner._logger, 'stop $_name', _player.stop, null);
  }

  Future<void> dispose() {
    _limit?.cancel();
    return guarded(_owner._logger, 'dispose $_name', _player.dispose, null);
  }
}
