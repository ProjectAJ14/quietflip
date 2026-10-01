import 'package:design_system/design_system.dart';
import 'package:device_services/device_services.dart';
import 'package:flip_clock/ui/components/sound_wave.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget wave, {bool reduceMotion = false}) => MaterialApp(
  theme: ThemeData(colorScheme: DesignSystem.blackScheme()),
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Center(child: SizedBox.square(dimension: 96, child: wave)),
  ),
);

const _ink = Color(0xFFFFFFFF);

final _start = DateTime(2026, 10);

List<SoundWave> everyWave(DateTime? playing) => [
  for (final tick in TickSound.values)
    SoundWave.tick(tick, playing: playing, color: _ink),
  for (final alarm in AlarmSound.values)
    SoundWave.alarm(alarm, playing: playing, color: _ink),
];

WavePose pose(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(
    find.descendant(
      of: find.byType(SoundWave),
      matching: find.byType(CustomPaint),
    ),
  );
  return (paint.painter! as SoundWavePainter).pose.value;
}

/// The still pose. (A running ticker shows as a transient frame callback.)
const rest = (time: SoundWave.restTime, energy: SoundWave.restEnergy);

void main() {
  testWidgets('every sound paints at rest and while playing', (tester) async {
    final waves = everyWave(null);
    for (var i = 0; i < waves.length; i++) {
      await tester.pumpWidget(host(waves[i]));
      expect(pose(tester), rest);
      expect(tester.binding.transientCallbackCount, 0, reason: 'no ticker');
      await tester.pumpWidget(host(everyWave(_start)[i]));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(pose(tester).time, closeTo(0.5, 0.02), reason: '$i');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('a tick pulses on each of three ticks, then rests', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(SoundWave.tick(TickSound.woodblock, playing: _start, color: _ink)),
    );
    await tester.pump();
    final energies = <double>[];
    for (final ms in [20, 480, 520, 480, 520]) {
      await tester.pump(Duration(milliseconds: ms));
      energies.add(pose(tester).energy);
    }
    // Sampled at 0.02, 0.5, 1.02, 1.5 and 2.02 s.
    expect(energies[0], greaterThan(0.9), reason: 'the first tick hits');
    expect(energies[1], lessThan(0.6));
    expect(energies[2], greaterThan(0.9), reason: 'the second tick hits');
    expect(energies[3], lessThan(0.6));
    expect(energies[4], greaterThan(0.9), reason: 'the third tick hits');
    await tester.pump(const Duration(seconds: 2));
    expect(pose(tester), rest);
    expect(tester.binding.transientCallbackCount, 0, reason: 'ticker stops');
  });

  testWidgets('an alarm moves at full energy for two loops, then rests', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(SoundWave.alarm(AlarmSound.beeps, playing: _start, color: _ink)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2100));
    expect(pose(tester).energy, 1);
    await tester.pump(const Duration(milliseconds: 200));
    expect(pose(tester).energy, SoundWave.restEnergy, reason: 'past 2.2 s');
    await tester.pump(const Duration(milliseconds: 500));
    expect(pose(tester), rest);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('stopping or restarting follows playing', (tester) async {
    Widget wave(DateTime? playing) =>
        host(SoundWave.alarm(AlarmSound.bell, playing: playing, color: _ink));
    await tester.pumpWidget(wave(_start));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(pose(tester).time, closeTo(1, 0.02));
    await tester.pumpWidget(wave(_start.add(const Duration(seconds: 1))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(pose(tester).time, closeTo(0.3, 0.02), reason: 'restarted');
    await tester.pumpWidget(wave(null));
    expect(pose(tester), rest);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('reduced motion holds the still pose while playing', (
    tester,
  ) async {
    for (final wave in everyWave(_start)) {
      await tester.pumpWidget(host(wave, reduceMotion: true));
      await tester.pump(const Duration(milliseconds: 500));
      expect(pose(tester), rest);
      expect(tester.binding.transientCallbackCount, 0);
    }
  });

  testWidgets('disposing while playing releases the ticker', (tester) async {
    await tester.pumpWidget(
      host(SoundWave.tick(TickSound.digital, playing: _start, color: _ink)),
    );
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('repaints only for a new wave, colour or pose', (tester) async {
    SoundWavePainter painter() =>
        tester
                .widget<CustomPaint>(
                  find.descendant(
                    of: find.byType(SoundWave),
                    matching: find.byType(CustomPaint),
                  ),
                )
                .painter!
            as SoundWavePainter;
    Widget wave(TickSound sound, Color color) =>
        host(SoundWave.tick(sound, playing: null, color: color));
    await tester.pumpWidget(wave(TickSound.classic, _ink));
    final first = painter();
    await tester.pumpWidget(wave(TickSound.classic, _ink));
    expect(painter().shouldRepaint(first), isFalse);
    await tester.pumpWidget(wave(TickSound.digital, _ink));
    expect(painter().shouldRepaint(first), isTrue);
    await tester.pumpWidget(wave(TickSound.classic, const Color(0xFF000000)));
    expect(painter().shouldRepaint(first), isTrue);
  });
}
