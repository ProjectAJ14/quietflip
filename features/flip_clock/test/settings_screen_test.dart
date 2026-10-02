import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:core/core.dart' show Logger;
import 'package:design_system/design_system.dart';
import 'package:device_services/device_services.dart';
import 'package:di/di.dart';
import 'package:flip_clock/data/repositories/settings_repository_imp.dart';
import 'package:flip_clock/flip_clock.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flip_clock/ui/components/display_value.dart';
import 'package:flip_clock/ui/components/skin_picker.dart';
import 'package:flip_clock/ui/components/sound_wave.dart';
import 'package:flip_clock/ui/screens/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';

import 'fakes.dart';

void main() {
  late FakeAlerts alerts;
  late FakeSound sound;
  late SettingsController settings;
  setUp(() async {
    await core.init();
    alerts = FakeAlerts();
    sound = FakeSound();
    settings = SettingsController(
      repository: SettingsRepositoryImp(
        store: FakeStore(),
        logger: di.get<Logger>(),
      ),
      alerts: alerts,
    );
  });
  tearDown(di.reset);

  var done = 0;
  var skins = 0;
  var customized = 0;

  Future<void> open(
    WidgetTester tester, {
    Size size = const Size(1280, 900),
    double textScale = 1,
    AppearanceMode mode = AppearanceMode.black,
    bool? desktop = true,
    bool isWeb = true,
    bool orientation = true,
    String? category,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    done = 0;
    skins = 0;
    customized = 0;
    await tester.pumpWidget(
      DesignSystemWrapper(
        mode: mode,
        builder: (context, theme) => MaterialApp(
          theme: theme,
          home: SettingsScreen(
            settings: settings,
            sound: sound,
            isWeb: isWeb,
            orientationSupported: orientation,
            desktop: desktop,
            onDone: () => done++,
            onSkins: () => skins++,
            onCustomize: () => customized++,
            category: category,
            now: () => DateTime(2026, 9, 29, 9, 41),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Bundled fonts load asynchronously; one landing between layout and
    // paint trips a debug-only text assertion, so let them finish first.
    await tester.runAsync(GoogleFonts.pendingFonts);
    await tester.pumpAndSettle();
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    unawaited(settings.close());
    // Let tooltip and ripple timers run out.
    await tester.pump(const Duration(seconds: 5));
  }

  Future<void> tap(WidgetTester tester, String label) async {
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  testWidgets('every category saves its settings', (tester) async {
    await open(tester);
    final c = strings.clock;

    // Appearance.
    await tap(tester, c.skins_view_all);
    expect(skins, 1);
    // The strip's selected tile offers Customize, and only that one.
    expect(find.text(c.skins_customize), findsOne);
    await tap(tester, c.skins_customize);
    expect(customized, 1);
    expect(find.text(c.skin_mono), findsOne);
    await tap(tester, c.theme_system);
    expect(settings.state.theme, ClockTheme.system);
    expect(settings.appearance.value, AppearanceMode.system);
    await tap(tester, c.theme_light);
    expect(settings.appearance.value, AppearanceMode.light);
    // Card size, after Theme; starts Large, so each tap is a change.
    expect(find.text(c.settings_card_size), findsOne);
    for (final (size, label) in [
      (CardSize.small, c.card_size_small),
      (CardSize.medium, c.card_size_medium),
      (CardSize.large, c.card_size_large),
    ]) {
      await tap(tester, label);
      expect(settings.state.cardSize, size);
    }
    await tester.drag(find.byType(Slider).first, const Offset(-2000, 0));
    await tester.pumpAndSettle();
    expect(settings.state.digitBrightness, ClockSettings.minBrightness);
    expect(find.text(c.percent('20')), findsOne);
    // Corners: a live sample over a slider from Square to Round.
    await tester.ensureVisible(find.byType(Slider).last);
    await tester.pumpAndSettle();
    expect(find.text(c.settings_corners), findsWidgets);
    expect(find.text(c.corners_square), findsOne);
    expect(find.text(c.corners_round), findsOne);
    expect(find.text(c.corners_value('14')), findsOne);
    expect(find.text('12'), findsWidgets);
    // The sample is look only: its button is drawn enabled and does nothing.
    final sample = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, c.action_start),
    );
    final before = settings.state;
    sample.onPressed!();
    expect(settings.state, before);
    await tester.drag(find.byType(Slider).last, const Offset(-2000, 0));
    await tester.pumpAndSettle();
    expect(settings.state.corner, DesignShape.minCorner);
    expect(find.text(c.corners_value('0')), findsOne);
    await tester.drag(find.byType(Slider).last, const Offset(2000, 0));
    await tester.pumpAndSettle();
    expect(settings.state.corner, DesignShape.maxCorner);
    expect(settings.corner.value, DesignShape.maxCorner);

    // Clock.
    await tap(tester, c.settings_clock);
    await tap(tester, c.use_24h);
    await tap(tester, c.show_seconds);
    await tap(tester, c.show_date);
    await tap(tester, c.orientation_landscape);
    expect(settings.state.use24h, isFalse);
    expect(settings.state.showSeconds, isTrue);
    expect(settings.state.showDate, isTrue);
    expect(settings.state.orientation, ClockOrientation.landscape);

    // Gestures.
    await tap(tester, c.settings_gestures);
    expect(find.text(c.gesture_footer), findsOne);
    await tap(tester, c.gesture_brightness);
    await tap(tester, c.gesture_modes);
    await tap(tester, c.gesture_tap);
    await tap(tester, c.gesture_idle_never);
    expect(settings.state.gestureBrightness, isFalse);
    expect(settings.state.gestureModes, isFalse);
    expect(settings.state.tapToggleControls, isFalse);
    expect(settings.state.controlsIdle, Duration.zero);
    await tap(tester, c.gesture_idle_seconds(8));
    expect(settings.state.controlsIdle, const Duration(seconds: 8));

    // Timers.
    await tap(tester, c.settings_timers);
    expect(find.text(c.timers_minutes(25)), findsOne);
    expect(find.text(c.timers_minutes(5)), findsOne);

    // Sound & alerts.
    await tap(tester, c.settings_sound);
    expect(find.text(c.web_closed_tab_note), findsOne);
    await tap(tester, c.tick_sound);
    await tap(tester, c.alarm_sound);
    expect(settings.state.flipSound, isTrue);
    expect(settings.state.alertSound, isFalse);
    alerts.grant = false;
    await tap(tester, c.system_notifications);
    expect(settings.state.systemAlerts, isFalse);
    expect(find.text(c.permission_denied), findsOne);
    alerts.grant = true;
    await tap(tester, c.system_notifications);
    expect(settings.state.systemAlerts, isTrue);
    expect(find.text(c.permission_denied), findsNothing);

    // Keep awake.
    await tap(tester, c.settings_awake);
    expect(find.text(c.full_screen_note), findsOne);
    await tap(tester, c.keep_screen_awake);
    await tap(tester, c.subtle_movement);
    expect(settings.state.keepAwake, isTrue);
    expect(settings.state.subtleMovement, isTrue);

    // Shortcuts.
    await tap(tester, c.settings_shortcuts);
    for (final key in [
      c.keycap_space,
      c.keycap_left_right,
      c.keycap_esc,
      c.keycap_l,
      c.keycap_r,
    ]) {
      expect(find.text(key), findsOne);
    }
    expect(find.text(c.key_rotation), findsOne);

    // About.
    await tap(tester, c.settings_about);
    expect(find.text(c.about_privacy_value), findsOne);

    await tap(tester, strings.generic.done);
    expect(done, 1);
    await close(tester);
  });

  testWidgets('Theme Light repaints the settings page on the light bg', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1280, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // Wired like apps/quietflip/lib/app.dart: the saved theme drives the
    // wrapper, so the page follows the choice without a restart.
    await tester.pumpWidget(
      ValueListenableBuilder<AppearanceMode>(
        valueListenable: settings.appearance,
        builder: (context, mode, _) => DesignSystemWrapper(
          mode: mode,
          builder: (context, theme) => MaterialApp(
            theme: theme,
            home: SettingsScreen(
              settings: settings,
              sound: sound,
              desktop: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(GoogleFonts.pendingFonts);
    await tester.pumpAndSettle();
    Color? page() => tester
        .widget<Material>(
          find
              .descendant(
                of: find.byType(SettingsShell),
                matching: find.byType(Material),
              )
              .first,
        )
        .color;
    expect(page(), DesignColors.dark.bg);

    await tap(tester, strings.clock.theme_light);
    await tester.runAsync(GoogleFonts.pendingFonts);
    await tester.pumpAndSettle();
    expect(settings.state.theme, ClockTheme.light);
    expect(settings.appearance.value, AppearanceMode.light);
    expect(page(), DesignColors.light.bg);

    await tap(tester, strings.clock.theme_dark);
    expect(settings.appearance.value, AppearanceMode.black);
    expect(page(), DesignColors.dark.bg);
    await close(tester);
  });

  testWidgets('About > Licenses opens the licence list', (tester) async {
    await open(tester);
    await tap(tester, strings.clock.settings_about);
    await tester.tap(find.text(strings.clock.about_licenses));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(LicensePage), findsOne);
    await close(tester);
  });

  testWidgets('iPhone landscape: the shell reaches both side edges', (
    tester,
  ) async {
    tester.view.padding = const FakeViewPadding(left: 59, right: 59);
    await open(
      tester,
      size: const Size(852, 393),
      desktop: false,
      isWeb: false,
    );
    expect(tester.getRect(find.byType(SettingsShell)).width, 852);
    final sidebar = tester.getRect(
      find
          .byWidgetPredicate(
            (w) =>
                w is ColoredBox && w.color == DesignColors.dark.surfaceSidebar,
          )
          .first,
    );
    expect(sidebar.left, 0);
    await close(tester);
  });

  testWidgets('orientation is hidden where the lock is unsupported', (
    tester,
  ) async {
    await open(tester, orientation: false, isWeb: false);
    await tap(tester, strings.clock.settings_clock);
    expect(find.text(strings.clock.orientation), findsNothing);
    await tap(tester, strings.clock.settings_sound);
    expect(find.text(strings.clock.web_closed_tab_note), findsNothing);
    // No rotation shortcut either.
    await tap(tester, strings.clock.settings_shortcuts);
    expect(find.text(strings.clock.key_rotation), findsNothing);
    await close(tester);
  });

  for (final web in [false, true]) {
    testWidgets('density follows the platform when not given (web $web)', (
      tester,
    ) async {
      // Tests run as Android: phone density unless on the web.
      await open(tester, desktop: null, isWeb: web, size: const Size(375, 800));
      expect(find.text(strings.clock.settings_gestures), findsOne);
      await close(tester);
    });
  }

  for (final mode in [AppearanceMode.black, AppearanceMode.light]) {
    for (final width in [375.0, 820.0, 1280.0]) {
      testWidgets('lays out at ${width}px in ${mode.name} at text scale 2', (
        tester,
      ) async {
        await open(
          tester,
          size: Size(width, 800),
          textScale: 2,
          mode: mode,
          desktop: false,
        );
        expect(tester.takeException(), isNull);
        await tap(tester, strings.clock.settings_gestures);
        expect(tester.takeException(), isNull);
        expect(find.text(strings.clock.gesture_brightness), findsOne);
        await close(tester);
      });
    }
  }

  group('Timers', () {
    final c = strings.clock;
    const m = Duration(minutes: 1);
    Finder segment(String label) => find.descendant(
      of: find.byType(SegmentedButton<TimerPreset>),
      matching: find.text(label),
    );
    Finder delete(Duration preset) =>
        find.byTooltip(c.timers_delete(presetSpoken(preset)));

    for (final width in [375.0, 820.0, 1280.0]) {
      testWidgets('default choice, delete, default falls back ($width)', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        await open(tester, size: Size(width, 900));
        await tap(tester, c.settings_timers);
        for (final label in [c.preset_pomodoro, '5m', '10m', '15m']) {
          expect(segment(label), findsOne, reason: label);
        }
        // Rows say what the abbreviation means.
        expect(find.bySemanticsLabel(presetSpoken(m * 10)), findsOne);
        await tester.tap(segment('10m'));
        await tester.pumpAndSettle();
        expect(settings.state.defaultTimer, Minutes(m * 10));

        await tester.tap(delete(m * 10));
        await tester.pumpAndSettle();
        expect(settings.state.timerPresets, [m * 5, m * 15]);
        expect(settings.state.defaultTimer, const PomodoroCycle());
        expect(segment('10m'), findsNothing);
        expect(tester.takeException(), isNull);
        semantics.dispose();
        await close(tester);
      });

      testWidgets(
        'Add timer: pick, cancel, refuse zero and duplicates ($width)',
        (tester) async {
          await open(tester, size: Size(width, 900));
          await tap(tester, c.settings_timers);
          Future<void> enter(int field, String value) async {
            await tester.enterText(find.byType(TextField).at(field), value);
            await tester.pump();
          }

          Finder ok() => find.widgetWithText(TextButton, strings.generic.ok);
          bool canConfirm() =>
              tester.widget<TextButton>(ok()).onPressed != null;

          await tap(tester, c.timers_add);
          await tap(tester, strings.generic.cancel);
          expect(
            settings.state.timerPresets,
            ClockSettings.defaultTimerPresets,
          );

          await tap(tester, c.timers_add);
          // It opens on 5:00, which is already a preset.
          expect(canConfirm(), isFalse);
          expect(find.text(c.timers_duplicate), findsOne);
          await enter(0, '75');
          await enter(1, '30');
          expect(find.text(c.timers_duplicate), findsNothing);
          await tap(tester, strings.generic.ok);
          expect(settings.state.timerPresets, [
            m * 5,
            m * 10,
            m * 15,
            const Duration(minutes: 75, seconds: 30),
          ]);
          expect(find.widgetWithText(SettingsValueRow, '75:30'), findsOne);

          // 0:00 and 60 seconds cannot be confirmed; letters never land.
          await tap(tester, c.timers_add);
          await enter(0, '');
          expect(canConfirm(), isFalse);
          await enter(0, '1');
          await enter(1, '60');
          expect(canConfirm(), isFalse);
          await enter(1, 'ab');
          expect(canConfirm(), isTrue);
          await tap(tester, strings.generic.cancel);
          await close(tester);
        },
      );

      testWidgets('six presets: Add is off and the footer says why ($width)', (
        tester,
      ) async {
        await settings.update(
          const ClockSettings().copyWith(
            timerPresets: [for (var i = 1; i <= 6; i++) m * i],
          ),
        );
        await open(tester, size: Size(width, 900));
        await tap(tester, c.settings_timers);
        await tester.scrollUntilVisible(
          find.text(c.timers_limit_footer),
          100,
          scrollable: find.byType(Scrollable).last,
        );
        await tap(tester, c.timers_add);
        expect(find.byType(AlertDialog), findsNothing);
        await tester.tap(delete(m));
        await tester.pumpAndSettle();
        expect(find.text(c.timers_limit_footer), findsNothing);
        await close(tester);
      });
    }

    test('spoken preset names', () {
      expect(presetSpoken(m * 5), c.preset_spoken_minutes(5));
      expect(
        presetSpoken(const Duration(seconds: 45)),
        c.preset_spoken_seconds(45),
      );
      expect(
        presetSpoken(const Duration(minutes: 1, seconds: 30)),
        c.preset_spoken_both(1, 30),
      );
    });

    testWidgets('openTimers starts on Timers, and Done closes', (tester) async {
      await open(tester, size: const Size(375, 800), category: 'timers');
      expect(find.text(c.timers_presets.toUpperCase()), findsOne);
      expect(find.text(c.timers_minutes(25)), findsOne);
      await tap(tester, strings.generic.done);
      expect(done, 1);
      await close(tester);
    });
  });

  group('Appearance skins strip', () {
    final c = strings.clock;
    for (final width in [375.0, 820.0, 1280.0]) {
      testWidgets('shows five skins, applies one, View all ($width)', (
        tester,
      ) async {
        await open(tester, size: Size(width, 900));
        // The phone layout starts on the category list.
        if (width < SettingsShell.splitBreakpoint) {
          await tap(tester, c.settings_appearance);
        }
        final tiles = find.byType(SkinTile);
        expect(tiles, findsNWidgets(SettingsScreen.skinStrip));
        expect(tester.widget<SkinTile>(tiles.first).selected, isTrue);
        await tester.tap(find.bySemanticsLabel(c.skin_paper));
        await tester.pumpAndSettle();
        expect(settings.state.skinId, 'paper');
        expect(
          tester
              .widgetList<SkinTile>(tiles)
              .where((t) => t.selected)
              .map((t) => t.skin.id),
          ['paper'],
        );
        await tap(tester, c.skins_view_all);
        expect(skins, 1);
        expect(tester.takeException(), isNull);
        await close(tester);
      });
    }

    testWidgets('a selected skin further down the list is always shown', (
      tester,
    ) async {
      await settings.selectSkin('orbit');
      await open(tester);
      final tiles = tester.widgetList<SkinTile>(find.byType(SkinTile));
      expect(tiles.first.skin.id, 'orbit');
      expect(tiles.first.selected, isTrue);
      expect(tiles, hasLength(SettingsScreen.skinStrip));
      await close(tester);
    });
  });

  group('Sound & alerts', () {
    final c = strings.clock;

    Future<void> openSound(
      WidgetTester tester, {
      Size size = const Size(1280, 900),
      double textScale = 1,
    }) async {
      await open(tester, size: size, textScale: textScale, desktop: false);
      await tap(tester, c.settings_sound);
    }

    /// Taps a tile without settling, so fake time stays where the test is.
    Future<void> pick(WidgetTester tester, String name) async {
      await tester.ensureVisible(find.text(name));
      await tester.pump();
      await tester.tap(find.text(name));
      await tester.pump();
    }

    Future<void> wait(WidgetTester tester, int ms) =>
        tester.pump(Duration(milliseconds: ms));

    testWidgets('two rows of five tiles, Classic and Chime selected', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openSound(tester);
      for (final name in [c.tick_classic, c.tick_digital, c.alarm_ring]) {
        expect(find.text(name), findsOne);
      }
      expect(find.byType(SoundWave), findsNWidgets(10));
      expect(find.text(c.sound_tick_hint), findsOne);
      expect(find.text(c.sound_alarm_hint), findsOne);
      expect(
        tester.getSemantics(
          find.bySemanticsLabel(
            '${c.tick_woodblock}, ${c.tick_woodblock_mood}',
          ),
        ),
        isSemantics(isInMutuallyExclusiveGroup: true, hasCheckedState: true),
      );
      expect(
        tester.getSemantics(
          find.bySemanticsLabel('${c.tick_classic}, ${c.tick_classic_mood}'),
        ),
        isSemantics(
          isInMutuallyExclusiveGroup: true,
          hasCheckedState: true,
          isChecked: true,
        ),
      );
      handle.dispose();
      await close(tester);
    });

    testWidgets('tap selects, saves, turns the tick on and ticks 3 times', (
      tester,
    ) async {
      await openSound(tester);
      expect(settings.state.flipSound, isFalse);
      await pick(tester, c.tick_woodblock);
      expect(settings.state.tickSound, TickSound.woodblock);
      expect(settings.state.flipSound, isTrue, reason: 'picking turns it on');
      expect(sound.ticks, [TickSound.woodblock]);
      final wave = find.byWidgetPredicate(
        (w) => w is SoundWave && w.playing != null,
      );
      expect(wave, findsOne, reason: 'its wave moves');
      await wait(tester, 999);
      expect(sound.ticks, hasLength(1));
      await wait(tester, 1);
      expect(sound.ticks, hasLength(2));
      await wait(tester, 1000);
      expect(sound.ticks, [for (var i = 0; i < 3; i++) TickSound.woodblock]);
      await wait(tester, 1500);
      expect(sound.ticks, hasLength(3), reason: 'three ticks only');
      expect(wave, findsNothing, reason: 'back to rest');
      expect(sound.stops, 0);
      await close(tester);
    });

    testWidgets('an alarm preview plays two loops, then stops', (tester) async {
      await openSound(tester);
      await pick(tester, c.alarm_beeps);
      expect(settings.state.alarmSound, AlarmSound.beeps);
      expect(sound.played, [AlarmSound.beeps]);
      await wait(tester, 2190);
      expect(sound.stops, 0);
      await wait(tester, 20);
      expect(sound.stops, 1, reason: '2 x 1.1 s');
      await close(tester);
      expect(sound.stops, 1, reason: 'leaving does not stop it twice');
    });

    testWidgets('a second tap cancels the first preview', (tester) async {
      await openSound(tester);
      await pick(tester, c.alarm_bell);
      await wait(tester, 500);
      await pick(tester, c.tick_clockwork);
      expect(sound.stops, 1, reason: 'the bell preview stops');
      await pick(tester, c.tick_digital);
      await wait(tester, 5000);
      expect(sound.played, [AlarmSound.bell]);
      expect(sound.stops, 1, reason: 'the bell timer was cancelled');
      expect(sound.ticks, [
        TickSound.clockwork,
        for (var i = 0; i < 3; i++) TickSound.digital,
      ]);
      await close(tester);
    });

    for (final (kind, first, second, picked) in [
      (
        'tick',
        c.tick_woodblock,
        c.tick_digital,
        () => settings.state.tickSound == TickSound.digital,
      ),
      (
        'alarm',
        c.alarm_bell,
        c.alarm_beeps,
        () => settings.state.alarmSound == AlarmSound.beeps,
      ),
    ]) {
      testWidgets('two $kind taps in one frame both land, keeping a change '
          'made between them', (tester) async {
        await openSound(tester);
        await tester.ensureVisible(find.text(first));
        await tester.pump();
        final use24h = settings.state.use24h;
        // No pump between: the second tap runs on the frame the first saw.
        await tester.tap(find.text(first));
        unawaited(settings.update(settings.state.copyWith(use24h: !use24h)));
        await tester.tap(find.text(second));
        await tester.pump();
        expect(picked(), isTrue, reason: 'the second tap wins');
        expect(settings.state.use24h, !use24h, reason: 'nothing reverted');
        await close(tester);
      });
    }

    testWidgets('leaving cancels the preview, stopping only its own alarm', (
      tester,
    ) async {
      await openSound(tester);
      await pick(tester, c.tick_split_flap);
      await tester.pumpWidget(const SizedBox());
      await wait(tester, 5000);
      expect(sound.ticks, [TickSound.splitFlap], reason: 'no more ticks');
      expect(sound.stops, 0, reason: 'a real alarm keeps ringing');
      unawaited(settings.close());

      sound = FakeSound();
      settings = SettingsController(
        repository: SettingsRepositoryImp(
          store: FakeStore(),
          logger: di.get<Logger>(),
        ),
        alerts: alerts,
      );
      await openSound(tester);
      await pick(tester, c.alarm_rising);
      await wait(tester, 1000);
      await close(tester);
      expect(sound.stops, 1, reason: 'its own alarm stops');
    });

    testWidgets('tiles dim while their switch is off; a tap turns it on', (
      tester,
    ) async {
      await settings.update(const ClockSettings(alertSound: false));
      await openSound(tester);
      double opacityOver(String name) => tester
          .widget<Opacity>(
            find.ancestor(of: find.text(name), matching: find.byType(Opacity)),
          )
          .opacity;
      expect(opacityOver(c.tick_classic), 0.45, reason: 'tick is off');
      expect(opacityOver(c.alarm_chime), 0.45);
      await pick(tester, c.alarm_chime);
      expect(settings.state.alertSound, isTrue);
      expect(settings.state.flipSound, isFalse, reason: 'only its own kind');
      expect(opacityOver(c.alarm_chime), 1);
      await tester.tap(find.text(c.tick_sound));
      await tester.pump();
      expect(settings.state.flipSound, isTrue);
      await close(tester);
    });

    for (final (width, rows) in [(900.0, 1), (360.0, 2)]) {
      testWidgets('${width}px wide: tiles in $rows row(s)', (tester) async {
        await openSound(tester, size: Size(width, 900));
        final tops = {
          for (final tick in TickSound.values)
            tester
                .getTopLeft(
                  // The five tick waves come first.
                  find.byType(SoundWave).at(tick.index),
                )
                .dy,
        };
        expect(tops, hasLength(rows));
        await close(tester);
      });
    }

    for (final width in [360.0, 1280.0]) {
      testWidgets('text scale 2 at ${width}px never clips', (tester) async {
        await openSound(tester, size: Size(width, 900), textScale: 2);
        expect(tester.takeException(), isNull);
        final name = tester.renderObject<RenderParagraph>(
          find.text(c.tick_split_flap),
        );
        expect(name.didExceedMaxLines, isFalse, reason: 'two lines at most');
        await close(tester);
      });
    }

    testWidgets('Enter on a focused tile selects and previews it', (
      tester,
    ) async {
      await openSound(tester);
      // The tile's InkWell owns the nearest focus node.
      Focus.of(tester.element(find.text(c.tick_digital))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(settings.state.tickSound, TickSound.digital);
      expect(sound.ticks, [TickSound.digital]);
      await close(tester);
    });
  });
}
