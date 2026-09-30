import 'package:flip_clock/flip_clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults: black, 24h, no seconds, alert sound on', () {
    const s = ClockSettings();
    expect(s.theme, ClockTheme.black);
    expect(s.use24h, isTrue);
    expect(s.showSeconds, isFalse);
    expect(s.flipSound, isFalse);
    expect(s.alertSound, isTrue);
    expect(s.systemAlerts, isFalse);
    expect(s.keepAwake, isFalse);
    expect(s.lastMode, ClockMode.clock);
    expect(s.secondsHintSeen, isFalse);
    expect(s.digitBrightness, 1.0);
    expect(s.subtleMovement, isFalse);
    expect(s.showDate, isFalse);
  });

  test('round-trips through json and copyWith', () {
    final s = const ClockSettings().copyWith(
      theme: ClockTheme.light,
      use24h: false,
      showSeconds: true,
      flipSound: true,
      alertSound: false,
      systemAlerts: true,
      keepAwake: true,
      lastMode: ClockMode.stopwatch,
      secondsHintSeen: true,
      digitBrightness: 0.4,
      subtleMovement: true,
      showDate: true,
    );
    expect(ClockSettings.fromJson(s.toJson()), s);
    expect(ClockSettings.fromJson(s.toJson()).hashCode, s.hashCode);
    expect(s, isNot(const ClockSettings()));
    expect(s.copyWith(), s);
  });

  test('corrupt fields fall back to defaults', () {
    expect(
      ClockSettings.fromJson({
        'theme': 'neon',
        'use24h': 'yes',
        'lastMode': 3,
        'secondsHintSeen': 'no',
        'subtleMovement': 'on',
        'showDate': 'true',
      }),
      const ClockSettings(),
    );
  });

  test('digit brightness clamps numbers and ignores non-numbers', () {
    double read(Object? v) =>
        ClockSettings.fromJson({'digitBrightness': v}).digitBrightness;
    expect(read(0.6), 0.6);
    expect(read(1), 1.0);
    expect(read(0.05), 0.2);
    expect(read(-3), 0.2);
    expect(read(7.5), 1.0);
    expect(read(double.nan), 1.0);
    expect(read('0.5'), 1.0);
    expect(read(null), 1.0);
    expect(
      const ClockSettings(digitBrightness: 0.5),
      isNot(const ClockSettings()),
    );
  });

  test(
    'quick dim cycles 100 -> 50 -> 20 -> 100 and steps down from between',
    () {
      expect(ClockSettings.nextDim(1), 0.5);
      expect(ClockSettings.nextDim(0.5), 0.2);
      expect(ClockSettings.nextDim(0.2), 1.0);
      expect(ClockSettings.nextDim(0.8), 0.5);
      expect(ClockSettings.nextDim(0.3), 0.2);
    },
  );

  test('routes are fixed', () {
    expect(FlipClockRouter.home, '/clock');
    expect(FlipClockRouter.settings, '/clock/settings');
  });
}
