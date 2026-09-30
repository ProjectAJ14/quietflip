import 'package:design_system/design_system.dart';
import 'package:flip_clock/data/models/skin.dart';
import 'package:flip_clock/ui/components/display_value.dart';
import 'package:flip_clock/ui/components/flip_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const mono = Skin(id: 'mono', name: 'Mono');

Widget host(Widget child, {bool reduceMotion = false}) => MaterialApp(
  theme: ThemeData(colorScheme: DesignSystem.blackScheme()),
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Scaffold(body: Center(child: child)),
  ),
);

FlipDisplay display(
  List<String> cards, {
  Skin skin = mono,
  String label = 'x',
  String? badge,
  String? meridiem,
  VoidCallback? onFlip,
  double size = 1,
}) => FlipDisplay(
  cards: cards,
  skin: skin,
  semanticsLabel: label,
  badge: badge,
  meridiem: meridiem,
  onFlip: onFlip,
  size: size,
);

double fontSizeOf(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style!.fontSize!;

Finder cardFill(Color color) => find.byWidgetPredicate(
  (w) =>
      w is Container &&
      w.decoration is BoxDecoration &&
      (w.decoration! as BoxDecoration).color == color,
);

void main() {
  testWidgets('one card per entry, a single semantics label', (tester) async {
    await tester.pumpWidget(
      host(display(['9', '41'], label: 'Now 9:41 AM', meridiem: 'AM')),
    );
    expect(find.text('9'), findsWidgets);
    expect(find.text('41'), findsWidgets);
    expect(find.text('AM'), findsOne);
    expect(find.bySemanticsLabel('Now 9:41 AM'), findsOneWidget);
    expect(find.byKey(FlipDisplay.flapKey), findsNothing);
  });

  testWidgets('the skin paints the cards, digits and seam', (tester) async {
    const skin = Skin(
      id: 'x',
      name: 'x',
      face: DisplayFace.orbitron,
      digitColor: DesignSkinColors.cyan,
      cardColor: DesignSkinColors.cardPaper,
      groundColor: DesignSkinColors.bgPaper,
    );
    await tester.pumpWidget(host(display(['12', '34'], skin: skin)));
    // Two halves per card.
    expect(cardFill(DesignSkinColors.cardPaper), findsNWidgets(4));
    final digit = tester.widget<Text>(find.text('12').first);
    expect(digit.style!.color, DesignSkinColors.cyan);
    expect(digit.style!.fontFamily, startsWith('Orbitron'));
    expect(digit.textScaler, TextScaler.noScaling);
    // The seam shows the ground, 2px, one per card.
    final seams = tester.widgetList<Container>(
      find.byWidgetPredicate(
        (w) => w is Container && w.color == DesignSkinColors.bgPaper,
      ),
    );
    expect(seams, hasLength(2));
  });

  testWidgets('no seam when the skin turns it off', (tester) async {
    await tester.pumpWidget(
      host(display(['12'], skin: mono.copyWith(seam: false))),
    );
    final seam = tester.getSize(
      find.byWidgetPredicate(
        (w) => w is Container && w.color == DesignSkinColors.bgInk,
      ),
    );
    expect(seam.height, 0);
  });

  testWidgets('cards fill a large space; digits are 0.78 x card height', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(display(['22', '42'])));
    final card = tester.getSize(cardFill(DesignSkinColors.cardInk).first);
    // Two cards and one 24px gap across 1280px: 628px cards (under 760).
    expect(card.height, closeTo((628 - 2) / 2, 0.01));
    final digit = tester.widget<Text>(find.text('22').first);
    expect(digit.style!.fontSize, closeTo(628 * 0.78, 0.01));
  });

  testWidgets('radius-md cards become radius-lg at digit-l sizes', (
    tester,
  ) async {
    BorderRadius radiusAt(Size size) {
      final c = tester.widget<Container>(
        cardFill(DesignSkinColors.cardInk).first,
      );
      return (c.decoration! as BoxDecoration).borderRadius! as BorderRadius;
    }

    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.view.physicalSize = const Size(800, 400);
    await tester.pumpWidget(host(display(['22', '42'])));
    expect(radiusAt(const Size(800, 400)).topLeft.x, DesignRadius.lg);
    tester.view.physicalSize = const Size(300, 100);
    await tester.pumpWidget(host(display(['22', '42'])));
    expect(radiusAt(const Size(300, 100)).topLeft.x, DesignRadius.md);
  });

  testWidgets('a monospaced face gets wider cards', (tester) async {
    tester.view.physicalSize = const Size(2000, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      host(
        display(['12'], skin: mono.copyWith(face: DisplayFace.jetBrainsMono)),
      ),
    );
    final card = tester.getSize(cardFill(DesignSkinColors.cardInk).first);
    expect(card.width, closeTo(400 * 1.3, 0.01));
  });

  testWidgets('AM/PM goes inside, beside or nowhere; the badge sits last', (
    tester,
  ) async {
    for (final place in SkinMeridiem.values) {
      await tester.pumpWidget(
        host(
          display(
            ['9', '41'],
            skin: mono.copyWith(meridiem: place),
            meridiem: 'PM',
            badge: '07',
          ),
        ),
      );
      expect(
        find.text('PM'),
        place == SkinMeridiem.hidden ? findsNothing : findsOne,
      );
      expect(find.text('07'), findsOne);
      if (place != SkinMeridiem.hidden) {
        final pm = tester.getCenter(find.text('PM'));
        final first = tester.getCenter(find.text('9').first);
        expect(pm.dx < first.dx, place == SkinMeridiem.left);
      }
    }
  });

  testWidgets('only the changed card folds; value is shown at once', (
    tester,
  ) async {
    var flips = 0;
    Widget show(List<String> cards) =>
        host(display(cards, onFlip: () => flips++));
    await tester.pumpWidget(show(['12', '34']));
    await tester.pumpWidget(show(['12', '34']));
    expect(flips, 0);

    await tester.pumpWidget(show(['12', '35']));
    expect(flips, 1);
    expect(find.text('35'), findsWidgets);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(FlipDisplay.flapKey), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byKey(FlipDisplay.flapKey), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.byKey(FlipDisplay.flapKey), findsNothing);

    await tester.pumpWidget(show(['13', '36']));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byKey(FlipDisplay.flapKey), findsNWidgets(2));
    await tester.pumpAndSettle();

    // Gaining a card counts as a change.
    await tester.pumpWidget(show(['01', '13', '36']));
    expect(flips, 3);
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion changes instantly', (tester) async {
    await tester.pumpWidget(host(display(['01']), reduceMotion: true));
    await tester.pumpWidget(host(display(['00']), reduceMotion: true));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byKey(FlipDisplay.flapKey), findsNothing);
    expect(find.text('01'), findsNothing);
  });

  testWidgets('iOS Reduce Motion also changes instantly', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(reduceMotion: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(host(display(['1'])));
    await tester.pumpWidget(host(display(['2'])));
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
        host(
          display(
            ['123', '59', '59'],
            skin: mono.copyWith(meridiem: SkinMeridiem.right),
            meridiem: 'PM',
            badge: '9',
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final box = tester.getSize(find.byType(FlipDisplay));
      expect(box.width, lessThanOrEqualTo(size.width));
      expect(box.height, lessThanOrEqualTo(size.height));
    });
  }

  testWidgets('unbounded space and large text scale still fit', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: ListView(
              children: [
                SizedBox(height: 200, child: display(['09', '41'])),
                Row(
                  children: [
                    Expanded(child: display(['09'])),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  group('AM/PM and badge scale with the card', () {
    testWidgets('large on a 1200x750 display, in the skin face', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1200, 750)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      const skin = Skin(id: 'x', name: 'x', face: DisplayFace.orbitron);
      await tester.pumpWidget(
        host(display(['9', '41'], skin: skin, meridiem: 'PM', badge: '07')),
      );
      expect(fontSizeOf(tester, 'PM'), greaterThan(40));
      expect(fontSizeOf(tester, '07'), greaterThan(30));
      final pm = tester.widget<Text>(find.text('PM'));
      expect(pm.style!.fontFamily, startsWith('Orbitron'));
      expect(pm.style!.color, DesignSkinColors.mono.withValues(alpha: 0.7));
      expect(
        tester.widget<Text>(find.text('07')).style!.fontFamily,
        startsWith('Orbitron'),
      );
      // The corner padding grows too: PM sits well inside the card.
      final card = tester.getRect(cardFill(DesignSkinColors.cardInk).first);
      expect(
        tester.getRect(find.text('PM')).left - card.left,
        greaterThan(DesignSpace.s3),
      );
    });

    testWidgets('beside the cards it is the same size', (tester) async {
      tester.view
        ..physicalSize = const Size(1200, 750)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        host(
          display(
            ['9', '41'],
            skin: mono.copyWith(meridiem: SkinMeridiem.right),
            meridiem: 'PM',
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(fontSizeOf(tester, 'PM'), greaterThan(40));
    });

    testWidgets('AM/PM and seconds scale with the card, clear of the digits', (
      tester,
    ) async {
      for (final h in const [80.0, 200.0]) {
        await tester.pumpWidget(
          host(
            SizedBox(
              width: 400,
              height: h,
              child: display(['9', '41'], meridiem: 'AM', badge: '07'),
            ),
          ),
        );
        final card = tester.getSize(cardFill(DesignSkinColors.cardInk).first);
        final cardHeight = card.height * 2 + FlipDisplay.seamHeight;
        expect(
          fontSizeOf(tester, 'AM'),
          closeTo(cardHeight * FlipDisplay.meridiemScale, 0.01),
        );
        expect(
          fontSizeOf(tester, '07'),
          closeTo(cardHeight * FlipDisplay.badgeScale, 0.01),
        );
        // AM/PM stays in the card's bottom margin, below the digit glyphs.
        final am = tester.getRect(find.text('AM'));
        final cardRect = tester.getRect(
          cardFill(DesignSkinColors.cardInk).at(1),
        );
        expect(am.bottom, lessThanOrEqualTo(cardRect.bottom));
        expect(
          am.top,
          greaterThan(cardRect.bottom - cardHeight * 0.25),
          reason: 'h=$h',
        );
      }
      // The token sizes are reached on real clock cards.
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 800,
            height: 200,
            child: display(['9', '41'], meridiem: 'AM', badge: '07'),
          ),
        ),
      );
      expect(fontSizeOf(tester, 'AM'), greaterThanOrEqualTo(18));
      expect(fontSizeOf(tester, '07'), greaterThanOrEqualTo(13));
    });

    testWidgets('12h drops the leading zero and shows AM/PM; 24h does not; '
        'switching at runtime updates the display', (tester) async {
      final t = DateTime(2026, 9, 30, 9, 5);
      Widget show({required bool use24h}) {
        final v = clockValue(t, use24h: use24h, showSeconds: false, skin: mono);
        return host(display(v.cards, meridiem: v.meridiem, badge: v.badge));
      }

      await tester.pumpWidget(show(use24h: false));
      expect(find.text('9'), findsWidgets);
      expect(find.text('AM'), findsOne);
      await tester.pumpWidget(show(use24h: true));
      await tester.pumpAndSettle();
      expect(find.text('09'), findsWidgets);
      expect(find.text('9'), findsNothing);
      expect(find.text('AM'), findsNothing);
      await tester.pumpWidget(show(use24h: false));
      await tester.pumpAndSettle();
      expect(find.text('AM'), findsOne);
      expect(find.text('09'), findsNothing);
    });
  });

  testWidgets('size shrinks the fitted card; out-of-range sizes clamp', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1280, 760)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    double cardHeight(double size) {
      final half = tester.getSize(cardFill(DesignSkinColors.cardInk).first);
      return half.height * 2 + FlipDisplay.seamHeight;
    }

    for (final (size, expected) in const [
      (1.0, 628.0),
      (0.6, 628 * 0.6),
      (2.0, 628.0),
      (0.0, 62.8),
    ]) {
      await tester.pumpWidget(host(display(['22', '42'], size: size)));
      expect(cardHeight(size), closeTo(expected, 0.01), reason: '$size');
      expect(
        tester.widget<Text>(find.text('22').first).style!.fontSize,
        closeTo(expected * FlipDisplay.digitScale, 0.01),
      );
    }
  });

  testWidgets('a themed skin draws light tokens in Mono Light', (tester) async {
    Widget themed(DesignColors colors) => MaterialApp(
      theme: ThemeData(extensions: [colors]),
      home: Scaffold(body: display(['12'], skin: mono.copyWith(themed: true))),
    );
    await tester.pumpWidget(themed(DesignColors.light));
    expect(cardFill(DesignColors.light.card), findsNWidgets(2));
    expect(
      tester.widget<Text>(find.text('12').first).style!.color,
      DesignColors.light.ink,
    );
    await tester.pumpWidget(themed(DesignColors.dark));
    await tester.pumpAndSettle();
    expect(cardFill(DesignSkinColors.cardInk), findsNWidgets(2));
  });

  group('display values', () {
    final t = DateTime(2026, 9, 30, 21, 5, 7);

    test('clock: 24h, 12h and each seconds style', () {
      final off = clockValue(t, use24h: true, showSeconds: false, skin: mono);
      expect(off.cards, ['21', '05']);
      expect(off.badge, isNull);
      expect(off.meridiem, isNull);
      final badge = clockValue(
        t,
        use24h: false,
        showSeconds: true,
        skin: mono.copyWith(seconds: SkinSeconds.badge),
      );
      expect(badge.cards, ['9', '05']);
      expect(badge.badge, '07');
      expect(badge.meridiem, 'PM');
      final cards = clockValue(
        DateTime(2026, 1, 1, 0, 1),
        use24h: false,
        showSeconds: true,
        skin: mono.copyWith(seconds: SkinSeconds.cards),
      );
      expect(cards.cards, ['12', '01', '00']);
      expect(cards.meridiem, 'AM');
      final none = clockValue(
        t,
        use24h: true,
        showSeconds: true,
        skin: mono.copyWith(seconds: SkinSeconds.off),
      );
      // A skin without seconds of its own shows them as cards, so the
      // Show seconds switch always shows something.
      expect(none.cards, ['21', '05', '07']);
      expect(none.badge, isNull);
      expect(
        clockValue(t, use24h: true, showSeconds: false, skin: mono).cards,
        ['21', '05'],
      );
    });

    test('durations: hours card from one hour; negative reads zero', () {
      expect(durationValue(const Duration(minutes: 25)).cards, ['25', '00']);
      expect(durationValue(const Duration(hours: 1, seconds: 5)).cards, [
        '01',
        '00',
        '05',
      ]);
      expect(durationValue(const Duration(seconds: -3)).cards, ['00', '00']);
      final sw = stopwatchValue(const Duration(seconds: 62, milliseconds: 950));
      expect(sw.cards, ['01', '02']);
      expect(sw.badge, '9');
      expect(stopwatchValue(const Duration(seconds: -1)).badge, '0');
    });
  });
}
