import 'dart:convert';

import 'package:core/core.dart' as core;
import 'package:core/core.dart' show Logger;
import 'package:design_system/design_system.dart';
import 'package:di/di.dart';
import 'package:device_services/device_services.dart';
import 'package:flip_clock/data/repositories/settings_repository_imp.dart';
import 'package:flip_clock/flip_clock.dart';
import 'package:flip_clock/state/clock_controller.dart';
import 'package:flip_clock/state/countdown_controller.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flip_clock/state/stopwatch_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';
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
      await c.update(c.state.copyWith(theme: ClockTheme.dark, use24h: false));
      expect(c.appearance.value, AppearanceMode.black);
      expect((await repo.load()).use24h, isFalse);
      await c.update(c.state.copyWith(theme: ClockTheme.system));
      expect(c.appearance.value, AppearanceMode.system);
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
      expect(sound.played, [AlarmSound.chime]);
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

    testWidgets('a finished timer plays the picked alarm', (tester) async {
      settings = const ClockSettings(alarmSound: AlarmSound.bell);
      final c = countdown();
      await c.start(const Duration(seconds: 3));
      clock.advance(const Duration(seconds: 3));
      await tester.pump(tick);
      expect(c.state.status, CountdownStatus.finished);
      expect(sound.played, [AlarmSound.bell]);
      await tester.pump(const Duration(seconds: 30));
      expect(sound.stops, 0, reason: 'a timer alarm loops until dismissed');
      await c.close();
    });

    testWidgets('a Pomodoro phase end is a short chime with any alarm', (
      tester,
    ) async {
      for (final alarm in AlarmSound.values) {
        settings = ClockSettings(alarmSound: alarm);
        sound.played.clear();
        sound.stops = 0;
        final c = countdown();
        await c.startPomodoro();
        clock.advance(const Duration(minutes: 25));
        await tester.pump(tick);
        expect(sound.played, [alarm]);
        await tester.pump(const Duration(seconds: 5));
        expect(sound.stops, 1, reason: '$alarm is cut short');
        await c.reset();
        await c.close();
      }
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
      expect(store.data, isEmpty);

      await c.start(const Duration(seconds: 10));
      await c.start(const Duration(seconds: 50));
      await c.startPreset(const Minutes(Duration(seconds: 50)));
      await c.resume();
      expect(c.state.duration, const Duration(seconds: 10));
      expect(c.state.status, CountdownStatus.running);
      await c.close();
    });

    testWidgets('toggle walks idle -> running -> paused -> running -> done', (
      tester,
    ) async {
      settings = const ClockSettings().copyWith(
        timerPresets: [const Duration(seconds: 3)],
        defaultTimer: const Minutes(Duration(seconds: 3)),
      );
      final c = countdown();
      await c.toggle();
      expect(c.state.status, CountdownStatus.running);
      expect(c.state.duration, const Duration(seconds: 3));
      expect(c.state.pomodoro, isNull);
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

    testWidgets('restart runs a finished timer again; ignored otherwise', (
      tester,
    ) async {
      final c = countdown();
      await c.restart();
      expect(c.state.status, CountdownStatus.idle);
      await c.start(const Duration(seconds: 3));
      await c.restart();
      expect(c.state.status, CountdownStatus.running);
      expect(sound.stops, 0);
      clock.advance(const Duration(seconds: 3));
      await c.check();
      expect(c.state.status, CountdownStatus.finished);
      await c.restart();
      expect(c.state.status, CountdownStatus.running);
      expect(c.state.remaining, const Duration(seconds: 3));
      expect(sound.stops, 1);
      await c.close();
    });

    testWidgets('Space on idle starts the default timer; presets start', (
      tester,
    ) async {
      final c = countdown();
      // The cycle by default.
      await c.toggle();
      expect(c.state.pomodoro, const Pomodoro());
      await c.reset();
      await c.startPreset(const Minutes(Duration(minutes: 10)));
      expect(c.state.status, CountdownStatus.running);
      expect(c.state.duration, const Duration(minutes: 10));
      expect(c.state.pomodoro, isNull);
      await c.reset();
      await c.startPreset(const PomodoroCycle());
      expect(c.state.pomodoro, const Pomodoro());
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

  group('Pomodoro', () {
    const focus = Duration(minutes: 25);
    const rest = Duration(minutes: 5);
    const id = CountdownController.alertId;

    testWidgets('focus, break, next round; chimes briefly; alert each end', (
      tester,
    ) async {
      final c = countdown();
      await c.start(const Duration(seconds: 90));
      await c.reset();
      await c.startPomodoro();
      expect(c.state.status, CountdownStatus.running);
      expect(c.state.pomodoro, const Pomodoro());
      expect(c.state.remaining, focus);
      expect(alerts.scheduled[id], clock.now.add(focus));
      expect(saved()['pomodoro'], {'phase': 'focus', 'round': 1});
      expect(saved()['timerMs'], 90000);

      clock.advance(focus);
      await tester.pump(tick);
      expect(c.state.status, CountdownStatus.running);
      expect(c.state.pomodoro, const Pomodoro(phase: PomodoroPhase.rest));
      expect(c.state.remaining, rest);
      expect(alerts.scheduled[id], clock.now.add(rest));
      expect(alerts.shown, [strings.clock.pomodoro]);
      expect(sound.alarms, 1);
      // One stop is the reset that left the 90 s timer.
      expect(sound.stops, 1);
      await tester.pump(const Duration(seconds: 5));
      expect(sound.stops, 2, reason: 'the chime is brief');

      clock.advance(rest);
      await tester.pump(tick);
      expect(c.state.pomodoro, const Pomodoro(round: 2));
      expect(c.state.remaining, focus);
      expect(sound.alarms, 2);

      // Ignored while a phase runs.
      await c.startPomodoro();
      await c.startNextPhase();
      expect(c.state.pomodoro, const Pomodoro(round: 2));
      expect(c.state.duration, focus);

      // Space pauses and resumes, cancelling and rescheduling the alert.
      await c.toggle();
      expect(c.state.status, CountdownStatus.paused);
      expect(alerts.scheduled, isEmpty);
      await c.toggle();
      expect(c.state.status, CountdownStatus.running);
      expect(alerts.scheduled[id], clock.now.add(focus));

      // Reset ends the cycle, silences the chime and restores the timer.
      await c.reset();
      expect(c.state.status, CountdownStatus.idle);
      expect(c.state.pomodoro, isNull);
      expect(c.state.duration, const Duration(seconds: 90));
      expect(saved().containsKey('pomodoro'), isFalse);
      final stops = sound.stops;
      await tester.pump(const Duration(seconds: 10));
      expect(sound.stops, stops, reason: 'the chime timer was cancelled');
      await c.close();
    });

    testWidgets('alert sound and system alerts off: silent phase change', (
      tester,
    ) async {
      settings = const ClockSettings(alertSound: false);
      final c = countdown();
      await c.startPomodoro();
      expect(alerts.scheduled, isEmpty);
      clock.advance(focus);
      await tester.pump(tick);
      expect(c.state.pomodoro, const Pomodoro(phase: PomodoroPhase.rest));
      expect(sound.alarms, 0);
      expect(alerts.shown, isEmpty);
      expect(alerts.scheduled, isEmpty);
      await c.close();
    });

    testWidgets('closing mid-chime cancels the chime timer', (tester) async {
      final c = countdown();
      await c.startPomodoro();
      clock.advance(focus);
      await tester.pump(tick);
      expect(sound.alarms, 1);
      await c.close();
      await tester.pump(const Duration(seconds: 10));
      expect(sound.stops, 0);
    });

    testWidgets('relaunch restores a phase; one ended while away waits', (
      tester,
    ) async {
      var c = countdown();
      await c.start(const Duration(seconds: 90));
      await c.reset();
      await c.startPomodoro();
      await c.close();

      clock.advance(const Duration(minutes: 10));
      c = countdown();
      await c.load();
      expect(c.state.status, CountdownStatus.running);
      expect(c.state.pomodoro, const Pomodoro());
      expect(c.state.remaining, const Duration(minutes: 15));
      await c.close();

      // Ended while closed: finished and silent, not skipped ahead.
      clock.advance(const Duration(hours: 1));
      c = countdown();
      await c.load();
      expect(c.state.status, CountdownStatus.finished);
      expect(c.state.pomodoro, const Pomodoro());
      expect(sound.alarms, 0);
      expect(saved()['pomodoro'], {'phase': 'focus', 'round': 1});

      // Space starts the next phase.
      await c.toggle();
      expect(c.state.status, CountdownStatus.running);
      expect(c.state.pomodoro, const Pomodoro(phase: PomodoroPhase.rest));
      expect(c.state.remaining, rest);
      await c.reset();
      expect(c.state.duration, const Duration(seconds: 90));
      await c.close();
    });

    test('corrupt saved pomodoro fields fall back safely', () async {
      final key = SettingsRepositoryImp.countdownKey;
      Future<CountdownController> restore(Map<String, Object?> json) async {
        store.data[key] = jsonEncode(json);
        final c = countdown();
        await c.load();
        return c;
      }

      const paused = {
        'durationMs': 1500000,
        'status': 'paused',
        'remainingMs': 60000,
      };

      // Unknown phase: a plain paused timer.
      var c = await restore({
        ...paused,
        'pomodoro': {'phase': 'nap', 'round': 1},
      });
      expect(c.state.status, CountdownStatus.paused);
      expect(c.state.pomodoro, isNull);
      await c.close();

      // Bad timer duration: reset falls back to the default.
      c = await restore({
        ...paused,
        'pomodoro': {'phase': 'rest', 'round': 2},
        'timerMs': -5,
      });
      expect(
        c.state.pomodoro,
        const Pomodoro(phase: PomodoroPhase.rest, round: 2),
      );
      await c.reset();
      expect(c.state.duration, Countdown.defaultDuration);
      await c.close();

      // An idle snapshot has no phase to resume.
      c = await restore({
        'durationMs': 1500000,
        'status': 'idle',
        'pomodoro': {'phase': 'focus', 'round': 3},
      });
      expect(c.state.status, CountdownStatus.idle);
      expect(c.state.pomodoro, isNull);
      await c.close();
    });

    test('a plain finished timer has no next phase', () async {
      final c = countdown();
      await c.startNextPhase();
      expect(c.state.status, CountdownStatus.idle);
      await c.start(const Duration(seconds: 1));
      clock.advance(const Duration(seconds: 1));
      await c.check();
      await c.startNextPhase();
      expect(c.state.status, CountdownStatus.finished);
      await c.close();
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

    testWidgets('laps: splits newest first, only while running, reset clears', (
      tester,
    ) async {
      final watch = FakeStopwatch();
      final c = StopwatchController(stopwatch: watch);
      c.lap();
      expect(c.state.laps, isEmpty, reason: 'idle');
      c.start();
      watch.reading = const Duration(seconds: 12);
      c.lap();
      watch.reading = const Duration(seconds: 20);
      c.lap();
      expect(c.state.laps, const [Duration(seconds: 8), Duration(seconds: 12)]);
      c.pause();
      watch.reading = const Duration(seconds: 25);
      c.lap();
      expect(c.state.laps, hasLength(2), reason: 'ignored while paused');
      expect(
        c.state,
        isNot(const StopwatchState(elapsed: Duration(seconds: 20))),
      );
      expect(
        c.state,
        StopwatchState(
          elapsed: const Duration(seconds: 20),
          laps: c.state.laps,
        ),
      );
      c.reset();
      expect(c.state.laps, isEmpty);
      expect(c.state, const StopwatchState());
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
    expect(
      const CountdownState(pomodoro: Pomodoro()),
      isNot(const CountdownState()),
    );
  });
}
