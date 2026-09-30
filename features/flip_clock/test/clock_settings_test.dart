import 'package:flip_clock/flip_clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults: black, 24h, no seconds, alert sound on', () {
    const s = ClockSettings();
    expect(s.theme, ClockTheme.dark);
    expect(s.use24h, isTrue);
    expect(s.showSeconds, isFalse);
    expect(s.flipSound, isFalse);
    expect(s.alertSound, isTrue);
    expect(s.systemAlerts, isFalse);
    expect(s.keepAwake, isFalse);
    expect(s.lastMode, ClockMode.clock);
    expect(s.digitBrightness, 1.0);
    expect(s.subtleMovement, isFalse);
    expect(s.showDate, isFalse);
    expect(s.orientation, ClockOrientation.auto);
    expect(s.tapToggleControls, isTrue);
    expect(s.controlsIdle, const Duration(seconds: 4));
    expect(s.gestureBrightness, isTrue);
    expect(s.gestureModes, isTrue);
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
      digitBrightness: 0.4,
      subtleMovement: true,
      showDate: true,
      orientation: ClockOrientation.landscape,
      tapToggleControls: false,
      controlsIdle: Duration.zero,
      gestureBrightness: false,
      gestureModes: false,
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
        'subtleMovement': 'on',
        'showDate': 'true',
        'orientation': 'sideways',
        'tapToggleControls': 'off',
        'controlsIdleMs': '2000',
        'gestureBrightness': 'no',
        'gestureModes': 0,
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

  test('controls idle reads only the offered choices', () {
    Duration read(Object? v) =>
        ClockSettings.fromJson({'controlsIdleMs': v}).controlsIdle;
    expect(read(2000), const Duration(seconds: 2));
    expect(read(8000), const Duration(seconds: 8));
    expect(read(0), Duration.zero);
    expect(read(3000), const Duration(seconds: 4));
    expect(read(-1), const Duration(seconds: 4));
    expect(read(null), const Duration(seconds: 4));
    expect(
      const ClockSettings(
        controlsIdle: Duration.zero,
      ).toJson()['controlsIdleMs'],
      0,
    );
    expect(
      const ClockSettings(tapToggleControls: false),
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

  test('gesture flags read their own keys and compare', () {
    final json = const ClockSettings(gestureBrightness: false).toJson();
    expect(json['gestureBrightness'], isFalse);
    expect(json['gestureModes'], isTrue);
    expect(
      ClockSettings.fromJson({'gestureModes': false}),
      const ClockSettings(gestureModes: false),
    );
    expect(
      const ClockSettings(gestureBrightness: false),
      isNot(const ClockSettings()),
    );
    expect(
      const ClockSettings(gestureModes: false),
      isNot(const ClockSettings()),
    );
  });

  test('routes are fixed', () {
    expect(FlipClockRouter.home, '/clock');
    expect(FlipClockRouter.settings, '/clock/settings');
  });

  test('theme migrates black to Dark and reads Light and System', () {
    ClockTheme read(Object? v) => ClockSettings.fromJson({'theme': v}).theme;
    expect(read('black'), ClockTheme.dark);
    expect(read('dark'), ClockTheme.dark);
    expect(read('light'), ClockTheme.light);
    expect(read('system'), ClockTheme.system);
    expect(read('neon'), ClockTheme.dark);
    expect(read(null), ClockTheme.dark);
  });
}
