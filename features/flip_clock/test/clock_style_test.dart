import 'package:flip_clock/data/models/clock_settings.dart';
import 'package:flip_clock/ui/components/display_value.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Runs [read] inside an app in [locale], with the device's 24-hour
  /// switch at [alwaysUse24].
  Future<T> inApp<T>(
    WidgetTester tester,
    T Function(BuildContext) read, {
    Locale locale = const Locale('en'),
    bool alwaysUse24 = false,
  }) async {
    late T value;
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('de'), Locale('ja')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: MediaQuery(
          data: MediaQueryData(alwaysUse24HourFormat: alwaysUse24),
          child: Builder(
            builder: (context) {
              value = read(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    return value;
  }

  group('uses24h', () {
    testWidgets('the user\'s choice wins over the device', (tester) async {
      expect(
        await inApp(
          tester,
          (c) => uses24h(c, const ClockSettings(use24h: false)),
          locale: const Locale('de'),
          alwaysUse24: true,
        ),
        isFalse,
      );
      expect(
        await inApp(tester, (c) => uses24h(c, const ClockSettings(use24h: true))),
        isTrue,
      );
    });

    testWidgets('unpicked, the language decides', (tester) async {
      expect(await inApp(tester, (c) => uses24h(c, const ClockSettings())), isFalse);
      expect(
        await inApp(
          tester,
          (c) => uses24h(c, const ClockSettings()),
          locale: const Locale('de'),
        ),
        isTrue,
      );
    });

    testWidgets('unpicked, the device\'s 24-hour switch wins', (tester) async {
      expect(
        await inApp(
          tester,
          (c) => uses24h(c, const ClockSettings()),
          alwaysUse24: true,
        ),
        isTrue,
      );
    });
  });

  testWidgets('meridiemOf gives the language\'s markers', (tester) async {
    expect(await inApp(tester, meridiemOf), (am: 'AM', pm: 'PM'));
    expect(
      await inApp(tester, meridiemOf, locale: const Locale('ja')),
      (am: '午前', pm: '午後'),
    );
  });
}
