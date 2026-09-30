import 'dart:ui' show Tristate;

import 'package:design_system/design_system.dart' as ds;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

const _tabs = ['Clock', 'Timer', 'Stopwatch'];

Future<void> _pump(
  WidgetTester tester,
  ds.AppearanceMode mode,
  Widget child, {
  double width = 400,
  double textScale = 1,
  bool disableAnimations = false,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ds.DesignSystemWrapper(
      mode: mode,
      builder: (_, theme) => MaterialApp(
        theme: theme,
        builder: (context, app) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: disableAnimations,
          ),
          child: app!,
        ),
        home: Scaffold(
          body: Align(alignment: Alignment.topCenter, child: child),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

ds.Island _island({
  ds.ChromeState state = ds.ChromeState.expanded,
  ds.IslandHud? hud,
  List<String> tabs = _tabs,
  ValueChanged<int>? onSelect,
}) => ds.Island(
  state: state,
  hud: hud,
  tabs: tabs,
  selected: 1,
  onSelect: onSelect ?? (_) {},
  tabsLabel: 'Modes',
);

double _opacity(WidgetTester tester, Type type) => tester
    .widget<AnimatedOpacity>(
      find.descendant(
        of: find.byType(type),
        matching: find.byType(AnimatedOpacity),
      ),
    )
    .opacity;

void main() {
  test('the island spring starts at 0, overshoots and ends at exactly 1', () {
    const curve = ds.DesignMotion.islandCurve;
    expect(curve.transform(0), 0);
    expect(curve.transform(1), 1);
    final samples = [for (var i = 1; i < 100; i++) curve.transform(i / 100)];
    expect(samples.any((x) => x > 1), isTrue);
    expect(curve.transform(0.999), closeTo(1, 0.01));
  });

  test('HUDs keep their values and reject out-of-range input', () {
    var level = 0.5;
    expect(ds.IslandBrightnessHud(level, '50%').value, 0.5);
    expect(ds.IslandTitleHud('Timer', level.toInt(), 2).count, 2);
    level = 1.5;
    expect(() => ds.IslandBrightnessHud(level, '150%'), throwsAssertionError);
    expect(() => ds.IslandTitleHud('Timer', 2, 2), throwsAssertionError);
  });

  for (final mode in [ds.AppearanceMode.black, ds.AppearanceMode.light]) {
    group('${mode.name} theme', () {
      testWidgets('dot, expanded and hidden island sizes', (tester) async {
        await _pump(tester, mode, _island(state: ds.ChromeState.dot));
        expect(tester.getSize(find.byType(ds.Island)), const Size(10, 10));
        expect(_opacity(tester, ds.Island), 1);
        expect(find.byType(ds.Island).hitTestable(), findsNothing);

        await _pump(tester, mode, _island());
        // Mid-morph the outgoing dot still fades beside the tabs.
        expect(tester.getSize(find.byType(ds.Island)).height, 52);

        await _pump(tester, mode, _island(state: ds.ChromeState.hidden));
        expect(tester.getSize(find.byType(ds.Island)), const Size(10, 10));
        expect(_opacity(tester, ds.Island), 0);
        expect(find.byType(ds.Island).hitTestable(), findsNothing);
        expect(find.bySemanticsLabel('Modes'), findsNothing);
      });

      testWidgets('a HUD wins over hidden and is announced', (tester) async {
        final semantics = tester.ensureSemantics();
        final colors = mode == ds.AppearanceMode.black
            ? ds.DesignColors.dark
            : ds.DesignColors.light;
        await _pump(
          tester,
          mode,
          _island(
            state: ds.ChromeState.hidden,
            hud: const ds.IslandBrightnessHud(0.72, '72%'),
          ),
        );
        expect(tester.getSize(find.byType(ds.Island)).height, 36);
        expect(_opacity(tester, ds.Island), 1);
        final brightness = tester.getSemantics(find.bySemanticsLabel('72%'));
        expect(
          brightness.getSemanticsData().flagsCollection.isLiveRegion,
          isTrue,
        );
        expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
        expect(
          tester.widget<Text>(find.text('72%')).style!.color,
          colors.islandInkMuted,
        );

        await _pump(
          tester,
          mode,
          _island(hud: const ds.IslandTitleHud('Timer', 1, 3)),
        );
        expect(tester.getSize(find.byType(ds.Island)).height, 36);
        expect(find.bySemanticsLabel('Timer'), findsOneWidget);
        final dots = tester
            .widgetList<DecoratedBox>(
              find.ancestor(
                of: find.byWidgetPredicate(
                  (w) => w is SizedBox && w.width == ds.Island.hudDot,
                ),
                matching: find.byType(DecoratedBox),
              ),
            )
            .map((d) => (d.decoration as BoxDecoration).color)
            .where((c) => c == colors.islandInk || c == colors.islandInkMuted)
            .toList();
        expect(dots, [
          colors.islandInkMuted,
          colors.islandInk,
          colors.islandInkMuted,
        ]);
        semantics.dispose();
      });

      testWidgets('tabs select, colour and describe themselves', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        final colors = ds.DesignColors.dark;
        final taps = <int>[];
        await _pump(tester, mode, _island(onSelect: taps.add));
        await tester.tap(find.text('Stopwatch'));
        expect(taps, [2]);

        expect(
          tester.widget<Text>(find.text('Timer')).style!.color,
          colors.islandOnActive,
        );
        expect(
          tester.widget<Text>(find.text('Clock')).style!.color,
          colors.islandInkMuted,
        );
        BoxDecoration pill(String tab) =>
            tester
                    .widget<DecoratedBox>(
                      find
                          .ancestor(
                            of: find.text(tab),
                            matching: find.byType(DecoratedBox),
                          )
                          .first,
                    )
                    .decoration
                as BoxDecoration;
        expect(pill('Timer').color, colors.islandActive);
        expect(pill('Clock').color, Colors.transparent);

        final bar = tester.getSemantics(find.bySemanticsLabel('Modes'));
        expect(bar.getSemanticsData().role, SemanticsRole.tabBar);
        final timer = tester
            .getSemantics(find.bySemanticsLabel('Timer'))
            .getSemanticsData();
        expect(timer.role, SemanticsRole.tab);
        expect(timer.flagsCollection.isSelected, Tristate.isTrue);
        expect(timer.flagsCollection.isButton, isTrue);
        final clock = tester
            .getSemantics(find.bySemanticsLabel('Clock'))
            .getSemanticsData();
        expect(clock.flagsCollection.isSelected, Tristate.isFalse);
        tester
            .getSemantics(find.bySemanticsLabel('Clock'))
            .owner!
            .performAction(
              tester.getSemantics(find.bySemanticsLabel('Clock')).id,
              SemanticsAction.tap,
            );
        expect(taps, [2, 0]);
        semantics.dispose();
      });

      testWidgets('four long tabs fit 320px at text scale 2', (tester) async {
        await _pump(
          tester,
          mode,
          _island(tabs: const ['Clockface', 'Countdown', 'Stopwatch', 'Alarm']),
          width: 320,
          textScale: 2,
        );
        expect(tester.takeException(), isNull);
        expect(
          tester.getSize(find.byType(ds.Island)).width,
          lessThanOrEqualTo(320 - 2 * ds.DesignSpace.s4),
        );
      });

      testWidgets('corner button taps only when expanded', (tester) async {
        var presses = 0;
        Widget corner(ds.ChromeState state) => ds.CornerButton(
          state: state,
          icon: Icons.settings_outlined,
          tooltip: 'Settings',
          onPressed: () => presses++,
          corner: Alignment.topRight,
        );
        final circle = find.descendant(
          of: find.byType(ds.CornerButton),
          matching: find.byType(AnimatedContainer),
        );

        await _pump(tester, mode, corner(ds.ChromeState.expanded));
        expect(tester.getSize(circle), const Size(44, 44));
        expect(find.byTooltip('Settings'), findsOneWidget);
        await tester.tap(find.byIcon(Icons.settings_outlined));
        expect(presses, 1);

        await _pump(tester, mode, corner(ds.ChromeState.dot));
        expect(
          tester.getSize(find.byType(ds.CornerButton)),
          const Size(44, 44),
        );
        expect(tester.getSize(circle), const Size(6, 6));
        expect(
          tester.getTopRight(circle),
          tester.getTopRight(find.byType(ds.CornerButton)),
        );
        await tester.tap(circle, warnIfMissed: false);
        expect(presses, 1);

        await _pump(tester, mode, corner(ds.ChromeState.hidden));
        expect(_opacity(tester, ds.CornerButton), 0);
        await tester.tap(circle, warnIfMissed: false);
        expect(presses, 1);
      });
    });
  }

  testWidgets('reduced motion drops the spring', (tester) async {
    await _pump(tester, ds.AppearanceMode.black, _island());
    expect(
      tester.widget<AnimatedSize>(find.byType(AnimatedSize)).duration,
      ds.DesignMotion.islandMorph,
    );

    await _pump(
      tester,
      ds.AppearanceMode.black,
      _island(state: ds.ChromeState.dot),
      disableAnimations: true,
    );
    // Zero-time AnimatedSize asserts mid-layout, so it is dropped instead.
    expect(find.byType(AnimatedSize), findsNothing);
    expect(tester.getSize(find.byType(ds.Island)), const Size(10, 10));

    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(reduceMotion: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await _pump(
      tester,
      ds.AppearanceMode.black,
      ds.CornerButton(
        state: ds.ChromeState.dot,
        icon: Icons.settings_outlined,
        tooltip: 'Settings',
        onPressed: () {},
        corner: Alignment.topLeft,
      ),
    );
    expect(
      tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).duration,
      Duration.zero,
    );
  });

  testWidgets('a theme switch mid-morph never lerps a shadow past 1', (
    tester,
  ) async {
    Widget corner(ds.AppearanceMode mode, ds.ChromeState state) =>
        ds.DesignSystemWrapper(
          mode: mode,
          builder: (_, theme) => MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Center(
                child: ds.CornerButton(
                  state: state,
                  icon: Icons.settings_outlined,
                  tooltip: 'Settings',
                  onPressed: () {},
                  corner: Alignment.topRight,
                ),
              ),
            ),
          ),
        );
    await tester.pumpWidget(
      corner(ds.AppearanceMode.light, ds.ChromeState.dot),
    );
    // Start the spring toward expanded, then switch theme while it
    // overshoots.
    await tester.pumpWidget(
      corner(ds.AppearanceMode.light, ds.ChromeState.expanded),
    );
    await tester.pump(const Duration(milliseconds: 150));
    // Light's blurred shadow to Dark's ring: past 1 the blur goes negative.
    await tester.pumpWidget(
      corner(ds.AppearanceMode.black, ds.ChromeState.expanded),
    );
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
    }
  });
}
