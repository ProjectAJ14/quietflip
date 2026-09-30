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
    );
    expect(ClockSettings.fromJson(s.toJson()), s);
    expect(ClockSettings.fromJson(s.toJson()).hashCode, s.hashCode);
    expect(s, isNot(const ClockSettings()));
    expect(s.copyWith(), s);
  });

  test('corrupt fields fall back to defaults', () {
    expect(
      ClockSettings.fromJson({'theme': 'neon', 'use24h': 'yes', 'lastMode': 3}),
      const ClockSettings(),
    );
  });

  test('routes are fixed', () {
    expect(FlipClockRouter.home, '/clock');
    expect(FlipClockRouter.settings, '/clock/settings');
  });
}
