import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart' show Closable;
import 'package:core/core.dart' as core;
import 'package:core/core.dart' show Logger;
import 'package:design_system/design_system.dart';
import 'package:device_services/device_services.dart';
import 'package:di/di.dart';
import 'package:flip_clock/data/models/skin.dart';
import 'package:flip_clock/data/repositories/settings_repository.dart';
import 'package:flip_clock/data/repositories/settings_repository_imp.dart';
import 'package:flip_clock/flip_clock.dart' as flip_clock;
import 'package:flip_clock/flip_clock.dart';
import 'package:flip_clock/state/clock_controller.dart';
import 'package:flip_clock/state/countdown_controller.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flip_clock/state/stopwatch_controller.dart';
import 'package:flip_clock/ui/components/controls.dart';
import 'package:flip_clock/ui/components/flip_display.dart';
import 'package:flip_clock/ui/components/gesture_layer.dart';
import 'package:flip_clock/ui/components/skin_picker.dart';
import 'package:flip_clock/ui/components/subtle_movement.dart';
import 'package:flip_clock/ui/components/timer_input.dart';
import 'package:flip_clock/ui/screens/index.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:timekeeping/timekeeping.dart';

import 'fakes.dart';

final theme = ThemeData(colorScheme: DesignSystem.blackScheme());

class Harness {
  Harness({FakeScreenBrightness? brightness})
    : brightness = brightness ?? FakeScreenBrightness() {
    final repo = SettingsRepositoryImp(store: store, logger: di.get<Logger>());
    settings = SettingsController(repository: repo, alerts: alerts);
    countdown = CountdownController(
      repository: repo,
      alerts: alerts,
      sound: sound,
      settings: () => settings.state,
      logger: di.get<Logger>(),
      now: wall.call,
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

  Widget screen({
    bool doubleTap = false,
    bool reduceMotion = false,
    ThemeData? appTheme,
  }) => MaterialApp(
    theme: appTheme ?? theme,
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

ChromeState chromeOf(WidgetTester tester) =>
    tester.widget<Island>(find.byType(Island)).state;

Reveal revealOf(WidgetTester tester, Finder f) => tester.widget<Reveal>(
  find.ancestor(of: f, matching: find.byType(Reveal)).first,
);

void main() {
  setUp(core.init);
  tearDown(di.reset);

  testWidgets('opens on the clock in 24h without seconds; settings toggle it', (
    tester,
  ) async {
    final h = Harness();
    await tester.pumpWidget(h.screen());
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
    await tester.tap(find.byTooltip(strings.clock.settings));
    expect(h.settingsOpened, 1);
    await h.dispose(tester);
  });

  testWidgets('date line shows under the clock and rolls over at midnight', (
    tester,
  ) async {
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
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });

  testWidgets('timer: start, pause, resume, reset, finish and dismiss', (
    tester,
  ) async {
    final h = Harness();
    await tester.pumpWidget(h.screen());
    await modeTab(tester, strings.clock.timer);
    expect(h.settings.state.lastMode, ClockMode.timer);
    expect(find.byType(TimerInput), findsOne);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '0');
    await tester.enterText(fields.at(1), '0');
    await tester.enterText(fields.at(2), '30');
    await tester.pump();
    expect(h.countdown.state.duration, const Duration(seconds: 30));
    // Focusing a field scrolls it into view; a scrolling page ignores taps.
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.clock.start));
    await tester.pump();
    expect(h.countdown.state.status, CountdownStatus.running);
    expect(
      find.bySemanticsLabel(strings.clock.time_remaining('00:00:30')),
      findsOne,
    );

    await tester.tap(find.text(strings.clock.pause));
    await tester.pump();
    expect(h.countdown.state.status, CountdownStatus.paused);
    await tester.tap(find.text(strings.clock.resume));
    await tester.pump();
    expect(h.countdown.state.status, CountdownStatus.running);
    await tester.tap(find.text(strings.clock.reset));
    await tester.pump();
    expect(h.countdown.state.status, CountdownStatus.idle);

    await tester.tap(find.text(strings.clock.start));
    await tester.pump();
    h.wall.advance(const Duration(seconds: 30));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();
    expect(find.text(strings.clock.times_up), findsOne);
    expect(h.sound.alarms, 1);
    await tester.tap(find.text(strings.clock.dismiss));
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
    await modeKey(tester, LogicalKeyboardKey.arrowRight);
    expect(h.settings.state.lastMode, ClockMode.stopwatch);
    h.wall.advance(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();
    await tester.pump(DesignMotion.islandMorph);
    expect(h.settings.state.lastMode, ClockMode.timer);
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
    await tester.pump();
    expect(h.settings.state.lastMode, ClockMode.timer);
    expect(find.text(strings.clock.times_up), findsOne);
    await h.countdown.reset();
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });

  testWidgets('pomodoro: start, round label, next phase, pause, reset', (
    tester,
  ) async {
    final h = Harness();
    await h.settings.update(const ClockSettings(lastMode: ClockMode.pomodoro));
    await tester.pumpWidget(h.screen());
    await tester.pump();
    expect(
      find.bySemanticsLabel(strings.clock.time_remaining('00:25:00')),
      findsOne,
    );
    await tester.tap(find.text(strings.clock.start));
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
    await tester.tap(find.text(strings.clock.reset));
    await tester.pump();
    // Back to the idle Pomodoro panel.
    expect(find.text(strings.clock.start), findsOne);
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
    await tester.pump();
    await tester.pump(DesignMotion.islandMorph);
    expect(h.settings.state.lastMode, ClockMode.pomodoro);
    expect(find.text(strings.clock.times_up), findsOne);
    expect(find.text(strings.clock.pomodoro_break(2)), findsOne);
    await tester.tap(find.text(strings.clock.start_focus));
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
    await tester.pump();
    expect(find.text(strings.clock.start_break), findsOne);
    expect(h.settings.state.lastMode, ClockMode.pomodoro);
    await tester.tap(find.text(strings.clock.dismiss));
    await tester.pump();
    // The idle Pomodoro panel offers a new focus.
    expect(find.text(strings.clock.start), findsOne);
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });

  testWidgets('Space activates a focused control instead of the timer', (
    tester,
  ) async {
    final h = Harness();
    await h.settings.update(const ClockSettings(lastMode: ClockMode.stopwatch));
    await tester.pumpWidget(h.screen());
    await tester.pump();
    await key(tester, LogicalKeyboardKey.tab);
    await key(tester, LogicalKeyboardKey.space);
    expect(h.stopwatch.state.running, isFalse);
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });

  testWidgets('screen readers get "show controls" once the chrome hides', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final h = Harness();
    await tester.pumpWidget(h.screen());
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

  testWidgets('timer input rejects out-of-range values', (tester) async {
    Duration? started;
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TimerInput(
            initial: const Duration(hours: 1, minutes: 2, seconds: 3),
            onStart: (d) => started = d,
          ),
        ),
      ),
    );
    expect(find.text('01'), findsOne);
    expect(find.text(strings.clock.invalid_duration), findsNothing);
    final minutes = find.byType(TextField).at(1);
    await tester.tap(minutes);
    await tester.enterText(minutes, '75');
    await tester.pump();
    expect(find.text(strings.clock.invalid_duration), findsOne);
    final start = find.widgetWithText(FilledButton, strings.clock.start);
    expect(tester.widget<FilledButton>(start).onPressed, isNull);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(started, isNull);
    await tester.enterText(minutes, '5');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(started, const Duration(hours: 1, minutes: 5, seconds: 3));
  });

  testWidgets('keyboard: Left/Right modes, Space start/pause, F and Esc', (
    tester,
  ) async {
    final h = Harness();
    await tester.pumpWidget(h.screen());
    await tester.pump();

    await modeKey(tester, LogicalKeyboardKey.arrowRight);
    await modeKey(tester, LogicalKeyboardKey.arrowRight);
    expect(h.settings.state.lastMode, ClockMode.stopwatch);
    await key(tester, LogicalKeyboardKey.space);
    expect(h.stopwatch.state.running, isTrue);
    h.watch.reading = const Duration(seconds: 2);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.bySemanticsLabel(strings.clock.elapsed('0:00:02.0')), findsOne);
    await key(tester, LogicalKeyboardKey.space);
    expect(h.stopwatch.state.running, isFalse);
    expect(find.text(strings.clock.resume), findsOne);
    await tester.tap(find.text(strings.clock.reset));
    await tester.pump();
    expect(h.stopwatch.state.isIdle, isTrue);

    await modeKey(tester, LogicalKeyboardKey.arrowLeft);
    expect(h.settings.state.lastMode, ClockMode.timer);
    await key(tester, LogicalKeyboardKey.space);
    expect(h.countdown.state.status, CountdownStatus.running);
    await key(tester, LogicalKeyboardKey.space);
    expect(h.countdown.state.status, CountdownStatus.paused);

    await modeKey(tester, LogicalKeyboardKey.arrowLeft);
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
    await modeKey(tester, LogicalKeyboardKey.arrowRight);
    await key(tester, LogicalKeyboardKey.keyS);
    expect(h.settings.state.showSeconds, isFalse);
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });

  testWidgets('keys typed into the timer do not switch modes', (tester) async {
    final h = Harness();
    await h.settings.update(const ClockSettings(lastMode: ClockMode.timer));
    await tester.pumpWidget(h.screen());
    await tester.tap(find.byType(TextField).first);
    await tester.pump();
    await modeKey(tester, LogicalKeyboardKey.arrowLeft);
    expect(h.settings.state.lastMode, ClockMode.timer);
    await h.dispose(tester);
  });

  testWidgets('chrome: dots after 4 s, gone after 7 s, tap toggles', (
    tester,
  ) async {
    final h = Harness();
    await h.settings.update(const ClockSettings(lastMode: ClockMode.stopwatch));
    await tester.pumpWidget(h.screen());
    final start = find.text(strings.clock.start);
    expect(chromeOf(tester), ChromeState.expanded);
    expect(revealOf(tester, start).visible, isTrue);

    await tester.pump(const Duration(seconds: 4));
    expect(chromeOf(tester), ChromeState.dot);
    expect(revealOf(tester, start).visible, isFalse);
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

  testWidgets('island tabs switch modes; corners open Skins and Settings', (
    tester,
  ) async {
    final h = Harness();
    await tester.pumpWidget(h.screen());
    await modeTab(tester, strings.clock.stopwatch);
    expect(h.settings.state.lastMode, ClockMode.stopwatch);
    await tester.tap(find.byTooltip(strings.clock.settings));
    expect(h.settingsOpened, 1);
    await tester.tap(find.byTooltip(strings.clock.skins_change));
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

    for (final mode in [ClockMode.timer, ClockMode.stopwatch]) {
      await h.settings.update(
        ClockSettings(lastMode: mode, digitBrightness: 0.2),
      );
      if (mode == ClockMode.timer) {
        await h.countdown.start(const Duration(minutes: 1));
      }
      await tester.pump();
      expect(digits(), 0.2, reason: '$mode');
      expect(
        find.ancestor(
          of: find.byType(RunControls),
          matching: find.byType(Opacity),
        ),
        findsNothing,
        reason: '$mode',
      );
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
    expect(find.byType(FlipDisplay), findsOne);
    await tester.tap(find.byTooltip(strings.clock.settings));
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.path,
      FlipClockRouter.settings,
    );
    expect(find.byType(SettingsScreen), findsOne);
    // Appearance > Skin opens the Skins sheet over Settings.
    await tester.tap(find.text(strings.clock.settings_skin));
    await tester.pumpAndSettle();
    expect(find.byType(SkinPicker), findsOne);
    // The sheet's Done sits above Settings' own.
    await tester.tap(find.text(strings.clock.skins_done).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.generic.done));
    await tester.pumpAndSettle();
    expect(find.byType(FlipClockScreen), findsOne);
    await tester.pumpWidget(const SizedBox());
    unawaited(di.reset());
    await tester.pump();
  });

  testWidgets('the palette opens skins; the ground follows the skin', (
    tester,
  ) async {
    final h = Harness();
    await tester.pumpWidget(h.screen());
    Color ground() =>
        tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor!;
    expect(ground(), DesignSkinColors.bgInk);
    await tester.tap(find.byTooltip(strings.clock.skins_change));
    await tester.pumpAndSettle();
    expect(find.byType(SkinPicker), findsOne);
    await tester.tap(find.widgetWithText(SkinTile, strings.clock.skin_paper));
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
      await tester.dragFrom(const Offset(400, 100), const Offset(0, 300));
      await tester.pump();
      // Down by half the 600px height: 0.5 - 0.5.
      expect(h.brightness.level, closeTo(0.0, 0.02));
      expect(hudOf(tester), isA<IslandBrightnessHud>());
      await tester.pump(DesignMotion.hudHold);
      expect(hudOf(tester), isNull);
      await h.dispose(tester);
    });

    testWidgets('where the device cannot, the drag dims the digits', (
      tester,
    ) async {
      final h = Harness(brightness: FakeScreenBrightness(supported: false));
      await tester.pumpWidget(h.screen());
      // Down by most of the height: clamps at the 20% floor.
      await tester.dragFrom(const Offset(400, 100), const Offset(0, 490));
      await tester.pump();
      expect(h.settings.state.digitBrightness, ClockSettings.minBrightness);
      expect(h.brightness.calls, isEmpty);
      await tester.pumpAndSettle();
      await h.dispose(tester);
    });

    testWidgets('a sideways swipe changes mode and names it in the island', (
      tester,
    ) async {
      final h = Harness();
      await tester.pumpWidget(h.screen());
      await tester.dragFrom(const Offset(600, 300), const Offset(-400, 0));
      await tester.pump();
      expect(h.settings.state.lastMode, ClockMode.timer);
      final hud = hudOf(tester)! as IslandTitleHud;
      expect(hud.title, strings.clock.mode_timer);
      expect(hud.index, ClockMode.timer.index);
      await tester.pumpAndSettle();
      expect(find.byType(TimerInput), findsOne);
      await h.dispose(tester);
    });

    testWidgets('swipes and drags can be switched off', (tester) async {
      final h = Harness();
      await h.settings.update(
        const ClockSettings(gestureModes: false, gestureBrightness: false),
      );
      await tester.pumpWidget(h.screen());
      await tester.dragFrom(const Offset(600, 300), const Offset(-400, 0));
      await tester.dragFrom(const Offset(400, 100), const Offset(0, 300));
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
      await tester.tap(find.byTooltip(strings.clock.skins_change));
      await tester.pumpAndSettle();
      final layer = tester.widget<GestureLayer>(find.byType(GestureLayer));
      expect(layer.enabled, isFalse);
      await h.dispose(tester);
    });

    testWidgets('typing a timer duration turns gestures off', (tester) async {
      final h = Harness();
      await h.settings.update(const ClockSettings(lastMode: ClockMode.timer));
      await tester.pumpWidget(h.screen());
      GestureLayer layer() =>
          tester.widget<GestureLayer>(find.byType(GestureLayer));
      expect(layer().enabled, isTrue);
      await tester.tap(find.byType(TextField).first);
      await tester.pump();
      expect(layer().enabled, isFalse);
      await tester.pumpAndSettle();
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
      expect(find.byType(TimerInput), findsOne);
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
      final names = [
        c.mode_pomodoro,
        c.mode_clock,
        c.mode_timer,
        c.mode_stopwatch,
      ];
      await tester.tap(find.text(names[mode.index]));
      await tester.pump();
      await tester.pumpAndSettle();
    }

    testWidgets('Timer by tab, Right key and swipe stays after idling', (
      tester,
    ) async {
      final ways = <String, Future<void> Function()>{
        'tab': () => tabTo(tester, ClockMode.timer),
        'key': () => modeKey(tester, LogicalKeyboardKey.arrowRight),
        'swipe': () async {
          await tester.dragFrom(const Offset(600, 300), const Offset(-400, 0));
          await tester.pumpAndSettle();
        },
      };
      for (final MapEntry(key: way, value: go) in ways.entries) {
        final h = Harness();
        await tester.pumpWidget(h.screen());
        expectMode(tester, h, ClockMode.clock);
        await go();
        expectMode(tester, h, ClockMode.timer);
        await idle(tester);
        expect(chromeOf(tester), ChromeState.hidden, reason: way);
        expectMode(tester, h, ClockMode.timer);
        expect(find.byType(TimerInput), findsOne, reason: way);
        await h.dispose(tester);
      }
    });

    testWidgets('a running countdown stays on Timer after idling', (
      tester,
    ) async {
      final h = Harness();
      await tester.pumpWidget(h.screen());
      await tabTo(tester, ClockMode.timer);
      await h.countdown.start(const Duration(minutes: 5));
      await tester.pump();
      await idle(tester);
      expectMode(tester, h, ClockMode.timer);
      expect(find.byType(RunControls), findsOne);
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
      await tabTo(tester, ClockMode.timer);
      await key(tester, LogicalKeyboardKey.keyF);
      expect(
        tester.widget<SubtleMovement>(find.byType(SubtleMovement)).enabled,
        isTrue,
      );
      expectMode(tester, h, ClockMode.timer);
      await idle(tester);
      expectMode(tester, h, ClockMode.timer);
      await key(tester, LogicalKeyboardKey.escape);
      expect(h.full.value.value, isFalse);
      expectMode(tester, h, ClockMode.timer);
      await idle(tester);
      expectMode(tester, h, ClockMode.timer);
      expect(find.byType(TimerInput), findsOne);
      await tester.pumpAndSettle();
      await h.dispose(tester);
    });

    testWidgets('opening and closing the Skins sheet stays', (tester) async {
      final h = Harness();
      await tester.pumpWidget(h.screen());
      await tabTo(tester, ClockMode.timer);
      await tester.tap(find.byTooltip(strings.clock.skins_change));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.clock.skins_done));
      await tester.pumpAndSettle();
      expectMode(tester, h, ClockMode.timer);
      await idle(tester);
      expectMode(tester, h, ClockMode.timer);
      expect(find.byType(TimerInput), findsOne);
      await h.dispose(tester);
    });

    testWidgets('Pomodoro and Stopwatch stay after idling too', (tester) async {
      for (final mode in [ClockMode.pomodoro, ClockMode.stopwatch]) {
        final h = Harness();
        await tester.pumpWidget(h.screen());
        await tabTo(tester, mode);
        await idle(tester);
        expectMode(tester, h, mode);
        // Its own content, not the Clock's.
        expect(find.byType(RunControls), findsExactly(mode.index == 3 ? 1 : 0));
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
      // Idle for a minute: any key brings the corner buttons back.
      await key(tester, LogicalKeyboardKey.keyQ);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(strings.clock.skins_change));
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

  for (final width in [390.0, 1280.0]) {
    testWidgets('the island sits top centre, clear of the corners ($width)', (
      tester,
    ) async {
      tester.view
        ..physicalSize = Size(width, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final h = Harness();
      await tester.pumpWidget(h.screen());
      await tester.pumpAndSettle();
      final island = tester.getRect(find.byType(Island));
      expect(island.center.dy, lessThan(844 / 4));
      expect(island.center.dx, closeTo(width / 2, 0.5));
      final corners = find.byType(CornerButton);
      expect(corners, findsExactly(2));
      for (var i = 0; i < 2; i++) {
        final corner = tester.getRect(corners.at(i));
        expect(corner.overlaps(island), isFalse, reason: 'corner $i');
        if (width < FlipClockScreen.stackedChromeWidth) {
          // Its own row under the corners.
          expect(island.top, greaterThanOrEqualTo(corner.bottom));
        } else {
          // Between them, at the same top inset.
          expect(island.top, corner.top, reason: 'corner $i');
        }
      }
      // Tabs keep their full size (the callout line is 20px), never shrunk.
      expect(
        tester.getSize(find.text(strings.clock.mode_stopwatch)).height,
        closeTo(20, 0.5),
      );
      // The digits start below the chrome.
      expect(
        tester.getRect(find.byType(FlipDisplay)).top,
        greaterThanOrEqualTo(island.bottom),
      );
      await h.dispose(tester);
    });
  }

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
      // A fresh tree: the design system's corner buttons cannot animate
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
        if (mode == ClockMode.timer) {
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

  testWidgets('a mouse click shows the chrome and never hides it', (
    tester,
  ) async {
    final h = Harness();
    await tester.pumpWidget(h.screen());
    await tester.pump(const Duration(seconds: 8));
    expect(chromeOf(tester), ChromeState.hidden);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(400, 350));
    // Moving there shows it (the hover), the click keeps it shown.
    await mouse.moveTo(const Offset(410, 360));
    await tester.pump();
    expect(chromeOf(tester), ChromeState.expanded);
    await mouse.down(const Offset(410, 360));
    await mouse.up();
    await tester.pump();
    expect(chromeOf(tester), ChromeState.expanded);
    // A touch tap still toggles.
    await tester.tapAt(const Offset(400, 350));
    await tester.pump();
    expect(chromeOf(tester), ChromeState.hidden);
    await mouse.removePointer();
    await h.dispose(tester);
  });
}
