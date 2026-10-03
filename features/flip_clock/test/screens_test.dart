import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart' show Closable;
import 'package:core/core.dart' as core;
import 'package:core/core.dart' show Logger;
import 'package:design_system/design_system.dart';
import 'package:device_services/device_services.dart';
import 'package:di/di.dart';
import 'package:flip_clock/analytics/clock_analytics.dart';
import 'package:flip_clock/data/models/skin.dart';
import 'package:flip_clock/data/skins.dart';
import 'package:flip_clock/data/repositories/settings_repository.dart';
import 'package:flip_clock/data/repositories/settings_repository_imp.dart';
import 'package:flip_clock/flip_clock.dart' as flip_clock;
import 'package:flip_clock/flip_clock.dart';
import 'package:flip_clock/state/chrome_controller.dart';
import 'package:flip_clock/state/clock_controller.dart';
import 'package:flip_clock/state/countdown_controller.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flip_clock/state/stopwatch_controller.dart';
import 'package:flip_clock/ui/components/flip_display.dart';
import 'package:flip_clock/ui/components/gesture_layer.dart';
import 'package:flip_clock/ui/components/skin_customizer.dart';
import 'package:flip_clock/ui/components/skin_picker.dart';
import 'package:flip_clock/ui/components/subtle_movement.dart';
import 'package:flip_clock/ui/screens/index.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:timekeeping/timekeeping.dart';

import 'contrast.dart';
import 'fakes.dart';
import 'ink.dart';

final theme = ThemeData(colorScheme: DesignSystem.blackScheme());

class Harness {
  Harness({FakeScreenBrightness? brightness, ClockAnalytics? analytics})
    : brightness = brightness ?? FakeScreenBrightness() {
    final repo = SettingsRepositoryImp(store: store, logger: di.get<Logger>());
    settings = SettingsController(
      repository: repo,
      alerts: alerts,
      analytics: analytics,
    );
    countdown = CountdownController(
      repository: repo,
      alerts: alerts,
      sound: sound,
      settings: () => settings.state,
      logger: di.get<Logger>(),
      now: wall.call,
      elapsed: wall.monotonic,
      analytics: analytics,
    );
    clock = ClockController(now: wall.call);
    stopwatch = StopwatchController(stopwatch: watch);
  }

  final store = FakeStore();
  final alerts = FakeAlerts();
  final sound = FakeSound();
  final full = FakeFullScreen();
  final wake = FakeWake();
  final FakeScreenBrightness brightness;
  final wall = FakeClock();
  final watch = FakeStopwatch();
  late final SettingsController settings;
  late final CountdownController countdown;
  late final ClockController clock;
  late final StopwatchController stopwatch;
  int settingsOpened = 0;
  int timerSettingsOpened = 0;

  Widget screen({
    bool doubleTap = false,
    bool reduceMotion = false,
    ThemeData? appTheme,
    bool orientationSupported = false,
    Locale? locale,
  }) => MaterialApp(
    theme: appTheme ?? theme,
    locale: locale,
    supportedLocales: locale == null
        ? const [Locale('en', 'US')]
        : LocalizationProvider.locales,
    localizationsDelegates: locale == null
        ? null
        : GlobalMaterialLocalizations.delegates,
    builder: reduceMotion
        ? (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          )
        : null,
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
      doubleTapFullScreen: doubleTap,
      onOpenSettings: () => settingsOpened++,
      onOpenTimerSettings: () => timerSettingsOpened++,
      orientationSupported: orientationSupported,
    ),
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

Future<void> key(WidgetTester tester, LogicalKeyboardKey k) async {
  await tester.sendKeyEvent(k);
  await tester.pump();
}

/// Presses Left/Right and waits for the panel to slide in.
Future<void> modeKey(WidgetTester tester, LogicalKeyboardKey k) async {
  await key(tester, k);
  await tester.pump(DesignMotion.islandMorph);
  await tester.pump();
}

/// Taps a mode tab and waits for the panel to slide in.
Future<void> modeTab(WidgetTester tester, String name) async {
  await tester.tap(find.text(name));
  await tester.pump();
  await tester.pump(DesignMotion.islandMorph);
  await tester.pump();
}

/// Shows the chrome, which launch keeps hidden, the way a key press does,
/// and waits for the island to open.
Future<void> showChrome(WidgetTester tester) async {
  await key(tester, LogicalKeyboardKey.keyQ);
  await tester.pump(DesignMotion.islandMorph);
  await tester.pump();
}

/// The stopwatch panel at zero.
String get stopwatchZero => strings.clock.elapsed('0:00:00.0');

ChromeState chromeOf(WidgetTester tester) =>
    tester.widget<Island>(find.byType(Island)).state;

/// An island tray action by its label (tooltip).
Finder action(String label) => find.byTooltip(label);

/// Taps the tray action [label].
Future<void> tapAction(WidgetTester tester, String label) async {
  await tester.tap(action(label));
  await tester.pump();
}

/// Lets the tray cross-fade finish frame by frame (a running stopwatch
/// never settles).
Future<void> crossFade(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Tooltips of the tray actions the island shows now.
List<String> trayOf(WidgetTester tester) => [
  for (final t in tester.widgetList<Tooltip>(
    find.descendant(of: find.byType(Island), matching: find.byType(Tooltip)),
  ))
    t.message!,
];

void main() {
  setUp(core.init);
  tearDown(di.reset);

  testWidgets('opens on the clock in 24h without seconds; settings toggle it', (
    tester,
  ) async {
    deviceOn24h(tester);
    final h = Harness();
    await tester.pumpWidget(h.screen());
    await showChrome(tester);
    expect(
      find.bySemanticsLabel(strings.clock.current_time('09:41')),
      findsOne,
    );
    await h.settings.update(
      h.settings.state.copyWith(use24h: false, showSeconds: true),
    );
    await tester.pump();
    expect(
      find.bySemanticsLabel(strings.clock.current_time('9:41:00 AM')),
      findsOne,
    );
    await tester.tap(action(strings.clock.action_settings));
    expect(h.settingsOpened, 1);
    await h.dispose(tester);
  });

  testWidgets('date line shows above the clock and rolls over at midnight', (
    tester,
  ) async {
    deviceOn24h(tester);
    final h = Harness();
    h.wall.now = DateTime(2026, 9, 29, 23, 59, 59);
    await tester.pumpWidget(h.screen());
    expect(find.text('Tuesday, September 29, 2026'), findsNothing);

    await h.settings.update(h.settings.state.copyWith(showDate: true));
    await tester.pump();
    expect(find.text('Tuesday, September 29, 2026'), findsOne);
    expect(
      find.bySemanticsLabel(
        strings.clock.current_time_and_date(
          '23:59',
          'Tuesday, September 29, 2026',
        ),
      ),
      findsOne,
    );

    h.wall.advance(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Wednesday, September 30, 2026'), findsOne);

    // A tiny window scales the date down instead of overflowing.
    tester.view
      ..physicalSize = const Size(200, 200)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pump();
    expect(tester.takeException(), isNull);
    await h.dispose(tester);
  });

  testWidgets('flip sound plays on each change only when enabled', (
    tester,
  ) async {
    final h = Harness();
    await h.settings.update(const ClockSettings(showSeconds: true));
    await tester.pumpWidget(h.screen());
    h.wall.advance(const Duration(minutes: 1));
    await tester.pump(const Duration(minutes: 1));
    expect(h.sound.flips, 0);
    await h.settings.update(h.settings.state.copyWith(flipSound: true));
    await tester.pump();
    h.wall.advance(const Duration(minutes: 1));
    await tester.pump(const Duration(minutes: 1));
    expect(h.sound.flips, 1);
    expect(h.sound.ticks, [TickSound.classic]);
    await h.settings.update(
      h.settings.state.copyWith(tickSound: TickSound.woodblock),
    );
    await tester.pump();
    h.wall.advance(const Duration(minutes: 1));
    await tester.pump(const Duration(minutes: 1));
    expect(h.sound.ticks.last, TickSound.woodblock, reason: 'the pick plays');
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });

  testWidgets('timer: start, pause, resume, reset, finish and dismiss', (
    tester,
  ) async {
    final h = Harness();
    const half = Duration(seconds: 30);
    await h.settings.update(
      const ClockSettings().copyWith(
        timerPresets: [half],
        defaultTimer: const Minutes(half),
      ),
    );
    await tester.pumpWidget(h.screen());
    await showChrome(tester);
    await modeTab(tester, strings.clock.mode_pomodoro);
    expect(h.settings.state.lastMode, ClockMode.pomodoro);
    // Idle shows the default timer.
    expect(
      find.bySemanticsLabel(strings.clock.time_remaining('00:00:30')),
      findsOne,
    );
    await tester.pumpAndSettle();
    await tester.tap(action(strings.clock.action_start));
    await tester.pump();
    expect(h.countdown.state.status, CountdownStatus.running);
    expect(
      find.bySemanticsLabel(strings.clock.time_remaining('00:00:30')),
      findsOne,
    );

    await tester.tap(action(strings.clock.action_pause));
    await tester.pump();
    expect(h.countdown.state.status, CountdownStatus.paused);
    await tester.tap(action(strings.clock.action_resume));
    await tester.pump();
    expect(h.countdown.state.status, CountdownStatus.running);
    await tester.tap(action(strings.clock.action_reset));
    await tester.pump();
    expect(h.countdown.state.status, CountdownStatus.idle);

    await tester.tap(action(strings.clock.action_start));
    await tester.pump();
    h.wall.advance(const Duration(seconds: 30));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();
    expect(find.text(strings.clock.times_up), findsOne);
    expect(h.sound.alarms, 1);
    await tester.tap(action(strings.clock.action_done));
    await tester.pump();
    expect(h.countdown.state.status, CountdownStatus.idle);
    expect(h.sound.stops, 2, reason: "reset and dismiss both silence");
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });

  testWidgets('a timer finishing on another mode switches to it', (
    tester,
  ) async {
    final h = Harness();
    await tester.pumpWidget(h.screen());
    await h.countdown.start(const Duration(seconds: 2));
    await modeKey(tester, LogicalKeyboardKey.arrowRight);
    expect(h.settings.state.lastMode, ClockMode.stopwatch);
    h.wall.advance(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();
    await tester.pump(DesignMotion.islandMorph);
    expect(h.settings.state.lastMode, ClockMode.pomodoro);
    // No mode HUD in the way: the finished tray shows at once.
    expect(find.text(strings.clock.times_up), findsOne);
    await h.countdown.reset();
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });

  testWidgets('relaunch with a finished-while-away timer opens on it', (
    tester,
  ) async {
    final h = Harness();
    await h.countdown.start(const Duration(seconds: 2));
    h.wall.advance(const Duration(seconds: 2));
    await h.countdown.check();
    expect(h.settings.state.lastMode, ClockMode.clock);
    await tester.pumpWidget(h.screen());
    await showChrome(tester);
    await tester.pump();
    expect(h.settings.state.lastMode, ClockMode.pomodoro);
    expect(find.text(strings.clock.times_up), findsOne);
    await h.countdown.reset();
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });

  testWidgets('analytics: a finished timer switching the panel is not the '
      "user's mode change; a key is", (tester) async {
    final client = FakeAnalyticsClient();
    final analytics = ClockAnalytics(client: client);
    final h = Harness(analytics: analytics);
    await tester.pumpWidget(h.screen());
    await tester.pump();
    expect(h.settings.state.lastMode, ClockMode.clock);
    await h.countdown.start(const Duration(minutes: 1));
    h.wall.advance(const Duration(minutes: 1));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();
    expect(h.settings.state.lastMode, ClockMode.pomodoro);
    await tester.pump(const Duration(seconds: 1));
    expect(client.names, [
      ClockAnalytics.timerStarted,
      ClockAnalytics.timerFinished,
    ]);
    await key(tester, LogicalKeyboardKey.arrowRight);
    await tester.pump(const Duration(seconds: 1));
    expect(client.names.last, ClockAnalytics.modeChanged);
    await h.countdown.reset();
    analytics.close();
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });

  testWidgets('pomodoro: start, round label, next phase, pause, reset', (
    tester,
  ) async {
    final h = Harness();
    await h.settings.update(const ClockSettings(lastMode: ClockMode.pomodoro));
    await tester.pumpWidget(h.screen());
    await showChrome(tester);
    await tester.pump();
    expect(
      find.bySemanticsLabel(strings.clock.time_remaining('00:25:00')),
      findsOne,
    );
    await tester.tap(action(strings.clock.action_start));
    await tester.pump();
    expect(find.text(strings.clock.pomodoro_focus(1)), findsOne);
    expect(
      find.bySemanticsLabel(strings.clock.time_remaining('00:25:00')),
      findsOne,
    );

    h.wall.advance(const Duration(minutes: 25));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();
    expect(find.text(strings.clock.pomodoro_break(1)), findsOne);
    expect(find.text(strings.clock.times_up), findsNothing);
    expect(h.sound.alarms, 1);
    await tester.pump(const Duration(seconds: 5));
    expect(h.sound.stops, 1);

    await key(tester, LogicalKeyboardKey.space);
    expect(h.countdown.state.status, CountdownStatus.paused);
    await tester.tap(action(strings.clock.action_reset));
    await tester.pump();
    // Back to the idle Pomodoro panel.
    expect(action(strings.clock.action_start), findsOne);
    expect(find.text(strings.clock.pomodoro_break(1)), findsNothing);
    expect(h.countdown.state.duration, Countdown.defaultDuration);
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });

  testWidgets('a pomodoro phase that ended while away offers the next one', (
    tester,
  ) async {
    final h = Harness();
    h.store.data[SettingsRepositoryImp.countdownKey] = jsonEncode({
      'durationMs': const Duration(minutes: 5).inMilliseconds,
      'status': 'running',
      'endsAtMs': h.wall.now.millisecondsSinceEpoch - 60000,
      'pomodoro': {'phase': 'rest', 'round': 2},
    });
    await h.countdown.load();
    await tester.pumpWidget(h.screen());
    await showChrome(tester);
    await tester.pump();
    await tester.pump(DesignMotion.islandMorph);
    expect(h.settings.state.lastMode, ClockMode.pomodoro);
    // No mode HUD in the way: the finished tray shows at once.
    expect(find.text(strings.clock.times_up), findsOne);
    expect(find.text(strings.clock.pomodoro_break(2)), findsOne);
    await tester.tap(action(strings.clock.start_focus));
    await tester.pump();
    expect(find.text(strings.clock.pomodoro_focus(3)), findsOne);
    expect(h.countdown.state.status, CountdownStatus.running);
    await h.countdown.reset();
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });

  testWidgets('a finished focus offers Start break', (tester) async {
    final h = Harness();
    h.store.data[SettingsRepositoryImp.countdownKey] = jsonEncode({
      'durationMs': const Duration(minutes: 25).inMilliseconds,
      'status': 'finished',
      'pomodoro': {'phase': 'focus', 'round': 1},
    });
    await h.countdown.load();
    await tester.pumpWidget(h.screen());
    await showChrome(tester);
    await tester.pump();
    expect(action(strings.clock.start_break), findsOne);
    expect(h.settings.state.lastMode, ClockMode.pomodoro);
    await tester.tap(action(strings.clock.action_done));
    await tester.pump();
    // The idle Pomodoro panel offers a new focus.
    expect(action(strings.clock.action_start), findsOne);
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });

  testWidgets('Space activates a focused control instead of the timer', (
    tester,
  ) async {
    final h = Harness();
    await h.settings.update(const ClockSettings(lastMode: ClockMode.stopwatch));
    await tester.pumpWidget(h.screen());
    await showChrome(tester);
    await tester.pump();
    await key(tester, LogicalKeyboardKey.tab);
    await key(tester, LogicalKeyboardKey.space);
    expect(h.stopwatch.state.running, isFalse);
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });

  testWidgets('launch shows the clock alone until a tap', (tester) async {
    final h = Harness();
    await h.settings.update(const ClockSettings(lastMode: ClockMode.stopwatch));
    await tester.pumpWidget(h.screen(orientationSupported: true));
    final c = strings.clock;
    List<ChromeState> corners() => [
      for (final b in tester.widgetList<CornerButton>(
        find.byType(CornerButton),
      ))
        b.state,
    ];
    expect(chromeOf(tester), ChromeState.hidden);
    expect(corners(), List.filled(3, ChromeState.hidden));
    expect(action(c.action_start), findsNothing);
    // Watched past the idle window: nothing comes up on its own.
    await tester.pump(const Duration(seconds: 10));
    expect(chromeOf(tester), ChromeState.hidden);

    // The first tap shows the full controls, which collapse as before.
    await tester.tapAt(const Offset(400, 300));
    await tester.pump();
    expect(chromeOf(tester), ChromeState.expanded);
    expect(corners(), List.filled(3, ChromeState.expanded));
    await tester.pump(DesignMotion.islandMorph);
    expect(action(c.action_start), findsOne);
    await tester.pump(DesignMotion.controlsIdle);
    expect(chromeOf(tester), ChromeState.dot);
    await tester.pump(DesignMotion.dotIdle);
    expect(chromeOf(tester), ChromeState.hidden);
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });

  testWidgets('screen readers get "show controls" while the chrome hides', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final h = Harness();
    await tester.pumpWidget(h.screen());
    // Hidden from launch.
    expect(find.bySemanticsLabel(strings.clock.show_controls), findsOne);
    await showChrome(tester);
    expect(find.bySemanticsLabel(strings.clock.show_controls), findsNothing);
    await tester.pump(const Duration(seconds: 8));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(strings.clock.show_controls), findsOne);
    tester.semantics.tap(find.semantics.byLabel(strings.clock.show_controls));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(strings.clock.show_controls), findsNothing);
    expect(chromeOf(tester), ChromeState.expanded);
    semantics.dispose();
    await h.dispose(tester);
  });

  testWidgets('entering full screen shows what it does, then hides it', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final h = Harness();
    await tester.pumpWidget(h.screen());
    final note = find.text(strings.clock.full_screen_note);
    expect(note, findsNothing);

    // Full screen entered without a key (a double tap, the system) still
    // shows the chrome that launch kept hidden.
    expect(chromeOf(tester), ChromeState.hidden);
    h.full.value.value = true;
    await tester.pump();
    expect(chromeOf(tester), ChromeState.expanded);
    expect(note, findsOne);
    h.full.value.value = false;
    await tester.pump();
    await key(tester, LogicalKeyboardKey.escape);
    expect(chromeOf(tester), ChromeState.hidden);
    expect(note, findsNothing);

    await key(tester, LogicalKeyboardKey.keyF);
    expect(note, findsOne);
    expect(
      tester.getSemantics(note),
      isSemantics(label: strings.clock.full_screen_note, isLiveRegion: true),
    );
    expect(chromeOf(tester), ChromeState.expanded);
    await tester.pump(FlipClockScreen.noteFor);
    expect(note, findsNothing);

    // Leaving clears it at once; re-entering shows it again.
    await key(tester, LogicalKeyboardKey.keyF);
    await key(tester, LogicalKeyboardKey.escape);
    expect(note, findsNothing);
    await tester.pumpAndSettle(FlipClockScreen.noteFor);
    semantics.dispose();
    await h.dispose(tester);
  });

  testWidgets('the full-screen listener is removed on dispose', (tester) async {
    final h = Harness();
    await tester.pumpWidget(h.screen());
    await h.dispose(tester);
    // No listener left: toggling after dispose must not touch the old state.
    await h.full.toggle();
    await tester.pump(FlipClockScreen.noteFor);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keyboard: Left/Right modes, Space start/pause, F and Esc', (
    tester,
  ) async {
    final h = Harness();
    await tester.pumpWidget(h.screen());
    await tester.pump();

    await modeKey(tester, LogicalKeyboardKey.arrowRight);
    expect(h.settings.state.lastMode, ClockMode.stopwatch);
    await key(tester, LogicalKeyboardKey.space);
    expect(h.stopwatch.state.running, isTrue);
    h.watch.reading = const Duration(seconds: 2);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.bySemanticsLabel(strings.clock.elapsed('0:00:02.0')), findsOne);
    await key(tester, LogicalKeyboardKey.space);
    expect(h.stopwatch.state.running, isFalse);
    await tester.pumpAndSettle();
    expect(action(strings.clock.action_resume), findsOne);
    await tester.tap(action(strings.clock.action_reset));
    await tester.pump();
    expect(h.stopwatch.state.isIdle, isTrue);

    await modeKey(tester, LogicalKeyboardKey.arrowLeft);
    await modeKey(tester, LogicalKeyboardKey.arrowLeft);
    expect(h.settings.state.lastMode, ClockMode.pomodoro);
    // Space starts the default timer: the cycle.
    await key(tester, LogicalKeyboardKey.space);
    expect(h.countdown.state.status, CountdownStatus.running);
    expect(h.countdown.state.pomodoro, isNotNull);
    await key(tester, LogicalKeyboardKey.space);
    expect(h.countdown.state.status, CountdownStatus.paused);

    await modeKey(tester, LogicalKeyboardKey.arrowRight);
    expect(h.settings.state.lastMode, ClockMode.clock);
    await key(tester, LogicalKeyboardKey.space);
    await key(tester, LogicalKeyboardKey.escape);
    expect(h.full.exits, 0);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyF);

    await key(tester, LogicalKeyboardKey.keyF);
    expect(h.full.value.value, isTrue);
    await key(tester, LogicalKeyboardKey.escape);
    expect(h.full.exits, 1);
    expect(h.full.value.value, isFalse);
    await key(tester, LogicalKeyboardKey.keyQ);
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });

  testWidgets('S toggles seconds in Clock mode only', (tester) async {
    deviceOn24h(tester);
    final h = Harness();
    await tester.pumpWidget(h.screen());
    await tester.pump();
    await key(tester, LogicalKeyboardKey.keyS);
    expect(h.settings.state.showSeconds, isTrue);
    expect(
      find.bySemanticsLabel(strings.clock.current_time('09:41:00')),
      findsOne,
    );
    final saved = await SettingsRepositoryImp(
      store: h.store,
      logger: di.get<Logger>(),
    ).load();
    expect(saved.showSeconds, isTrue);
    await key(tester, LogicalKeyboardKey.keyS);
    expect(h.settings.state.showSeconds, isFalse);

    await modeKey(tester, LogicalKeyboardKey.arrowRight);
    await key(tester, LogicalKeyboardKey.keyS);
    expect(h.settings.state.showSeconds, isFalse);
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });

  testWidgets('chrome: dots after 4 s, gone after 7 s, tap toggles', (
    tester,
  ) async {
    final h = Harness();
    await h.settings.update(const ClockSettings(lastMode: ClockMode.stopwatch));
    await tester.pumpWidget(h.screen());
    await showChrome(tester);
    final start = action(strings.clock.action_start);
    expect(chromeOf(tester), ChromeState.expanded);
    expect(start, findsOne);

    await tester.pump(const Duration(seconds: 4));
    expect(chromeOf(tester), ChromeState.dot);
    await tester.pumpAndSettle();
    expect(start, findsNothing);
    await tester.pump(const Duration(seconds: 3));
    expect(chromeOf(tester), ChromeState.hidden);
    // Watched past the window: it stays hidden.
    await tester.pump(const Duration(seconds: 10));
    expect(chromeOf(tester), ChromeState.hidden);

    // A tap on the clock shows the chrome; another hides it.
    await tester.tapAt(const Offset(400, 300));
    await tester.pump();
    expect(chromeOf(tester), ChromeState.expanded);
    await tester.tapAt(const Offset(400, 300));
    await tester.pump();
    expect(chromeOf(tester), ChromeState.hidden);

    // Any key shows it; Esc hides it (outside full screen).
    await key(tester, LogicalKeyboardKey.keyQ);
    expect(chromeOf(tester), ChromeState.expanded);
    await key(tester, LogicalKeyboardKey.escape);
    expect(chromeOf(tester), ChromeState.hidden);

    // A mouse move shows it.
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(10, 10));
    await mouse.moveTo(const Offset(20, 20));
    await tester.pump();
    expect(chromeOf(tester), ChromeState.expanded);
    await mouse.removePointer();

    // A tap on a control is the control's, not a toggle.
    await tester.tap(start);
    await tester.pump();
    expect(h.stopwatch.state.running, isTrue);
    expect(chromeOf(tester), ChromeState.expanded);
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });

  testWidgets('tap-to-toggle off and a changed idle time are honoured', (
    tester,
  ) async {
    final h = Harness();
    await h.settings.update(
      const ClockSettings(
        tapToggleControls: false,
        controlsIdle: Duration(seconds: 2),
      ),
    );
    await tester.pumpWidget(h.screen());
    await showChrome(tester);
    await tester.pump(const Duration(seconds: 2));
    expect(chromeOf(tester), ChromeState.dot);
    await tester.tapAt(const Offset(400, 300));
    await tester.pump();
    expect(chromeOf(tester), ChromeState.dot);
    // Never: stays expanded.
    await h.settings.update(
      h.settings.state.copyWith(controlsIdle: Duration.zero),
    );
    await key(tester, LogicalKeyboardKey.keyQ);
    await tester.pump(const Duration(minutes: 1));
    expect(chromeOf(tester), ChromeState.expanded);
    await h.dispose(tester);
  });

  testWidgets('island tabs switch modes; the tray opens Skins and Settings', (
    tester,
  ) async {
    final h = Harness();
    await tester.pumpWidget(h.screen());
    await showChrome(tester);
    await modeTab(tester, strings.clock.stopwatch);
    expect(h.settings.state.lastMode, ClockMode.stopwatch);
    await tester.tap(action(strings.clock.action_settings));
    expect(h.settingsOpened, 1);
    await tester.tap(action(strings.clock.action_skins));
    await tester.pumpAndSettle();
    expect(find.byType(SkinPicker), findsOne);
    await h.dispose(tester);
  });

  testWidgets('D dims only the digits, and saves', (tester) async {
    final h = Harness();
    await tester.pumpWidget(h.screen());
    double digits() => tester
        .widget<Opacity>(
          find
              .ancestor(
                of: find.byType(FlipDisplay),
                matching: find.byType(Opacity),
              )
              .first,
        )
        .opacity;
    expect(digits(), 1.0);

    await key(tester, LogicalKeyboardKey.keyD);
    expect(h.settings.state.digitBrightness, 0.5);
    expect(digits(), 0.5);
    final saved = h.store.data[SettingsRepositoryImp.settingsKey]!;
    expect(
      ClockSettings.fromJson(jsonDecode(saved) as Map<String, Object?>),
      const ClockSettings(digitBrightness: 0.5),
    );
    await key(tester, LogicalKeyboardKey.keyD);
    expect(h.settings.state.digitBrightness, 0.2);
    await key(tester, LogicalKeyboardKey.keyD);
    expect(h.settings.state.digitBrightness, 1.0);
    // The chrome is never dimmed.
    expect(
      find.ancestor(of: find.byType(Island), matching: find.byType(Opacity)),
      findsNothing,
    );

    for (final mode in [ClockMode.pomodoro, ClockMode.stopwatch]) {
      await h.settings.update(
        ClockSettings(lastMode: mode, digitBrightness: 0.2),
      );
      if (mode == ClockMode.pomodoro) {
        await h.countdown.start(const Duration(minutes: 1));
      }
      await tester.pump();
      expect(digits(), 0.2, reason: '$mode');
    }
    await h.countdown.reset();
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });

  testWidgets('subtle movement shifts the display each minute in full screen', (
    tester,
  ) async {
    final h = Harness();
    await tester.pumpWidget(h.screen());
    bool moving() =>
        tester.widget<SubtleMovement>(find.byType(SubtleMovement)).enabled;
    Offset shift() => tester.getTopLeft(find.byType(FlipDisplay));
    final still = shift();
    await key(tester, LogicalKeyboardKey.keyF);
    expect(moving(), isFalse, reason: 'setting off');
    expect(shift(), still, reason: 'off: centred, same padding');

    // Turning it on eases to this minute's offset.
    await h.settings.update(h.settings.state.copyWith(subtleMovement: true));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    final first = shift();
    expect(SubtleMovement.offsetAt(h.wall.now), isNot(Offset.zero));
    expect(first - still, SubtleMovement.offsetAt(h.wall.now));

    // Same minute: no movement.
    h.wall.advance(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(shift(), first);

    // Next minute: moves gently over about a second.
    final from = SubtleMovement.offsetAt(h.wall.now);
    h.wall.now = DateTime(2026, 9, 29, 9, 42);
    await tester.pump(const Duration(seconds: 1));
    final to = SubtleMovement.offsetAt(h.wall.now);
    expect(to, isNot(from));
    await tester.pump(const Duration(milliseconds: 500));
    final mid = shift();
    expect(mid, isNot(first));
    await tester.pump(const Duration(seconds: 1));
    expect(shift() - first, to - from);
    for (var m = 0; m < 24 * 60; m++) {
      final o = SubtleMovement.offsetAt(DateTime(2026, 1, 1, 0, m));
      expect(o.dx.abs() <= SubtleMovement.maxShift, isTrue);
      expect(o.dy.abs() <= SubtleMovement.maxShift, isTrue);
    }

    // Turning it off, or leaving full screen, stops it and re-centres at
    // once; the clock does not move again in later minutes.
    await h.settings.update(h.settings.state.copyWith(subtleMovement: false));
    await tester.pump();
    expect(moving(), isFalse);
    expect(shift(), still);
    await h.settings.update(h.settings.state.copyWith(subtleMovement: true));
    await tester.pump();
    expect(moving(), isTrue);
    await h.full.exit();
    await tester.pump();
    expect(moving(), isFalse);
    expect(shift(), still);
    h.wall.now = DateTime(2026, 9, 29, 9, 43);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(shift(), still);
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });

  testWidgets('subtle movement jumps with reduced motion and never overflows', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(200, 100)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final h = Harness();
    await h.settings.update(const ClockSettings(subtleMovement: true));
    h.full.value.value = true;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: h.screen(),
      ),
    );
    expect(
      tester.widget<SubtleMovement>(find.byType(SubtleMovement)).enabled,
      isTrue,
    );
    expect(tester.takeException(), isNull);
    final before = tester.getTopLeft(find.byType(FlipDisplay));
    h.wall.now = DateTime(2026, 9, 29, 9, 42);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(
      tester.getTopLeft(find.byType(FlipDisplay)),
      isNot(before),
      reason: 'jumped without animating',
    );
    await h.dispose(tester);
  });

  testWidgets('compact windows keep every mode tab and never overflow', (
    tester,
  ) async {
    for (final size in const [Size(360, 640), Size(640, 360), Size(200, 100)]) {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      final h = Harness();
      await tester.pumpWidget(h.screen());
      await showChrome(tester);
      expect(tester.takeException(), isNull, reason: '$size');
      expect(find.text(strings.clock.stopwatch), findsOne, reason: '$size');
      await h.dispose(tester);
    }
    tester.view.reset();
  });

  testWidgets('wake lock follows setting, lifecycle and screen visibility', (
    tester,
  ) async {
    final h = Harness();
    await tester.pumpWidget(h.screen());
    expect(h.wake.calls, [false]);
    await h.settings.update(const ClockSettings(keepAwake: true));
    await tester.pump();
    expect(h.wake.calls.last, isTrue);

    await h.countdown.start(const Duration(seconds: 5));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    expect(h.wake.calls.last, isFalse);
    h.wall.advance(const Duration(seconds: 10));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(h.wake.calls.last, isTrue);
    expect(h.countdown.state.status, CountdownStatus.finished);

    await tester.pumpWidget(const SizedBox());
    expect(h.wake.calls.last, isFalse);
    await h.dispose(tester);
  });

  testWidgets('init loads the selected tick ahead while the tick is on', (
    tester,
  ) async {
    final sound = FakeSound();
    di
      ..register<KeyValueStore>(
        FakeStore()
          ..data[SettingsRepositoryImp.settingsKey] =
              '{"flipSound":true,"tickSound":"clockwork"}',
      )
      ..register<LocalAlerts>(FakeAlerts())
      ..register<SoundPlayer>(sound)
      ..register<OrientationLock>(FakeOrientation())
      ..register<FullScreenController>(FakeFullScreen());
    await flip_clock.init();
    expect(sound.warmed, [TickSound.clockwork], reason: 'warmed at start');
    final settings = di.get<SettingsController>();
    Future<void> change(ClockSettings Function(ClockSettings) edit) async {
      await settings.update(edit(settings.state));
      await tester.pump();
    }

    await change((s) => s.copyWith(tickSound: TickSound.digital));
    await change((s) => s.copyWith(use24h: !(s.use24h ?? false)));
    await change((s) => s.copyWith(flipSound: false));
    await change((s) => s.copyWith(tickSound: TickSound.woodblock));
    expect(sound.warmed, [
      TickSound.clockwork,
      TickSound.digital,
    ], reason: 'a new sound warms; other fields and a silent tick do not');
    await change((s) => s.copyWith(flipSound: true));
    expect(sound.warmed.last, TickSound.woodblock, reason: 'turning it on');
    expect(sound.ticks, isEmpty, reason: 'warming plays nothing');
  });

  test('shortcut groups follow the platform and the shortest side', () {
    for (final (platform, side, touch, keyboard) in [
      (TargetPlatform.iOS, 393.0, true, false), // iPhone, and web on one
      (TargetPlatform.android, 599.0, true, false),
      (TargetPlatform.iOS, 600.0, true, true), // iPad mini and up
      (TargetPlatform.android, 800.0, true, true),
      (TargetPlatform.macOS, 393.0, false, true),
      (TargetPlatform.windows, 1080.0, false, true),
      (TargetPlatform.linux, 1080.0, false, true),
    ]) {
      expect(FlipClockRouter.shortcutsFor(platform, side), (
        touch: touch,
        keyboard: keyboard,
      ), reason: '$platform at $side');
    }
  });

  testWidgets('the settings route passes the shortcut groups, on resize too', (
    tester,
  ) async {
    di
      ..register<KeyValueStore>(FakeStore())
      ..register<LocalAlerts>(FakeAlerts())
      ..register<SoundPlayer>(FakeSound())
      ..register<FullScreenController>(FakeFullScreen())
      ..register<ScreenWake>(FakeWake())
      ..register<OrientationLock>(FakeOrientation())
      ..register<ScreenBrightness>(FakeScreenBrightness());
    await flip_clock.init();
    // defaultTargetPlatform is iOS on an iPhone, in the app or a browser.
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    tester.view
      ..physicalSize = const Size(393, 852)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: FlipClockRouter.settings,
      routes: const FlipClockRouter().routes,
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    SettingsScreen screen() =>
        tester.widget<SettingsScreen>(find.byType(SettingsScreen));
    expect(
      (screen().touchShortcuts, screen().keyboardShortcuts),
      (true, false),
    );
    // Turned into an iPad-sized window: keys join the touch gestures.
    tester.view.physicalSize = const Size(820, 1180);
    await tester.pumpAndSettle();
    expect((screen().touchShortcuts, screen().keyboardShortcuts), (true, true));
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    tester.view.physicalSize = const Size(1280, 800);
    await tester.pumpAndSettle();
    expect(
      (screen().touchShortcuts, screen().keyboardShortcuts),
      (false, true),
    );
    debugDefaultTargetPlatformOverride = null;
    await tester.pumpWidget(const SizedBox());
    unawaited(di.reset());
    await tester.pump();
  });

  testWidgets('init registers everything; routes open settings and back', (
    tester,
  ) async {
    final store = FakeStore()
      ..data[SettingsRepositoryImp.settingsKey] =
          '{"theme":"light","orientation":"landscape"}';
    final orientation = FakeOrientation();
    di
      ..register<KeyValueStore>(store)
      ..register<LocalAlerts>(FakeAlerts())
      ..register<SoundPlayer>(FakeSound())
      ..register<FullScreenController>(FakeFullScreen())
      ..register<ScreenWake>(FakeWake())
      ..register<OrientationLock>(orientation)
      ..register<ScreenBrightness>(FakeScreenBrightness());
    await flip_clock.init();
    expect(di.has<SettingsRepository>(), isTrue);
    expect(di.has<CountdownController>(), isTrue);
    expect(flip_clock.appearance().value, AppearanceMode.light);
    expect(flip_clock.appFace().value, isNull);

    // The saved orientation applies at start, then follows each change.
    expect(orientation.calls, [ScreenOrientation.landscape]);
    final prefs = di.get<SettingsController>();
    await prefs.update(
      prefs.state.copyWith(orientation: ClockOrientation.portrait),
    );
    await prefs.update(
      prefs.state.copyWith(orientation: ClockOrientation.auto),
    );
    await tester.pump();
    expect(orientation.calls, [
      ScreenOrientation.landscape,
      ScreenOrientation.portrait,
      ScreenOrientation.auto,
    ]);

    // Settings reach the countdown: turning system alerts on mid-countdown
    // schedules its alert, turning them off cancels it.
    final countdown = di.get<CountdownController>();
    final alerts = di.get<LocalAlerts>() as FakeAlerts;
    final settings = di.get<SettingsController>();
    await countdown.start(const Duration(seconds: 5));
    expect(alerts.scheduled, isEmpty);
    await settings.setSystemAlerts(true);
    await tester.pump();
    expect(alerts.scheduled, contains(CountdownController.alertId));
    await settings.setSystemAlerts(false);
    await tester.pump();
    expect(alerts.scheduled, isEmpty);
    await countdown.reset();

    const make = FlipClockRouter.new;
    final router = GoRouter(
      initialLocation: FlipClockRouter.home,
      routes: make().routes,
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: theme, routerConfig: router),
    );
    await showChrome(tester);
    expect(find.byType(FlipDisplay), findsOne);
    await tester.tap(action(strings.clock.action_settings));
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.path,
      FlipClockRouter.settings,
    );
    expect(find.byType(SettingsScreen), findsOne);
    // Appearance > View all opens the Skins sheet over Settings.
    await tester.tap(find.text(strings.clock.skins_view_all));
    await tester.pumpAndSettle();
    expect(find.byType(SkinPicker), findsOne);
    // The sheet's Done sits above Settings' own.
    await tester.tap(find.text(strings.clock.skins_done).last);
    await tester.pumpAndSettle();
    // The strip's selected tile opens the customizer on that skin.
    await tester.tap(find.text(strings.clock.skins_customize).first);
    await tester.pumpAndSettle();
    expect(find.byType(SkinCustomizer), findsOne);
    await tester.tap(
      find.text(
        MaterialLocalizations.of(
          tester.element(find.byType(SkinCustomizer)),
        ).cancelButtonLabel,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.generic.done));
    await tester.pumpAndSettle();
    expect(find.byType(FlipClockScreen), findsOne);
    // The Pomodoro tray's tune icon opens Settings on Timers.
    await modeTab(tester, strings.clock.mode_pomodoro);
    await tester.pumpAndSettle();
    await tester.tap(action(strings.clock.action_timer_settings));
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.toString(),
      FlipClockRouter.timerSettings,
    );
    expect(
      tester.widget<SettingsScreen>(find.byType(SettingsScreen)).category,
      'timers',
    );
    expect(find.text(strings.clock.timers_presets.toUpperCase()), findsOne);
    await tester.tap(find.text(strings.generic.done));
    await tester.pumpAndSettle();
    expect(find.byType(FlipClockScreen), findsOne);

    // With a sync, ?category=account opens the Account page and the app's
    // callbacks get the route's context.
    final cloud = FakeCloudSync();
    final calls = <String>[];
    final accountRouter = GoRouter(
      initialLocation: FlipClockRouter.accountSettings,
      routes: FlipClockRouter(
        sync: cloud,
        onSignIn: (context) => calls.add('in ${context.mounted}'),
        onSignOut: (context) async => calls.add('out'),
        onDeleteAccount: (context) async {
          calls.add('delete');
          return AccountDeletion.needsSignIn;
        },
      ).routes,
    );
    addTearDown(accountRouter.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: theme, routerConfig: accountRouter),
    );
    await tester.pumpAndSettle();
    final screen = tester.widget<SettingsScreen>(find.byType(SettingsScreen));
    expect(screen.category, 'account');
    expect(screen.sync, same(cloud));
    expect(find.text(strings.sync.sign_in), findsOne);
    screen.onSignIn!();
    await screen.onSignOut!();
    expect(await screen.onDeleteAccount!(), AccountDeletion.needsSignIn);
    expect(calls, ['in true', 'out', 'delete']);
    await tester.pumpWidget(const SizedBox());
    unawaited(di.reset());
    await tester.pump();
  });

  testWidgets('the palette opens skins; the ground follows the skin', (
    tester,
  ) async {
    final h = Harness();
    await tester.pumpWidget(h.screen());
    await showChrome(tester);
    Color ground() =>
        tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor!;
    expect(ground(), DesignSkinColors.bgInk);
    await tester.tap(action(strings.clock.action_skins));
    await tester.pumpAndSettle();
    expect(find.byType(SkinPicker), findsOne);
    final paper = find.widgetWithText(SkinTile, strings.clock.skin_paper);
    await tester.ensureVisible(paper);
    await tester.pumpAndSettle();
    await tester.tap(paper);
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.clock.skins_done));
    await tester.pumpAndSettle();
    expect(h.settings.state.skinId, 'paper');
    expect(ground(), DesignSkinColors.bgPaper);
    await h.dispose(tester);
  });

  testWidgets('a skin with the date line shows it without the setting', (
    tester,
  ) async {
    final h = Harness();
    await h.settings.saveSkin(
      const Skin(id: '', name: 'Dated', showDate: true),
    );
    await tester.pumpWidget(h.screen());
    final date = MaterialLocalizations.of(
      tester.element(find.byType(FlipClockScreen)),
    ).formatFullDate(h.wall.now);
    expect(find.text(date), findsOne);
    await h.dispose(tester);
  });

  group('gestures', () {
    IslandHud? hudOf(WidgetTester tester) =>
        tester.widget<Island>(find.byType(Island)).hud;

    testWidgets('Up/Down change the device brightness in 10% steps', (
      tester,
    ) async {
      final h = Harness();
      await tester.pumpWidget(h.screen());
      await key(tester, LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(h.brightness.level, closeTo(0.6, 1e-9));
      final hud = hudOf(tester)! as IslandBrightnessHud;
      expect(hud.label, strings.clock.brightness_value('60'));
      await key(tester, LogicalKeyboardKey.arrowDown);
      await key(tester, LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(h.brightness.level, closeTo(0.4, 1e-9));
      // In-app dimming untouched while the device is driven.
      expect(h.settings.state.digitBrightness, 1.0);
      // The HUD goes 1.2 s after the last change.
      await tester.pump(DesignMotion.hudHold);
      expect(hudOf(tester), isNull);
      await h.dispose(tester);
      expect(h.brightness.calls.last, 'reset');
    });

    testWidgets('a vertical drag changes the device brightness', (
      tester,
    ) async {
      final h = Harness();
      await tester.pumpWidget(h.screen());
      await tester.dragFrom(const Offset(100, 100), const Offset(0, 300));
      await tester.pump();
      // Down by half the 600px height: 0.5 - 0.5.
      expect(h.brightness.level, closeTo(0.0, 0.02));
      expect(hudOf(tester), isA<IslandBrightnessHud>());
      await tester.pump(DesignMotion.hudHold);
      expect(hudOf(tester), isNull);
      await h.dispose(tester);
    });

    testWidgets(
      'the readout clears even when brightness lands after the drag',
      (tester) async {
        final h = Harness()..brightness.hold = Completer<void>();
        await tester.pumpWidget(h.screen());
        await tester.dragFrom(const Offset(100, 100), const Offset(0, 300));
        await tester.pump();
        // The finger is up; the platform answers only now.
        h.brightness.hold!.complete();
        h.brightness.hold = null;
        await tester.pump();
        await tester.pump();
        expect(hudOf(tester), isA<IslandBrightnessHud>());
        await tester.pump(DesignMotion.hudHold);
        expect(hudOf(tester), isNull);
        await h.dispose(tester);
      },
    );

    testWidgets('where the device cannot, the drag dims the digits', (
      tester,
    ) async {
      final h = Harness(brightness: FakeScreenBrightness(supported: false));
      await tester.pumpWidget(h.screen());
      // Down by most of the height: clamps at the 20% floor.
      await tester.dragFrom(const Offset(100, 100), const Offset(0, 490));
      await tester.pump();
      expect(h.settings.state.digitBrightness, ClockSettings.minBrightness);
      expect(h.brightness.calls, isEmpty);
      await tester.pumpAndSettle();
      await h.dispose(tester);
    });

    /// Pumps 16 ms frames across the island morph: in every frame the
    /// island stays open, shows no HUD and is never shorter than its
    /// tabs-only height (the smaller of Clock's and Stopwatch's).
    Future<void> expectMorphInPlace(WidgetTester tester) async {
      const frame = Duration(milliseconds: 16);
      final island = find.byType(Island);
      for (var t = Duration.zero; t <= DesignMotion.islandMorph; t += frame) {
        await tester.pump(frame);
        expect(hudOf(tester), isNull, reason: '$t');
        expect(chromeOf(tester), ChromeState.expanded, reason: '$t');
        expect(
          tester.getSize(island).height,
          greaterThanOrEqualTo(DesignSize.islandExpandedHeight),
          reason: '$t',
        );
      }
    }

    testWidgets('a swipe changes mode in the open island, no HUD', (
      tester,
    ) async {
      final h = Harness();
      await h.settings.update(
        const ClockSettings(lastMode: ClockMode.stopwatch),
      );
      await tester.pumpWidget(h.screen());
      await showChrome(tester);
      await tester.pumpAndSettle();
      await tester.dragFrom(const Offset(200, 300), const Offset(400, 0));
      await expectMorphInPlace(tester);
      expect(h.settings.state.lastMode, ClockMode.clock);
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(Island)).height,
        DesignSize.islandExpandedHeight,
      );
      expect(tester.widget<Island>(find.byType(Island)).selected, 1);
      await h.dispose(tester);
    });

    testWidgets('a swipe that springs back changes nothing', (tester) async {
      final h = Harness();
      await tester.pumpWidget(h.screen());
      await tester.pumpAndSettle();
      final before = h.settings.state;
      await tester.dragFrom(const Offset(600, 300), const Offset(-100, 0));
      await tester.pump();
      expect(hudOf(tester), isNull);
      await tester.pumpAndSettle();
      expect(h.settings.state, same(before));
      await h.dispose(tester);
    });

    testWidgets('Left/Right change mode in the open island, no HUD', (
      tester,
    ) async {
      final h = Harness();
      await tester.pumpWidget(h.screen());
      await showChrome(tester);
      await tester.pumpAndSettle();
      await key(tester, LogicalKeyboardKey.arrowRight);
      await expectMorphInPlace(tester);
      expect(h.settings.state.lastMode, ClockMode.stopwatch);
      await key(tester, LogicalKeyboardKey.arrowLeft);
      await expectMorphInPlace(tester);
      expect(h.settings.state.lastMode, ClockMode.clock);
      await h.dispose(tester);
    });

    testWidgets('swipes and drags can be switched off', (tester) async {
      final h = Harness();
      await h.settings.update(
        const ClockSettings(gestureModes: false, gestureBrightness: false),
      );
      await tester.pumpWidget(h.screen());
      await tester.dragFrom(const Offset(600, 300), const Offset(-400, 0));
      await tester.dragFrom(const Offset(100, 100), const Offset(0, 300));
      await tester.pumpAndSettle();
      expect(h.settings.state.lastMode, ClockMode.clock);
      expect(h.brightness.calls, isEmpty);
      await h.dispose(tester);
    });

    testWidgets('gestures are off while a sheet covers the clock', (
      tester,
    ) async {
      final h = Harness();
      await tester.pumpWidget(h.screen());
      await showChrome(tester);
      await tester.tap(action(strings.clock.action_skins));
      await tester.pumpAndSettle();
      final layer = tester.widget<GestureLayer>(find.byType(GestureLayer));
      expect(layer.enabled, isFalse);
      await h.dispose(tester);
    });

    testWidgets('double tap toggles full screen where offered', (tester) async {
      final h = Harness();
      await tester.pumpWidget(h.screen(doubleTap: true));
      await tester.tapAt(const Offset(400, 300));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(const Offset(400, 300));
      await tester.pumpAndSettle();
      expect(h.full.toggles, 1);
      await h.dispose(tester);
    });

    testWidgets('with reduced motion the panel jumps', (tester) async {
      final h = Harness();
      await tester.pumpWidget(h.screen(reduceMotion: true));
      await key(tester, LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(find.bySemanticsLabel(stopwatchZero), findsOne);
      await h.dispose(tester);
    });

    testWidgets('Left/Right stop at the ends: no wrap', (tester) async {
      final h = Harness();
      await h.settings.update(
        const ClockSettings(lastMode: ClockMode.pomodoro),
      );
      await tester.pumpWidget(h.screen());
      await modeKey(tester, LogicalKeyboardKey.arrowLeft);
      expect(h.settings.state.lastMode, ClockMode.pomodoro);
      for (var i = 0; i < 5; i++) {
        await modeKey(tester, LogicalKeyboardKey.arrowRight);
      }
      expect(h.settings.state.lastMode, ClockMode.stopwatch);
      await h.dispose(tester);
    });

    testWidgets('backgrounding returns the device to its brightness', (
      tester,
    ) async {
      final h = Harness();
      await tester.pumpWidget(h.screen());
      await key(tester, LogicalKeyboardKey.arrowDown);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(h.brightness.calls, contains('reset'));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      await h.dispose(tester);
    });
  });

  group('mode stays put', () {
    /// Watches the clock long enough for the chrome to go dot, then hidden.
    Future<void> idle(WidgetTester tester) async {
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
    }

    /// The panel on screen and the island's tab agree on [mode].
    void expectMode(WidgetTester tester, Harness h, ClockMode mode) {
      final pages = tester.widget<PageView>(find.byType(PageView)).controller!;
      expect(pages.page!.round(), mode.index, reason: 'panel');
      expect(h.settings.state.lastMode, mode, reason: 'saved mode');
      expect(
        tester.widget<Island>(find.byType(Island)).selected,
        mode.index,
        reason: 'island',
      );
    }

    Future<void> tabTo(WidgetTester tester, ClockMode mode) async {
      final c = strings.clock;
      final names = [c.mode_pomodoro, c.mode_clock, c.mode_stopwatch];
      await tester.tap(find.text(names[mode.index]));
      await tester.pump();
      await tester.pumpAndSettle();
    }

    testWidgets('Stopwatch by tab, Right key and swipe stays after idling', (
      tester,
    ) async {
      final ways = <String, Future<void> Function()>{
        'tab': () => tabTo(tester, ClockMode.stopwatch),
        'key': () => modeKey(tester, LogicalKeyboardKey.arrowRight),
        'swipe': () async {
          await tester.dragFrom(const Offset(600, 300), const Offset(-400, 0));
          await tester.pumpAndSettle();
        },
      };
      for (final MapEntry(key: way, value: go) in ways.entries) {
        final h = Harness();
        await tester.pumpWidget(h.screen());
        await showChrome(tester);
        expectMode(tester, h, ClockMode.clock);
        await go();
        expectMode(tester, h, ClockMode.stopwatch);
        await idle(tester);
        expect(chromeOf(tester), ChromeState.hidden, reason: way);
        expectMode(tester, h, ClockMode.stopwatch);
        expect(find.bySemanticsLabel(stopwatchZero), findsOne, reason: way);
        await h.dispose(tester);
      }
    });

    testWidgets('a running countdown stays on Pomodoro after idling', (
      tester,
    ) async {
      final h = Harness();
      await tester.pumpWidget(h.screen());
      await showChrome(tester);
      await tabTo(tester, ClockMode.pomodoro);
      await h.countdown.start(const Duration(minutes: 5));
      await tester.pump();
      await idle(tester);
      expectMode(tester, h, ClockMode.pomodoro);
      expect(
        find.bySemanticsLabel(strings.clock.time_remaining('00:05:00')),
        findsOne,
      );
      await h.countdown.reset();
      await tester.pumpAndSettle();
      await h.dispose(tester);
    });

    testWidgets('full screen with subtle movement, in and out, stays', (
      tester,
    ) async {
      final h = Harness();
      await h.settings.update(const ClockSettings(subtleMovement: true));
      await tester.pumpWidget(h.screen());
      await showChrome(tester);
      await tabTo(tester, ClockMode.stopwatch);
      await key(tester, LogicalKeyboardKey.keyF);
      expect(
        tester.widget<SubtleMovement>(find.byType(SubtleMovement)).enabled,
        isTrue,
      );
      expectMode(tester, h, ClockMode.stopwatch);
      await idle(tester);
      expectMode(tester, h, ClockMode.stopwatch);
      await key(tester, LogicalKeyboardKey.escape);
      expect(h.full.value.value, isFalse);
      expectMode(tester, h, ClockMode.stopwatch);
      await idle(tester);
      expectMode(tester, h, ClockMode.stopwatch);
      expect(find.bySemanticsLabel(stopwatchZero), findsOne);
      await tester.pumpAndSettle();
      await h.dispose(tester);
    });

    testWidgets('opening and closing the Skins sheet stays', (tester) async {
      final h = Harness();
      await tester.pumpWidget(h.screen());
      await showChrome(tester);
      await tabTo(tester, ClockMode.stopwatch);
      await tester.tap(action(strings.clock.action_skins));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.clock.skins_done));
      await tester.pumpAndSettle();
      expectMode(tester, h, ClockMode.stopwatch);
      await idle(tester);
      expectMode(tester, h, ClockMode.stopwatch);
      expect(find.bySemanticsLabel(stopwatchZero), findsOne);
      await h.dispose(tester);
    });

    testWidgets('Pomodoro and Stopwatch stay after idling too', (tester) async {
      for (final mode in [ClockMode.pomodoro, ClockMode.stopwatch]) {
        final h = Harness();
        await tester.pumpWidget(h.screen());
        await showChrome(tester);
        await tabTo(tester, mode);
        await idle(tester);
        expectMode(tester, h, mode);
        // Its own content, not the Clock's.
        expect(
          find.bySemanticsLabel(stopwatchZero),
          findsExactly(mode == ClockMode.stopwatch ? 1 : 0),
        );
        expect(
          find.bySemanticsLabel(strings.clock.current_time('09:41')),
          findsNothing,
        );
        await h.dispose(tester);
      }
    });
  });

  group('flip sound only while the clock is seen', () {
    Future<void> minute(WidgetTester tester, Harness h) async {
      h.wall.advance(const Duration(minutes: 1));
      await tester.pump(const Duration(minutes: 1));
    }

    Future<Harness> withSound(WidgetTester tester) async {
      final h = Harness();
      await h.settings.update(const ClockSettings(flipSound: true));
      await tester.pumpWidget(h.screen());
      await minute(tester, h);
      expect(h.sound.flips, 1, reason: 'on screen: flips');
      return h;
    }

    testWidgets('off by default', (tester) async {
      expect(const ClockSettings().flipSound, isFalse);
      final h = Harness();
      await tester.pumpWidget(h.screen());
      await minute(tester, h);
      expect(h.sound.flips, 0);
      await tester.pumpAndSettle();
      await h.dispose(tester);
    });

    testWidgets('silent under the Skins sheet, flips again once closed', (
      tester,
    ) async {
      final h = await withSound(tester);
      // Idle for a minute: any key brings the island back.
      await key(tester, LogicalKeyboardKey.keyQ);
      await tester.pumpAndSettle();
      await tester.tap(action(strings.clock.action_skins));
      await tester.pumpAndSettle();
      await minute(tester, h);
      expect(h.sound.flips, 1);
      await tester.tap(find.text(strings.clock.skins_done));
      await tester.pumpAndSettle();
      await minute(tester, h);
      expect(h.sound.flips, 2);
      await tester.pumpAndSettle();
      await h.dispose(tester);
    });

    testWidgets('silent under a pushed route, flips again once popped', (
      tester,
    ) async {
      final h = await withSound(tester);
      final nav = Navigator.of(tester.element(find.byType(FlipClockScreen)));
      unawaited(
        nav.push(MaterialPageRoute<void>(builder: (_) => const SizedBox())),
      );
      await tester.pumpAndSettle();
      await minute(tester, h);
      expect(h.sound.flips, 1);
      nav.pop();
      await tester.pumpAndSettle();
      await minute(tester, h);
      expect(h.sound.flips, 2);
      await tester.pumpAndSettle();
      await h.dispose(tester);
    });

    testWidgets('silent while the app is away, flips again on resume', (
      tester,
    ) async {
      final h = await withSound(tester);
      for (final s in const [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(s);
      }
      await minute(tester, h);
      expect(h.sound.flips, 1);
      for (final s in const [
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(s);
      }
      await tester.pump();
      await minute(tester, h);
      expect(h.sound.flips, 2);
      await tester.pumpAndSettle();
      await h.dispose(tester);
    });
  });

  testWidgets('a tray action presses down without ink', (tester) async {
    final h = Harness();
    await h.settings.update(const ClockSettings(lastMode: ClockMode.stopwatch));
    await tester.pumpWidget(h.screen());
    await showChrome(tester);
    await tester.pumpAndSettle();
    await tester.tap(action(strings.clock.action_start));
    await tester.pump(const Duration(milliseconds: 50));
    expect(h.stopwatch.state.running, isTrue);
    expect(liveInk(tester), isEmpty);
    await h.dispose(tester);
  });

  for (final width in [375.0, 1280.0]) {
    testWidgets('the island is the only control, top centre ($width)', (
      tester,
    ) async {
      tester.view
        ..physicalSize = Size(width, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final h = Harness();
      await h.settings.update(
        const ClockSettings(lastMode: ClockMode.stopwatch),
      );
      await tester.pumpWidget(h.screen());
      await showChrome(tester);
      await tester.pumpAndSettle();
      final island = tester.getRect(find.byType(Island));
      expect(island.center.dy, lessThan(844 / 4));
      expect(island.center.dx, closeTo(width / 2, 0.5));
      // Every button on the screen is the island's or a corner button's.
      for (final type in [Pressable]) {
        final all = find.byType(type);
        int inside(Type owner) => find
            .descendant(of: find.byType(owner), matching: find.byType(type))
            .evaluate()
            .length;
        expect(
          all.evaluate().length,
          inside(Island) + inside(CornerButton),
          reason: '$type',
        );
      }
      // Skins top-left, Settings top-right, clear of the island; no
      // Rotation where the screen cannot be locked.
      final skins = tester.getRect(find.byTooltip(strings.clock.action_skins));
      final settings = tester.getRect(
        find.byTooltip(strings.clock.action_settings),
      );
      expect(skins.left, lessThan(width / 4));
      expect(settings.right, greaterThan(width * 3 / 4));
      expect(skins.top, settings.top);
      expect(skins.overlaps(island), isFalse);
      expect(settings.overlaps(island), isFalse);
      expect(find.byTooltip(strings.clock.action_rotation), findsNothing);
      // Tabs are laid out at full size (the callout line is 20px); the
      // painted size is checked with the real fonts under 'corner chrome'.
      expect(
        tester.getSize(find.text(strings.clock.mode_stopwatch)).height,
        closeTo(20, 0.5),
      );
      // The chrome floats over the clock: the digits centre in the panel,
      // nothing is reserved for the island.
      expect(
        tester.getCenter(find.byType(FlipDisplay)).dy,
        closeTo(tester.getCenter(find.byType(PageView)).dy, 1),
      );
      await h.dispose(tester);
    });
  }

  group('clock layout', () {
    bool stacked(WidgetTester tester, String a, String b) =>
        tester.getCenter(find.text(a).first).dy <
        tester.getCenter(find.text(b).first).dy - 1;

    for (final (size, stacks) in [
      (const Size(390, 844), true),
      (const Size(844, 390), false),
      // Near square: inside the band, it stays the row it starts as.
      (const Size(600, 640), false),
    ]) {
      for (final seconds in [false, true]) {
        testWidgets('${size.width}x${size.height} seconds $seconds: '
            '${stacks ? 'stacked' : 'one row'}', (tester) async {
          tester.view
            ..physicalSize = size
            ..devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final h = Harness();
          await h.settings.update(ClockSettings(showSeconds: seconds));
          await tester.pumpWidget(h.screen());
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(stacked(tester, '09', '41'), stacks);
          if (seconds) expect(stacked(tester, '41', '00'), stacks);
          await h.dispose(tester);
        });
      }
    }

    for (final side in [SkinMeridiem.left, SkinMeridiem.right]) {
      testWidgets('portrait 12h, AM/PM $side, text scale 2, all modes fit', (
        tester,
      ) async {
        tester.view
          ..physicalSize = const Size(390, 844)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final h = Harness();
        await h.settings.saveSkin(
          const Skin(id: '', name: 'Side').copyWith(meridiem: side),
        );
        await h.settings.update(
          h.settings.state.copyWith(use24h: false, showDate: true),
        );
        await tester.pumpWidget(h.screen());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(stacked(tester, '09', '41'), isTrue);
        expect(find.text('AM'), findsOne);
        for (final mode in [ClockMode.pomodoro, ClockMode.stopwatch]) {
          await h.settings.update(h.settings.state.copyWith(lastMode: mode));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '$mode');
        }
        await h.dispose(tester);
      });
    }

    testWidgets('with the date on, the digits still get the rest', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(844, 390)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final h = Harness();
      await h.settings.update(const ClockSettings(showDate: true));
      await tester.pumpWidget(h.screen());
      await tester.pumpAndSettle();
      // Height-limited cards fill down to the padding (space-4 on a
      // phone): the date takes its line, not half the panel.
      final panel = tester.getRect(find.byType(PageView));
      expect(
        tester.getRect(find.byType(FlipDisplay)).bottom,
        closeTo(panel.bottom - DesignSpace.s4, 1),
      );
      await h.dispose(tester);
    });

    testWidgets('the date sits above the time, space-6 apart, bottom free', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(800, 800)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final h = Harness();
      await h.settings.update(const ClockSettings(showDate: true));
      await tester.pumpWidget(h.screen());
      await tester.pumpAndSettle();
      final date = tester.getRect(
        find.text(
          MaterialLocalizations.of(
            tester.element(find.byType(FlipClockScreen)),
          ).formatFullDate(h.wall.now),
        ),
      );
      final display = tester.getRect(find.byType(FlipDisplay));
      expect(display.top - date.bottom, closeTo(DesignSpace.s6, 0.5));
      // Centred as one block in the free space: nothing parked below.
      final panel = tester.getRect(find.byType(PageView));
      // Width-limited cards leave room: the same padding (space-8) on
      // every side; the island floats over it, nothing is reserved for it.
      final above = date.top - (panel.top + DesignSpace.s8);
      final below = panel.bottom - DesignSpace.s8 - display.bottom;
      expect(below, greaterThan(0));
      expect(above, closeTo(below, 1));
      await h.dispose(tester);
    });
  });

  group('the clock fills the screen; the chrome floats over it', () {
    /// A phone window: [size] with its notch / home-bar [insets].
    void phone(
      WidgetTester tester,
      Size size, {
      double top = 0,
      double bottom = 0,
      double side = 0,
    }) {
      final insets = FakeViewPadding(
        left: side,
        top: top,
        right: side,
        bottom: bottom,
      );
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1
        ..padding = insets
        ..viewPadding = insets;
      addTearDown(tester.view.reset);
    }

    /// One card's height: a stack is [n] cards with space-6 between them.
    double cardHeight(WidgetTester tester, int n, {required bool stacked}) {
      final display = tester.getSize(find.byType(FlipDisplay));
      return stacked
          ? (display.height - DesignSpace.s6 * (n - 1)) / n
          : display.height;
    }

    testWidgets('the display sits in the safe area centre in every mode', (
      tester,
    ) async {
      phone(tester, const Size(393, 852), top: 59, bottom: 34);
      // The safe area: 393 x 759 from y 59.
      const centre = Offset(393 / 2, 59 + 759 / 2);
      final h = Harness();
      await h.settings.update(const ClockSettings(showSeconds: true));
      await tester.pumpWidget(h.screen(orientationSupported: true));
      await showChrome(tester);
      await tester.pumpAndSettle();
      for (final mode in ClockMode.values) {
        await h.settings.update(h.settings.state.copyWith(lastMode: mode));
        await tester.pump();
        await tester.pump(DesignMotion.islandMorph);
        expect(chromeOf(tester), ChromeState.expanded);
        final open = tester.getCenter(find.byType(FlipDisplay));
        expect(open.dx, closeTo(centre.dx, 1), reason: '$mode expanded');
        expect(open.dy, closeTo(centre.dy, 1), reason: '$mode expanded');
        await tester.pump(const Duration(seconds: 8));
        await tester.pumpAndSettle();
        expect(chromeOf(tester), ChromeState.hidden);
        final hidden = tester.getCenter(find.byType(FlipDisplay));
        expect(hidden.dx, closeTo(centre.dx, 1), reason: '$mode hidden');
        expect(hidden.dy, closeTo(centre.dy, 1), reason: '$mode hidden');
        await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pumpAndSettle();
      }
      await h.dispose(tester);
    });

    for (final (name, size, insets, seconds, n, stacks, want) in [
      // The brief's table (226 / 351 / 339) leaves out SubtleMovement's
      // constant 16 px (8 a side, on or off), so each box is 16 px smaller.
      // Height-bound: 759 safe - 2 x 16 - 16, less two 24 gaps, over three.
      (
        'portrait H:M:S',
        const Size(393, 852),
        (top: 59.0, bottom: 34.0, side: 0.0),
        true,
        3,
        true,
        221.0,
      ),
      // The two-card stack is width-bound: 345, under (711 - 24) / 2.
      (
        'portrait H:M',
        const Size(393, 852),
        (top: 59.0, bottom: 34.0, side: 0.0),
        false,
        2,
        true,
        345.0,
      ),
      // Height-bound row: 393 - 21 - 2 x 16 - 16 (width allows 331).
      (
        'landscape H:M',
        const Size(852, 393),
        (top: 0.0, bottom: 21.0, side: 59.0),
        false,
        2,
        false,
        324.0,
      ),
    ]) {
      testWidgets('iPhone 15 Pro $name cards are about $want px', (
        tester,
      ) async {
        phone(
          tester,
          size,
          top: insets.top,
          bottom: insets.bottom,
          side: insets.side,
        );
        final h = Harness();
        await h.settings.update(ClockSettings(showSeconds: seconds));
        await tester.pumpWidget(h.screen(orientationSupported: true));
        await tester.pumpAndSettle();
        expect(cardHeight(tester, n, stacked: stacks), closeTo(want, 2));
        await h.dispose(tester);
      });
    }

    testWidgets('nothing moves as the chrome expands, collapses or hides', (
      tester,
    ) async {
      phone(tester, const Size(393, 852), top: 59, bottom: 34);
      final h = Harness();
      await h.settings.update(
        const ClockSettings(showSeconds: true, showDate: true),
      );
      await tester.pumpWidget(h.screen(orientationSupported: true));
      await showChrome(tester);
      await tester.pumpAndSettle();
      final date = find.text(
        MaterialLocalizations.of(
          tester.element(find.byType(FlipClockScreen)),
        ).formatFullDate(h.wall.now),
      );
      List<Rect> layout() => [
        tester.getRect(find.byType(FlipDisplay)),
        tester.getRect(date),
      ];
      final expanded = layout();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(chromeOf(tester), ChromeState.dot);
      expect(layout(), expanded);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(chromeOf(tester), ChromeState.hidden);
      expect(layout(), expanded);
      await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();
      expect(chromeOf(tester), ChromeState.expanded);
      expect(layout(), expanded);
      await h.dispose(tester);
    });

    for (final scale in const [1.0, 2.0]) {
      testWidgets('320 x 568 at text scale $scale fits, date included', (
        tester,
      ) async {
        phone(tester, const Size(320, 568), top: 20);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final h = Harness();
        await h.settings.update(
          const ClockSettings(showSeconds: true, showDate: true),
        );
        await tester.pumpWidget(h.screen(orientationSupported: true));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        // Inside the space-4 box in the safe area, the date above.
        final box = const Rect.fromLTRB(
          0,
          20,
          320,
          568,
        ).deflate(DesignSpace.s4);
        final display = tester.getRect(find.byType(FlipDisplay));
        final date = tester.getRect(
          find.text(
            MaterialLocalizations.of(
              tester.element(find.byType(FlipClockScreen)),
            ).formatFullDate(h.wall.now),
          ),
        );
        for (final r in [display, date]) {
          expect(box.inflate(0.5).contains(r.topLeft), isTrue, reason: '$r');
          expect(box.inflate(0.5).contains(r.bottomRight), isTrue);
        }
        expect(date.bottom, lessThanOrEqualTo(display.top));
        await h.dispose(tester);
      });
    }
  });

  testWidgets('the date and round label use the skin face', (tester) async {
    final h = Harness();
    await h.settings.saveSkin(
      const Skin(id: '', name: 'Orb', face: DisplayFace.orbitron),
    );
    await h.settings.update(h.settings.state.copyWith(showDate: true));
    await tester.pumpWidget(h.screen());
    await tester.runAsync(GoogleFonts.pendingFonts);
    await tester.pump();
    final date = MaterialLocalizations.of(
      tester.element(find.byType(FlipClockScreen)),
    ).formatFullDate(h.wall.now);
    TextStyle styleOf(String text) =>
        tester.widget<Text>(find.text(text)).style!;
    expect(styleOf(date).fontFamily, startsWith('Orbitron'));
    final text = Theme.of(tester.element(find.byType(FlipDisplay))).textTheme;
    expect(styleOf(date).fontSize, text.headlineSmall!.fontSize);

    await h.settings.update(
      h.settings.state.copyWith(lastMode: ClockMode.pomodoro),
    );
    await h.countdown.startPomodoro();
    await tester.pumpAndSettle();
    final round = styleOf(strings.clock.pomodoro_focus(1));
    expect(round.fontFamily, startsWith('Orbitron'));
    expect(round.fontSize, text.titleLarge!.fontSize);
    await h.countdown.reset();
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });

  testWidgets('Mono ground follows the theme; Paper keeps its own', (
    tester,
  ) async {
    Color ground() =>
        tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor!;
    final light = theme.copyWith(extensions: const [DesignColors.light]);
    final black = theme.copyWith(extensions: const [DesignColors.dark]);
    for (final (skin, want) in [
      ('mono', (DesignColors.light.bg, DesignColors.dark.bg)),
      ('paper', (DesignSkinColors.bgPaper, DesignSkinColors.bgPaper)),
    ]) {
      final h = Harness();
      await h.settings.selectSkin(skin);
      await tester.pumpWidget(h.screen(appTheme: light));
      expect(ground(), want.$1, reason: '$skin light');
      // A fresh tree: the design system's island cannot animate
      // their shadow between two themes mid-flight.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(h.screen(appTheme: black));
      expect(ground(), want.$2, reason: '$skin black');
      await h.dispose(tester);
    }
  });

  testWidgets('card size scales every display on the screen', (tester) async {
    for (final mode in ClockMode.values) {
      final heights = <CardSize, double>{};
      for (final size in [CardSize.large, CardSize.medium]) {
        final h = Harness();
        await h.settings.update(ClockSettings(lastMode: mode, cardSize: size));
        if (mode == ClockMode.pomodoro) {
          await h.countdown.start(const Duration(minutes: 5));
        }
        await tester.pumpWidget(h.screen());
        await tester.pump();
        final display = find.byType(FlipDisplay);
        expect(tester.widget<FlipDisplay>(display).size, size.factor);
        final card = find.descendant(
          of: display,
          matching: find.byWidgetPredicate(
            (w) => w.runtimeType.toString() == '_FlipCard',
          ),
        );
        heights[size] = tester.getSize(card.first).height;
        await h.countdown.reset();
        await tester.pumpAndSettle();
        await h.dispose(tester);
      }
      expect(
        heights[CardSize.medium]! / heights[CardSize.large]!,
        closeTo(0.8, 0.01),
        reason: '$mode',
      );
    }
  });

  testWidgets('a mouse click toggles the chrome like a tap', (tester) async {
    final h = Harness();
    await tester.pumpWidget(h.screen());
    await tester.pump(const Duration(seconds: 8));
    expect(chromeOf(tester), ChromeState.hidden);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(400, 350));
    // Moving there shows it (desktop discoverability)...
    await mouse.moveTo(const Offset(410, 360));
    await tester.pump();
    expect(chromeOf(tester), ChromeState.expanded);
    // ...and a click in the same motion does not hide it again.
    await mouse.down(const Offset(410, 360));
    await mouse.up();
    await tester.pump();
    expect(chromeOf(tester), ChromeState.expanded);
    // Later clicks toggle both ways.
    await tester.pump(ChromeController.hoverGrace);
    await mouse.down(const Offset(410, 360));
    await mouse.up();
    await tester.pump();
    expect(chromeOf(tester), ChromeState.hidden);
    await mouse.down(const Offset(410, 360));
    await mouse.up();
    await tester.pump();
    expect(chromeOf(tester), ChromeState.expanded);
    // A touch tap toggles too.
    await tester.tapAt(const Offset(400, 350));
    await tester.pump();
    expect(chromeOf(tester), ChromeState.hidden);
    await mouse.removePointer();
    await h.dispose(tester);
  });

  testWidgets('island actions are legible on every skin in both themes', (
    tester,
  ) async {
    final themes = {
      'dark': theme.copyWith(extensions: const [DesignColors.dark]),
      'light': ThemeData(
        colorScheme: DesignSystem.monoLightScheme(),
        extensions: const [DesignColors.light],
      ),
    };
    final failures = <String>[];
    for (final MapEntry(key: name, value: t) in themes.entries) {
      for (final skin in Skins.builtIn()) {
        final h = Harness();
        await h.settings.update(
          ClockSettings(skinId: skin.id, lastMode: ClockMode.pomodoro),
        );
        await tester.pumpWidget(h.screen(appTheme: t));
        await showChrome(tester);
        void check(String state) {
          final island = find.byType(Island);
          // The selected tab's pill is drawn behind the label, not around it.
          final pill = find.descendant(
            of: find.byType(AnimatedPositionedDirectional),
            matching: find.byType(DecoratedBox),
          );
          final pillRect = tester.getRect(pill);
          final pillColor =
              (tester.widget<DecoratedBox>(pill).decoration as BoxDecoration)
                  .color!;
          Color backdrop(Element e) =>
              pillRect.contains(
                tester.getRect(find.byElementPredicate((x) => x == e)).center,
              )
              ? pillColor
              : backdropOfElement(e);
          for (final e in [
            ...find
                .descendant(of: island, matching: find.byType(Icon))
                .evaluate(),
            ...find
                .descendant(of: island, matching: find.byType(Text))
                .evaluate(),
          ]) {
            final w = e.widget;
            final ink = w is Icon ? w.color! : (w as Text).style!.color!;
            final ratio = contrastOf(ink, backdrop(e));
            if (ratio < 4.5) failures.add('$name/${skin.id}/$state $w $ratio');
          }
        }

        check('idle');
        await h.countdown.start(const Duration(minutes: 1));
        await tester.pumpAndSettle();
        check('running');
        await h.countdown.pause();
        await tester.pumpAndSettle();
        check('paused');
        await h.countdown.reset();
        await tester.pumpAndSettle();
        await h.dispose(tester);
      }
    }
    expect(failures, isEmpty);
  });

  group('corner chrome', () {
    final c = strings.clock;
    ChromeState cornerOf(WidgetTester tester, String tooltip) => tester
        .widget<CornerButton>(
          find.ancestor(
            of: find.byTooltip(tooltip),
            matching: find.byType(CornerButton),
          ),
        )
        .state;

    testWidgets('Skins and Settings follow the island, frame for frame', (
      tester,
    ) async {
      final h = Harness();
      await tester.pumpWidget(h.screen(orientationSupported: true));
      await showChrome(tester);
      await tester.pumpAndSettle();
      for (final (expected, wait) in [
        (ChromeState.expanded, DesignMotion.controlsIdle),
        (ChromeState.dot, DesignMotion.dotIdle),
        (ChromeState.hidden, Duration.zero),
      ]) {
        expect(chromeOf(tester), expected);
        for (final t in [
          c.action_skins,
          c.action_settings,
          c.action_rotation,
        ]) {
          expect(cornerOf(tester, t), expected, reason: '$t $expected');
        }
        await tester.pump(wait);
        await tester.pump();
      }
      await h.dispose(tester);
    });

    for (final (width, below) in [
      (390.0, true),
      (599.0, true),
      (600.0, false),
      (1280.0, false),
    ]) {
      testWidgets('at ${width}px the island is full size, '
          '${below ? 'below' : 'between'} the corner buttons', (tester) async {
        tester.view
          ..physicalSize = Size(width, 844)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final h = Harness();
        // The real theme and fonts, so the painted size is the real one.
        await tester.pumpWidget(
          DesignSystemWrapper(
            mode: AppearanceMode.black,
            builder: (_, t) => h.screen(appTheme: t),
          ),
        );
        await showChrome(tester);
        await tester.runAsync(GoogleFonts.pendingFonts);
        await tester.pumpAndSettle();
        final island = tester.getRect(find.byType(Island));
        final skins = tester.getRect(find.byTooltip(c.action_skins));
        final settings = tester.getRect(find.byTooltip(c.action_settings));
        // Painted, not just laid out: never scaled down to squeeze in.
        final tab = find
            .ancestor(
              of: find.text(c.mode_clock),
              matching: find.byType(Pressable),
            )
            .first;
        expect(
          tester.getRect(tab).height,
          closeTo(DesignSize.cornerButton, 0.5),
        );
        expect(island.center.dx, closeTo(width / 2, 0.5));
        expect(skins.top, settings.top);
        if (below) {
          expect(island.top, closeTo(skins.bottom + DesignSpace.s2, 0.5));
        } else {
          expect(island.top, skins.top);
          expect(skins.right, lessThanOrEqualTo(island.left));
          expect(settings.left, greaterThanOrEqualTo(island.right));
        }
        // The island floats over the clock, which stays centred.
        expect(
          tester.getCenter(find.byType(FlipDisplay)).dy,
          closeTo(tester.getCenter(find.byType(PageView)).dy, 1),
        );
        await h.dispose(tester);
      });
    }

    testWidgets('a corner tap is the button\'s own, never a chrome toggle', (
      tester,
    ) async {
      final h = Harness();
      await tester.pumpWidget(h.screen());
      await showChrome(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(c.action_settings));
      await tester.pump();
      expect(h.settingsOpened, 1);
      expect(chromeOf(tester), ChromeState.expanded);
      await tester.tap(find.byTooltip(c.action_skins));
      await tester.pumpAndSettle();
      expect(find.text(c.skins_title), findsOne);
      await h.dispose(tester);
    });

    testWidgets('Rotation cycles auto, portrait, landscape and says so', (
      tester,
    ) async {
      final h = Harness();
      await tester.pumpWidget(h.screen(orientationSupported: true));
      await showChrome(tester);
      await tester.pumpAndSettle();
      final rotation = find.byTooltip(c.action_rotation);
      // Bottom right.
      final box = tester.getRect(rotation);
      final screen = tester.getRect(find.byType(FlipClockScreen));
      expect(box.right, greaterThan(screen.width * 3 / 4));
      expect(box.bottom, greaterThan(screen.height * 3 / 4));
      expect(find.byIcon(Icons.screen_rotation_outlined), findsOne);
      final semantics = tester.ensureSemantics();
      // The button speaks its current rotation, and says the new one.
      final button = find.ancestor(
        of: rotation,
        matching: find.byType(CornerButton),
      );
      expect(
        tester.getSemantics(button),
        isSemantics(
          label: c.action_rotation,
          value: c.orientation_auto,
          isButton: true,
          isLiveRegion: true,
        ),
      );
      for (final (orientation, name, icon) in [
        (
          ClockOrientation.portrait,
          c.orientation_portrait,
          Icons.stay_current_portrait_outlined,
        ),
        (
          ClockOrientation.landscape,
          c.orientation_landscape,
          Icons.stay_current_landscape_outlined,
        ),
        (
          ClockOrientation.auto,
          c.orientation_auto,
          Icons.screen_rotation_outlined,
        ),
      ]) {
        await tester.tap(rotation);
        await tester.pump();
        expect(h.settings.state.orientation, orientation);
        expect(find.byIcon(icon), findsOne);
        expect(
          tester.getSemantics(button),
          isSemantics(value: name, isLiveRegion: true),
        );
        // No HUD; the tap was the button's: the open island stays.
        final island = tester.widget<Island>(find.byType(Island));
        expect(island.hud, isNull);
        expect(island.state, ChromeState.expanded);
      }
      // R cycles too, also without a HUD.
      await key(tester, LogicalKeyboardKey.keyR);
      expect(h.settings.state.orientation, ClockOrientation.portrait);
      expect(tester.widget<Island>(find.byType(Island)).hud, isNull);
      semantics.dispose();
      await h.dispose(tester);
    });

    testWidgets('no Rotation and no R where the screen cannot be locked', (
      tester,
    ) async {
      final h = Harness();
      await tester.pumpWidget(h.screen());
      await tester.pumpAndSettle();
      expect(find.byTooltip(c.action_rotation), findsNothing);
      await key(tester, LogicalKeyboardKey.keyR);
      expect(h.settings.state.orientation, ClockOrientation.auto);
      await h.dispose(tester);
    });
  });

  group('island tray', () {
    final c = strings.clock;

    testWidgets('each mode and state offers its own actions', (tester) async {
      final h = Harness();
      const ninety = Duration(seconds: 90);
      await h.settings.update(
        const ClockSettings().copyWith(
          timerPresets: [...ClockSettings.defaultTimerPresets, ninety],
        ),
      );
      await tester.pumpWidget(h.screen());
      await showChrome(tester);
      expect(trayOf(tester), [], reason: 'clock');

      await h.settings.update(
        h.settings.state.copyWith(lastMode: ClockMode.pomodoro),
      );
      await tester.pumpAndSettle();
      expect(trayOf(tester), [
        c.action_start,
        c.preset_pomodoro,
        // Ascending: 90 s first.
        '1:30',
        '5m',
        '10m',
        '15m',
        c.action_timer_settings,
      ]);
      await h.countdown.start(ninety);
      await tester.pumpAndSettle();
      expect(trayOf(tester), [c.action_pause, c.action_reset]);
      await h.countdown.pause();
      await tester.pumpAndSettle();
      expect(trayOf(tester), [c.action_resume, c.action_reset]);
      await h.countdown.reset();

      await h.settings.update(
        h.settings.state.copyWith(lastMode: ClockMode.stopwatch),
      );
      await tester.pumpAndSettle();
      expect(trayOf(tester), [c.action_start]);
      h.stopwatch.start();
      await tester.pump();
      await crossFade(tester);
      expect(trayOf(tester), [c.action_pause, c.action_lap]);
      h.watch.reading = const Duration(seconds: 2);
      h.stopwatch.pause();
      await tester.pumpAndSettle();
      expect(trayOf(tester), [c.action_resume, c.action_reset]);
      await tapAction(tester, c.action_reset);
      expect(h.stopwatch.state.isIdle, isTrue);
      await tapAction(tester, c.action_start);
      expect(h.stopwatch.state.running, isTrue);
      await crossFade(tester);
      h.watch.reading = const Duration(seconds: 3);
      await tapAction(tester, c.action_pause);
      expect(h.stopwatch.state.running, isFalse);
      await tester.pumpAndSettle();
      await tapAction(tester, c.action_resume);
      expect(h.stopwatch.state.running, isTrue);
      h.stopwatch.reset();
      await tester.pumpAndSettle();
      await h.dispose(tester);
    });

    testWidgets('one tap on 10m starts a 10 minute countdown', (tester) async {
      final h = Harness();
      await h.settings.update(
        const ClockSettings(lastMode: ClockMode.pomodoro),
      );
      await tester.pumpWidget(h.screen());
      await showChrome(tester);
      // The chip reads in full to a screen reader.
      final semantics = tester.ensureSemantics();
      expect(find.bySemanticsLabel(c.preset_spoken_minutes(10)), findsOne);
      semantics.dispose();
      await tapAction(tester, '10m');
      expect(h.countdown.state.status, CountdownStatus.running);
      expect(h.countdown.state.duration, const Duration(minutes: 10));
      expect(h.countdown.state.pomodoro, isNull);
      await h.countdown.reset();
      await tester.pumpAndSettle();
      // The Pomodoro chip starts the cycle.
      await tapAction(tester, c.preset_pomodoro);
      expect(h.countdown.state.pomodoro, isNotNull);
      await h.countdown.reset();
      await tester.pumpAndSettle();
      // The tune icon opens the timer settings.
      await tapAction(tester, c.action_timer_settings);
      expect(h.timerSettingsOpened, 1);
      expect(chromeOf(tester), ChromeState.expanded);
      await h.dispose(tester);
    });

    testWidgets('Start runs the default timer', (tester) async {
      final h = Harness();
      const m = Duration(minutes: 15);
      await h.settings.update(
        const ClockSettings(
          lastMode: ClockMode.pomodoro,
        ).copyWith(defaultTimer: const Minutes(m)),
      );
      await tester.pumpWidget(h.screen());
      await showChrome(tester);
      expect(find.bySemanticsLabel(c.time_remaining('00:15:00')), findsOne);
      await tapAction(tester, c.action_start);
      expect(h.countdown.state.duration, m);
      expect(h.countdown.state.pomodoro, isNull);
      await h.countdown.reset();
      await tester.pumpAndSettle();
      await h.dispose(tester);
    });

    testWidgets('finishing while hidden opens the finished tray; Restart', (
      tester,
    ) async {
      final h = Harness();
      await tester.pumpWidget(h.screen());
      await h.countdown.start(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 8));
      expect(chromeOf(tester), ChromeState.hidden);
      h.wall.advance(const Duration(seconds: 5));
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
      expect(chromeOf(tester), ChromeState.expanded);
      expect(h.settings.state.lastMode, ClockMode.pomodoro);
      expect(find.text(c.times_up), findsOne);
      expect(trayOf(tester), [c.action_restart, c.action_done]);
      expect(h.sound.alarms, 1);

      await tapAction(tester, c.action_restart);
      expect(h.countdown.state.status, CountdownStatus.running);
      expect(h.countdown.state.duration, const Duration(seconds: 5));
      expect(h.sound.stops, 1, reason: 'Restart silences the alarm');

      // The idle collapse still applies to the finished tray.
      h.wall.advance(const Duration(seconds: 5));
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
      expect(chromeOf(tester), ChromeState.expanded);
      await tester.pump(const Duration(seconds: 8));
      expect(chromeOf(tester), ChromeState.hidden);
      // A tap shows it again; Done ends it.
      await tester.tapAt(const Offset(100, 300));
      await tester.pumpAndSettle();
      await tapAction(tester, c.action_done);
      expect(h.countdown.state.status, CountdownStatus.idle);
      await tester.pumpAndSettle();
      await h.dispose(tester);
    });
  });

  /// Rows of laps visible before the grid scrolls.
  const lapRows = 3;

  group('stopwatch laps', () {
    final c = strings.clock;

    testWidgets('Start, Lap, Lap, Pause, Reset from the island alone', (
      tester,
    ) async {
      final h = Harness();
      await h.settings.update(
        const ClockSettings(lastMode: ClockMode.stopwatch),
      );
      await tester.pumpWidget(h.screen());
      await showChrome(tester);
      await tapAction(tester, c.action_start);
      await crossFade(tester);
      expect(trayOf(tester).take(2), [c.action_pause, c.action_lap]);
      h.watch.reading = const Duration(seconds: 12, milliseconds: 400);
      await tapAction(tester, c.action_lap);
      h.watch.reading = const Duration(seconds: 20);
      await tapAction(tester, c.action_lap);
      // Newest first, numbered from the start, left to right.
      expect(find.text(c.lap_label(2, '0:00:07.6')), findsOne);
      expect(find.text(c.lap_label(1, '0:00:12.4')), findsOne);
      final newest = tester.getRect(find.text(c.lap_label(2, '0:00:07.6')));
      final oldest = tester.getRect(find.text(c.lap_label(1, '0:00:12.4')));
      expect(newest.right, lessThan(oldest.left));
      expect(newest.center.dy, closeTo(oldest.center.dy, 0.5));
      await tapAction(tester, c.action_pause);
      await crossFade(tester);
      await tapAction(tester, c.action_reset);
      expect(h.stopwatch.state.isIdle, isTrue);
      expect(h.stopwatch.state.laps, isEmpty);
      expect(find.text(c.lap_label(1, '0:00:12.4')), findsNothing);
      await tester.pumpAndSettle();
      await h.dispose(tester);
    });

    int columnsOf(WidgetTester tester) =>
        (tester.widget<GridView>(find.byType(GridView)).gridDelegate
                as SliverGridDelegateWithFixedCrossAxisCount)
            .crossAxisCount;
    double scrollOf(WidgetTester tester) => tester
        .state<ScrollableState>(
          find.descendant(
            of: find.byType(GridView),
            matching: find.byType(Scrollable),
          ),
        )
        .position
        .maxScrollExtent;

    /// A stopwatch on screen at [width] with [count] one-second laps.
    Future<Harness> lapped(
      WidgetTester tester,
      int count, {
      double width = 1280,
      double textScale = 1,
      String skinId = 'mono',
    }) async {
      tester.view
        ..physicalSize = Size(width, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final h = Harness();
      await h.settings.update(
        ClockSettings(lastMode: ClockMode.stopwatch, skinId: skinId),
      );
      await tester.pumpWidget(h.screen());
      h.stopwatch.start();
      await tester.pump();
      for (var i = 1; i <= count; i++) {
        h.watch.reading = Duration(seconds: i);
        h.stopwatch.lap();
      }
      // The laps reach the panel on the stream, after this frame; the next
      // one draws them (nothing else schedules a frame while the chrome is
      // hidden).
      await tester.pump();
      await tester.pump();
      return h;
    }

    Future<void> done(WidgetTester tester, Harness h) async {
      h.stopwatch.reset();
      await tester.pumpAndSettle();
      await h.dispose(tester);
    }

    testWidgets('one column at 320px, several at 1280px', (tester) async {
      // A wide face (Orbitron) fits one label across a phone.
      var h = await lapped(tester, 4, width: 320, skinId: 'orbit');
      expect(columnsOf(tester), 1);
      await done(tester, h);
      // A condensed face fits more: the width is measured, not guessed.
      h = await lapped(tester, 4, width: 320);
      expect(columnsOf(tester), 2);
      await done(tester, h);
      h = await lapped(tester, 12);
      expect(columnsOf(tester), greaterThan(3));
      expect(tester.takeException(), isNull);
      await done(tester, h);
    });

    testWidgets('three full rows show without scrolling; one more scrolls', (
      tester,
    ) async {
      var h = await lapped(tester, 1);
      // One lap: one centred cell.
      expect(columnsOf(tester), 1);
      await done(tester, h);
      h = await lapped(tester, 30);
      final columns = columnsOf(tester);
      await done(tester, h);

      h = await lapped(tester, columns * lapRows);
      expect(scrollOf(tester), 0);
      await done(tester, h);
      h = await lapped(tester, columns * lapRows + 1);
      expect(scrollOf(tester), greaterThan(0));
      // Newest first: the oldest is past the fold until scrolled.
      expect(find.text(c.lap_label(1, '0:00:01.0')), findsNothing);
      await tester.drag(find.byType(GridView), const Offset(0, -300));
      await tester.pump();
      expect(find.text(c.lap_label(1, '0:00:01.0')), findsOne);
      await done(tester, h);
    });

    testWidgets('text scale 2 takes fewer columns and never clips', (
      tester,
    ) async {
      var h = await lapped(tester, 30);
      final normal = columnsOf(tester);
      await done(tester, h);
      h = await lapped(tester, 30, textScale: 2);
      expect(columnsOf(tester), lessThan(normal));
      expect(tester.takeException(), isNull);
      // Every label fits its cell unscaled.
      final label = find.text(c.lap_label(30, '0:00:01.0'));
      final fitted = tester.widget<FittedBox>(
        find.ancestor(of: label, matching: find.byType(FittedBox)).first,
      );
      expect(fitted.fit, BoxFit.scaleDown);
      expect(
        tester.getSize(label).width,
        lessThanOrEqualTo(
          tester
              .getSize(
                find.ancestor(of: label, matching: find.byType(Center)).first,
              )
              .width,
        ),
      );
      await done(tester, h);
    });

    testWidgets('L laps in Stopwatch mode only, in the skin face', (
      tester,
    ) async {
      final h = Harness();
      await h.settings.update(
        const ClockSettings(lastMode: ClockMode.stopwatch, skinId: 'orbit'),
      );
      await tester.pumpWidget(h.screen());
      h.stopwatch.start();
      await tester.pump();
      for (var i = 1; i <= 5; i++) {
        h.watch.reading = Duration(seconds: i);
        await key(tester, LogicalKeyboardKey.keyL);
      }
      expect(h.stopwatch.state.laps, hasLength(5));
      final lap = tester.widget<Text>(find.text(c.lap_label(5, '0:00:01.0')));
      expect(lap.style!.fontFamily, startsWith('Orbitron'));
      expect(lap.style!.color, Skins.resolve('orbit', const []).digitColor);

      // Elsewhere L does nothing.
      h.stopwatch.pause();
      await h.settings.update(
        h.settings.state.copyWith(lastMode: ClockMode.clock),
      );
      await tester.pumpAndSettle();
      await key(tester, LogicalKeyboardKey.keyL);
      expect(h.stopwatch.state.laps, hasLength(5));
      h.stopwatch.reset();
      await tester.pumpAndSettle();
      await h.dispose(tester);
    });
  });
}
