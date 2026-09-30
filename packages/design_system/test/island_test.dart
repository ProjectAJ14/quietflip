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
  List<ds.IslandAction> actions = const [],
  List<ds.IslandAction> trailing = const [],
  String? status,
}) => ds.Island(
  state: state,
  hud: hud,
  tabs: tabs,
  selected: 1,
  onSelect: onSelect ?? (_) {},
  tabsLabel: 'Modes',
  actions: actions,
  trailing: trailing,
  status: status,
);

/// Start (primary), a disabled Reset, two chips and a tune icon.
List<ds.IslandAction> _actions([List<String>? log]) => [
  ds.IslandAction(
    label: 'Start',
    icon: Icons.play_arrow_rounded,
    primary: true,
    onPressed: () => log?.add('Start'),
  ),
  const ds.IslandAction(label: 'Reset', icon: Icons.restart_alt_rounded),
  ds.IslandAction(label: '5m', onPressed: () => log?.add('5m')),
  ds.IslandAction(label: '10m', onPressed: () => log?.add('10m')),
  ds.IslandAction(
    label: 'Timers',
    icon: Icons.tune_rounded,
    onPressed: () => log?.add('Timers'),
  ),
];

List<ds.IslandAction> _trailing([List<String>? log]) => [
  ds.IslandAction(
    label: 'Settings',
    icon: Icons.settings_outlined,
    onPressed: () => log?.add('Settings'),
  ),
];

final _rule = find.byWidgetPredicate(
  (w) => w is SizedBox && w.width == 1 && w.child is ColoredBox,
);

/// WCAG contrast of two opaque colours, 1..21.
double _contrast(Color a, Color b) {
  final x = a.computeLuminance();
  final y = b.computeLuminance();
  return (x > y ? x + 0.05 : y + 0.05) / (x > y ? y + 0.05 : x + 0.05);
}

/// The nearest filled box behind [e].
Color _backdrop(Element e) {
  Color? found;
  e.visitAncestorElements((a) {
    final w = a.widget;
    if (w is DecoratedBox) {
      final c = (w.decoration as BoxDecoration).color;
      if (c != null && c.a > 0) {
        found = c;
        return false;
      }
    }
    return true;
  });
  return found!;
}

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

      testWidgets('the tray lays out actions, chips, a rule and a status', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        final log = <String>[];
        await _pump(
          tester,
          mode,
          _island(
            actions: _actions(log),
            trailing: _trailing(log),
            status: "Time's up",
          ),
          width: 800,
        );
        expect(
          tester.getSize(find.byType(ds.Island)).height,
          ds.Island.trayHeight,
        );
        for (final label in ['Start', 'Reset', 'Timers', 'Settings']) {
          expect(find.byTooltip(label), findsOneWidget, reason: label);
        }
        expect(find.text('5m'), findsOneWidget);
        expect(_rule, findsOneWidget);
        final status = tester.getSemantics(find.bySemanticsLabel("Time's up"));
        expect(status.getSemanticsData().flagsCollection.isLiveRegion, isTrue);

        await tester.tap(find.byIcon(Icons.play_arrow_rounded));
        await tester.tap(find.text('10m'));
        await tester.tap(find.byIcon(Icons.tune_rounded));
        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.tap(find.byIcon(Icons.restart_alt_rounded));
        expect(log, ['Start', '10m', 'Timers', 'Settings']);
        final reset = tester
            .getSemantics(find.bySemanticsLabel('Reset'))
            .getSemanticsData();
        expect(reset.flagsCollection.isButton, isTrue);
        expect(reset.flagsCollection.isEnabled, Tristate.isFalse);
        semantics.dispose();
      });

      testWidgets('trailing alone has no rule; no tray keeps the tab height', (
        tester,
      ) async {
        await _pump(tester, mode, _island(trailing: _trailing()));
        expect(_rule, findsNothing);
        expect(
          tester.getSize(find.byType(ds.Island)).height,
          ds.Island.trayHeight,
        );
        await _pump(tester, mode, _island());
        expect(tester.getSize(find.byType(ds.Island)).height, 52);
      });

      testWidgets('every tray action is legible on the island', (tester) async {
        await _pump(
          tester,
          mode,
          _island(actions: _actions(), trailing: _trailing(), status: 'Done'),
        );
        final tray = find.byType(SingleChildScrollView);
        final icons = find.descendant(of: tray, matching: find.byType(Icon));
        final texts = find.descendant(of: tray, matching: find.byType(Text));
        expect(icons, findsNWidgets(4));
        expect(texts, findsNWidgets(3));
        for (final e in [...icons.evaluate(), ...texts.evaluate()]) {
          final w = e.widget;
          final ink = w is Icon ? w.color! : (w as Text).style!.color!;
          expect(
            _contrast(ink, _backdrop(e)),
            greaterThanOrEqualTo(4.5),
            reason: '$w',
          );
        }
      });

      testWidgets('the tray scrolls at 320px and text scale 2', (tester) async {
        final log = <String>[];
        await _pump(
          tester,
          mode,
          _island(
            actions: [
              ..._actions(log),
              for (var m = 20; m < 25; m++)
                ds.IslandAction(label: '${m}m', onPressed: () {}),
            ],
            trailing: _trailing(log),
          ),
          width: 320,
          textScale: 2,
        );
        expect(tester.takeException(), isNull);
        expect(
          tester.getSize(find.byType(ds.Island)).width,
          lessThanOrEqualTo(320 - 2 * ds.DesignSpace.s4),
        );
        // The primary action comes first and is on screen.
        await tester.tap(find.byIcon(Icons.play_arrow_rounded));
        expect(log, ['Start']);
        // Settings is past the end until the tray is scrolled.
        expect(
          find.byIcon(Icons.settings_outlined).hitTestable(),
          findsNothing,
        );
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(-2000, 0),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.settings_outlined));
        expect(log, ['Start', 'Settings']);
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
    await _pump(tester, ds.AppearanceMode.black, _island(actions: _actions()));
    // The tray still cross-fades; only the spring goes.
    expect(find.byType(AnimatedSize), findsNothing);
    expect(
      tester
          .widget<AnimatedSwitcher>(
            find
                .ancestor(
                  of: find.byType(SingleChildScrollView),
                  matching: find.byType(AnimatedSwitcher),
                )
                .first,
          )
          .duration,
      ds.DesignMotion.fade,
    );
    expect(tester.getSize(find.byType(ds.Island)).height, ds.Island.trayHeight);
  });
}
