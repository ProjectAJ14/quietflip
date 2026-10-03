import 'dart:async';

import 'package:analytics/analytics.dart' show AnalyticsClient;
import 'package:cloud_sync/cloud_sync.dart' hide init;
import 'package:core/core.dart' as core;
import 'package:core/core.dart' show Logger;
import 'package:device_services/device_services.dart' hide init;
import 'package:di/di.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flip_clock/analytics/clock_analytics.dart';
import 'package:flip_clock/data/models/skin.dart';
import 'package:flip_clock/data/repositories/settings_repository_imp.dart';
import 'package:flip_clock/flip_clock.dart';
import 'package:flip_clock/state/countdown_controller.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flip_clock/state/settings_sync.dart';
import 'package:flip_clock/state/stopwatch_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timekeeping/timekeeping.dart';

import 'fakes.dart';

const settle = Duration(seconds: 1);

/// Events as nested lists, which `expect` compares deeply (records with
/// maps inside compare by identity).
List<List<Object?>> flat(List<(String, Map<String, dynamic>?)> events) => [
  for (final (name, parameters) in events) [name, parameters],
];

void main() {
  late FakeAnalyticsClient client;
  late ClockAnalytics analytics;

  setUp(() {
    client = FakeAnalyticsClient();
    analytics = ClockAnalytics(client: client, settle: settle);
  });

  group('user properties', () {
    test('describe the defaults', () {
      analytics.identify(const ClockSettings());
      expect(client.properties, {
        'theme': 'dark',
        'skin': 'mono',
        'clock_format': 'device',
        'show_seconds': 'false',
        'show_date': 'false',
        'card_size': 'large',
        'tick_sound': 'off',
        'alarm_sound': 'chime',
        'system_alerts': 'false',
        'keep_awake': 'false',
        'subtle_movement': 'false',
        'default_timer': 'pomodoro',
        'timer_presets': '3',
        'custom_skins': '0',
      });
    });

    test('follow every choice, custom skins as "custom"', () {
      const custom = Skin(id: 'custom-1', name: 'Mine');
      final p = ClockAnalytics.properties(
        const ClockSettings(
          theme: ClockTheme.light,
          use24h: true,
          flipSound: true,
          tickSound: TickSound.clockwork,
          alertSound: false,
          skinId: 'custom-1',
          customSkins: [custom],
          defaultTimer: Minutes(Duration(minutes: 10)),
        ),
      );
      expect(p['theme'], 'light');
      expect(p['clock_format'], '24h');
      expect(p['tick_sound'], 'clockwork');
      expect(p['alarm_sound'], 'off');
      expect(p['skin'], 'custom');
      expect(p['custom_skins'], '1');
      expect(p['default_timer'], '600s');
      expect(
        ClockAnalytics.properties(const ClockSettings(use24h: false)),
        containsPair('clock_format', '12h'),
      );
      // Firebase limits: names up to 24 characters, values up to 36.
      for (final MapEntry(:key, :value) in p.entries) {
        expect(key.length, lessThanOrEqualTo(24));
        expect(value.length, lessThanOrEqualTo(36));
      }
    });
  });

  group('settings changes', () {
    test('are logged once they settle, first to last, with properties', () {
      fakeAsync((async) {
        const a = ClockSettings();
        final b = a.copyWith(corner: 4);
        final c = b.copyWith(corner: 6, theme: ClockTheme.light);
        analytics
          ..settingsChanged(a, b)
          ..settingsChanged(b, c);
        async.elapse(settle - const Duration(milliseconds: 1));
        expect(client.events, isEmpty);
        async.elapse(const Duration(milliseconds: 1));
        expect(
          flat(client.events),
          flat([
            (
              ClockAnalytics.settingChanged,
              {'setting': 'theme', 'setting_value': 'light'},
            ),
            (
              ClockAnalytics.settingChanged,
              {'setting': 'corner', 'setting_value': '6'},
            ),
          ]),
        );
        expect(client.properties['theme'], 'light');
      });
    });

    test('a change back to where it started logs nothing', () {
      fakeAsync((async) {
        const a = ClockSettings();
        final b = a.copyWith(keepAwake: true);
        analytics
          ..settingsChanged(a, b)
          ..settingsChanged(b, a);
        async.elapse(settle);
        expect(client.events, isEmpty);
      });
    });

    test('name each kind of change', () {
      const mine = Skin(id: 'custom-1', name: 'Mine');
      const other = Skin(id: 'custom-2', name: 'Other');
      const from = ClockSettings(customSkins: [mine, other]);
      final to = from.copyWith(
        lastMode: ClockMode.stopwatch,
        skinId: 'custom-3',
        customSkins: [
          const Skin(id: 'custom-3', name: 'New'),
          mine.copyWith(name: 'Renamed'),
        ],
        timerPresets: const [Duration(minutes: 5), Duration(seconds: 90)],
        use24h: true,
        controlsIdle: Duration.zero,
        digitBrightness: 0.5,
        flipSound: true,
        tickSound: TickSound.clockwork,
      );
      final events = ClockAnalytics.changes(from, to);
      expect(
        flat(events),
        flat([
          (
            ClockAnalytics.settingChanged,
            {'setting': 'use24h', 'setting_value': '24h'},
          ),
          (
            ClockAnalytics.settingChanged,
            {'setting': 'flip_sound', 'setting_value': 'true'},
          ),
          (
            ClockAnalytics.settingChanged,
            {'setting': 'tick_sound', 'setting_value': 'clockwork'},
          ),
          (ClockAnalytics.modeChanged, {'mode': 'stopwatch'}),
          (
            ClockAnalytics.settingChanged,
            {'setting': 'digit_brightness', 'setting_value': '50'},
          ),
          (
            ClockAnalytics.skinSelected,
            {'skin': 'custom', 'skin_type': 'custom'},
          ),
          (ClockAnalytics.skinCreated, {'custom_skins': 2}),
          (ClockAnalytics.skinEdited, {'custom_skins': 2}),
          (ClockAnalytics.skinDeleted, {'custom_skins': 2}),
          (
            ClockAnalytics.settingChanged,
            {'setting': 'controls_idle', 'setting_value': '0'},
          ),
          (ClockAnalytics.timerPresetAdded, {'duration_s': 90}),
          (ClockAnalytics.timerPresetRemoved, {'duration_s': 600}),
          (ClockAnalytics.timerPresetRemoved, {'duration_s': 900}),
        ]),
      );
      expect(
        flat(
          ClockAnalytics.changes(
            to,
            to.copyWith(
              skinId: 'paper',
              defaultTimer: const Minutes(Duration(seconds: 90)),
              use24h: false,
            ),
          ),
        ),
        flat([
          (
            ClockAnalytics.settingChanged,
            {'setting': 'use24h', 'setting_value': '12h'},
          ),
          (
            ClockAnalytics.skinSelected,
            {'skin': 'paper', 'skin_type': 'built_in'},
          ),
          (
            ClockAnalytics.settingChanged,
            {'setting': 'default_timer', 'setting_value': '90s'},
          ),
        ]),
      );
      expect(
        flat(
          ClockAnalytics.changes(
            const ClockSettings(use24h: true),
            const ClockSettings(),
          ),
        ),
        flat([
          (
            ClockAnalytics.settingChanged,
            {'setting': 'use24h', 'setting_value': 'device'},
          ),
        ]),
      );
    });

    test('from the cloud log one event and refresh the properties', () {
      analytics.settingsChanged(
        const ClockSettings(),
        const ClockSettings(theme: ClockTheme.system),
        source: SettingsSource.cloud,
      );
      expect(client.names, [ClockAnalytics.settingsFromCloud]);
      expect(client.properties['theme'], 'system');
    });

    test('by the app log nothing but the properties', () {
      analytics.settingsChanged(
        const ClockSettings(),
        const ClockSettings(lastMode: ClockMode.pomodoro, keepAwake: true),
        source: SettingsSource.app,
      );
      expect(client.events, isEmpty);
      expect(client.properties['keep_awake'], 'true');
    });

    test('a cloud or app change first logs the user changes still '
        'settling, and is never part of the next one', () {
      fakeAsync((async) {
        const a = ClockSettings();
        final b = a.copyWith(theme: ClockTheme.light);
        // The cloud copy is based on another device's settings.
        final c = b.copyWith(skinId: 'paper');
        final d = c.copyWith(lastMode: ClockMode.pomodoro);
        final e = d.copyWith(showDate: true);
        analytics.settingsChanged(a, b);
        async.elapse(const Duration(milliseconds: 500));
        analytics.settingsChanged(b, c, source: SettingsSource.cloud);
        expect(
          flat(client.events),
          flat([
            (
              ClockAnalytics.settingChanged,
              {'setting': 'theme', 'setting_value': 'light'},
            ),
            (ClockAnalytics.settingsFromCloud, null),
          ]),
        );
        // The cloud's skin wins over the user's older properties.
        expect(client.properties['skin'], 'paper');
        analytics
          ..settingsChanged(c, d, source: SettingsSource.app)
          ..settingsChanged(d, e);
        async.elapse(settle);
        expect(
          flat(client.events.skip(2).toList()),
          flat([
            (
              ClockAnalytics.settingChanged,
              {'setting': 'show_date', 'setting_value': 'true'},
            ),
          ]),
        );
        expect(client.properties['skin'], 'paper');
      });
    });
  });

  group('countdown', () {
    const idle = CountdownState(duration: Duration(minutes: 5));
    const running = CountdownState(
      status: CountdownStatus.running,
      duration: Duration(minutes: 5),
      remaining: Duration(minutes: 5),
    );
    const paused = CountdownState(
      status: CountdownStatus.paused,
      duration: Duration(minutes: 5),
      remaining: Duration(minutes: 3),
    );
    const finished = CountdownState(
      status: CountdownStatus.finished,
      duration: Duration(minutes: 5),
    );
    const focus = CountdownState(
      status: CountdownStatus.running,
      duration: Duration(minutes: 25),
      remaining: Duration(minutes: 25),
      pomodoro: Pomodoro(),
    );
    const focusDone = CountdownState(
      status: CountdownStatus.finished,
      duration: Duration(minutes: 25),
      pomodoro: Pomodoro(),
    );
    const rest = CountdownState(
      status: CountdownStatus.running,
      duration: Duration(minutes: 5),
      remaining: Duration(minutes: 5),
      pomodoro: Pomodoro(phase: PomodoroPhase.rest),
    );

    test('logs each transition, never a tick', () {
      analytics
        ..countdownChanged(idle, running)
        ..countdownChanged(
          running,
          const CountdownState(
            status: CountdownStatus.running,
            duration: Duration(minutes: 5),
            remaining: Duration(minutes: 4),
          ),
        )
        ..countdownChanged(running, paused)
        ..countdownChanged(paused, running)
        ..countdownChanged(running, finished)
        ..countdownChanged(finished, running)
        ..countdownChanged(finished, idle)
        ..countdownChanged(paused, idle)
        ..countdownChanged(idle, focus)
        ..countdownChanged(focus, focusDone)
        ..countdownChanged(focusDone, rest)
        ..countdownChanged(rest, idle);
      expect(
        flat(client.events),
        flat([
          (ClockAnalytics.timerStarted, {'kind': 'timer', 'duration_s': 300}),
          (ClockAnalytics.timerPaused, {'kind': 'timer', 'remaining_s': 180}),
          (ClockAnalytics.timerResumed, {'kind': 'timer', 'remaining_s': 300}),
          (ClockAnalytics.timerFinished, {'kind': 'timer', 'duration_s': 300}),
          (ClockAnalytics.timerStarted, {'kind': 'timer', 'duration_s': 300}),
          (ClockAnalytics.timerDismissed, {'kind': 'timer'}),
          (
            ClockAnalytics.timerCancelled,
            {'kind': 'timer', 'remaining_s': 180},
          ),
          (
            ClockAnalytics.timerStarted,
            {'kind': 'pomodoro', 'duration_s': 1500},
          ),
          (
            ClockAnalytics.timerFinished,
            {
              'kind': 'pomodoro',
              'duration_s': 1500,
              'phase': 'focus',
              'round': 1,
            },
          ),
          (ClockAnalytics.pomodoroPhaseStarted, {'phase': 'break', 'round': 1}),
          (
            ClockAnalytics.timerCancelled,
            {'kind': 'pomodoro', 'remaining_s': 300},
          ),
        ]),
      );
    });
  });

  group('stopwatch', () {
    test('logs start, lap, pause, resume and reset, never a tick', () {
      const idle = StopwatchState();
      const started = StopwatchState(running: true);
      const ticking = StopwatchState(
        elapsed: Duration(seconds: 3),
        running: true,
      );
      const lapped = StopwatchState(
        elapsed: Duration(seconds: 3),
        running: true,
        laps: [Duration(seconds: 3)],
      );
      const paused = StopwatchState(
        elapsed: Duration(seconds: 4),
        laps: [Duration(seconds: 3)],
      );
      analytics
        ..stopwatchChanged(idle, started)
        ..stopwatchChanged(started, ticking)
        ..stopwatchChanged(ticking, lapped)
        ..stopwatchChanged(lapped, paused)
        ..stopwatchChanged(paused, lapped)
        ..stopwatchChanged(paused, idle);
      expect(
        flat(client.events),
        flat([
          (ClockAnalytics.stopwatchStarted, null),
          (ClockAnalytics.stopwatchLap, {'lap': 1}),
          (ClockAnalytics.stopwatchPaused, {'elapsed_s': 4, 'laps': 1}),
          (ClockAnalytics.stopwatchResumed, null),
          (ClockAnalytics.stopwatchReset, {'elapsed_s': 4, 'laps': 1}),
        ]),
      );
    });
  });

  test('logs the notification permission answer', () {
    analytics
      ..notificationPermissionAnswered(granted: true)
      ..notificationPermissionAnswered(granted: false);
    expect(
      flat(client.events),
      flat([
        (ClockAnalytics.notificationPermission, {'granted': 'true'}),
        (ClockAnalytics.notificationPermission, {'granted': 'false'}),
      ]),
    );
  });

  test('follows full screen until closed', () {
    final active = ValueNotifier(false);
    addTearDown(active.dispose);
    analytics.followFullScreen(active);
    active.value = true;
    active.value = false;
    analytics.close();
    active.value = true;
    expect(
      flat(client.events),
      flat([
        (ClockAnalytics.fullScreenChanged, {'on': 'true'}),
        (ClockAnalytics.fullScreenChanged, {'on': 'false'}),
      ]),
    );
  });

  test('follows the account and sync status until closed', () {
    final sync = FakeCloudSync();
    analytics.followSync(sync);
    expect(client.properties, {'account': 'guest', 'cloud_sync': 'off'});
    sync.accountValue.value = const SyncAccount(
      uid: 'u1',
      email: 'a@b.c',
      provider: SyncProvider.google,
    );
    sync.statusValue.value = const SyncPending();
    expect(client.properties, {'account': 'google', 'cloud_sync': 'on'});
    sync.statusValue.value = SyncFailed(DateTime(2026), SyncFailure.offline);
    expect(
      flat(client.events),
      flat([
        (ClockAnalytics.syncFailed, {'reason': 'offline'}),
      ]),
    );
    // Never the uid or the email.
    expect('${client.events}${client.properties}', isNot(contains('u1')));
    expect('${client.events}${client.properties}', isNot(contains('a@b.c')));
    analytics.close();
    sync.statusValue.value = SyncFailed(DateTime(2027), SyncFailure.denied);
    expect(client.events, hasLength(1));
  });

  test('close logs settings still settling, then nothing more', () {
    fakeAsync((async) {
      analytics
        ..settingsChanged(
          const ClockSettings(),
          const ClockSettings(keepAwake: true),
        )
        ..close();
      expect(
        flat(client.events),
        flat([
          (
            ClockAnalytics.settingChanged,
            {'setting': 'keep_awake', 'setting_value': 'true'},
          ),
        ]),
      );
      final properties = {...client.properties};
      analytics
        ..settingsChanged(
          const ClockSettings(),
          const ClockSettings(showDate: true),
        )
        ..countdownChanged(
          const CountdownState(),
          const CountdownState(status: CountdownStatus.running),
        )
        ..identify(const ClockSettings());
      async.elapse(settle);
      expect(client.events, hasLength(1));
      expect(client.properties, properties);
      expect(client.properties['keep_awake'], 'true');
    });
  });

  test('without a client every call is a no-op', () {
    fakeAsync((async) {
      final off = ClockAnalytics(settle: settle)
        ..identify(const ClockSettings())
        ..settingsChanged(
          const ClockSettings(),
          const ClockSettings(keepAwake: true),
        )
        ..countdownChanged(
          const CountdownState(),
          const CountdownState(status: CountdownStatus.running),
        );
      async.elapse(settle);
      off.close();
      expect(async.pendingTimers, isEmpty);
    });
  });

  group('controllers report', () {
    late FakeStore store;
    late SettingsRepositoryImp repo;

    setUp(() async {
      await core.init();
      store = FakeStore();
      repo = SettingsRepositoryImp(store: store, logger: di.get<Logger>());
    });
    tearDown(di.reset);

    test('settings: load identifies, user changes and cloud copies '
        'are told apart, the permission answer is logged', () async {
      await repo.save(const ClockSettings(theme: ClockTheme.light));
      final alerts = FakeAlerts()..grant = false;
      final settings = SettingsController(
        repository: repo,
        alerts: alerts,
        analytics: analytics,
      );
      addTearDown(settings.close);
      await settings.load();
      expect(client.properties['theme'], 'light');
      expect(client.events, isEmpty);

      await settings.update(
        settings.state.copyWith(theme: ClockTheme.dark),
        source: SettingsSource.cloud,
      );
      expect(client.names, [ClockAnalytics.settingsFromCloud]);

      await settings.setSystemAlerts(true);
      expect(client.names.last, ClockAnalytics.notificationPermission);
      await settings.setSystemAlerts(false);
      expect(
        client.names.where((n) => n == ClockAnalytics.notificationPermission),
        hasLength(1),
      );
    });

    test('settings: a user change is logged after it settles', () {
      fakeAsync((async) {
        final settings = SettingsController(
          repository: repo,
          alerts: FakeAlerts(),
          analytics: analytics,
        );
        unawaited(settings.selectSkin('paper'));
        async.flushMicrotasks();
        async.elapse(settle);
        expect(client.names, [
          ClockAnalytics.settingChanged,
          ClockAnalytics.skinSelected,
        ]);
        unawaited(settings.close());
        async.flushMicrotasks();
      });
    });

    test('countdown: a restored countdown is not logged, a new one is', () {
      fakeAsync((async) {
        final clock = FakeClock();
        CountdownController make() => CountdownController(
          repository: repo,
          alerts: FakeAlerts(),
          sound: FakeSound(),
          settings: () => const ClockSettings(),
          logger: di.get<Logger>(),
          now: clock.call,
          elapsed: clock.monotonic,
          analytics: analytics,
        );
        final first = make();
        unawaited(first.start(const Duration(minutes: 5)));
        async.flushMicrotasks();
        expect(client.names, [ClockAnalytics.timerStarted]);
        unawaited(first.close());

        final restored = make();
        unawaited(restored.load());
        async.flushMicrotasks();
        expect(restored.state.status, CountdownStatus.running);
        expect(client.names, [ClockAnalytics.timerStarted]);
        unawaited(restored.pause());
        async.flushMicrotasks();
        expect(client.names.last, ClockAnalytics.timerPaused);
        unawaited(restored.close());
        async.flushMicrotasks();
      });
    });

    test('stopwatch: transitions are logged', () {
      final watch = FakeStopwatch();
      final stopwatch = StopwatchController(
        stopwatch: watch,
        analytics: analytics,
      );
      addTearDown(stopwatch.close);
      stopwatch.start();
      watch.reading = const Duration(seconds: 2);
      stopwatch
        ..lap()
        ..reset();
      expect(client.names, [
        ClockAnalytics.stopwatchStarted,
        ClockAnalytics.stopwatchLap,
        ClockAnalytics.stopwatchReset,
      ]);
    });

    test('init wires analytics when a client is registered', () async {
      final full = FakeFullScreen();
      final sync = FakeCloudSync();
      addTearDown(sync.remote.close);
      di
        ..register<AnalyticsClient>(client)
        ..register<KeyValueStore>(store)
        ..register<LocalAlerts>(FakeAlerts())
        ..register<SoundPlayer>(FakeSound())
        ..register<OrientationLock>(FakeOrientation())
        ..register<FullScreenController>(full);
      await init(sync: sync);
      expect(di.has<ClockAnalytics>(), isTrue);
      expect(di.has<SettingsSync>(), isTrue);
      expect(client.properties['theme'], 'dark');
      expect(client.properties['account'], 'guest');
      await full.toggle();
      expect(client.names, [ClockAnalytics.fullScreenChanged]);
    });
  });
}
