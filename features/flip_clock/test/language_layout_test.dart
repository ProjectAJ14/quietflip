import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:core/core.dart' show Logger;
import 'package:design_system/design_system.dart';
import 'package:di/di.dart';
import 'package:flip_clock/data/repositories/settings_repository_imp.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flip_clock/ui/screens/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';

import 'fakes.dart';
import 'screens_test.dart' show Harness, modeKey, showChrome;

/// Long words (German) and tall glyphs (Japanese) on a phone and a tablet:
/// every Settings page lays out without overflow. The test font draws each
/// glyph a full em wide, so text runs wider here than on a device.
void main() {
  setUp(core.init);
  tearDown(() {
    LocalizationProvider.select(const []);
    di.reset();
  });

  const sizes = {'phone': Size(390, 844), 'tablet': Size(1024, 1366)};

  for (final language in ['de', 'ja']) {
    for (final MapEntry(key: device, value: size) in sizes.entries) {
      testWidgets('Settings in $language on a $device', (tester) async {
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
}
