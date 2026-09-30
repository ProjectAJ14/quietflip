import 'package:flip_clock/ui/components/gesture_layer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records every callback of a [GestureLayer].
class _Log {
  int taps = 0;
  int doubleTaps = 0;
  int starts = 0;
  int brightnessEnds = 0;
  int swipeEnds = 0;
  final List<double> brightness = [];
  final List<int> pages = [];
}

void main() {
  late PageController pages;
  late _Log log;

  setUp(() {
    pages = PageController();
    log = _Log();
  });
  tearDown(() => pages.dispose());

  Future<void> pump(
    WidgetTester tester, {
    bool enabled = true,
    bool brightness = true,
    bool modes = true,
    bool doubleTap = false,
    Widget? child,
  }) => tester.pumpWidget(
    MaterialApp(
      home: GestureLayer(
        pages: pages,
        pageCount: 4,
        enabled: enabled,
        brightness: brightness,
        modes: modes,
        onTap: () => log.taps++,
        onDoubleTap: doubleTap ? () => log.doubleTaps++ : null,
        onGestureStart: () => log.starts++,
        onBrightness: log.brightness.add,
        onBrightnessEnd: () => log.brightnessEnds++,
        onPage: log.pages.add,
        onSwipeEnd: () => log.swipeEnds++,
        child:
            child ??
            PageView(
              controller: pages,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                ColoredBox(color: Colors.red),
                ColoredBox(color: Colors.green),
                ColoredBox(color: Colors.blue),
                ColoredBox(color: Colors.yellow),
              ],
            ),
      ),
    ),
  );

  final layer = find.byType(GestureLayer);
  const width = 800.0; // default test surface is 800 x 600
  const height = 600.0;

  Future<void> drag(WidgetTester tester, List<Offset> moves) async {
    final gesture = await tester.startGesture(tester.getCenter(layer));
    for (final move in moves) {
      await gesture.moveBy(move);
    }
    await gesture.up();
    await tester.pumpAndSettle();
  }

  double sum(List<double> values) => values.fold(0, (a, b) => a + b);

  testWidgets('a tap calls onTap at once when there is no double tap', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(layer);
    await tester.tap(layer);
    expect(log.taps, 2);
    expect(log.doubleTaps, 0);
  });

  testWidgets('a double tap calls onDoubleTap when given', (tester) async {
    await pump(tester, doubleTap: true);
    await tester.tap(layer);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(layer);
    await tester.pumpAndSettle();
    expect(log.doubleTaps, 1);
  });

  testWidgets('a child button keeps its own tap', (tester) async {
    var pressed = 0;
    await pump(
      tester,
      child: Center(
        child: ElevatedButton(
          onPressed: () => pressed++,
          child: const SizedBox.square(dimension: 40),
        ),
      ),
    );
    await tester.tap(find.byType(ElevatedButton));
    expect(pressed, 1);
    expect(log.taps, 0);
  });

  testWidgets('10 px right then 40 px down locks to vertical', (tester) async {
    await pump(tester);
    await drag(tester, const [Offset(10, 0), Offset(0, 40)]);
    expect(log.brightness, isNotEmpty);
    expect(sum(log.brightness), closeTo(-40 / height, 1e-9));
    expect(log.brightnessEnds, 1);
    expect(pages.page, 0);
    expect(log.pages, isEmpty);
  });

  testWidgets('40 px right with 11 px down locks to horizontal', (
    tester,
  ) async {
    await pump(tester);
    pages.jumpToPage(1);
    final gesture = await tester.startGesture(tester.getCenter(layer));
    await gesture.moveBy(const Offset(40, 11));
    await tester.pump();
    expect(pages.offset, width - 40);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(log.brightness, isEmpty);
    expect(log.pages, [1]);
    expect(log.swipeEnds, 1);
  });

  testWidgets('a drag up by half the height adds up to 0.5', (tester) async {
    await pump(tester);
    await drag(tester, List.filled(10, const Offset(0, -height / 20)));
    expect(sum(log.brightness), closeTo(0.5, 1e-9));
    expect(log.brightnessEnds, 1);
  });

  testWidgets('24% springs back and reports the same page', (tester) async {
    await pump(tester);
    await drag(tester, List.filled(4, const Offset(-width * 0.06, 0)));
    expect(pages.page, 0);
    expect(log.pages, [0]);
    expect(log.swipeEnds, 1);
  });

  testWidgets('26% moves one page', (tester) async {
    await pump(tester);
    await drag(tester, List.filled(2, const Offset(-width * 0.13, 0)));
    expect(pages.page, 1);
    expect(log.pages, [1]);
    await drag(tester, List.filled(2, const Offset(width * 0.13, 0)));
    expect(pages.page, 0);
    expect(log.pages, [1, 0]);
  });

  testWidgets('a fast fling moves one page, a slow one does not', (
    tester,
  ) async {
    await pump(tester);
    await tester.fling(layer, const Offset(-50, 0), 400);
    await tester.pumpAndSettle();
    expect(pages.page, 0);
    await tester.fling(layer, const Offset(-50, 0), 1000);
    await tester.pumpAndSettle();
    expect(pages.page, 1);
    await tester.fling(layer, const Offset(50, 0), 1000);
    await tester.pumpAndSettle();
    expect(pages.page, 0);
    expect(log.pages, [0, 1, 0]);
  });

  testWidgets('swipes never wrap around', (tester) async {
    await pump(tester);
    await drag(tester, const [Offset(300, 0)]);
    expect(pages.page, 0);
    pages.jumpToPage(3);
    await drag(tester, const [Offset(-300, 0)]);
    expect(pages.page, 3);
    expect(log.pages, [0, 3]);
  });

  testWidgets('a disabled layer ignores taps and drags', (tester) async {
    await pump(tester, enabled: false, doubleTap: true);
    await tester.tap(layer);
    await drag(tester, const [Offset(-400, 0)]);
    await drag(tester, const [Offset(0, -200)]);
    expect(log.taps, 0);
    expect(log.starts, 0);
    expect(log.brightness, isEmpty);
    expect(log.pages, isEmpty);
    expect(pages.page, 0);
  });

  testWidgets('brightness: false ignores vertical drags', (tester) async {
    await pump(tester, brightness: false);
    await drag(tester, const [Offset(0, -200), Offset(-300, 0)]);
    expect(log.brightness, isEmpty);
    expect(log.brightnessEnds, 0);
    expect(log.starts, 0);
    expect(pages.page, 0);
  });

  testWidgets('modes: false ignores horizontal swipes', (tester) async {
    await pump(tester, modes: false);
    await drag(tester, const [Offset(-400, 0), Offset(0, -200)]);
    expect(pages.page, 0);
    expect(log.pages, isEmpty);
    expect(log.swipeEnds, 0);
    expect(log.brightness, isEmpty);
    expect(log.starts, 0);
  });

  testWidgets('onGestureStart fires once per drag', (tester) async {
    await pump(tester);
    await drag(tester, List.filled(8, const Offset(0, -20)));
    expect(log.starts, 1);
    await drag(tester, List.filled(8, const Offset(-20, 0)));
    expect(log.starts, 2);
  });

  testWidgets('a drag shorter than the axis lock does nothing', (tester) async {
    await pump(tester);
    final gesture = await tester.startGesture(
      tester.getCenter(layer),
      kind: PointerDeviceKind.mouse,
    );
    await gesture.moveBy(const Offset(5, 5));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(log.starts, 0);
    expect(log.brightness, isEmpty);
    expect(log.pages, isEmpty);
  });
}
