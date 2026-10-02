import 'dart:ui' show Tristate;

import 'package:design_system/design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  bool disableAnimations = false,
  AppearanceMode mode = AppearanceMode.black,
}) async {
  await tester.pumpWidget(
    DesignSystemWrapper(
      mode: mode,
      builder: (_, theme) => MaterialApp(
        theme: theme,
        builder: (context, app) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: disableAnimations),
          child: app!,
        ),
        home: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}

Widget _box([double width = 120, double height = 60]) =>
    SizedBox(width: width, height: height);

/// The scale the press applies to the child right now.
double _scale(WidgetTester tester) => tester
    .widget<Transform>(
      find.descendant(
        of: find.byType(Pressable),
        matching: find.byType(Transform),
      ),
    )
    .transform
    .entry(0, 0);

double _opacity(WidgetTester tester) => tester
    .widget<Opacity>(
      find.descendant(
        of: find.byType(Pressable),
        matching: find.byType(Opacity),
      ),
    )
    .opacity;

Finder _ring() => find.descendant(
  of: find.byType(Pressable),
  matching: find.byWidgetPredicate(
    (w) =>
        w is DecoratedBox &&
        w.position == DecorationPosition.foreground &&
        (w.decoration as BoxDecoration).border != null,
  ),
);

void main() {
  testWidgets('scales to pressScale while held and back after release', (
    tester,
  ) async {
    var taps = 0;
    await _pump(tester, Pressable(onTap: () => taps++, child: _box()));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(Pressable)),
    );
    // Starts on pointer down: shows well inside the 100 ms tap delay.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));
    expect(_scale(tester), lessThan(1));
    await tester.pump(DesignMotion.pressIn);
    expect(_scale(tester), closeTo(DesignMotion.pressScale, 1e-6));
    expect(taps, 0, reason: 'fires on up, not on down');
    await gesture.up();
    expect(taps, 1);
    await tester.pump();
    await tester.pump(DesignMotion.pressOut ~/ 2);
    expect(_scale(tester), inExclusiveRange(DesignMotion.pressScale, 1));
    await tester.pumpAndSettle();
    expect(_scale(tester), 1);
  });

  testWidgets('a 44 px child presses to pressScaleSmall', (tester) async {
    await _pump(tester, Pressable(onTap: () {}, child: _box(44, 44)));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(Pressable)),
    );
    await tester.pumpAndSettle();
    expect(_scale(tester), closeTo(DesignMotion.pressScaleSmall, 1e-6));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(_scale(tester), 1);
  });

  testWidgets('a press inside another Pressable shrinks only the inner one', (
    tester,
  ) async {
    var outer = 0;
    var inner = 0;
    await _pump(
      tester,
      Pressable(
        key: const Key('outer'),
        onTap: () => outer++,
        child: SizedBox(
          width: 200,
          height: 120,
          child: Center(
            child: Pressable(
              key: const Key('inner'),
              onTap: () => inner++,
              child: _box(80, 40),
            ),
          ),
        ),
      ),
    );
    double scaleOf(String key) => tester
        .widget<Transform>(
          find
              .descendant(
                of: find.byKey(Key(key)),
                matching: find.byType(Transform),
              )
              .first,
        )
        .transform
        .entry(0, 0);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('inner'))),
    );
    await tester.pumpAndSettle();
    expect(scaleOf('inner'), lessThan(1));
    expect(scaleOf('outer'), 1);
    await gesture.up();
    await tester.pumpAndSettle();
    expect((inner, outer), (1, 0));
  });

  testWidgets('dragging off cancels and releases without firing', (
    tester,
  ) async {
    var taps = 0;
    await _pump(tester, Pressable(onTap: () => taps++, child: _box()));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(Pressable)),
    );
    await tester.pumpAndSettle();
    await gesture.moveBy(const Offset(200, 0));
    await tester.pumpAndSettle();
    expect(_scale(tester), 1);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(taps, 0);
  });

  testWidgets('a press that becomes a scroll does not fire', (tester) async {
    var taps = 0;
    await _pump(
      tester,
      SizedBox(
        height: 300,
        child: ListView(
          children: [
            Pressable(onTap: () => taps++, child: _box(200, 100)),
            _box(200, 1000),
          ],
        ),
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(Pressable)),
    );
    await tester.pump(const Duration(milliseconds: 10));
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(0, -10));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();
    expect(_scale(tester), 1);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(taps, 0);
  });

  testWidgets('a long press fires onLongPress, not onTap', (tester) async {
    var taps = 0;
    var longs = 0;
    await _pump(
      tester,
      Pressable(onTap: () => taps++, onLongPress: () => longs++, child: _box()),
    );
    await tester.longPress(find.byType(Pressable));
    await tester.pumpAndSettle();
    expect((taps, longs), (0, 1));
    expect(_scale(tester), 1);
  });

  testWidgets('a second finger does not restart the press', (tester) async {
    var taps = 0;
    await _pump(tester, Pressable(onTap: () => taps++, child: _box()));
    final center = tester.getCenter(find.byType(Pressable));
    final first = await tester.startGesture(center);
    await tester.pumpAndSettle();
    final second = await tester.startGesture(center, pointer: 2);
    await second.up();
    await tester.pumpAndSettle();
    expect(_scale(tester), closeTo(DesignMotion.pressScale, 1e-6));
    await first.up();
    await tester.pumpAndSettle();
    expect(_scale(tester), 1);
  });

  testWidgets('Enter and Space fire with a press-and-release', (tester) async {
    var taps = 0;
    await _pump(tester, Pressable(onTap: () => taps++, child: _box()));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    await tester.pump(DesignMotion.pressIn ~/ 2);
    expect(taps, 1);
    expect(_scale(tester), lessThan(1));
    await tester.pumpAndSettle();
    expect(_scale(tester), 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(taps, 2);
  });

  testWidgets('a keyboard press disposed mid-way does not throw', (
    tester,
  ) async {
    await _pump(tester, Pressable(onTap: () {}, child: _box()));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows a 2 px accent ring at focusRadius when focused', (
    tester,
  ) async {
    final radius = DesignShape.circular(9);
    await _pump(
      tester,
      Pressable(onTap: () {}, focusRadius: radius, child: _box()),
      mode: AppearanceMode.light,
    );
    expect(_ring(), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final decoration =
        tester.widget<DecoratedBox>(_ring()).decoration as BoxDecoration;
    final side = (decoration.border! as Border).top;
    expect(side.width, 2);
    expect(side.color, DesignColors.light.accent);
    expect(decoration.borderRadius, radius);
  });

  testWidgets('the ring defaults to the sm corner', (tester) async {
    await _pump(tester, Pressable(onTap: () {}, child: _box()));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final decoration =
        tester.widget<DecoratedBox>(_ring()).decoration as BoxDecoration;
    expect(
      decoration.borderRadius,
      DesignShape.circular(const DesignShape().sm),
    );
  });

  testWidgets('shows the click cursor on hover, and no wash', (tester) async {
    await _pump(tester, Pressable(onTap: () {}, child: _box()));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.byType(Pressable)));
    await tester.pump();
    expect(
      RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
      SystemMouseCursors.click,
    );
    expect(_scale(tester), 1);
    expect(_opacity(tester), 1);
    await mouse.removePointer();
  });

  testWidgets('disabled ignores press, keys and focus', (tester) async {
    final handle = tester.ensureSemantics();
    var longs = 0;
    await _pump(tester, Pressable(onLongPress: () => longs++, child: _box()));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(Pressable)),
    );
    await tester.pumpAndSettle();
    expect(_scale(tester), 1);
    await gesture.up();
    await tester.longPress(find.byType(Pressable));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(longs, 0);
    expect(_ring(), findsNothing);
    expect(
      tester.getSemantics(find.byType(Pressable)),
      isSemantics(
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
        hasTapAction: false,
      ),
    );
    handle.dispose();
  });

  testWidgets('disabling mid-press releases it', (tester) async {
    Widget pressable(VoidCallback? onTap) =>
        Pressable(onTap: onTap, child: _box());
    await _pump(tester, pressable(() {}));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(Pressable)),
    );
    await tester.pumpAndSettle();
    await _pump(tester, pressable(null));
    await tester.pump();
    expect(_scale(tester), 1);
    await gesture.up();
  });

  testWidgets('reduced motion dips opacity instead of scaling', (tester) async {
    await _pump(
      tester,
      Pressable(onTap: () {}, child: _box()),
      disableAnimations: true,
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(Pressable)),
    );
    await tester.pump();
    await tester.pump(DesignMotion.pressIn);
    expect(_opacity(tester), closeTo(DesignMotion.pressOpacity, 1e-6));
    expect(_scale(tester), 1);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(_opacity(tester), 1);
  });

  testWidgets('semantics: button, label, tap action, selected', (tester) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await _pump(
      tester,
      Pressable(
        onTap: () => taps++,
        onLongPress: () {},
        semanticsLabel: 'Start',
        selected: true,
        child: _box(),
      ),
    );
    final node = tester.getSemantics(find.byType(Pressable));
    expect(
      node,
      isSemantics(
        label: 'Start',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasSelectedState: true,
        isSelected: true,
        isFocusable: true,
        hasTapAction: true,
        hasLongPressAction: true,
        hasFocusAction: true,
      ),
    );
    tester.semantics.tap(find.semantics.byLabel('Start'));
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('a role replaces the button flag and keeps unselected', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pump(
      tester,
      Pressable(
        onTap: () {},
        role: SemanticsRole.tab,
        semanticsLabel: 'Clock',
        child: _box(),
      ),
    );
    final data = tester.getSemantics(find.byType(Pressable)).getSemanticsData();
    expect(data.role, SemanticsRole.tab);
    expect(data.flagsCollection.isButton, isFalse);
    expect(data.flagsCollection.isSelected, Tristate.isFalse);
    handle.dispose();
  });
}
