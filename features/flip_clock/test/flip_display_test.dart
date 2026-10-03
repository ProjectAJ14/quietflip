import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flip_clock/data/models/skin.dart';
import 'package:flip_clock/ui/components/display_value.dart';
import 'package:flip_clock/ui/components/flip_card_geometry.dart';
import 'package:flip_clock/ui/components/flip_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'flip_card_probe.dart';

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

/// Every card of the display.
final cards = find.byWidgetPredicate((w) => '${w.runtimeType}' == '_FlipCard');

/// Card [i]'s own painter (pins, crack) as a canvas callback, so `paints`
/// sees only what it draws and not the halves under it.
void Function(Canvas) cardPaint(WidgetTester tester, [int i = 0]) {
  final finder = find.byKey(FlipDisplay.hingeKey).at(i);
  final painter = tester.widget<CustomPaint>(finder).foregroundPainter!;
  final size = tester.getSize(finder);
  return (canvas) => painter.paint(canvas, size);
}

/// The card halves that carry a shade or a cast shadow right now.
List<BoxDecoration> shaded(WidgetTester tester) => tester
    .widgetList<Container>(find.byType(Container))
    .map((c) => c.foregroundDecoration)
    .whereType<BoxDecoration>()
    .toList();

/// The fold's angle at [t] of a flip: 0 upright, pi landed.
double turnAt(double t) => FlipDisplay.flipCurve.transform(t) * math.pi;

/// English markers, as `MaterialLocalizations` gives them in English.
const en = (am: 'AM', pm: 'PM');

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
    expect(cardFace(DesignSkinColors.cardPaper), findsNWidgets(4));
    final digit = tester.widget<Text>(find.text('12').first);
    expect(digit.style!.color, DesignSkinColors.cyan);
    expect(digit.style!.fontFamily, startsWith('Orbitron'));
    expect(digit.textScaler, TextScaler.noScaling);
    // The split line: a dark crack over a bright lip, shaded from the card.
    final geometry = FlipCardGeometry(tester.getSize(cards.first), 0);
    expect(
      cardPaint(tester),
      paints
        ..rect(
          rect: geometry.crack,
          color: shadeOf(DesignSkinColors.cardPaper, 0.85),
        )
        ..rect(rect: geometry.underside)
        ..rect(
          rect: geometry.lip,
          color: lightOf(DesignSkinColors.cardPaper, 0.45),
        ),
    );
    // No shade on a card at rest.
    expect(shaded(tester), isEmpty);
  });

  testWidgets('the digits centre on the axle in every face, shrunk or not', (
    tester,
  ) async {
    for (final face in DisplayFace.values) {
      // '1' fits the card; '12' is wider than it in the test font and
      // shrinks.
      for (final value in ['1', '12']) {
        await tester.pumpWidget(
          host(
            SizedBox(
              width: 400,
              height: 200,
              child: display([value], skin: mono.copyWith(face: face)),
            ),
          ),
        );
        // Real face metrics, not the test font's: the leading differs.
        await tester.runAsync(GoogleFonts.pendingFonts);
        await tester.pumpAndSettle();
        final card = tester.getRect(
          find.byWidgetPredicate((w) => '${w.runtimeType}' == '_FlipCard'),
        );
        final halves = find.text(value);
        expect(halves, findsNWidgets(2));
        for (var i = 0; i < 2; i++) {
          final text = tester.widget<Text>(halves.at(i));
          final paragraph = tester.renderObject<RenderParagraph>(halves.at(i));
          // The paragraph only answers baseline queries during layout; a
          // painter over the same span, in the same font, gives the same
          // distance.
          final painter = TextPainter(
            text: paragraph.text,
            textDirection: TextDirection.ltr,
          )..layout();
          addTearDown(painter.dispose);
          final baseline = painter.computeDistanceToActualBaseline(
            TextBaseline.alphabetic,
          );
          final centre = paragraph.localToGlobal(
            Offset(0, baseline - face.digitCentre * text.style!.fontSize!),
          );
          expect(
            centre.dy,
            closeTo(card.center.dy, 0.5),
            reason: '${face.name} $value half $i',
          );
        }
      }
    }
  });

  testWidgets('pins sit inside the card; nothing is painted outside', (
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
      // One painter per card draws its pins and crack, over the card.
      final painters = find.byKey(FlipDisplay.hingeKey);
      expect(painters, findsNWidgets(2));
      final box = tester.getRect(find.byType(FlipDisplay));
      for (var i = 0; i < 2; i++) {
        final card = tester.getRect(cards.at(i));
        expect(tester.getRect(painters.at(i)), card);
        final geometry = FlipCardGeometry(card.size, 0);
        expect(geometry.hasHinges, isTrue);
        // Every pin pixel lies inside the card, so inside the display.
        for (final pin in [geometry.pinLeft, geometry.pinRight]) {
          final rect = pin.outerRect.shift(card.topLeft);
          expect(card.contains(rect.topLeft), isTrue);
          expect(rect.right, lessThanOrEqualTo(card.right));
          expect(rect.bottom, lessThanOrEqualTo(card.bottom));
        }
        expect(box.contains(card.topLeft), isTrue);
        expect(card.right, lessThanOrEqualTo(box.right));
        expect(
          cardPaint(tester, i),
          paints
            ..rrect(rrect: geometry.pinLeft)
            ..line()
            ..line()
            ..rrect()
            ..rrect(rrect: geometry.pinRight),
        );
      }
    }
  });

  testWidgets('the display is exactly its cards and gaps wide', (tester) async {
    tester.view
      ..physicalSize = const Size(2000, 760)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final (face, ratio) in const [
      (DisplayFace.barlowCondensed, 1.0),
      (DisplayFace.jetBrainsMono, 1.3),
    ]) {
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 1200,
            height: 300,
            child: display(['12', '34', '56'], skin: mono.copyWith(face: face)),
          ),
        ),
      );
      final height = tester.getSize(cards.first).height;
      expect(
        tester.getRect(cards.last).right - tester.getRect(cards.first).left,
        closeTo(3 * height * ratio + 2 * DesignSpace.s6, 1e-9),
      );
      // The cards are as tall as the box allows (nothing reserved for pins).
      expect(height, math.min(300, (1200 - 2 * DesignSpace.s6) / (3 * ratio)));
    }
  });

  testWidgets('cards fill a large space; digits are 0.78 x card height', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(display(['22', '42'])));
    final card = tester.getSize(cards.first);
    // Two cards and one 24px gap across 1280px: 628px cards (under 760).
    expect(card.height, 628);
    final digit = tester.widget<Text>(find.text('22').first);
    expect(digit.style!.fontSize, closeTo(628 * 0.78, 0.01));
  });

  testWidgets('md cards become lg at digit-l sizes, from the app corner', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.view.physicalSize = const Size(800, 400);
    await tester.pumpWidget(host(display(['22', '42'])));
    expect(
      cardCorner(tester, cards.first),
      closeTo(const DesignShape().lg, 0.05),
    );
    tester.view.physicalSize = const Size(300, 100);
    await tester.pumpWidget(host(display(['22', '42'])));
    expect(
      cardCorner(tester, cards.first),
      closeTo(const DesignShape().md, 0.05),
    );
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
    final card = tester.getSize(cards.first);
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
    expect(find.byKey(FlipDisplay.hingeKey), findsOneWidget);
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
    final height = tester.getSize(cards.first).height;
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
      final card = tester.getRect(cards.first);
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
        final cardHeight = tester.getSize(cards.first).height;
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
        final cardRect = tester.getRect(cards.first);
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
        final v = clockValue(
          t,
          use24h: use24h,
          showSeconds: false,
          skin: mono,
          meridiem: en,
        );
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
    double cardHeight(double size) => tester.getSize(cards.first).height;

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
    expect(cardFace(DesignColors.light.card), findsNWidgets(2));
    expect(
      cardPaint(tester),
      paints..rect(color: shadeOf(DesignColors.light.card, 0.85)),
    );
    expect(
      tester.widget<Text>(find.text('12').first).style!.color,
      DesignColors.light.ink,
    );
    await tester.pumpWidget(themed(DesignColors.dark));
    await tester.pumpAndSettle();
    expect(cardFace(DesignSkinColors.cardInk), findsNWidgets(2));
  });

  group('paint', () {
    const paper = Skin(
      id: 'paper',
      name: 'Paper',
      digitColor: DesignSkinColors.inkPaper,
      cardColor: DesignSkinColors.cardPaper,
      groundColor: DesignSkinColors.bgPaper,
    );

    testWidgets('the card painter draws crack, lip, cavities, then pins', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(SizedBox(width: 300, height: 300, child: display(['12']))),
      );
      const card = DesignSkinColors.cardInk;
      final g = FlipCardGeometry(tester.getSize(cards.first), 0);
      expect(g.hasHinges, isTrue);
      final rims = lightOf(card, 0.6).withValues(alpha: 0.6);
      PaintPattern pin(PaintPattern p, RRect pin) => p
        ..rrect(rrect: pin, style: PaintingStyle.fill)
        ..line(color: rims, strokeWidth: 1)
        ..line(color: rims, strokeWidth: 1)
        ..rrect(
          rrect: pin.deflate(0.25),
          style: PaintingStyle.stroke,
          strokeWidth: 0.5,
          color: shadeOf(card, 0.85),
        );
      expect(
        cardPaint(tester),
        pin(
          pin(
            paints
              ..rect(rect: g.crack, color: shadeOf(card, 0.85))
              ..rect(rect: g.underside, color: shadeOf(card, 0.4))
              ..rect(rect: g.lip, color: lightOf(card, 0.45))
              ..path(color: shadeOf(card, 0.85))
              ..path(color: shadeOf(card, 0.85)),
            g.pinLeft,
          ),
          g.pinRight,
        ),
      );
    });

    testWidgets('a card under 80px has the crack and lip but no pins', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(SizedBox(width: 300, height: 79, child: display(['12']))),
      );
      expect(tester.getSize(cards.first).height, 79);
      expect(cardPaint(tester), paintsExactlyCountTimes(#drawRRect, 0));
      expect(cardPaint(tester), paintsExactlyCountTimes(#drawPath, 0));
      expect(cardPaint(tester), paintsExactlyCountTimes(#drawRect, 3));
    });

    testWidgets('the crack is dark on light and dark skins alike', (
      tester,
    ) async {
      for (final skin in [mono, paper]) {
        await tester.pumpWidget(host(display(['12'], skin: skin)));
        final crack = shadeOf(skin.cardColor, 0.85);
        expect(
          crack.computeLuminance(),
          lessThan(skin.cardColor.computeLuminance()),
          reason: skin.name,
        );
        expect(crack.computeLuminance(), lessThan(0.05), reason: skin.name);
        expect(cardPaint(tester), paints..rect(color: crack));
      }
    });

    testWidgets('each half is lit from above', (tester) async {
      for (final skin in [mono, paper]) {
        await tester.pumpWidget(host(display(['12'], skin: skin)));
        final faces = cardFace(skin.cardColor);
        expect(faces, findsNWidgets(2));
        LinearGradient fill(int i) =>
            // ignore: avoid_dynamic_calls
            (tester.widget<CustomPaint>(faces.at(i)).painter! as dynamic).fill
                as LinearGradient;
        final top = fill(0).colors;
        final bottom = fill(1).colors;
        expect(top.first, lightOf(skin.cardColor, 0.10));
        expect(top.last, shadeOf(skin.cardColor, 0.12));
        expect(
          top.first.computeLuminance(),
          greaterThan(top.last.computeLuminance()),
        );
        expect(bottom.first, skin.cardColor);
        expect(bottom.last, shadeOf(skin.cardColor, 0.18));
      }
    });

    testWidgets('the top half has a rim that fades down the sides', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(SizedBox(width: 300, height: 300, child: display(['12']))),
      );
      const card = DesignSkinColors.cardInk;
      final faces = cardFace(card);
      final size = tester.getSize(faces.first);
      void Function(Canvas) face(int i) {
        final painter = tester.widget<CustomPaint>(faces.at(i)).painter!;
        return (canvas) => painter.paint(canvas, size);
      }

      // Fill, then a 1px stroke just inside the card outline.
      expect(
        face(0),
        paints
          ..rect(rect: Offset.zero & size)
          ..rrect(style: PaintingStyle.stroke, strokeWidth: 1),
      );
      expect(face(1), paintsExactlyCountTimes(#drawRRect, 0));
    });

    testWidgets('painters repaint only when the card or its colour change', (
      tester,
    ) async {
      CustomPainter cardPainter() => tester
          .widget<CustomPaint>(find.byKey(FlipDisplay.hingeKey))
          .foregroundPainter!;
      CustomPainter facePainter(Color card) =>
          tester.widget<CustomPaint>(cardFace(card).first).painter!;
      Widget show(Skin skin, double h) => host(
        SizedBox(
          width: 400,
          height: h,
          child: display(['12'], skin: skin),
        ),
      );
      await tester.pumpWidget(show(mono, 200));
      final card = cardPainter();
      final face = facePainter(mono.cardColor);
      // A digit colour change leaves the card and its halves alone.
      await tester.pumpWidget(
        show(mono.copyWith(digitColor: DesignSkinColors.cyan), 200),
      );
      expect(cardPainter().shouldRepaint(card), isFalse);
      expect(facePainter(mono.cardColor).shouldRepaint(face), isFalse);
      await tester.pumpWidget(
        show(mono.copyWith(cardColor: DesignSkinColors.cardPaper), 200),
      );
      expect(cardPainter().shouldRepaint(card), isTrue);
      expect(
        facePainter(DesignSkinColors.cardPaper).shouldRepaint(face),
        isTrue,
      );
      await tester.pumpWidget(show(mono, 150));
      expect(cardPainter().shouldRepaint(card), isTrue);
      expect(facePainter(mono.cardColor).shouldRepaint(face), isTrue);
    });
  });

  group('display values', () {
    final t = DateTime(2026, 9, 30, 21, 5, 7);

    test('clock: 24h, 12h and each seconds style', () {
      final off = clockValue(
        t,
        use24h: true,
        showSeconds: false,
        skin: mono,
        meridiem: en,
      );
      expect(off.cards, ['21', '05']);
      expect(off.badge, isNull);
      expect(off.meridiem, isNull);
      final badge = clockValue(
        t,
        use24h: false,
        showSeconds: true,
        skin: mono.copyWith(seconds: SkinSeconds.badge),
        meridiem: en,
      );
      expect(badge.cards, ['09', '05']);
      expect(badge.badge, '07');
      expect(badge.meridiem, 'PM');
      final cards = clockValue(
        DateTime(2026, 1, 1, 0, 1),
        use24h: false,
        showSeconds: true,
        skin: mono.copyWith(seconds: SkinSeconds.cards),
        meridiem: en,
      );
      expect(cards.cards, ['12', '01', '00']);
      expect(cards.meridiem, 'AM');
      final none = clockValue(
        t,
        use24h: true,
        showSeconds: true,
        skin: mono.copyWith(seconds: SkinSeconds.off),
        meridiem: en,
      );
      // A skin without seconds of its own shows them as cards, so the
      // Show seconds switch always shows something.
      expect(none.cards, ['21', '05', '07']);
      expect(none.badge, isNull);
      expect(
        clockValue(
          t,
          use24h: true,
          showSeconds: false,
          skin: mono,
          meridiem: en,
        ).cards,
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
