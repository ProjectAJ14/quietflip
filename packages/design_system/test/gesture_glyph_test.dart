import 'package:design_system/design_system.dart' as ds;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ds.AppearanceMode mode = ds.AppearanceMode.black,
  bool reduced = false,
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    ds.DesignSystemWrapper(
      mode: mode,
      builder: (_, theme) => MaterialApp(
        theme: theme,
        builder: (context, app) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: reduced,
            textScaler: TextScaler.linear(textScale),
          ),
          child: app!,
        ),
        home: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}

ds.GestureGlyphPainter _painter(WidgetTester tester) =>
    tester
            .widget<CustomPaint>(
              find.descendant(
                of: find.byType(ds.GestureGlyph),
                matching: find.byType(CustomPaint),
              ),
            )
            .painter!
        as ds.GestureGlyphPainter;

Duration _ms(int ms) => Duration(milliseconds: ms);

void main() {
  const loop = ds.DesignMotion.gestureLoop;

  test('the loop and its phases are design tokens', () {
    expect(loop, _ms(1600));
    expect(ds.DesignMotion.gestureFade, _ms(150));
    expect(ds.DesignMotion.gestureRing, _ms(450));
    expect(ds.DesignMotion.gestureTravel, _ms(600));
    expect(ds.DesignMotion.gestureTravelCurve, Curves.easeInOutCubic);
    expect(ds.GestureGlyph.dot, 10);
    expect(ds.GestureGlyph.ringMax, 28);
    expect(ds.GestureGlyph.travel, 18);
  });

  group('tap frames', () {
    ds.GestureFrame at(int ms) =>
        ds.GestureGlyph.frameAt(ds.GestureKind.tap, _ms(ms));

    test('0 ms: the dot is up, no ring', () {
      final f = at(0);
      expect(f.dot, Offset.zero);
      expect(f.scale, 1);
      expect(f.opacity, 1);
      expect(f.ring, 0);
      expect(f.trail, isNull);
      expect(f.arrow, isNull);
    });

    test('150 ms: pressed to 0.7, the ring starts at the dot', () {
      expect(at(75).scale, closeTo(0.85, 1e-9));
      final f = at(150);
      expect(f.scale, closeTo(0.7, 1e-9));
      expect(f.ring, closeTo(10, 1e-9));
      expect(f.ringOpacity, closeTo(1, 1e-9));
    });

    test('400 ms: released, the ring is part grown and fading', () {
      final f = at(400);
      expect(f.scale, 1);
      expect(f.ring, closeTo(10 + 18 * 250 / 450, 1e-9));
      expect(f.ringOpacity, closeTo(1 - 250 / 450, 1e-9));
    });

    test('800 ms: rest, no ring', () {
      final f = at(800);
      expect(f.scale, 1);
      expect(f.ring, 0);
    });

    test('the second loop taps the same way', () {
      expect(at(1600 + 400), at(400));
    });
  });

  group('swipe frames', () {
    for (final (kind, first) in [
      (ds.GestureKind.swipeHorizontal, const Offset(1, 0)),
      (ds.GestureKind.swipeVertical, const Offset(0, -1)),
    ]) {
      ds.GestureFrame at(int ms) => ds.GestureGlyph.frameAt(kind, _ms(ms));
      const half = ds.GestureGlyph.travel / 2;

      test('$kind 0 ms: invisible at the start, no trail', () {
        final f = at(0);
        expect(f.dot, -first * half);
        expect(f.opacity, 0);
        expect(f.trail, isNull);
        expect(f.ring, 0);
        expect(f.scale, 1);
      });

      test('$kind 400 ms: eased part way, a trail behind it', () {
        final f = at(400);
        final p = Curves.easeInOutCubic.transform(250 / 600);
        final lag = Curves.easeInOutCubic.transform(100 / 600);
        expect(f.opacity, 1);
        expect(f.dot, -first * half + first * (ds.GestureGlyph.travel * p));
        expect(f.trail, -first * half + first * (ds.GestureGlyph.travel * lag));
      });

      test('$kind 800 ms: at the end, fading out', () {
        final f = at(800);
        expect(f.dot, first * half);
        expect(f.opacity, closeTo(1 - 50 / 150, 1e-9));
        expect(f.trail, isNotNull);
      });

      test('$kind rests after 900 ms', () {
        expect(at(1000).opacity, 0);
        expect(at(1000).trail, isNull);
      });

      test('$kind goes the other way on the next loop', () {
        expect(at(1600).dot, first * half);
        expect(at(1600 + 800).dot, -first * half);
      });
    }
  });

  test('still frames: the ring at mid size, an arrow for swipes', () {
    final tap = ds.GestureGlyph.still(ds.GestureKind.tap);
    expect(tap.ring, 19);
    expect(tap.opacity, 1);
    expect(tap.arrow, isNull);
    expect(
      ds.GestureGlyph.still(ds.GestureKind.swipeHorizontal).arrow,
      const Offset(1, 0),
    );
    expect(
      ds.GestureGlyph.still(ds.GestureKind.swipeVertical).arrow,
      const Offset(0, -1),
    );
    expect(ds.GestureGlyph.still(ds.GestureKind.swipeVertical).opacity, 1);
  });

  for (final kind in ds.GestureKind.values) {
    testWidgets('$kind paints its frame at 0, 400 and 800 ms', (tester) async {
      await _pump(tester, ds.GestureGlyph(kind));
      for (final ms in [0, 400, 800]) {
        expect(_painter(tester).frame, ds.GestureGlyph.frameAt(kind, _ms(ms)));
        expect(
          find.byType(ds.GestureGlyph),
          paints..rrect(color: ds.DesignColors.dark.surfaceRaised),
        );
        await tester.pump(_ms(400));
      }
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('$kind under reduced motion draws the still frame', (
      tester,
    ) async {
      await _pump(tester, ds.GestureGlyph(kind), reduced: true);
      expect(tester.binding.transientCallbackCount, 0);
      await tester.pump(_ms(400));
      expect(_painter(tester).frame, ds.GestureGlyph.still(kind));
      expect(find.byType(ds.GestureGlyph), paints..circle());
    });
  }

  testWidgets('stops ticking offstage and resumes when visible', (
    tester,
  ) async {
    Widget glyph(bool on) => TickerMode(
      enabled: on,
      child: const ds.GestureGlyph(ds.GestureKind.tap),
    );
    await _pump(tester, glyph(false));
    await tester.pump(_ms(400));
    expect(tester.binding.transientCallbackCount, 0);
    expect(
      _painter(tester).frame,
      ds.GestureGlyph.frameAt(ds.GestureKind.tap, Duration.zero),
    );
    await _pump(tester, glyph(true));
    expect(tester.binding.transientCallbackCount, greaterThan(0));
    // A muted ticker keeps its clock: 400 ms passed offstage.
    await tester.pump(_ms(100));
    expect(_painter(tester).frame.ring, greaterThan(0));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('turning reduced motion on stops it, off starts it', (
    tester,
  ) async {
    const glyph = ds.GestureGlyph(ds.GestureKind.swipeVertical);
    bool running() =>
        (_painter(tester).progress as AnimationController).isAnimating;
    await _pump(tester, glyph);
    expect(running(), isTrue);
    await _pump(tester, glyph, reduced: true);
    expect(running(), isFalse);
    expect(
      _painter(tester).frame,
      ds.GestureGlyph.still(ds.GestureKind.swipeVertical),
    );
    await _pump(tester, glyph);
    expect(running(), isTrue);
    expect(_painter(tester).still, isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  for (final mode in [ds.AppearanceMode.black, ds.AppearanceMode.light]) {
    testWidgets('a tile on surfaceRaised with an ink dot ($mode)', (
      tester,
    ) async {
      await _pump(
        tester,
        const ds.GestureGlyph(ds.GestureKind.tap),
        mode: mode,
        textScale: 2,
        reduced: true,
      );
      final colors = mode == ds.AppearanceMode.black
          ? ds.DesignColors.dark
          : ds.DesignColors.light;
      expect(
        tester.getSize(find.byType(ds.GestureGlyph)),
        const Size.square(ds.SettingsShell.iconTileSize),
      );
      expect(
        find.byType(ds.GestureGlyph),
        paints
          ..rrect(color: colors.surfaceRaised)
          // The still ring at half opacity, then the fingertip.
          ..circle(color: colors.ink.withValues(alpha: 0.5))
          ..circle(color: colors.ink),
      );
      expect(_painter(tester).color, colors.ink);
    });
  }

  testWidgets('is not announced', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, const ds.GestureGlyph(ds.GestureKind.tap));
    expect(tester.getSemantics(find.byType(ds.GestureGlyph)).label, isEmpty);
    expect(
      find.descendant(
        of: find.byType(ds.GestureGlyph),
        matching: find.byType(ExcludeSemantics),
      ),
      findsOne,
    );
    handle.dispose();
    await tester.pumpWidget(const SizedBox());
  });

  test('repaints only for a new frame source', () {
    final a = AnimationController(vsync: const TestVSync());
    addTearDown(a.dispose);
    ds.GestureGlyphPainter p({
      ds.GestureKind kind = ds.GestureKind.tap,
      Color color = const Color(0xff000000),
      bool still = false,
      Animation<double>? anim,
    }) => ds.GestureGlyphPainter(
      kind: kind,
      color: color,
      still: still,
      progress: anim ?? a,
    );
    expect(p().shouldRepaint(p()), isFalse);
    expect(p().shouldRepaint(p(kind: ds.GestureKind.swipeVertical)), isTrue);
    expect(p().shouldRepaint(p(color: const Color(0xffffffff))), isTrue);
    expect(p().shouldRepaint(p(still: true)), isTrue);
    expect(p().shouldRepaint(p(anim: kAlwaysCompleteAnimation)), isTrue);
  });

  testWidgets('a swipe paints its trail; the still frame an arrow', (
    tester,
  ) async {
    const glyph = ds.GestureGlyph(ds.GestureKind.swipeHorizontal);
    await _pump(tester, glyph);
    await tester.pump(_ms(400));
    expect(
      find.byType(ds.GestureGlyph),
      paints
        ..line()
        ..circle(),
    );
    await _pump(tester, glyph, reduced: true);
    expect(
      find.byType(ds.GestureGlyph),
      paints
        ..circle()
        ..path(),
    );
    await tester.pumpWidget(const SizedBox());
  });
}
