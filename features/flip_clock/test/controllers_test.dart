import 'dart:convert';

import 'package:core/core.dart' as core;
import 'package:core/core.dart' show Logger;
import 'package:design_system/design_system.dart';
import 'package:di/di.dart';
import 'package:flip_clock/data/repositories/settings_repository_imp.dart';
import 'package:flip_clock/flip_clock.dart';
import 'package:flip_clock/state/clock_controller.dart';
import 'package:flip_clock/state/countdown_controller.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flip_clock/state/stopwatch_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timekeeping/timekeeping.dart';

import 'fakes.dart';

const tick = Duration(milliseconds: 250);

void main() {
  late FakeStore store;
  late FakeAlerts alerts;
  late FakeSound sound;
  late FakeClock clock;
  late SettingsRepositoryImp repo;
  var settings = const ClockSettings();

  setUp(() async {
    await core.init();
    store = FakeStore();
    alerts = FakeAlerts();
    sound = FakeSound();
    clock = FakeClock();
    repo = SettingsRepositoryImp(store: store, logger: di.get<Logger>());
    settings = const ClockSettings(systemAlerts: true);
  });
  tearDown(di.reset);

  CountdownController countdown({bool notify = true, Duration tick = tick}) =>
      CountdownController(
        repository: repo,
        alerts: alerts,
        sound: sound,
        settings: () => settings,
        logger: di.get<Logger>(),
        now: clock.call,
        notifyOnFinish: notify,
        tick: tick,
      );

  Map<String, Object?> saved() =>
      jsonDecode(store.data[SettingsRepositoryImp.countdownKey]!)
          as Map<String, Object?>;

  group('SettingsController', () {
    test('loads, saves every change and drives appearance', () async {
      await repo.save(const ClockSettings(theme: ClockTheme.light));
      final c = SettingsController(repository: repo, alerts: alerts);
      expect(c.appearance.value, AppearanceMode.black);
      await c.load();
      expect(c.state.theme, ClockTheme.light);
      expect(c.appearance.value, AppearanceMode.light);
      await c.update(c.state.copyWith(theme: ClockTheme.black, use24h: false));
      expect(c.appearance.value, AppearanceMode.black);
      expect((await repo.load()).use24h, isFalse);
      await c.close();
    });

    test('system alerts ask permission only when turned on', () async {
      final c = SettingsController(repository: repo, alerts: alerts);
      expect(await c.setSystemAlerts(true), isTrue);
      expect(c.state.systemAlerts, isTrue);
      expect(await c.setSystemAlerts(false), isTrue);
      expect(c.state.systemAlerts, isFalse);
      expect(alerts.permissionRequests, 1);
      alerts.grant = false;
      expect(await c.setSystemAlerts(true), isFalse);
      expect(c.state.systemAlerts, isFalse);
      expect((await repo.load()).systemAlerts, isFalse);
      await c.close();
    });

    test('ignores results arriving after close', () async {
      final c = SettingsController(repository: repo, alerts: alerts);
      final loading = c.load();
      final asking = c.setSystemAlerts(true);
      await c.close();
      await loading;
      expect(await asking, isTrue);
    });
  });

  group('CountdownController', () {
    testWidgets('start, tick down, finish with alarm and notification', (
      tester,
    ) async {
      final c = countdown();
      expect(c.state.status, CountdownStatus.idle);
      await c.start(const Duration(seconds: 30));
      expect(c.state.status, CountdownStatus.running);
      expect(c.state.remaining, const Duration(seconds: 30));
      expect(
        alerts.scheduled[CountdownController.alertId],
        clock.now.add(const Duration(seconds: 30)),
      );
      expect(saved()['status'], 'running');

      clock.advance(const Duration(milliseconds: 10400));
      await tester.pump(tick);
      expect(c.state.remaining, const Duration(seconds: 20));

      clock.advance(const Duration(seconds: 20));
      await tester.pump(tick);
      expect(c.state.status, CountdownStatus.finished);
      expect(c.state.remaining, Duration.zero);
      expect(sound.alarms, 1);
      expect(alerts.shown, hasLength(1));
      expect(saved()['status'], 'finished');

      // No repeat: further ticks are stopped.
      await tester.pump(tick * 4);
      expect(sound.alarms, 1);

      await c.reset();
      expect(c.state.status, CountdownStatus.idle);
      expect(c.state.duration, const Duration(seconds: 30));
      expect(sound.stops, 1);
      expect(alerts.cancelled, [CountdownController.alertId]);
      await c.close();
    });

    testWidgets('pause, resume and reset; alerts follow', (tester) async {
      final c = countdown();
      await c.start(const Duration(seconds: 30));
      clock.advance(const Duration(seconds: 5));
      await c.pause();
      expect(c.state.status, CountdownStatus.paused);
      expect(c.state.remaining, const Duration(seconds: 25));
      expect(alerts.scheduled, isEmpty);
      expect(saved()['status'], 'paused');

      clock.advance(const Duration(minutes: 5));
      await tester.pump(tick * 4);
      expect(c.state.remaining, const Duration(seconds: 25));

      await c.resume();
      expect(c.state.status, CountdownStatus.running);
      expect(
        alerts.scheduled[CountdownController.alertId],
        clock.now.add(const Duration(seconds: 25)),
      );
      await c.reset();
      expect(c.state.status, CountdownStatus.idle);
      expect(alerts.scheduled, isEmpty);
      await c.close();
    });

    testWidgets('invalid or out-of-state calls are ignored', (tester) async {
      final c = countdown();
      await c.start(Duration.zero);
      await c.start(Countdown.max + const Duration(seconds: 1));
      expect(c.state.status, CountdownStatus.idle);
      await c.pause();
      await c.resume();
      expect(c.state.status, CountdownStatus.idle);
      await c.setDuration(Duration.zero);
      expect(store.data, isEmpty);
      await c.setDuration(const Duration(minutes: 2));
      expect(c.state.duration, const Duration(minutes: 2));
      expect(saved()['durationMs'], 120000);

      await c.start(const Duration(seconds: 10));
      await c.start(const Duration(seconds: 50));
      await c.setDuration(const Duration(seconds: 50));
      await c.resume();
      expect(c.state.duration, const Duration(seconds: 10));
      expect(c.state.status, CountdownStatus.running);
      await c.close();
    });

    testWidgets('toggle walks idle -> running -> paused -> running -> done', (
      tester,
    ) async {
      final c = countdown();
      await c.setDuration(const Duration(seconds: 3));
      await c.toggle();
      expect(c.state.status, CountdownStatus.running);
      await c.toggle();
      expect(c.state.status, CountdownStatus.paused);
      await c.toggle();
      expect(c.state.status, CountdownStatus.running);
      clock.advance(const Duration(seconds: 3));
      await c.check();
      expect(c.state.status, CountdownStatus.finished);
      await c.toggle();
      expect(c.state.status, CountdownStatus.idle);
      await c.close();
    });

    testWidgets('a one-shot timer finishes even when ticks are throttled', (
      tester,
    ) async {
      final c = countdown(tick: const Duration(hours: 1));
      await c.start(const Duration(seconds: 3));
      clock.advance(const Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 3));
      expect(c.state.status, CountdownStatus.finished);
      expect(sound.alarms, 1);
      await c.close();
    });

    testWidgets('an invalid entry keeps Space from starting', (tester) async {
      final c = countdown();
      await c.setDuration(null);
      await c.toggle();
      expect(c.state.status, CountdownStatus.idle);
      await c.setDuration(Duration.zero);
      await c.toggle();
      expect(c.state.status, CountdownStatus.idle);
      await c.setDuration(const Duration(seconds: 4));
      await c.toggle();
      expect(c.state.status, CountdownStatus.running);
      expect(c.state.duration, const Duration(seconds: 4));

      // Reset brings back a valid input.
      await c.setDuration(null);
      await c.reset();
      await c.toggle();
      expect(c.state.status, CountdownStatus.running);
      await c.close();
    });

    testWidgets('syncAlert follows the setting mid-countdown', (tester) async {
      settings = const ClockSettings();
      final c = countdown();
      await c.syncAlert();
      expect(alerts.scheduled, isEmpty);
      await c.start(const Duration(minutes: 10));
      expect(alerts.scheduled, isEmpty);

      settings = const ClockSettings(systemAlerts: true);
      await c.syncAlert();
      expect(
        alerts.scheduled[CountdownController.alertId],
        clock.now.add(const Duration(minutes: 10)),
      );

      settings = const ClockSettings();
      await c.syncAlert();
      expect(alerts.scheduled, isEmpty);
      expect(alerts.cancelled, [CountdownController.alertId]);
      await c.close();
    });

    testWidgets('pausing after the end finishes instead', (tester) async {
      final c = countdown();
      await c.start(const Duration(seconds: 3));
      clock.advance(const Duration(seconds: 4));
      await c.pause();
      expect(c.state.status, CountdownStatus.finished);
      expect(sound.alarms, 1);
      await c.close();
    });

    testWidgets('app resume recomputes from the wall clock', (tester) async {
      final c = countdown();
      await c.start(const Duration(seconds: 30));
      clock.advance(const Duration(minutes: 1));
      await c.check();
      expect(c.state.status, CountdownStatus.finished);
      await c.close();
    });

    testWidgets('respects sound and alert settings', (tester) async {
      settings = const ClockSettings(alertSound: false);
      final c = countdown(notify: false);
      await c.start(const Duration(seconds: 1));
      expect(alerts.scheduled, isEmpty);
      clock.advance(const Duration(seconds: 1));
      await c.check();
      expect(c.state.status, CountdownStatus.finished);
      expect(sound.alarms, 0);
      expect(alerts.shown, isEmpty);
      await c.close();
    });

    testWidgets('native platforms rely on the scheduled notification', (
      tester,
    ) async {
      final c = countdown(notify: false);
      await c.start(const Duration(seconds: 1));
      clock.advance(const Duration(seconds: 1));
      await c.check();
      expect(alerts.shown, isEmpty);
      expect(sound.alarms, 1);
      await c.close();
    });

    testWidgets('relaunch restores running, paused and finished-while-away', (
      tester,
    ) async {
      var c = countdown();
      await c.load();
      expect(c.state.status, CountdownStatus.idle);
      await c.start(const Duration(seconds: 30));
      await c.close();

      // Still running: keeps ticking from the saved end.
      clock.advance(const Duration(seconds: 10));
      c = countdown();
      await c.load();
      expect(c.state.status, CountdownStatus.running);
      expect(c.state.remaining, const Duration(seconds: 20));
      clock.advance(const Duration(seconds: 20));
      await tester.pump(tick);
      expect(c.state.status, CountdownStatus.finished);
      await c.reset();
      await c.start(const Duration(seconds: 30));
      await c.close();

      // Ended while closed: shows finished, silently, and saves it.
      final alarmsBefore = sound.alarms;
      clock.advance(const Duration(hours: 1));
      c = countdown();
      await c.load();
      expect(c.state.status, CountdownStatus.finished);
      expect(sound.alarms, alarmsBefore);
      expect(saved()['status'], 'finished');
      await c.close();

      // Corrupt snapshot: idle default.
      store.data[SettingsRepositoryImp.countdownKey] = '{"status": 7}';
      c = countdown();
      await c.load();
      expect(c.state.status, CountdownStatus.idle);
      await c.close();
      await c.check();
    });
  });

  group('StopwatchController', () {
    testWidgets('start, tick, pause, resume, reset', (tester) async {
      final watch = FakeStopwatch();
      final c = StopwatchController(stopwatch: watch);
      expect(c.state.isIdle, isTrue);
      c.start();
      c.start();
      expect(c.state.running, isTrue);
      watch.reading = const Duration(milliseconds: 1234);
      await tester.pump(const Duration(milliseconds: 100));
      expect(c.state.elapsed, const Duration(milliseconds: 1234));
      c.toggle();
      expect(
        c.state,
        const StopwatchState(elapsed: Duration(milliseconds: 1234)),
      );
      expect(c.state.isIdle, isFalse);
      expect(c.state.hashCode, isNot(const StopwatchState().hashCode));
      watch.reading = const Duration(seconds: 9);
      await tester.pump(const Duration(seconds: 1));
      expect(c.state.elapsed, const Duration(milliseconds: 1234));
      c.toggle();
      expect(c.state.running, isTrue);
      c.reset();
      expect(c.state, const StopwatchState());
      c.start();
      await c.close();
    });

    test('measures with a real monotonic stopwatch', () {
      final c = StopwatchController(stopwatch: Stopwatch());
      c.start();
      expect(c.state.running, isTrue);
      c.pause();
      expect(c.state.running, isFalse);
      return c.close();
    });
  });

  group('ClockController', () {
    testWidgets('ticks on each second boundary while started', (tester) async {
      final t0 = DateTime(2026, 9, 29, 9, 41, 7, 600);
      clock.now = t0;
      final c = ClockController(now: clock.call);
      expect(c.state, t0);
      clock.now = DateTime(2026, 9, 29, 9, 41, 7, 700);
      c.refresh();
      expect(c.state, t0, reason: 'not started: refresh is a no-op');

      c.start();
      expect(c.state, clock.now);
      clock.now = DateTime(2026, 9, 29, 9, 41, 8);
      await tester.pump(const Duration(milliseconds: 299));
      expect(c.state, DateTime(2026, 9, 29, 9, 41, 7, 700));
      await tester.pump(const Duration(milliseconds: 1));
      expect(c.state, DateTime(2026, 9, 29, 9, 41, 8));

      // Time or time-zone change shows on refresh (app resume).
      clock.now = DateTime(2026, 9, 29, 14, 0, 0, 500);
      c.refresh();
      expect(c.state, clock.now);

      c.stop();
      clock.now = DateTime(2026, 9, 29, 15);
      await tester.pump(const Duration(seconds: 2));
      expect(c.state, DateTime(2026, 9, 29, 14, 0, 0, 500));
      await c.close();
    });

    test('defaults to the system clock', () async {
      final c = ClockController();
      expect(DateTime.now().difference(c.state).inSeconds, lessThan(5));
      await c.close();
    });
  });

  test('CountdownState equality', () {
    const a = CountdownState(duration: Duration(seconds: 1));
    expect(a, const CountdownState(duration: Duration(seconds: 1)));
    expect(
      a.hashCode,
      const CountdownState(duration: Duration(seconds: 1)).hashCode,
    );
    expect(a, isNot(const CountdownState()));
  });
}
