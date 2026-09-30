import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart' show Closable;
import 'package:core/core.dart' as core;
import 'package:core/core.dart' show Logger;
import 'package:design_system/design_system.dart';
import 'package:device_services/device_services.dart';
import 'package:di/di.dart';
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
import 'package:flip_clock/ui/components/subtle_movement.dart';
import 'package:flip_clock/ui/components/timer_input.dart';
import 'package:flip_clock/ui/screens/index.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:timekeeping/timekeeping.dart';

import 'fakes.dart';

final theme = ThemeData(colorScheme: DesignSystem.blackScheme());

class Harness {
  Harness() {
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
  final wall = FakeClock();
  final watch = FakeStopwatch();
  late final SettingsController settings;
  late final CountdownController countdown;
  late final ClockController clock;
  late final StopwatchController stopwatch;
  int settingsOpened = 0;

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

  testWidgets('flip sound plays on each change only when enabled', (
    tester,
  ) async {
    final h = Harness();
    await h.settings.update(const ClockSettings(showSeconds: true));
    await tester.pumpWidget(h.screen());
    h.wall.advance(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(h.sound.flips, 0);
    await h.settings.update(h.settings.state.copyWith(flipSound: true));
    await tester.pump();
    h.wall.advance(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(h.sound.flips, 1);
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });

  testWidgets('timer: start, pause, resume, reset, finish and dismiss', (
    tester,
  ) async {
    final h = Harness();
    await tester.pumpWidget(h.screen());
    await tester.tap(find.text(strings.clock.timer));
    await tester.pump();
    expect(h.settings.state.lastMode, ClockMode.timer);
    expect(find.byType(TimerInput), findsOne);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '0');
    await tester.enterText(fields.at(1), '0');
    await tester.enterText(fields.at(2), '30');
    await tester.pump();
    expect(h.countdown.state.duration, const Duration(seconds: 30));
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
    await key(tester, LogicalKeyboardKey.digit3);
    expect(h.settings.state.lastMode, ClockMode.stopwatch);
    h.wall.advance(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();
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

  testWidgets('screen readers can reveal hidden full-screen controls', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final h = Harness();
    await tester.pumpWidget(h.screen());
    await tester.tap(find.byTooltip(strings.clock.enter_full_screen));
    await tester.pump();
    await tester.pumpAndSettle(FlipClockScreen.revealFor);
    final reveal = find.bySemanticsLabel(strings.clock.show_controls);
    expect(reveal, findsOne);
    tester.semantics.tap(find.semantics.byLabel(strings.clock.show_controls));
    await tester.pump();
    expect(find.bySemanticsLabel(strings.clock.show_controls), findsNothing);
    expect(
      revealOf(tester, find.byTooltip(strings.clock.settings)).visible,
      isTrue,
    );
    await tester.pumpAndSettle(FlipClockScreen.revealFor);
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

    await tester.tap(find.byTooltip(strings.clock.enter_full_screen));
    await tester.pump();
    expect(revealOf(tester, note).visible, isTrue);
    expect(
      tester.getSemantics(note),
      isSemantics(label: strings.clock.full_screen_note, isLiveRegion: true),
    );

    expect(find.semantics.byLabel(strings.clock.full_screen_note), findsOne);

    // Hidden with the controls after revealFor.
    await tester.pump(FlipClockScreen.revealFor);
    expect(revealOf(tester, note).visible, isFalse);
    expect(
      revealOf(tester, find.byTooltip(strings.clock.settings)).visible,
      isFalse,
    );
    await tester.pumpAndSettle();
    // Faded out, so screen readers no longer see it either.
    expect(
      find.semantics.byLabel(strings.clock.full_screen_note),
      findsNothing,
    );

    // A later reveal shows the controls only, not the note again.
    await tester.tapAt(const Offset(400, 300));
    await tester.pump();
    expect(
      revealOf(tester, find.byTooltip(strings.clock.settings)).visible,
      isTrue,
    );
    expect(revealOf(tester, note).visible, isFalse);

    // Leaving and re-entering shows it again; leaving clears it.
    await key(tester, LogicalKeyboardKey.escape);
    expect(note, findsNothing);
    await key(tester, LogicalKeyboardKey.keyF);
    expect(revealOf(tester, note).visible, isTrue);
    await key(tester, LogicalKeyboardKey.keyF);
    await tester.pumpAndSettle(FlipClockScreen.revealFor);
    semantics.dispose();
    await h.dispose(tester);
  });

  testWidgets('the full-screen listener is removed on dispose', (tester) async {
    final h = Harness();
    await tester.pumpWidget(h.screen());
    await h.dispose(tester);
    // No listener left: toggling after dispose must not touch the old state.
    await h.full.toggle();
    await tester.pump(FlipClockScreen.revealFor);
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

  testWidgets('keyboard: 1/2/3 modes, Space start/pause, F and Esc', (
    tester,
  ) async {
    final h = Harness();
    await tester.pumpWidget(h.screen());
    await tester.pump();

    await key(tester, LogicalKeyboardKey.digit3);
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

    await key(tester, LogicalKeyboardKey.digit2);
    expect(h.settings.state.lastMode, ClockMode.timer);
    await key(tester, LogicalKeyboardKey.space);
    expect(h.countdown.state.status, CountdownStatus.running);
    await key(tester, LogicalKeyboardKey.space);
    expect(h.countdown.state.status, CountdownStatus.paused);

    await key(tester, LogicalKeyboardKey.digit1);
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

  testWidgets('seconds button and S toggle seconds and retire the hint', (
    tester,
  ) async {
    final h = Harness();
    await tester.pumpWidget(h.screen());
    await tester.pump();
    final hint = find.text(strings.clock.seconds_hint);
    expect(hint, findsOne);

    await tester.tap(find.byTooltip(strings.clock.show_seconds));
    await tester.pump();
    expect(h.settings.state.showSeconds, isTrue);
    expect(h.settings.state.secondsHintSeen, isTrue);
    expect(hint, findsNothing);
    expect(find.byTooltip(strings.clock.hide_seconds), findsOne);
    expect(
      find.bySemanticsLabel(strings.clock.current_time('09:41:00')),
      findsOne,
    );
    final saved = await SettingsRepositoryImp(
      store: h.store,
      logger: di.get<Logger>(),
    ).load();
    expect(saved.secondsHintSeen, isTrue);

    await key(tester, LogicalKeyboardKey.keyS);
    expect(h.settings.state.showSeconds, isFalse);
    expect(find.byTooltip(strings.clock.show_seconds), findsOne);

    // Not in other modes: no button, S ignored.
    await key(tester, LogicalKeyboardKey.digit3);
    expect(find.byTooltip(strings.clock.show_seconds), findsNothing);
    await key(tester, LogicalKeyboardKey.keyS);
    expect(h.settings.state.showSeconds, isFalse);
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });

  testWidgets('seconds hint: dismiss saves; hidden in full screen', (
    tester,
  ) async {
    final h = Harness();
    await tester.pumpWidget(h.screen());
    final hint = find.text(strings.clock.seconds_hint);
    await tester.tap(find.byTooltip(strings.clock.enter_full_screen));
    await tester.pump();
    expect(hint, findsNothing);
    await key(tester, LogicalKeyboardKey.escape);
    expect(hint, findsOne);

    await tester.tap(find.byTooltip(strings.clock.dismiss_hint));
    await tester.pump();
    expect(hint, findsNothing);
    expect(h.settings.state.showSeconds, isFalse);
    expect(
      h.store.data[SettingsRepositoryImp.settingsKey],
      contains('"secondsHintSeen":true'),
    );
    await tester.pumpAndSettle(FlipClockScreen.revealFor);
    await h.dispose(tester);
  });

  testWidgets('digits typed into the timer do not switch modes', (
    tester,
  ) async {
    final h = Harness();
    await h.settings.update(const ClockSettings(lastMode: ClockMode.timer));
    await tester.pumpWidget(h.screen());
    await tester.tap(find.byType(TextField).first);
    await tester.pump();
    await key(tester, LogicalKeyboardKey.digit1);
    expect(h.settings.state.lastMode, ClockMode.timer);
    await h.dispose(tester);
  });

  testWidgets('full screen hides controls until tap or mouse move', (
    tester,
  ) async {
    final h = Harness();
    await h.settings.update(const ClockSettings(lastMode: ClockMode.stopwatch));
    await tester.pumpWidget(h.screen());
    await tester.tap(find.byTooltip(strings.clock.enter_full_screen));
    await tester.pump();
    expect(h.full.toggles, 1);
    final settingsButton = find.byTooltip(strings.clock.settings);
    final start = find.text(strings.clock.start);
    // Entering shows the controls briefly, then hides them.
    expect(revealOf(tester, settingsButton).visible, isTrue);
    await tester.pump(FlipClockScreen.revealFor);
    expect(revealOf(tester, settingsButton).visible, isFalse);
    expect(revealOf(tester, start).visible, isFalse);

    await tester.tapAt(const Offset(400, 300));
    await tester.pump();
    expect(revealOf(tester, settingsButton).visible, isTrue);
    expect(revealOf(tester, start).visible, isTrue);
    await tester.pump(const Duration(seconds: 2));
    await tester.tapAt(const Offset(400, 300));
    await tester.pump(const Duration(seconds: 2));
    expect(revealOf(tester, start).visible, isTrue);
    await tester.pump(FlipClockScreen.revealFor);
    expect(revealOf(tester, start).visible, isFalse);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(10, 10));
    await mouse.moveTo(const Offset(20, 20));
    await tester.pump();
    expect(revealOf(tester, settingsButton).visible, isTrue);
    await tester.tap(find.byTooltip(strings.clock.exit_full_screen));
    await tester.pump();
    expect(h.full.value.value, isFalse);
    await mouse.removePointer();
    await tester.pumpAndSettle();
    await h.dispose(tester);
  });

  testWidgets('dim button and D key dim only the digits, and save', (
    tester,
  ) async {
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
    final dim = find.byTooltip(strings.clock.dim_digits);
    expect(digits(), 1.0);
    expect(dim, findsNothing);

    await key(tester, LogicalKeyboardKey.keyD);
    expect(h.settings.state.digitBrightness, 0.5);
    expect(digits(), 0.5);
    final saved = h.store.data[SettingsRepositoryImp.settingsKey]!;
    expect(
      ClockSettings.fromJson(jsonDecode(saved) as Map<String, Object?>),
      const ClockSettings(digitBrightness: 0.5),
    );

    await tester.tap(find.byTooltip(strings.clock.enter_full_screen));
    await tester.pump();
    await tester.tapAt(const Offset(400, 300));
    await tester.pump();
    expect(revealOf(tester, dim).visible, isTrue);
    await tester.tap(dim);
    await tester.pump();
    expect(h.settings.state.digitBrightness, 0.2);
    // The top bar is never dimmed.
    expect(
      find.ancestor(of: dim, matching: find.byType(Opacity)),
      findsNothing,
    );
    await tester.tap(dim);
    await tester.pump();
    expect(h.settings.state.digitBrightness, 1.0);

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
    await tester.tap(find.byTooltip(strings.clock.enter_full_screen));
    await tester.pump();
    expect(find.byType(SubtleMovement), findsNothing, reason: 'setting off');

    await h.settings.update(h.settings.state.copyWith(subtleMovement: true));
    await tester.pump();
    Offset shift() => tester.getTopLeft(find.byType(FlipDisplay));
    final first = shift();
    expect(SubtleMovement.offsetAt(h.wall.now), isNot(Offset.zero));

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

    // Turning it off, or leaving full screen, removes it.
    await h.settings.update(h.settings.state.copyWith(subtleMovement: false));
    await tester.pump();
    expect(find.byType(SubtleMovement), findsNothing);
    await h.settings.update(h.settings.state.copyWith(subtleMovement: true));
    await tester.pump();
    expect(find.byType(SubtleMovement), findsOne);
    await h.full.exit();
    await tester.pump();
    expect(find.byType(SubtleMovement), findsNothing);
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
    expect(find.byType(SubtleMovement), findsOne);
    expect(tester.takeException(), isNull);
    final before = tester.getTopLeft(find.byType(FlipDisplay));
    h.wall.now = DateTime(2026, 9, 29, 9, 42);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(
      tester.getTopLeft(find.byType(FlipDisplay)),
      isNot(before),
      reason: 'jumped without animating',
    );
    await h.dispose(tester);
  });

  testWidgets('compact windows show icon-only modes and never overflow', (
    tester,
  ) async {
    for (final size in const [Size(360, 640), Size(640, 360), Size(200, 100)]) {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      final h = Harness();
      await tester.pumpWidget(h.screen());
      expect(tester.takeException(), isNull, reason: '$size');
      expect(
        size.width < 520
            ? find.byTooltip(strings.clock.stopwatch)
            : find.text(strings.clock.stopwatch),
        findsOne,
        reason: '$size',
      );
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

  testWidgets('settings screen saves every toggle', (tester) async {
    tester.view
      ..physicalSize = const Size(800, 2000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final h = Harness();
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: SettingsScreen(settings: h.settings, isWeb: true),
      ),
    );
    expect(find.text(strings.clock.web_closed_tab_note), findsOne);
    expect(find.text(strings.clock.shortcut_full_screen), findsOne);
    expect(find.text(strings.clock.shortcut_seconds), findsOne);
    expect(find.text(strings.clock.shortcut_dim), findsOne);
    expect(find.text(strings.clock.percent('100')), findsOne);
    final slider = find.byType(Slider);
    expect(
      tester.getSemantics(slider),
      isSemantics(
        label: strings.clock.digit_brightness,
        value: strings.clock.percent('100'),
        isSlider: true,
      ),
    );
    await tester.drag(slider, const Offset(-2000, 0));
    await tester.pump();
    expect(h.settings.state.digitBrightness, 0.2);
    expect(find.text(strings.clock.percent('20')), findsOne);
    await h.settings.update(const ClockSettings());
    await tester.pump();
    expect(find.text(strings.clock.full_screen_note), findsOne);

    Future<void> tap(String label) async {
      await tester.tap(find.text(label));
      await tester.pump();
    }

    await tap(strings.clock.theme_light);
    await tap(strings.clock.use_24h);
    await tap(strings.clock.show_seconds);
    await tap(strings.clock.flip_sound);
    await tap(strings.clock.alert_sound);
    await tap(strings.clock.keep_screen_awake_description);
    await tap(strings.clock.subtle_movement);
    expect(
      h.settings.state,
      const ClockSettings(
        theme: ClockTheme.light,
        use24h: false,
        showSeconds: true,
        flipSound: true,
        alertSound: false,
        keepAwake: true,
        subtleMovement: true,
      ),
    );
    expect(h.settings.appearance.value, AppearanceMode.light);

    h.alerts.grant = false;
    await tap(strings.clock.system_notifications);
    expect(h.settings.state.systemAlerts, isFalse);
    expect(find.text(strings.clock.permission_denied), findsOne);
    h.alerts.grant = true;
    await tap(strings.clock.system_notifications);
    expect(h.settings.state.systemAlerts, isTrue);
    expect(find.text(strings.clock.permission_denied), findsNothing);
    await h.dispose(tester);
  });

  testWidgets('init registers everything; routes open settings and back', (
    tester,
  ) async {
    final store = FakeStore()
      ..data[SettingsRepositoryImp.settingsKey] = '{"theme":"light"}';
    di
      ..register<KeyValueStore>(store)
      ..register<LocalAlerts>(FakeAlerts())
      ..register<SoundPlayer>(FakeSound())
      ..register<FullScreenController>(FakeFullScreen())
      ..register<ScreenWake>(FakeWake());
    await flip_clock.init();
    expect(di.has<SettingsRepository>(), isTrue);
    expect(di.has<CountdownController>(), isTrue);
    expect(flip_clock.appearance().value, AppearanceMode.light);

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
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(FlipClockScreen), findsOne);
    await tester.pumpWidget(const SizedBox());
    unawaited(di.reset());
    await tester.pump();
  });
}
