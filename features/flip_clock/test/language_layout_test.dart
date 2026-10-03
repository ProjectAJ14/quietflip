import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:core/core.dart' show Logger;
import 'package:design_system/design_system.dart';
import 'package:di/di.dart';
import 'package:flip_clock/data/repositories/settings_repository_imp.dart';
import 'package:flip_clock/data/models/clock_settings.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flip_clock/ui/components/flip_display.dart';
import 'package:flip_clock/ui/components/skin_picker.dart';
import 'package:flip_clock/ui/screens/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';

import 'fakes.dart';
import 'screens_test.dart' show Harness, modeKey, showChrome;

/// Settings in [language] at [size], fonts loaded; close the returned
/// controller when done.
Future<SettingsController> _pumpSettings(
  WidgetTester tester,
  String language,
  Size size,
) async {
  LocalizationProvider.select([Locale(language)]);
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final settings = SettingsController(
    repository: SettingsRepositoryImp(
      store: FakeStore(),
      logger: di.get<Logger>(),
    ),
    alerts: FakeAlerts(),
  );
  await tester.pumpWidget(
    DesignSystemWrapper(
      mode: AppearanceMode.black,
      builder: (context, theme) => MaterialApp(
        theme: theme,
        locale: Locale(language),
        supportedLocales: LocalizationProvider.locales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: SettingsScreen(
          settings: settings,
          sound: FakeSound(),
          isWeb: false,
          orientationSupported: true,
          touchShortcuts: true,
          keyboardShortcuts: true,
          desktop: false,
          onDone: () {},
          onSkins: () {},
          onCustomize: () {},
          now: () => DateTime(2026, 9, 29, 9, 41),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.runAsync(GoogleFonts.pendingFonts);
  await tester.pumpAndSettle();
  return settings;
}

/// Long words (German), tall glyphs (Japanese) and right-to-left Arabic on a
/// phone and a tablet: every Settings page lays out without overflow. The
/// test font draws each glyph a full em wide, so text runs wider here than
/// on a device.
void main() {
  setUp(core.init);
  tearDown(() {
    LocalizationProvider.select(const []);
    di.reset();
  });

  const sizes = {'phone': Size(390, 844), 'tablet': Size(1024, 1366)};

  for (final language in ['de', 'ja', 'ar']) {
    for (final MapEntry(key: device, value: size) in sizes.entries) {
      testWidgets('Settings in $language on a $device', (tester) async {
        final settings = await _pumpSettings(tester, language, size);
        final c = strings.clock;
        for (final category in [
          c.settings_appearance,
          c.settings_clock,
          c.settings_gestures,
          c.settings_timers,
          c.settings_sound,
          c.settings_awake,
          c.settings_shortcuts,
          c.settings_about,
        ]) {
          final row = find.text(category).first;
          await tester.ensureVisible(row);
          await tester.pump(const Duration(seconds: 1));
          await tester.tap(row);
          // Fixed steps: the Shortcuts glyphs loop, so nothing settles.
          await tester.pump(const Duration(seconds: 1));
          expect(tester.takeException(), isNull, reason: category);
          final navigator = tester.state<NavigatorState>(
            find.byType(Navigator).last,
          );
          // A phone opens each page on its own; a tablet shows it beside
          // the list.
          expect(navigator.canPop(), device == 'phone', reason: category);
          if (navigator.canPop()) {
            navigator.pop();
            await tester.pump(const Duration(seconds: 1));
          }
        }
        await tester.pumpWidget(const SizedBox());
        unawaited(settings.close());
        await tester.pump(const Duration(seconds: 5));
      });
    }
  }

  for (final language in ['de', 'ja']) {
    for (final MapEntry(key: device, value: size) in sizes.entries) {
      testWidgets('the clock and its island in $language on a $device', (
        tester,
      ) async {
        LocalizationProvider.select([Locale(language)]);
        tester.view
          ..physicalSize = size
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final h = Harness();
        // 12-hour time with seconds and the date: the longest clock line.
        await h.settings.update(
          h.settings.state.copyWith(
            use24h: false,
            showSeconds: true,
            showDate: true,
          ),
        );
        await tester.pumpWidget(h.screen(locale: Locale(language)));
        await showChrome(tester);
        expect(tester.takeException(), isNull);
        // Pomodoro's tray: Start, the cycle chip and each preset.
        await modeKey(tester, LogicalKeyboardKey.arrowLeft);
        expect(find.text(strings.clock.preset_minutes(5)), findsOneWidget);
        expect(tester.takeException(), isNull);
        await modeKey(tester, LogicalKeyboardKey.arrowRight);
        await modeKey(tester, LogicalKeyboardKey.arrowRight);
        expect(tester.takeException(), isNull);
        await h.dispose(tester);
      });
    }
  }

  group('right to left (Arabic)', () {
    /// Whether the [Icon] found by [icon] is drawn mirrored.
    bool mirrored(WidgetTester tester, IconData icon) => tester
        .widgetList<Transform>(
          find.descendant(
            of: find.byIcon(icon).first,
            matching: find.byType(Transform),
          ),
        )
        .any((t) => t.transform.entry(0, 0) == -1);

    testWidgets('Settings on a tablet: the sidebar is on the right', (
      tester,
    ) async {
      final settings = await _pumpSettings(tester, 'ar', sizes['tablet']!);
      final c = strings.clock;
      final nav = tester.getRect(find.text(c.settings_appearance).first);
      final title = tester.getRect(find.text(c.settings_appearance).last);
      expect(nav.left, greaterThan(1024 - DesignSize.sidebarWidth));
      expect(title.right, lessThan(1024 - DesignSize.sidebarWidth));
      await tester.pumpWidget(const SizedBox());
      unawaited(settings.close());
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('Settings on a phone: the back chevron points right', (
      tester,
    ) async {
      final settings = await _pumpSettings(tester, 'ar', sizes['phone']!);
      expect(mirrored(tester, Icons.chevron_right_rounded), isTrue);
      await tester.tap(find.text(strings.clock.settings_appearance));
      await tester.pumpAndSettle();
      final back = find.byIcon(Icons.chevron_left_rounded);
      expect(mirrored(tester, Icons.chevron_left_rounded), isTrue);
      expect(tester.getCenter(back).dx, greaterThan(390 / 2));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      unawaited(settings.close());
      await tester.pump(const Duration(seconds: 5));
    });

    Future<Harness> clock(WidgetTester tester) async {
      LocalizationProvider.select(const [Locale('ar')]);
      // Landscape, so the cards sit in one row.
      tester.view
        ..physicalSize = const Size(844, 390)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final h = Harness();
      await h.settings.update(
        h.settings.state.copyWith(use24h: true, showDate: true),
      );
      await tester.pumpWidget(
        h.screen(locale: const Locale('ar'), orientationSupported: true),
      );
      await showChrome(tester);
      return h;
    }

    testWidgets('the clock: digits read left to right, chrome mirrors', (
      tester,
    ) async {
      final h = await clock(tester);
      expect(tester.takeException(), isNull);
      final display = find.byType(FlipDisplay);
      expect(
        Directionality.of(tester.element(find.text('09').first)),
        TextDirection.ltr,
      );
      expect(Directionality.of(tester.element(display)), TextDirection.rtl);
      expect(
        tester.getCenter(find.text('09').first).dx,
        lessThan(tester.getCenter(find.text('41').first).dx),
      );
      final c = strings.clock;
      // Skins and Rotation on the right, Settings on the left.
      expect(
        tester.getCenter(find.byTooltip(c.action_skins)).dx,
        greaterThan(844 / 2),
      );
      expect(
        tester.getCenter(find.byTooltip(c.action_settings)).dx,
        lessThan(844 / 2),
      );
      expect(
        tester.getCenter(find.byTooltip(c.action_rotation)).dx,
        lessThan(844 / 2),
      );
      // The mode tabs run right to left, as the pages do.
      expect(
        tester.getCenter(find.text(c.mode_pomodoro)).dx,
        greaterThan(tester.getCenter(find.text(c.mode_stopwatch)).dx),
      );
      await h.dispose(tester);
    });

    testWidgets('Left is the next mode, Right the previous', (tester) async {
      final h = await clock(tester);
      expect(h.settings.state.lastMode, ClockMode.clock);
      await modeKey(tester, LogicalKeyboardKey.arrowLeft);
      expect(h.settings.state.lastMode, ClockMode.stopwatch);
      await modeKey(tester, LogicalKeyboardKey.arrowRight);
      await modeKey(tester, LogicalKeyboardKey.arrowRight);
      expect(h.settings.state.lastMode, ClockMode.pomodoro);
      expect(tester.takeException(), isNull);
      await h.dispose(tester);
    });

    testWidgets('a swipe to the right moves to the next mode', (tester) async {
      final h = await clock(tester);
      await tester.dragFrom(const Offset(200, 250), const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(h.settings.state.lastMode, ClockMode.stopwatch);
      await tester.dragFrom(const Offset(600, 250), const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.dragFrom(const Offset(600, 250), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(h.settings.state.lastMode, ClockMode.pomodoro);
      await h.dispose(tester);
    });

    testWidgets('the Skins sheet: lays out, the check sits top-left', (
      tester,
    ) async {
      final h = await clock(tester);
      await tester.tap(find.byTooltip(strings.clock.action_skins));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final check = find.byType(SelectionCheck).first;
      final tile = find.ancestor(of: check, matching: find.byType(Stack)).first;
      expect(
        tester.getTopLeft(check).dx - tester.getTopLeft(tile).dx,
        lessThan(tester.getSize(tile).width / 2),
      );
      expect(tester.getSize(tile).width, greaterThan(100));
      await h.dispose(tester);
    });
  });
}
