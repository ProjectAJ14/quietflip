import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:core/core.dart' show Logger;
import 'package:design_system/design_system.dart';
import 'package:di/di.dart';
import 'package:flip_clock/data/repositories/settings_repository_imp.dart';
import 'package:flip_clock/flip_clock.dart';
import 'package:flip_clock/state/settings_controller.dart';
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
    await tap(tester, c.settings_skin);
    expect(skins, 1);
    expect(find.text(c.skin_mono), findsOne);
    await tap(tester, c.theme_system);
    expect(settings.state.theme, ClockTheme.system);
    expect(settings.appearance.value, AppearanceMode.system);
    await tap(tester, c.theme_light);
    expect(settings.appearance.value, AppearanceMode.light);
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
    for (final key in [c.keycap_space, c.keycap_left_right, c.keycap_esc]) {
      expect(find.text(key), findsOne);
    }

    // About.
    await tap(tester, c.settings_about);
    expect(find.text(c.about_privacy_value), findsOne);

    await tap(tester, strings.generic.done);
    expect(done, 1);
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
}
