import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:device_services/device_services.dart';
import 'package:device_services/src/sound/audio_sound_player.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'fakes.dart';

class _MockPlayer extends Mock implements AudioPlayer {
  AudioCache? cache;

  @override
  set audioCache(AudioCache value) => cache = value;
}

/// One pool per tick sound, recording every call into a shared log.
class _FakePool extends Fake implements AudioPool {
  _FakePool(this.path, this.log);

  final String path;
  final List<String> log;
  Object? startError;

  @override
  Future<StopFunction> start({double volume = 1.0}) async {
    if (startError case final error?) throw error;
    log.add('start $path');
    return () async => log.add('stop $path');
  }

  @override
  Future<void> dispose() async => log.add('dispose $path');
}

void main() {
  late FakeLogger logger;
  late _MockPlayer alarm;
  late List<String> log;
  late List<_FakePool> pools;
  late List<AudioCache?> caches;
  late List<int> sizes;
  late int failCreates;

  setUpAll(() {
    registerFallbackValue(AssetSource('x'));
    registerFallbackValue(ReleaseMode.loop);
  });

  setUp(() {
    logger = FakeLogger();
    alarm = _MockPlayer();
    when(() => alarm.play(any())).thenAnswer((_) async {});
    when(() => alarm.setReleaseMode(any())).thenAnswer((_) async {});
    when(alarm.stop).thenAnswer((_) async {});
    when(alarm.dispose).thenAnswer((_) async {});
    log = [];
    pools = [];
    caches = [];
    sizes = [];
    failCreates = 0;
  });

  Future<AudioPool> createPool({
    required String path,
    required int maxPlayers,
    AudioCache? audioCache,
  }) async {
    // Yield first, as the real pool does while it loads the file.
    await Future<void>.delayed(Duration.zero);
    if (failCreates > 0) {
      failCreates--;
      throw StateError('no audio');
    }
    log.add('create $path');
    caches.add(audioCache);
    sizes.add(maxPlayers);
    final pool = _FakePool(path, log);
    pools.add(pool);
    return pool;
  }

  AudioSoundPlayer build({Duration limit = const Duration(seconds: 60)}) =>
      AudioSoundPlayer(
        alarm: alarm,
        logger: logger,
        createPool: createPool,
        alarmLimit: limit,
      );

  test('loads sounds from the package assets', () async {
    await build().playTick(TickSound.classic);
    expect(alarm.cache?.prefix, 'packages/device_services/assets/sounds/');
    expect(caches.single, same(alarm.cache));
    expect(sizes.single, 2);
  });

  test('each tick plays its own file', () async {
    final sounds = build();
    for (final tick in TickSound.values) {
      await sounds.playTick(tick);
    }
    expect(
      [
        for (final line in log)
          if (line.startsWith('start ')) line,
      ],
      [for (final tick in TickSound.values) 'start ${tick.file}'],
    );
  });

  test('rapid ticks: one pool per sound, one play per call, a switch stops '
      'the previous sound first', () async {
    const c = TickSound.classic;
    const d = TickSound.digital;
    const w = TickSound.woodblock;
    final taps = [c, c, d, d, d, w, c, w, w, d];
    final sounds = build();
    await Future.wait([for (final tap in taps) sounds.playTick(tap)]);
    expect([for (final pool in pools) pool.path], [c.file, d.file, w.file]);
    final expected = <String>[];
    TickSound? previous;
    for (final tap in taps) {
      if (previous != null && previous != tap) {
        expected.add('stop ${previous.file}');
      }
      expected.add('start ${tap.file}');
      previous = tap;
    }
    expect([
      for (final line in log)
        if (!line.startsWith('create')) line,
    ], expected);
    expect(logger.errors, isEmpty);
  });

  test('warmTick loads the pool without playing; the tick reuses it', () async {
    final sounds = build();
    await sounds.warmTick(TickSound.splitFlap);
    expect(log, ['create ${TickSound.splitFlap.file}']);
    await sounds.warmTick(TickSound.splitFlap);
    await sounds.playTick(TickSound.splitFlap);
    expect(log, [
      'create ${TickSound.splitFlap.file}',
      'start ${TickSound.splitFlap.file}',
    ]);
  });

  test(
    'a failed pool is logged, not thrown, and the next tick retries',
    () async {
      failCreates = 2;
      final sounds = build();
      await sounds.warmTick(TickSound.clockwork);
      await sounds.playTick(TickSound.clockwork);
      expect(logger.errors, hasLength(2));
      expect(log, isEmpty);
      await sounds.playTick(TickSound.clockwork);
      expect(log, [
        'create ${TickSound.clockwork.file}',
        'start ${TickSound.clockwork.file}',
      ]);
    },
  );

  test('a failing start is logged and later ticks still play', () async {
    final sounds = build();
    await sounds.warmTick(TickSound.digital);
    pools.single.startError = StateError('busy');
    await sounds.playTick(TickSound.digital);
    expect(logger.errors, hasLength(1));
    pools.single.startError = null;
    await sounds.playTick(TickSound.digital);
    expect(log.last, 'start ${TickSound.digital.file}');
  });

  test('each alarm loops its own file until stopped', () async {
    for (final sound in AlarmSound.values) {
      final sounds = build();
      await sounds.playAlarm(sound);
      verify(() => alarm.setReleaseMode(ReleaseMode.loop)).called(1);
      final source =
          verify(() => alarm.play(captureAny())).captured.single as AssetSource;
      expect(source.path, sound.file);
      await sounds.stopAlarm();
      verify(alarm.stop).called(1);
    }
  });

  test('a new alarm replaces the looping one, never stacks', () async {
    final sounds = build();
    await sounds.playAlarm(AlarmSound.bell);
    await sounds.playAlarm(AlarmSound.beeps);
    verifyInOrder([
      () => alarm.play(any(that: AssetSourceMatcher(AlarmSound.bell.file))),
      alarm.stop,
      () => alarm.play(any(that: AssetSourceMatcher(AlarmSound.beeps.file))),
    ]);
  });

  test('every bundled sound file exists', () {
    final files = [
      for (final tick in TickSound.values) tick.file,
      for (final alarm in AlarmSound.values) alarm.file,
    ];
    expect(files.toSet(), hasLength(files.length));
    for (final file in files) {
      expect(File('assets/sounds/$file').existsSync(), isTrue, reason: file);
    }
  });

  test('alarm stops by itself after the limit', () async {
    await build(
      limit: const Duration(milliseconds: 5),
    ).playAlarm(AlarmSound.chime);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    verify(alarm.stop).called(1);
  });

  test('player failures are logged, not thrown', () async {
    when(() => alarm.play(any())).thenThrow(StateError('no audio'));
    when(alarm.dispose).thenThrow(StateError('gone'));
    final sounds = build();
    await sounds.playAlarm(AlarmSound.chime);
    await sounds.dispose();
    expect(logger.errors, hasLength(2));
  });

  test('dispose releases the alarm player and every pool', () async {
    final sounds = build();
    await sounds.playTick(TickSound.classic);
    await sounds.warmTick(TickSound.digital);
    await sounds.dispose();
    verify(alarm.dispose).called(1);
    expect(
      [
        for (final line in log)
          if (line.startsWith('dispose')) line,
      ],
      [
        'dispose ${TickSound.classic.file}',
        'dispose ${TickSound.digital.file}',
      ],
    );
  });
}

/// Matches an [AssetSource] by its path ([AssetSource] has no `==`).
class AssetSourceMatcher extends Matcher {
  AssetSourceMatcher(this.path);

  final String path;

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) =>
      item is AssetSource && item.path == path;

  @override
  Description describe(Description description) =>
      description.add('AssetSource($path)');
}
