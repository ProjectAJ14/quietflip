import 'package:design_system/design_system.dart';
import 'package:device_services/device_services.dart';
import 'package:flip_clock/flip_clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timekeeping/timekeeping.dart';

void main() {
  test('defaults: black, device clock style, seconds, alert sound on', () {
    const s = ClockSettings();
    expect(s.theme, ClockTheme.dark);
    // Unpicked: the device's 24-hour switch or language decides.
    expect(s.use24h, isNull);
    expect(s.showSeconds, isTrue);
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
    expect(s.cardSize, CardSize.large);
    expect(s.tickSound, TickSound.classic);
    expect(s.alarmSound, AlarmSound.chime);
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
      cardSize: CardSize.small,
      tickSound: TickSound.woodblock,
      alarmSound: AlarmSound.beeps,
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

  test('corner: default 14, round trip, clamp, per-field fallback', () {
    expect(const ClockSettings().corner, DesignShape.defaultCorner);
    const s = ClockSettings(corner: 6);
    expect(s.toJson()['corner'], 6);
    expect(ClockSettings.fromJson(s.toJson()), s);
    expect(s.copyWith(corner: 8).corner, 8);
    expect(s, isNot(const ClockSettings()));
    expect(s.hashCode, isNot(const ClockSettings().hashCode));
    double read(Object? v) => ClockSettings.fromJson({'corner': v}).corner;
    expect(read(-4), DesignShape.minCorner);
    expect(read(99), DesignShape.maxCorner);
    expect(read(10), 10);
    // Off-step values snap to the slider's 2px steps.
    expect(read(13), 14);
    expect(read(10.9), 10);
    expect(read(double.nan), DesignShape.defaultCorner);
    expect(read('round'), DesignShape.defaultCorner);
    expect(ClockSettings.cornerStep, 2);
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

  test('card size: factors, json by name, per-field fallback', () {
    expect(CardSize.large.factor, 1.0);
    expect(CardSize.medium.factor, 0.8);
    expect(CardSize.small.factor, 0.6);
    const medium = ClockSettings(cardSize: CardSize.medium);
    expect(medium.toJson()['cardSize'], 'medium');
    expect(ClockSettings.fromJson(medium.toJson()).cardSize, CardSize.medium);
    expect(medium, isNot(const ClockSettings()));
    expect(medium.hashCode, isNot(const ClockSettings().hashCode));
    for (final bad in [null, 'huge', 2]) {
      final read = ClockSettings.fromJson({'cardSize': bad, 'use24h': false});
      expect(read.cardSize, CardSize.large, reason: '$bad');
      expect(read.use24h, isFalse);
    }
  });

  test('sound picks: json by name, unknown or missing keeps the default', () {
    const picked = ClockSettings(
      tickSound: TickSound.splitFlap,
      alarmSound: AlarmSound.ring,
    );
    expect(picked.toJson()['tickSound'], 'splitFlap');
    expect(picked.toJson()['alarmSound'], 'ring');
    expect(ClockSettings.fromJson(picked.toJson()), picked);
    expect(
      picked.copyWith(tickSound: TickSound.digital).tickSound,
      TickSound.digital,
    );
    for (final changed in [
      const ClockSettings(tickSound: TickSound.digital),
      const ClockSettings(alarmSound: AlarmSound.bell),
    ]) {
      expect(changed, isNot(const ClockSettings()));
      expect(changed.hashCode, isNot(const ClockSettings().hashCode));
    }
    for (final bad in [null, 'kazoo', 2]) {
      final read = ClockSettings.fromJson({
        'tickSound': bad,
        'alarmSound': bad,
        'flipSound': true,
      });
      expect(read.tickSound, TickSound.classic, reason: '$bad');
      expect(read.alarmSound, AlarmSound.chime, reason: '$bad');
      expect(read.flipSound, isTrue, reason: 'other fields still read');
    }
    final old = ClockSettings.fromJson({
      'flipSound': true,
      'alertSound': false,
    });
    expect(old.tickSound, TickSound.classic, reason: 'an old install');
    expect(old.alarmSound, AlarmSound.chime);
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

  group('timer presets', () {
    const m = Duration(minutes: 1);

    test('default: 5, 10, 15 min and the pomodoro cycle', () {
      const s = ClockSettings();
      expect(s.timerPresets, [m * 5, m * 10, m * 15]);
      expect(s.defaultTimer, const PomodoroCycle());
      expect(s.toJson()['defaultTimerMs'], isNull);
    });

    test('round trip through json, equality and hash', () {
      final s = const ClockSettings().copyWith(
        timerPresets: [m * 23, m * 5],
        defaultTimer: Minutes(m * 23),
      );
      expect(s.timerPresets, [m * 5, m * 23]);
      expect(s.defaultTimer, Minutes(m * 23));
      final back = ClockSettings.fromJson(s.toJson());
      expect(back, s);
      expect(back.hashCode, s.hashCode);
      expect(back, isNot(const ClockSettings()));
      expect(Minutes(m * 5), isNot(Minutes(m * 6)));
      expect(Minutes(m * 5).hashCode, Minutes(m * 5).hashCode);
      expect(const PomodoroCycle(), isNot(Minutes(m)));
      expect(const PomodoroCycle().hashCode, const PomodoroCycle().hashCode);
    });

    test('at most 6, no duplicates, valid only, ascending', () {
      final s = const ClockSettings().copyWith(
        timerPresets: [
          for (var i = 8; i >= 1; i--) m * i,
          m * 3,
          Duration.zero,
          Countdown.max + m,
        ],
      );
      expect(s.timerPresets, [for (var i = 1; i <= 6; i++) m * i]);
      expect(ClockSettings.maxTimerPresets, 6);
    });

    test('invalid json entries are dropped, not crashed on', () {
      final s = ClockSettings.fromJson({
        'timerPresetsMs': [60000, 'x', null, 0, 60000, 120000, -5],
        'defaultTimerMs': 'soon',
      });
      expect(s.timerPresets, [m, m * 2]);
      expect(s.defaultTimer, const PomodoroCycle());
      expect(
        ClockSettings.fromJson({'timerPresetsMs': 'x'}).timerPresets,
        ClockSettings.defaultTimerPresets,
      );
      // A default that is not among the presets falls back to the cycle.
      expect(
        ClockSettings.fromJson({
          'timerPresetsMs': [60000],
          'defaultTimerMs': 120000,
        }).defaultTimer,
        const PomodoroCycle(),
      );
    });

    test('deleting the default preset resets the default to the cycle', () {
      final s = const ClockSettings().copyWith(defaultTimer: Minutes(m * 10));
      expect(s.defaultTimer, Minutes(m * 10));
      expect(
        s.copyWith(timerPresets: [m * 5]).defaultTimer,
        const PomodoroCycle(),
      );
      // Deleting another one keeps it.
      expect(s.copyWith(timerPresets: [m * 10]).defaultTimer, Minutes(m * 10));
      // A default that is not offered is refused.
      expect(
        s.copyWith(defaultTimer: Minutes(m * 7)).defaultTimer,
        const PomodoroCycle(),
      );
    });

    test('a saved Timer mode opens on Pomodoro', () {
      expect(
        ClockSettings.fromJson({'lastMode': 'timer'}).lastMode,
        ClockMode.pomodoro,
      );
      expect(ClockMode.values, [
        ClockMode.pomodoro,
        ClockMode.clock,
        ClockMode.stopwatch,
      ]);
    });
  });
}
