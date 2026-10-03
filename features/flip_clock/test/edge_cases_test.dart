import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart' show Closable;
import 'package:core/core.dart' as core;
import 'package:core/core.dart' show Logger;
import 'package:design_system/design_system.dart';
import 'package:flip_clock/ui/components/flip_display.dart';
import 'package:di/di.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flip_clock/data/repositories/settings_repository_imp.dart';
import 'package:flip_clock/flip_clock.dart';
import 'package:flip_clock/state/clock_controller.dart';
import 'package:flip_clock/state/countdown_controller.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flip_clock/state/stopwatch_controller.dart';
import 'package:flip_clock/ui/screens/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';
import 'package:timekeeping/timekeeping.dart';

import 'fakes.dart';

final theme = ThemeData(colorScheme: DesignSystem.blackScheme());

/// Screen wiring whose wall clock is whatever [now] says (fake time in
/// widget tests), unlike the hand-moved clock of `screens_test.dart`.
class Rig {
  Rig(DateTime Function() now) {
    final repo = SettingsRepositoryImp(store: store, logger: di.get<Logger>());
    settings = SettingsController(repository: repo, alerts: alerts);
    countdown = CountdownController(
      repository: repo,
      alerts: alerts,
      sound: sound,
      settings: () => settings.state,
      logger: di.get<Logger>(),
      now: now,
    );
    clock = ClockController(now: now);
    stopwatch = StopwatchController(stopwatch: watch);
  }

  final store = FakeStore();
  final alerts = FakeAlerts();
  final sound = FakeSound();
  final full = FakeFullScreen();
  final wake = FakeWake();
  final brightness = FakeScreenBrightness();
  final watch = FakeStopwatch();
  late final SettingsController settings;
  late final CountdownController countdown;
  late final ClockController clock;
  late final StopwatchController stopwatch;

  Widget screen() => MaterialApp(
    theme: theme,
    home: FlipClockScreen(
      settings: settings,
      clock: clock,
      countdown: countdown,
      stopwatch: stopwatch,
      fullScreen: full,
      wake: wake,
      sound: sound,
      brightness: brightness,
      logger: di.get<Logger>(),
      doubleTapFullScreen: false,
      onOpenSettings: () {},
      onOpenTimerSettings: () {},
      // Every corner button on screen, as on a phone.
      orientationSupported: true,
    ),
  );

  Widget settingsScreen() => MaterialApp(
    theme: theme,
    home: SettingsScreen(settings: settings, sound: sound, isWeb: true),
  );

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    // Not awaited: a closed broadcast stream completes outside fake time.
    for (final c in <Closable>[countdown, stopwatch, clock, settings]) {
      unawaited(Future.value(c.close()));
    }
    await tester.pump();
  }
}

/// A wall clock that follows the widget tester's fake time.
DateTime Function() fakeWall(WidgetTester tester, DateTime start) {
  final t0 = tester.binding.clock.now();
  return () => start.add(tester.binding.clock.now().difference(t0));
}

/// Local wall-clock fields for a UTC [instant] in a zone that springs
/// forward (UTC-8 -> UTC-7) at [jump]: the fields a phone shows, as a UTC
/// value so the test does not depend on the machine's time zone.
DateTime pacificFields(DateTime instant, DateTime jump) => instant.add(
  instant.isBefore(jump)
      ? const Duration(hours: -8)
      : const Duration(hours: -7),
);

/// English markers, as `MaterialLocalizations` gives them in English.
const en = (am: 'AM', pm: 'PM');

void main() {
  setUp(core.init);
  tearDown(di.reset);

  group('formatClock boundaries', () {
    String f(int h, int m, {bool use24h = false}) => formatClock(
      DateTime(2026, 1, 1, h, m),
      use24h: use24h,
      showSeconds: false,
      meridiem: en,
    );

    test('12h reads 12 at midnight and noon, never 0 or 13', () {
      expect(f(0, 0), '12:00 AM');
      expect(f(0, 59), '12:59 AM');
      expect(f(1, 0), '1:00 AM');
      expect(f(11, 59), '11:59 AM');
      expect(f(12, 0), '12:00 PM');
      expect(f(12, 59), '12:59 PM');
      expect(f(13, 0), '1:00 PM');
      expect(f(23, 59), '11:59 PM');
    });

    test('24h pads 00:xx and keeps 12:xx', () {
      expect(f(0, 0, use24h: true), '00:00');
      expect(f(0, 7, use24h: true), '00:07');
      expect(f(12, 0, use24h: true), '12:00');
      expect(f(23, 59, use24h: true), '23:59');
    });
  });

  group('daylight saving', () {
    final jump = DateTime.utc(2026, 3, 8, 10); // 02:00 PST -> 03:00 PDT

    test('the clock shows the jump on the next tick, still aligned', () {
      fakeAsync((async) {
        final start = DateTime.utc(2026, 3, 8, 9, 59, 58, 400);
        final c = ClockController(
          now: () => pacificFields(start.add(async.elapsed), jump),
        );
        final shown = <String>[];
        final sub = c.stream.listen(
          (t) => shown.add(
            formatClock(t, use24h: true, showSeconds: true, meridiem: en),
          ),
        );
        c.start();
        async.elapse(const Duration(seconds: 3));
        expect(shown, ['01:59:58', '01:59:59', '03:00:00', '03:00:01']);
        // Ticks land on the second boundary across the jump.
        expect(c.state.millisecond, 0);
        expect(async.pendingTimers.single.duration, const Duration(seconds: 1));
        unawaited(sub.cancel());
        unawaited(c.close());
        async.flushMicrotasks();
        expect(async.pendingTimers, isEmpty);
      });
    });

    test('falling back repeats the hour without stalling the clock', () {
      fakeAsync((async) {
        final back = DateTime.utc(2026, 11, 1, 9); // 02:00 PDT -> 01:00 PST
        final start = DateTime.utc(2026, 11, 1, 8, 59, 59);
        DateTime fields(DateTime i) => i.add(
          i.isBefore(back)
              ? const Duration(hours: -7)
              : const Duration(hours: -8),
        );
        final c = ClockController(now: () => fields(start.add(async.elapsed)))
          ..start();
        expect(
          formatClock(c.state, use24h: false, showSeconds: true, meridiem: en),
          '1:59:59 AM',
        );
        async.elapse(const Duration(seconds: 1));
        expect(
          formatClock(c.state, use24h: false, showSeconds: true, meridiem: en),
          '1:00:00 AM',
        );
        expect(async.pendingTimers, hasLength(1));
        unawaited(c.close());
        async.flushMicrotasks();
      });
    });

    test('a countdown across a real local jump runs its exact duration', () {
      // Uses the machine's zone when it has a transition this year.
      DateTime? before;
      for (var h = 0; h < 366 * 24; h++) {
        final a = DateTime.utc(2026).add(Duration(hours: h)).toLocal();
        final b = a.add(const Duration(hours: 1));
        if (a.timeZoneOffset != b.timeZoneOffset) {
          before = a;
          break;
        }
      }
      if (before == null) {
        markTestSkipped('The local time zone has no daylight saving.');
        return;
      }
      var now = before.subtract(const Duration(minutes: 30));
      final c = Countdown(now: () => now)
        ..setDuration(const Duration(hours: 1))
        ..start();
      now = now.add(const Duration(minutes: 59));
      expect(
        now.timeZoneOffset,
        isNot(c.endsAt!.subtract(const Duration(hours: 1)).timeZoneOffset),
      );
      expect(c.remaining(), const Duration(minutes: 1));
      expect(c.checkFinished(), isFalse);
      now = now.add(const Duration(minutes: 1));
      expect(c.checkFinished(), isTrue);
    });

    test('countdown remaining is instant-based, not wall-field based', () {
      var now = DateTime.utc(2026, 3, 8, 9, 30); // 01:30 PST
      final c = Countdown(now: () => now)
        ..setDuration(const Duration(hours: 1))
        ..start();
      // Instant +59 min: the wall fields read 03:29 (two hours later).
      now = now.add(const Duration(minutes: 59));
      expect(
        formatClock(
          pacificFields(now, jump),
          use24h: true,
          showSeconds: false,
          meridiem: en,
        ),
        '03:29',
      );
      expect(c.remaining(), const Duration(minutes: 1));
      now = now.add(const Duration(minutes: 1));
      expect(c.checkFinished(), isTrue);
    });
  });

  group('time-zone change while open', () {
    test('clock shows the new local time on the next tick and on resume', () {
      fakeAsync((async) {
        final start = DateTime.utc(2026, 9, 29, 16, 41);
        var offset = const Duration(hours: 2); // Berlin summer
        final c = ClockController(
          now: () => start.add(async.elapsed).add(offset),
        )..start();
        String shown() => formatClock(
          c.state,
          use24h: true,
          showSeconds: false,
          meridiem: en,
        );
        expect(shown(), '18:41');
        offset = const Duration(hours: -4); // flew to New York
        async.elapse(const Duration(seconds: 1));
        expect(shown(), '12:41');
        offset = const Duration(hours: 9); // Tokyo, seen on resume
        c.refresh();
        expect(shown(), '01:41');
        expect(async.pendingTimers, hasLength(1));
        unawaited(c.close());
        async.flushMicrotasks();
      });
    });

    test('countdown end instant and stopwatch ignore the zone', () async {
      final store = FakeStore();
      final repo = SettingsRepositoryImp(
        store: store,
        logger: di.get<Logger>(),
      );
      final alerts = FakeAlerts();
      // Same instant read as local, then (after a zone change) as UTC.
      var now = DateTime.utc(2026, 9, 29, 16, 41).toLocal();
      final c = CountdownController(
        repository: repo,
        alerts: alerts,
        sound: FakeSound(),
        settings: () => const ClockSettings(systemAlerts: true),
        logger: di.get<Logger>(),
        now: () => now,
      );
      await c.start(const Duration(minutes: 10));
      final end = alerts.scheduled[CountdownController.alertId]!;
      now = now.toUtc().add(const Duration(minutes: 4));
      await c.check();
      expect(c.state.remaining, const Duration(minutes: 6));
      expect(alerts.scheduled[CountdownController.alertId], end);

      final watch = FakeStopwatch();
      final s = StopwatchController(stopwatch: watch)..start();
      watch.reading = const Duration(seconds: 90);
      now = now.add(const Duration(hours: 9));
      s.pause();
      expect(s.state.elapsed, const Duration(seconds: 90));
      await c.close();
      await s.close();
    });
  });

  group('wall clock jumps during a countdown', () {
    late FakeStore store;
    late FakeAlerts alerts;
    late FakeClock wall;
    late SettingsRepositoryImp repo;

    setUp(() {
      store = FakeStore();
      alerts = FakeAlerts();
      wall = FakeClock();
      repo = SettingsRepositoryImp(store: store, logger: di.get<Logger>());
    });

    CountdownController make() => CountdownController(
      repository: repo,
      alerts: alerts,
      sound: FakeSound(),
      settings: () => const ClockSettings(systemAlerts: true),
      logger: di.get<Logger>(),
      now: wall.call,
    );

    int savedEnd() =>
        (jsonDecode(store.data[SettingsRepositoryImp.countdownKey]!)
                as Map<String, Object?>)['endsAtMs']!
            as int;

    test(
      'forward (device slept past the end) finishes on the next check',
      () async {
        final c = make();
        await c.start(const Duration(minutes: 5));
        wall.advance(const Duration(hours: 3));
        await c.check();
        expect(c.state.status, CountdownStatus.finished);
        expect(c.state.remaining, Duration.zero);
        await c.close();
      },
    );

    test(
      'backward rebases the end, the snapshot and the system alert',
      () async {
        final c = make();
        await c.start(const Duration(minutes: 5));
        wall.advance(const Duration(minutes: 1));
        await c.check();
        final oldEnd = alerts.scheduled[CountdownController.alertId]!;
        wall.advance(const Duration(hours: -2));
        await c.check();
        expect(c.state.remaining, const Duration(minutes: 5));
        final newEnd = wall.now.add(const Duration(minutes: 5));
        expect(alerts.scheduled[CountdownController.alertId], newEnd);
        expect(newEnd, isNot(oldEnd));
        expect(savedEnd(), newEnd.millisecondsSinceEpoch);
        // A plain tick afterwards changes nothing.
        final saves = store.data.length;
        await c.check();
        expect(store.data.length, saves);
        wall.advance(const Duration(minutes: 5));
        await c.check();
        expect(c.state.status, CountdownStatus.finished);
        await c.close();
      },
    );

    test(
      'relaunch after the clock was set back re-saves and re-alerts',
      () async {
        final first = make();
        await first.start(const Duration(minutes: 5));
        await first.close();
        alerts.scheduled.clear();
        wall.advance(const Duration(days: -1));
        final c = make();
        await c.load();
        final end = wall.now.add(const Duration(minutes: 5));
        expect(c.state.status, CountdownStatus.running);
        expect(alerts.scheduled[CountdownController.alertId], end);
        expect(savedEnd(), end.millisecondsSinceEpoch);
        await c.close();
      },
    );

    test(
      'relaunch after the clock jumped past the end shows finished',
      () async {
        final first = make();
        await first.start(const Duration(minutes: 5));
        await first.close();
        wall.advance(const Duration(days: 2));
        final c = make();
        await c.load();
        expect(c.state.status, CountdownStatus.finished);
        await c.close();
      },
    );
  });

  group('running for hours on a charger', () {
    test('the clock keeps one aligned timer for a day', () {
      fakeAsync((async) {
        final start = DateTime(2026, 9, 29, 9, 41, 7, 321, 654);
        final c = ClockController(now: () => start.add(async.elapsed));
        var ticks = 0;
        var misaligned = 0;
        final sub = c.stream.listen((t) {
          ticks++;
          if (t.millisecond != 0 || t.microsecond != 0) misaligned++;
        });
        c.start();
        for (var h = 0; h < 24; h++) {
          async.elapse(const Duration(hours: 1));
          expect(async.pendingTimers, hasLength(1), reason: 'hour $h');
        }
        // One emission per second (the first, unaligned, is the start).
        expect(ticks, 24 * 3600 + 1);
        expect(misaligned, 1);
        expect(
          c.state,
          DateTime(2026, 9, 29, 9, 41, 7).add(const Duration(hours: 24)),
        );
        unawaited(sub.cancel());
        unawaited(c.close());
        async.flushMicrotasks();
        expect(async.pendingTimers, isEmpty);
      });
    });

    test('a long countdown keeps exactly its two timers', () {
      fakeAsync((async) {
        final start = DateTime(2026, 9, 29, 9);
        final store = FakeStore();
        final c = CountdownController(
          repository: SettingsRepositoryImp(
            store: store,
            logger: di.get<Logger>(),
          ),
          alerts: FakeAlerts(),
          sound: FakeSound(),
          settings: () => const ClockSettings(),
          logger: di.get<Logger>(),
          now: () => start.add(async.elapsed),
        );
        unawaited(c.start(const Duration(hours: 12)));
        async.flushMicrotasks();
        for (var h = 1; h < 12; h++) {
          async.elapse(const Duration(hours: 1));
          expect(async.pendingTimers, hasLength(2), reason: 'hour $h');
          expect(c.state.remaining, Duration(hours: 12 - h));
        }
        async.elapse(const Duration(hours: 1));
        expect(c.state.status, CountdownStatus.finished);
        expect(async.pendingTimers, isEmpty);
        unawaited(c.close());
        async.flushMicrotasks();
      });
    });

    testWidgets('the screen ticks for hours: aligned, no leak, awake', (
      tester,
    ) async {
      deviceOn24h(tester);
      final rig = Rig(fakeWall(tester, DateTime(2026, 9, 29, 9, 41, 7, 500)));
      await rig.settings.update(
        const ClockSettings(keepAwake: true, showSeconds: true),
      );
      await tester.pumpWidget(rig.screen());
      await tester.pump(const Duration(milliseconds: 500));
      // Let the chrome settle to hidden (4 s + 3 s) before counting.
      await tester.pump(const Duration(seconds: 8));
      await tester.pump(const Duration(seconds: 1));
      final elements = tester.allElements.length;
      for (var m = 0; m < 3 * 60; m++) {
        await tester.pump(const Duration(minutes: 1));
      }
      await tester.pump(const Duration(seconds: 1));
      expect(rig.clock.state.millisecond, 0);
      expect(
        find.bySemanticsLabel(strings.clock.current_time('12:41:18')),
        findsOne,
      );
      expect(tester.allElements.length, elements);
      expect(rig.wake.calls, [true]);
      await rig.dispose(tester);
      expect(rig.wake.calls, [true, false]);
    });
  });

  group('window resize', () {
    const sizes = [
      Size(320, 1024), // iPad slide-over
      Size(320, 568), // smallest phone
      Size(507, 1024), // iPad split view
      Size(1024, 320),
      Size(200, 100),
      Size(1366, 1024),
      Size(390, 844),
    ];

    Future<void> atEachSize(
      WidgetTester tester,
      Future<void> Function(Size size, double scale) check,
    ) async {
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.view.devicePixelRatio = 1;
      for (final scale in const [1.0, 2.0]) {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        for (final size in sizes) {
          tester.view.physicalSize = size;
          await check(size, scale);
        }
      }
    }

    testWidgets('every mode lays out at every size and text scale', (
      tester,
    ) async {
      await atEachSize(tester, (size, scale) async {
        final rig = Rig(fakeWall(tester, DateTime(2026, 9, 29, 23, 59)));
        await tester.pumpWidget(rig.screen());
        for (final mode in ClockMode.values) {
          await rig.settings.update(ClockSettings(lastMode: mode));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '$mode $size x$scale');
        }
        await rig.dispose(tester);
      });
    });

    testWidgets('chrome floats over the clock: nothing moves when it hides', (
      tester,
    ) async {
      await atEachSize(tester, (size, scale) async {
        final rig = Rig(fakeWall(tester, DateTime(2026, 9, 29, 23, 59)));
        await rig.settings.update(
          const ClockSettings(showSeconds: true, showDate: true),
        );
        await tester.pumpWidget(rig.screen());
        await tester.pumpAndSettle();
        for (final mode in ClockMode.values) {
          await rig.settings.update(
            rig.settings.state.copyWith(lastMode: mode),
          );
          if (mode == ClockMode.stopwatch) {
            rig.stopwatch.start();
            for (var i = 0; i < 4; i++) {
              rig.stopwatch.lap();
            }
            rig.stopwatch.pause();
          }
          await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
          await tester.pumpAndSettle();
          final screen = Offset.zero & size;
          List<Rect> content() => [
            for (final f in [find.byType(FlipDisplay), find.byType(GridView)])
              for (final e in f.evaluate())
                tester.getRect(find.byWidget(e.widget)),
          ].where(screen.overlaps).toList();
          final expanded = content();
          expect(expanded, isNotEmpty, reason: '$mode $size');
          for (final d in expanded) {
            // Inside the window: the chrome may draw over it, never the edge.
            expect(
              screen.inflate(0.5).contains(d.topLeft) &&
                  screen.inflate(0.5).contains(d.bottomRight),
              isTrue,
              reason: '$mode $size x$scale: $d',
            );
          }
          await tester.pump(const Duration(seconds: 8));
          await tester.pumpAndSettle();
          expect(content(), expanded, reason: '$mode $size x$scale hidden');
          expect(tester.takeException(), isNull, reason: '$mode $size');
        }
        rig.stopwatch.reset();
        await rig.dispose(tester);
      });
    });

    testWidgets('stopwatch laps lay out at every size and text scale', (
      tester,
    ) async {
      await atEachSize(tester, (size, scale) async {
        final rig = Rig(fakeWall(tester, DateTime(2026, 9, 29, 9)));
        await rig.settings.update(
          const ClockSettings(lastMode: ClockMode.stopwatch),
        );
        await tester.pumpWidget(rig.screen());
        rig.stopwatch.start();
        for (var i = 0; i < 5; i++) {
          rig.stopwatch.lap();
        }
        rig.stopwatch.pause();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$size x$scale');
        rig.stopwatch.reset();
        await rig.dispose(tester);
      });
    });

    testWidgets('settings lays out at every size and text scale', (
      tester,
    ) async {
      await atEachSize(tester, (size, scale) async {
        final rig = Rig(fakeWall(tester, DateTime(2026, 9, 29, 9)));
        await tester.pumpWidget(rig.settingsScreen());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$size x$scale');
        // The last list is the category detail (phone root or split pane).
        await tester.drag(find.byType(ListView).last, const Offset(0, -5000));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$size x$scale end');
        await rig.dispose(tester);
      });
    });

    testWidgets('resizing mid-run keeps the timer, stopwatch and full screen', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.view.devicePixelRatio = 1;
      final rig = Rig(fakeWall(tester, DateTime(2026, 9, 29, 9)));
      await rig.settings.update(
        const ClockSettings(lastMode: ClockMode.pomodoro),
      );
      await tester.pumpWidget(rig.screen());
      await rig.countdown.start(const Duration(minutes: 10));
      rig.stopwatch.start();
      await tester.pump();

      var step = 0;
      Future<void> resizeThrough(String label) async {
        for (final scale in const [1.0, 2.0]) {
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          for (final size in sizes) {
            tester.view.physicalSize = size;
            step++;
            await tester.pump(const Duration(seconds: 1));
            expect(tester.takeException(), isNull, reason: '$label $size');
          }
        }
      }

      await resizeThrough('timer');
      await rig.full.toggle();
      await tester.pump();
      await resizeThrough('timer full screen');
      await rig.settings.update(
        const ClockSettings(lastMode: ClockMode.stopwatch),
      );
      rig.watch.reading = const Duration(minutes: 1);
      await resizeThrough('stopwatch full screen');
      await tester.pumpAndSettle();

      expect(rig.countdown.state.status, CountdownStatus.running);
      expect(
        rig.countdown.state.remaining,
        const Duration(minutes: 10) - Duration(seconds: step),
      );
      expect(rig.stopwatch.state.elapsed, const Duration(minutes: 1));
      expect(rig.stopwatch.state.running, isTrue);
      expect(rig.full.value.value, isTrue);
      await rig.dispose(tester);
    });
  });
}
