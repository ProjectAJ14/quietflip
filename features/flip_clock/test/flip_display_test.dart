import 'package:design_system/design_system.dart';
import 'package:flip_clock/ui/components/flip_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child, {bool reduceMotion = false}) => MaterialApp(
  theme: ThemeData(colorScheme: DesignSystem.blackScheme()),
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('shows every character and a single semantics label', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const FlipDisplay(text: '9:41 AM', semanticsLabel: 'Now 9:41 AM')),
    );
    for (final c in ['9', '4', '1', 'A', 'M', ':']) {
      expect(find.text(c), findsWidgets);
    }
    expect(find.bySemanticsLabel('Now 9:41 AM'), findsOneWidget);
    expect(find.byKey(FlipDisplay.flapKey), findsNothing);
  });

  testWidgets('digits grow to fill a large centred space', (tester) async {
    tester.view.physicalSize = const Size(1280, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      host(const FlipDisplay(text: '22:42', semanticsLabel: '22:42')),
    );
    // getRect is in screen space, so it includes the FittedBox scale.
    expect(tester.getRect(find.byType(Row).first).width, greaterThan(768));
  });

  testWidgets('only the changed card folds; value is shown at once', (
    tester,
  ) async {
    var flips = 0;
    Widget display(String t) =>
        host(FlipDisplay(text: t, semanticsLabel: t, onFlip: () => flips++));
    await tester.pumpWidget(display('12:34.5'));
    await tester.pumpWidget(display('12:34.5'));
    expect(flips, 0);

    await tester.pumpWidget(display('12:35.5'));
    expect(flips, 1);
    // New digit visible on the top half immediately.
    expect(find.text('5'), findsWidgets);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(FlipDisplay.flapKey), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(FlipDisplay.flapKey), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byKey(FlipDisplay.flapKey), findsNothing);
    expect(find.bySemanticsLabel('12:35.5'), findsOneWidget);

    // Two cards change: two flaps.
    await tester.pumpWidget(display('12:46.5'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byKey(FlipDisplay.flapKey), findsNWidgets(2));
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion changes instantly', (tester) async {
    await tester.pumpWidget(
      host(
        const FlipDisplay(text: '00:00:01', semanticsLabel: 'a'),
        reduceMotion: true,
      ),
    );
    await tester.pumpWidget(
      host(
        const FlipDisplay(text: '00:00:00', semanticsLabel: 'b'),
        reduceMotion: true,
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byKey(FlipDisplay.flapKey), findsNothing);
    expect(find.text('1'), findsNothing);
  });

  testWidgets('iOS Reduce Motion also changes instantly', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(reduceMotion: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      host(const FlipDisplay(text: '1', semanticsLabel: 'a')),
    );
    await tester.pumpWidget(
      host(const FlipDisplay(text: '2', semanticsLabel: 'b')),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byKey(FlipDisplay.flapKey), findsNothing);
  });

  for (final size in const [Size(200, 100), Size(2000, 1200)]) {
    testWidgets('fits a ${size.width}x${size.height} window without overflow', (
      tester,
    ) async {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        host(const FlipDisplay(text: '123:59:59.9', semanticsLabel: 'x')),
      );
      expect(tester.takeException(), isNull);
      final box = tester.getSize(find.byType(FlipDisplay));
      expect(box.width, lessThanOrEqualTo(size.width));
      expect(box.height, lessThanOrEqualTo(size.height));
    });
  }

  testWidgets('large text scale still fits', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: const Scaffold(
            body: FlipDisplay(text: '09:41', semanticsLabel: 'x'),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
