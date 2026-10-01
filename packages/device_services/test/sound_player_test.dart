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

void main() {
  late FakeLogger logger;
  late _MockPlayer flip;
  late _MockPlayer alarm;

  setUpAll(() {
    registerFallbackValue(AssetSource('x'));
    registerFallbackValue(ReleaseMode.loop);
  });

  setUp(() {
    logger = FakeLogger();
    flip = _MockPlayer();
    alarm = _MockPlayer();
    for (final player in [flip, alarm]) {
      when(() => player.play(any())).thenAnswer((_) async {});
      when(() => player.setReleaseMode(any())).thenAnswer((_) async {});
      when(player.stop).thenAnswer((_) async {});
      when(player.dispose).thenAnswer((_) async {});
    }
  });

  AudioSoundPlayer build({Duration limit = const Duration(seconds: 60)}) =>
      AudioSoundPlayer(
        flip: flip,
        alarm: alarm,
        logger: logger,
        alarmLimit: limit,
      );

  test('loads sounds from the package assets', () {
    build();
    expect(flip.cache?.prefix, 'packages/device_services/assets/sounds/');
    expect(alarm.cache, same(flip.cache));
  });

  test('each tick plays its own file', () async {
    final sounds = build();
    for (final tick in TickSound.values) {
      await sounds.playTick(tick);
    }
    final played = verify(() => flip.play(captureAny())).captured;
    expect(
      [for (final source in played) (source as AssetSource).path],
      [for (final tick in TickSound.values) tick.file],
    );
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
    when(() => flip.play(any())).thenThrow(StateError('no audio'));
    when(() => alarm.play(any())).thenThrow(StateError('no audio'));
    when(flip.dispose).thenThrow(StateError('gone'));
    final sounds = build();
    await sounds.playTick(TickSound.classic);
    await sounds.playAlarm(AlarmSound.chime);
    await sounds.dispose();
    expect(logger.errors, hasLength(3));
  });

  test('dispose releases both players', () async {
    await build().dispose();
    verify(flip.dispose).called(1);
    verify(alarm.dispose).called(1);
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
