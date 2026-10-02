import 'dart:math' as math;

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
  bool stackable = false,
}) => FlipDisplay(
  cards: cards,
  skin: skin,
  semanticsLabel: label,
  badge: badge,
  meridiem: meridiem,
  onFlip: onFlip,
  size: size,
  stackable: stackable,
);

double fontSizeOf(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style!.fontSize!;

Finder cardFill(Color color) => find.byWidgetPredicate(
  (w) =>
      w is Container &&
      w.decoration is BoxDecoration &&
      (w.decoration! as BoxDecoration).color == color,
);

/// Plain split-line strips painted [color].
Finder lineOf(Color color) =>
    find.byWidgetPredicate((w) => w is ColoredBox && w.color == color);

/// The card halves that carry a shade or a cast shadow right now.
List<BoxDecoration> shaded(WidgetTester tester) => tester
    .widgetList<Container>(find.byType(Container))
    .map((c) => c.foregroundDecoration)
    .whereType<BoxDecoration>()
    .toList();

/// The fold's angle at [t] of a flip: 0 upright, pi landed.
double turnAt(double t) => FlipDisplay.flipCurve.transform(t) * math.pi;

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

  testWidgets('the skin paints the cards, digits and split line', (
    tester,
  ) async {
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
    // The split line: 1px of ground over 1px of light, one per card.
    expect(lineOf(DesignSkinColors.bgPaper), findsNWidgets(2));
    final light = lineOf(
      Color.lerp(DesignSkinColors.bgPaper, DesignSkinColors.cyan, 0.12)!,
    );
    expect(light, findsNWidgets(2));
    expect(tester.getSize(light.first).height, FlipDisplay.seamHeight / 2);
    // No shade on a card at rest.
    expect(shaded(tester), isEmpty);
  });

  testWidgets('every card has two hinge pins on the split line, half outside', (
    tester,
  ) async {
    for (final skin in [mono, mono.copyWith(themed: true)]) {
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 400,
            height: 200,
            child: display(['12', '34'], skin: skin),
          ),
        ),
      );
      final pins = find.byKey(FlipDisplay.hingeKey);
      expect(pins, findsNWidgets(4));
      final top = tester.getRect(cardFill(DesignSkinColors.cardInk).at(0));
      final bottom = tester.getRect(cardFill(DesignSkinColors.cardInk).at(1));
      final height = bottom.bottom - top.top;
      final left = tester.getRect(pins.at(0));
      final right = tester.getRect(pins.at(1));
      expect(left.height, closeTo(height * FlipDisplay.hingeHeightScale, 0.01));
      expect(left.width, closeTo(FlipDisplay.hingeWidth(height), 0.01));
      // Centred on the split line and on the card's side edges.
      expect(left.center.dy, closeTo((top.bottom + bottom.top) / 2, 0.01));
      expect(left.center.dx, closeTo(top.left, 0.01));
      expect(right.center.dx, closeTo(top.right, 0.01));
      // Inside the display, clear of the next card's pins.
      final box = tester.getRect(find.byType(FlipDisplay));
      for (var i = 0; i < 4; i++) {
        final pin = tester.getRect(pins.at(i));
        expect(pin.left, greaterThanOrEqualTo(box.left - 0.01));
        expect(pin.right, lessThanOrEqualTo(box.right + 0.01));
      }
      expect(
        tester.getRect(pins.at(2)).left,
        greaterThan(tester.getRect(pins.at(1)).right),
      );
    }
  });

  testWidgets('pins stay in the gap and the window at the largest size', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(2000, 1200)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final stackable in [false, true]) {
      await tester.pumpWidget(
        host(display(['12', '34', '56'], stackable: stackable)),
      );
      final pins = find.byKey(FlipDisplay.hingeKey);
      expect(pins, findsNWidgets(6));
      for (var i = 0; i < 6; i++) {
        final pin = tester.getRect(pins.at(i));
        expect(pin.left, greaterThanOrEqualTo(0));
        expect(pin.right, lessThanOrEqualTo(2000));
        expect(pin.width, lessThanOrEqualTo(FlipDisplay.hingeMaxWidth));
      }
      for (var i = 1; i < 5; i += 2) {
        final a = tester.getRect(pins.at(i));
        final b = tester.getRect(pins.at(i + 1));
        expect(a.overlaps(b), isFalse);
      }
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('cards fill a large space; digits are 0.78 x card height', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(display(['22', '42'])));
    final card = tester.getSize(cardFill(DesignSkinColors.cardInk).first);
    // Two cards, one 24px gap and two outer half pins (20px wide at this
    // size) across 1280px: 618px cards (under 760).
    expect(card.height, closeTo((618 - 2) / 2, 0.01));
    final digit = tester.widget<Text>(find.text('22').first);
    expect(digit.style!.fontSize, closeTo(618 * 0.78, 0.01));
  });

  testWidgets('md cards become lg at digit-l sizes, from the app corner', (
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
    expect(radiusAt(const Size(800, 400)).topLeft.x, const DesignShape().lg);
    tester.view.physicalSize = const Size(300, 100);
    await tester.pumpWidget(host(display(['22', '42'])));
    expect(radiusAt(const Size(300, 100)).topLeft.x, const DesignShape().md);
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
    expect(shaded(tester), isEmpty);
    // The pins and split line do not move, so they stay.
    expect(find.byKey(FlipDisplay.hingeKey), findsNWidgets(2));
    expect(lineOf(DesignSkinColors.bgInk), findsOneWidget);
  });

  testWidgets('the flap turns once about the pins, shaded as it tips', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(SizedBox(width: 200, height: 160, child: display(['01']))),
    );
    await tester.pumpWidget(
      host(SizedBox(width: 200, height: 160, child: display(['02']))),
    );
    final half = tester.getSize(cardFill(DesignSkinColors.cardInk).first);
    final height = half.height * 2 + FlipDisplay.seamHeight;
    debugPrint('H $height ${tester.getSize(find.byType(FlipDisplay))}');
    final ms = FlipDisplay.flipDuration.inMilliseconds;
    var elapsed = 0;
    for (final t in const [0.25, 0.75]) {
      final at = (ms * t).round();
      await tester.pump(Duration(milliseconds: at - elapsed));
      elapsed = at;
      final turn = turnAt(at / ms);
      final shade = FlipDisplay.maxShade * math.sin(turn);
      final fold = tester.widget<Transform>(find.byKey(FlipDisplay.flapKey));
      final falling = t < 0.5;
      // The top half falls about its bottom edge; the bottom lands about
      // its top edge.
      expect(
        fold.alignment,
        falling ? Alignment.bottomCenter : Alignment.topCenter,
      );
      // Perspective follows the card height (the rotation scales it by cos).
      final angle = falling ? turn : math.pi - turn;
      expect(
        fold.transform.entry(3, 2),
        closeTo(FlipDisplay.perspective / height * math.cos(angle), 1e-9),
      );
      // The flap shows the old value while falling and the new one landing.
      expect(
        find.descendant(
          of: find.byKey(FlipDisplay.flapKey),
          matching: find.text(falling ? '01' : '02'),
        ),
        findsOneWidget,
      );
      // The flap darkens edge-on and casts a fading shadow on the bottom half.
      final decorations = shaded(tester);
      expect(decorations, hasLength(2));
      final flat = decorations.firstWhere((d) => d.color != null);
      expect(flat.color!.a, closeTo(shade, 0.01));
      final cast = decorations.firstWhere((d) => d.gradient != null);
      final colors = (cast.gradient! as LinearGradient).colors;
      expect(colors.first.a, closeTo(shade, 0.01));
      expect(colors.last.a, 0);
    }
    await tester.pumpAndSettle();
    expect(find.byKey(FlipDisplay.flapKey), findsNothing);
    expect(shaded(tester), isEmpty);
    expect(find.text('01'), findsNothing);
  });

  testWidgets('a change mid-fall keeps falling; mid-landing falls again', (
    tester,
  ) async {
    Widget show(String v) => host(display([v]));
    await tester.pumpWidget(show('01'));
    await tester.pumpWidget(show('02'));
    await tester.pump(const Duration(milliseconds: 60));
    final before = tester.widget<Transform>(find.byKey(FlipDisplay.flapKey));
    // Still falling: the same flap carries on from where it was.
    await tester.pumpWidget(show('03'));
    final after = tester.widget<Transform>(find.byKey(FlipDisplay.flapKey));
    expect(after.transform, before.transform);
    expect(
      find.descendant(
        of: find.byKey(FlipDisplay.flapKey),
        matching: find.text('01'),
      ),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
    expect(find.text('03'), findsWidgets);
    expect(find.text('01'), findsNothing);
    expect(find.text('02'), findsNothing);

    // Landing: the top half starts falling again from what it showed.
    await tester.pumpWidget(show('04'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpWidget(show('05'));
    await tester.pump(const Duration(milliseconds: 10));
    final fold = tester.widget<Transform>(find.byKey(FlipDisplay.flapKey));
    expect(fold.alignment, Alignment.bottomCenter);
    expect(
      find.descendant(
        of: find.byKey(FlipDisplay.flapKey),
        matching: find.text('04'),
      ),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
    expect(find.text('05'), findsWidgets);
    expect(find.text('04'), findsNothing);
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

    testWidgets('both clocks show two-digit hours; only 12h shows AM/PM; '
        'switching at runtime updates the display', (tester) async {
      final t = DateTime(2026, 9, 30, 21, 5);
      Widget show({required bool use24h}) {
        final v = clockValue(t, use24h: use24h, showSeconds: false, skin: mono);
        return host(display(v.cards, meridiem: v.meridiem, badge: v.badge));
      }

      await tester.pumpWidget(show(use24h: false));
      // Padded like the minutes, so the hour card is never half empty.
      expect(find.text('09'), findsWidgets);
      expect(find.text('9'), findsNothing);
      expect(find.text('PM'), findsOne);
      await tester.pumpWidget(show(use24h: true));
      await tester.pumpAndSettle();
      expect(find.text('21'), findsWidgets);
      expect(find.text('PM'), findsNothing);
      await tester.pumpWidget(show(use24h: false));
      await tester.pumpAndSettle();
      expect(find.text('PM'), findsOne);
      expect(find.text('21'), findsNothing);
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
      (1.0, 618.0),
      (0.6, 618 * 0.6),
      (2.0, 618.0),
      (0.0, 61.8),
    ]) {
      await tester.pumpWidget(host(display(['22', '42'], size: size)));
      expect(cardHeight(size), closeTo(expected, 0.01), reason: '$size');
      expect(
        tester.widget<Text>(find.text('22').first).style!.fontSize,
        closeTo(expected * FlipDisplay.digitScale, 0.01),
      );
    }
  });

  group('stacked layout', () {
    /// Pumps a stackable 12 34 display in a [w] x [h] box.
    Future<void> boxed(
      WidgetTester tester,
      double w,
      double h, {
      List<String> cards = const ['12', '34'],
      String? meridiem,
      String? badge,
      Skin skin = mono,
      bool stackable = true,
      bool reduceMotion = false,
    }) async {
      tester.view
        ..physicalSize = const Size(1400, 1400)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        host(
          SizedBox(
            width: w,
            height: h,
            child: display(
              cards,
              meridiem: meridiem,
              badge: badge,
              skin: skin,
              stackable: stackable,
            ),
          ),
          reduceMotion: reduceMotion,
        ),
      );
      await tester.pumpAndSettle();
    }

    bool stacked(WidgetTester tester, String first, String last) =>
        tester.getCenter(find.text(first).first).dy <
        tester.getCenter(find.text(last).first).dy - 1;

    testWidgets('tall stacks hours over minutes, wide stays one row', (
      tester,
    ) async {
      await boxed(tester, 400, 600);
      expect(stacked(tester, '12', '34'), isTrue);
      expect(
        tester.getCenter(find.text('12').first).dx,
        closeTo(tester.getCenter(find.text('34').first).dx, 0.5),
      );
      await boxed(tester, 800, 300);
      expect(stacked(tester, '12', '34'), isFalse);
      // Tiles and previews never stack.
      await boxed(tester, 400, 600, stackable: false);
      expect(stacked(tester, '12', '34'), isFalse);
    });

    testWidgets('the 15% band keeps whichever layout is showing', (
      tester,
    ) async {
      // 400 wide: one row fits 188px cards. At 420 high the stack fits 198
      // (inside the band), at 500 238 (stack), at 300 138 (row).
      await boxed(tester, 400, 420);
      expect(stacked(tester, '12', '34'), isFalse, reason: 'starts a row');
      await boxed(tester, 400, 500);
      expect(stacked(tester, '12', '34'), isTrue);
      await boxed(tester, 400, 420);
      expect(stacked(tester, '12', '34'), isTrue, reason: 'stays stacked');
      await boxed(tester, 400, 300);
      expect(stacked(tester, '12', '34'), isFalse);
      await boxed(tester, 400, 420);
      expect(stacked(tester, '12', '34'), isFalse, reason: 'stays a row');
    });

    testWidgets('three groups stack; badge and AM/PM keep their places', (
      tester,
    ) async {
      await boxed(
        tester,
        400,
        900,
        cards: ['09', '41', '07'],
        meridiem: 'AM',
        badge: '5',
        skin: mono.copyWith(meridiem: SkinMeridiem.right),
      );
      expect(stacked(tester, '09', '41'), isTrue);
      expect(stacked(tester, '41', '07'), isTrue);
      // Card [i] of [n] (cards are keyed from the right).
      Rect card(int i, int n) => tester.getRect(
        find.byWidgetPredicate(
          (w) => w.key == ValueKey(n - i) && '${w.runtimeType}' == '_FlipCard',
        ),
      );
      // AM/PM beside the last card of the last row, level with it.
      final last = card(2, 3);
      final am = tester.getRect(find.text('AM'));
      expect(am.left, greaterThanOrEqualTo(last.right));
      expect(am.top, greaterThanOrEqualTo(last.top));
      expect(am.bottom, lessThanOrEqualTo(last.bottom));
      // The badge sits inside the last card, in its bottom-right corner.
      final badge = tester.getRect(find.text('5'));
      expect(
        last.contains(badge.topLeft) &&
            last.contains(badge.bottomRight - const Offset(0.01, 0.01)),
        isTrue,
      );
      expect(badge.center.dx, greaterThan(last.center.dx));
      expect(badge.center.dy, greaterThan(last.center.dy));

      await boxed(tester, 400, 900, cards: ['09', '41'], meridiem: 'PM');
      // Left AM/PM sits inside the first card, in its bottom-left corner.
      final first = card(0, 2);
      final pm = tester.getRect(find.text('PM'));
      expect(
        first.contains(pm.topLeft) &&
            first.contains(pm.bottomRight - const Offset(0.01, 0.01)),
        isTrue,
      );
      expect(pm.center.dx, lessThan(first.center.dx));
      expect(pm.center.dy, greaterThan(first.center.dy));
    });

    testWidgets('switching cross-fades; reduced motion swaps at once', (
      tester,
    ) async {
      AnimatedSwitcher switcher() => tester.widget<AnimatedSwitcher>(
        find.descendant(
          of: find.byType(FlipDisplay),
          matching: find.byType(AnimatedSwitcher),
        ),
      );
      await boxed(tester, 400, 600);
      expect(switcher().duration, DesignMotion.fade);
      await boxed(tester, 400, 600, reduceMotion: true);
      expect(switcher().duration, Duration.zero);
    });
  });

  testWidgets('a themed skin draws light tokens in Mono Light', (tester) async {
    Widget themed(DesignColors colors) => MaterialApp(
      theme: ThemeData(extensions: [colors]),
      home: Scaffold(body: display(['12'], skin: mono.copyWith(themed: true))),
    );
    await tester.pumpWidget(themed(DesignColors.light));
    expect(cardFill(DesignColors.light.card), findsNWidgets(2));
    expect(lineOf(DesignColors.light.bg), findsOneWidget);
    expect(find.byKey(FlipDisplay.hingeKey), findsNWidgets(2));
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
      expect(badge.cards, ['09', '05']);
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
