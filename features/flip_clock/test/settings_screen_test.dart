import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:core/core.dart' show Logger;
import 'package:design_system/design_system.dart';
import 'package:di/di.dart';
import 'package:flip_clock/data/repositories/settings_repository_imp.dart';
import 'package:flip_clock/flip_clock.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flip_clock/ui/components/skin_picker.dart';
import 'package:flip_clock/ui/screens/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';

import 'fakes.dart';

void main() {
  late FakeAlerts alerts;
  late SettingsController settings;
  setUp(() async {
    await core.init();
    alerts = FakeAlerts();
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

  Future<void> open(
    WidgetTester tester, {
    Size size = const Size(1280, 900),
    double textScale = 1,
    AppearanceMode mode = AppearanceMode.black,
    bool? desktop = true,
    bool isWeb = true,
    bool orientation = true,
    bool openTimers = false,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    done = 0;
    skins = 0;
    await tester.pumpWidget(
      DesignSystemWrapper(
        mode: mode,
        builder: (context, theme) => MaterialApp(
          theme: theme,
          home: SettingsScreen(
            settings: settings,
            isWeb: isWeb,
            orientationSupported: orientation,
            desktop: desktop,
            onDone: () => done++,
            onSkins: () => skins++,
            openTimers: openTimers,
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
    await tester.drag(find.byType(Slider), const Offset(-2000, 0));
    await tester.pumpAndSettle();
    expect(settings.state.digitBrightness, ClockSettings.minBrightness);
    expect(find.text(c.percent('20')), findsOne);

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
    await tap(tester, c.flip_sound);
    await tap(tester, c.alert_sound);
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
    ]) {
      expect(find.text(key), findsOne);
    }

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
            home: SettingsScreen(settings: settings, desktop: true),
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

  testWidgets('orientation is hidden where the lock is unsupported', (
    tester,
  ) async {
    await open(tester, orientation: false, isWeb: false);
    await tap(tester, strings.clock.settings_clock);
    expect(find.text(strings.clock.orientation), findsNothing);
    await tap(tester, strings.clock.settings_sound);
    expect(find.text(strings.clock.web_closed_tab_note), findsNothing);
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
    Finder delete(String preset) => find.descendant(
      of: find.widgetWithText(SettingsValueRow, preset),
      matching: find.byTooltip(c.timers_delete),
    );

    testWidgets('default choice, delete, and the default falling back', (
      tester,
    ) async {
      await open(tester);
      await tap(tester, c.settings_timers);
      for (final label in [c.preset_pomodoro, '5m', '10m', '15m']) {
        expect(segment(label), findsOne, reason: label);
      }
      await tester.tap(segment('10m'));
      await tester.pumpAndSettle();
      expect(settings.state.defaultTimer, Minutes(m * 10));
      // Pomodoro lengths stay read-only.
      expect(find.text(c.timers_minutes(25)), findsOne);

      await tester.tap(delete('10m'));
      await tester.pumpAndSettle();
      expect(settings.state.timerPresets, [m * 5, m * 15]);
      expect(settings.state.defaultTimer, const PomodoroCycle());
      expect(segment('10m'), findsNothing);
      await close(tester);
    });

    testWidgets(
      'Add timer picks minutes and seconds; cancel and zero add none',
      (tester) async {
        await open(tester);
        await tap(tester, c.settings_timers);
        Future<void> enter(int field, String value) async {
          await tester.enterText(find.byType(TextField).at(field), value);
          await tester.pump();
        }

        Finder ok() => find.widgetWithText(TextButton, strings.generic.ok);

        await tap(tester, c.timers_add);
        await tap(tester, strings.generic.cancel);
        expect(settings.state.timerPresets, ClockSettings.defaultTimerPresets);

        await tap(tester, c.timers_add);
        await enter(0, '75');
        await enter(1, '30');
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
        expect(tester.widget<TextButton>(ok()).onPressed, isNull);
        await enter(0, '1');
        await enter(1, '60');
        expect(tester.widget<TextButton>(ok()).onPressed, isNull);
        await enter(1, 'ab');
        expect(tester.widget<TextButton>(ok()).onPressed, isNotNull);
        await tap(tester, strings.generic.cancel);
        await close(tester);
      },
    );

    testWidgets('six presets: Add is off and the footer says why', (
      tester,
    ) async {
      await settings.update(
        const ClockSettings().copyWith(
          timerPresets: [for (var i = 1; i <= 6; i++) m * i],
        ),
      );
      await open(tester);
      await tap(tester, c.settings_timers);
      expect(find.text(c.timers_limit_footer), findsOne);
      await tap(tester, c.timers_add);
      expect(find.byType(AlertDialog), findsNothing);
      await tester.tap(delete('1m'));
      await tester.pumpAndSettle();
      expect(find.text(c.timers_limit_footer), findsNothing);
      await close(tester);
    });

    testWidgets('openTimers starts on Timers, and Done closes', (tester) async {
      await open(tester, size: const Size(375, 800), openTimers: true);
      expect(find.text(c.timers_presets.toUpperCase()), findsOne);
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
}
