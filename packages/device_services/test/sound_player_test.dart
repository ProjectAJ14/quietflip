import 'package:audioplayers/audioplayers.dart';
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

  test('plays the flip click', () async {
    await build().playFlip();
    final source =
        verify(() => flip.play(captureAny())).captured.single as AssetSource;
    expect(source.path, 'flip.wav');
  });

  test('loops the alarm until stopped', () async {
    final sounds = build();
    await sounds.playAlarm();
    verify(() => alarm.setReleaseMode(ReleaseMode.loop)).called(1);
    final source =
        verify(() => alarm.play(captureAny())).captured.single as AssetSource;
    expect(source.path, 'alarm.wav');
    await sounds.stopAlarm();
    verify(alarm.stop).called(1);
  });

  test('alarm stops by itself after the limit', () async {
    await build(limit: const Duration(milliseconds: 5)).playAlarm();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    verify(alarm.stop).called(1);
  });

  test('player failures are logged, not thrown', () async {
    when(() => flip.play(any())).thenThrow(StateError('no audio'));
    when(() => alarm.play(any())).thenThrow(StateError('no audio'));
    when(flip.dispose).thenThrow(StateError('gone'));
    final sounds = build();
    await sounds.playFlip();
    await sounds.playAlarm();
    await sounds.dispose();
    expect(logger.errors, hasLength(3));
  });

  test('dispose releases both players', () async {
    await build().dispose();
    verify(flip.dispose).called(1);
    verify(alarm.dispose).called(1);
  });
}
