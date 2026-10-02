import 'dart:ui' show Tristate;

import 'package:design_system/design_system.dart' as ds;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

const _tabs = ['Clock', 'Timer', 'Stopwatch'];

Future<void> _pump(
  WidgetTester tester,
  ds.AppearanceMode mode,
  Widget child, {
  double width = 400,
  double textScale = 1,
  bool disableAnimations = false,
  bool settle = true,
  double corner = ds.DesignShape.defaultCorner,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ds.DesignSystemWrapper(
      mode: mode,
      corner: corner,
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
  if (settle) await tester.pumpAndSettle();
}

ds.Island _island({
  ds.ChromeState state = ds.ChromeState.expanded,
  ds.IslandHud? hud,
  List<String> tabs = _tabs,
  int selected = 1,
  ValueChanged<int>? onSelect,
  List<ds.IslandAction> actions = const [],
  String? status,
}) => ds.Island(
  state: state,
  hud: hud,
  tabs: tabs,
  selected: selected,
  onSelect: onSelect ?? (_) {},
  tabsLabel: 'Modes',
  actions: actions,
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
  ds.IslandAction(
    label: '5m',
    semanticsLabel: '5 minute timer',
    onPressed: () => log?.add('5m'),
  ),
  ds.IslandAction(label: '10m', onPressed: () => log?.add('10m')),
  ds.IslandAction(
    label: 'Timers',
    icon: Icons.tune_rounded,
    onPressed: () => log?.add('Timers'),
  ),
];

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

/// The selected-tab pill behind the tab row.
Finder get _pill => find.descendant(
  of: find.byType(AnimatedPositionedDirectional),
  matching: find.byType(DecoratedBox),
);

Rect _pillRect(WidgetTester tester) => tester.getRect(_pill);

Color? _pillColor(WidgetTester tester) =>
    (tester.widget<DecoratedBox>(_pill).decoration as BoxDecoration).color;

/// The tappable box of the tab labelled [tab].
Rect _tabRect(WidgetTester tester, String tab) => tester.getRect(
  find.ancestor(of: find.text(tab), matching: find.byType(ds.Pressable)),
);

Color? _labelColor(WidgetTester tester, String tab) =>
    tester.widget<Text>(find.text(tab)).style!.color;

void main() {
  test('the island spring starts at 0, overshoots and ends at exactly 1', () {
    const curve = ds.DesignMotion.islandCurve;
    expect(curve.transform(0), 0);
    expect(curve.transform(1), 1);
    final samples = [for (var i = 1; i < 100; i++) curve.transform(i / 100)];
    expect(samples.any((x) => x > 1), isTrue);
    expect(curve.transform(0.999), closeTo(1, 0.01));
  });

  test('the HUD keeps its value and rejects out-of-range input', () {
    var level = 0.5;
    expect(ds.IslandBrightnessHud(level, '50%').value, 0.5);
    level = 1.5;
    expect(() => ds.IslandBrightnessHud(level, '150%'), throwsAssertionError);
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
        expect(
          tester.getSize(find.byType(ds.Island)).height,
          ds.DesignSize.islandExpandedHeight,
        );

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
        // One selected pill, behind the selected tab only.
        expect(_pillColor(tester), colors.islandActive);
        expect(_pillRect(tester), _tabRect(tester, 'Timer'));

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

      testWidgets('the tray lays out actions, chips and a status', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        final log = <String>[];
        await _pump(
          tester,
          mode,
          _island(actions: _actions(log), status: "Time's up"),
          width: 800,
        );
        expect(
          tester.getSize(find.byType(ds.Island)).height,
          ds.Island.trayHeight,
        );
        for (final label in ['Start', 'Reset', 'Timers']) {
          expect(find.byTooltip(label), findsOneWidget, reason: label);
        }
        expect(find.text('5m'), findsOneWidget);
        // An abbreviated chip is spoken in full; others by their label.
        expect(find.bySemanticsLabel('5 minute timer'), findsOneWidget);
        expect(find.bySemanticsLabel('10m'), findsOneWidget);
        final status = tester.getSemantics(find.bySemanticsLabel("Time's up"));
        expect(status.getSemanticsData().flagsCollection.isLiveRegion, isTrue);

        await tester.tap(find.byIcon(Icons.play_arrow_rounded));
        await tester.tap(find.text('10m'));
        await tester.tap(find.byIcon(Icons.tune_rounded));
        await tester.tap(find.byIcon(Icons.restart_alt_rounded));
        expect(log, ['Start', '10m', 'Timers']);
        final reset = tester
            .getSemantics(find.bySemanticsLabel('Reset'))
            .getSemanticsData();
        expect(reset.flagsCollection.isButton, isTrue);
        expect(reset.flagsCollection.isEnabled, Tristate.isFalse);
        semantics.dispose();
      });

      testWidgets('a status alone makes a tray; none keeps the tab height', (
        tester,
      ) async {
        await _pump(tester, mode, _island(status: 'Done'));
        expect(
          tester.getSize(find.byType(ds.Island)).height,
          ds.Island.trayHeight,
        );
        await _pump(tester, mode, _island());
        expect(
          tester.getSize(find.byType(ds.Island)).height,
          ds.DesignSize.islandExpandedHeight,
        );
      });

      testWidgets('every tray action is legible on the island', (tester) async {
        await _pump(tester, mode, _island(actions: _actions(), status: 'Done'));
        final tray = find.byType(SingleChildScrollView);
        final icons = find.descendant(of: tray, matching: find.byType(Icon));
        final texts = find.descendant(of: tray, matching: find.byType(Text));
        expect(icons, findsNWidgets(3));
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
              ds.IslandAction(
                label: 'Last',
                icon: Icons.settings_outlined,
                onPressed: () => log.add('Last'),
              ),
            ],
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
        // The last action is past the end until the tray is scrolled.
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
        expect(log, ['Start', 'Last']);
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

  /// Product of every opacity between the island's fill and the screen.
  double paintedOpacity(WidgetTester tester) {
    var opacity = 1.0;
    RenderObject? node = tester.renderObject(
      find
          .descendant(
            of: find.byType(ds.Island),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    while (node != null) {
      if (node is RenderOpacity) opacity *= node.opacity;
      if (node is RenderAnimatedOpacity) opacity *= node.opacity.value;
      node = node.parent;
    }
    return opacity;
  }

  testWidgets('hiding shrinks the island to a dot before it fades', (
    tester,
  ) async {
    await _pump(tester, ds.AppearanceMode.black, _island(actions: _actions()));
    final expanded = tester.getSize(find.byType(ds.Island)).height;
    expect(expanded, ds.Island.trayHeight);
    await _pump(
      tester,
      ds.AppearanceMode.black,
      _island(state: ds.ChromeState.hidden, actions: _actions()),
      settle: false,
    );
    var last = expanded;
    for (var t = 0; t <= 600; t += 16) {
      await tester.pump(const Duration(milliseconds: 16));
      final height = tester.getSize(find.byType(ds.Island)).height;
      final opacity = paintedOpacity(tester);
      if (height >= expanded / 2) {
        expect(opacity, greaterThan(0.9), reason: '$t ms, $height px');
      }
      // No overshoot on the way out: the shape only ever gets smaller.
      expect(height, lessThanOrEqualTo(last + 0.01), reason: '$t ms');
      last = height;
    }
    expect(
      tester.getSize(find.byType(ds.Island)).height,
      ds.DesignSize.islandDot,
    );
    expect(paintedOpacity(tester), 0);
  });

  AnimatedSize morph(WidgetTester tester) =>
      tester.widget<AnimatedSize>(find.byType(AnimatedSize));

  testWidgets('growing springs; going to the dot shrinks without a fade', (
    tester,
  ) async {
    await _pump(
      tester,
      ds.AppearanceMode.black,
      _island(state: ds.ChromeState.dot),
    );
    await _pump(tester, ds.AppearanceMode.black, _island(), settle: false);
    expect(morph(tester).curve, ds.DesignMotion.islandCurve);
    expect(morph(tester).duration, ds.DesignMotion.islandMorph);
    await tester.pumpAndSettle();

    await _pump(
      tester,
      ds.AppearanceMode.black,
      _island(state: ds.ChromeState.dot),
      settle: false,
    );
    expect(morph(tester).curve, ds.DesignMotion.collapseCurve);
    expect(morph(tester).duration, ds.DesignMotion.islandCollapse);
    for (var t = 0; t < 400; t += 16) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(paintedOpacity(tester), 1, reason: '$t ms');
    }
    expect(tester.getSize(find.byType(ds.Island)), const Size(10, 10));

    // The dot is already small: hiding it is a plain fade.
    await _pump(
      tester,
      ds.AppearanceMode.black,
      _island(state: ds.ChromeState.hidden),
      settle: false,
    );
    final fade = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
    expect(fade.duration, ds.DesignMotion.fade);
    expect(fade.curve, Curves.linear);
    await tester.pumpAndSettle();
    expect(paintedOpacity(tester), 0);
  });

  testWidgets('reduced motion hides with a plain cross-fade', (tester) async {
    await _pump(
      tester,
      ds.AppearanceMode.black,
      _island(actions: _actions()),
      disableAnimations: true,
    );
    await _pump(
      tester,
      ds.AppearanceMode.black,
      _island(state: ds.ChromeState.hidden, actions: _actions()),
      disableAnimations: true,
      settle: false,
    );
    expect(find.byType(AnimatedSize), findsNothing);
    final fade = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
    expect(fade.duration, ds.DesignMotion.fade);
    expect(fade.curve, Curves.linear);
  });

  testWidgets('spacing: inset, row gap, item and group gaps, centred tray', (
    tester,
  ) async {
    await _pump(
      tester,
      ds.AppearanceMode.black,
      _island(actions: _actions()),
      width: 800,
    );
    final island = tester.getRect(find.byType(ds.Island));
    final clock = tester.getRect(
      find.ancestor(
        of: find.text('Clock'),
        matching: find.byType(ds.Pressable),
      ),
    );
    final start = tester.getRect(find.byTooltip('Start'));
    final reset = tester.getRect(find.byTooltip('Reset'));
    final chip = tester.getRect(
      find.ancestor(of: find.text('5m'), matching: find.byType(ds.Pressable)),
    );
    final tray = tester.getRect(find.byType(SingleChildScrollView));
    expect(clock.top - island.top, ds.DesignSpace.islandInset);
    expect(island.bottom - start.bottom, ds.DesignSpace.islandInset);
    expect(start.top - clock.bottom, ds.DesignSpace.islandRowGap);
    expect(clock.height, ds.DesignSize.cornerButton);
    expect(start.height, ds.DesignSize.cornerButton);
    expect(chip.height, ds.DesignSize.cornerButton);
    // Start and Reset are one group; the chips are the next.
    expect(reset.left - start.right, ds.DesignSpace.islandItemGap);
    expect(chip.left - reset.right, ds.DesignSpace.islandGroupGap);
    expect(
      tester.getRect(find.text('5m')).left - chip.left,
      ds.DesignSpace.islandItemPadding,
    );
    expect(tray.center.dx, closeTo(island.center.dx, 0.01));
  });

  for (final mode in [ds.AppearanceMode.black, ds.AppearanceMode.light]) {
    testWidgets('${mode.name}: the island floats on shadows and a highlight', (
      tester,
    ) async {
      final colors = mode == ds.AppearanceMode.black
          ? ds.DesignColors.dark
          : ds.DesignColors.light;
      await _pump(tester, mode, _island(actions: _actions()));
      final fill =
          tester
                  .widget<DecoratedBox>(
                    find
                        .descendant(
                          of: find.byType(ds.Island),
                          matching: find.byType(DecoratedBox),
                        )
                        .first,
                  )
                  .decoration
              as BoxDecoration;
      expect(fill.color, colors.island);
      expect(fill.boxShadow, colors.islandElevation.shadows);
      final paint = tester.widget<CustomPaint>(
        find
            .descendant(
              of: find.byType(ds.Island),
              matching: find.byType(CustomPaint),
            )
            .first,
      );
      expect(paint.foregroundPainter, isNotNull);
      expect(paint.painter, isNotNull);
      for (final p in [paint.painter!, paint.foregroundPainter!]) {
        expect(p.shouldRepaint(p), isFalse);
      }
      // The rim is painted: a stroke on the island's outline, lit on top
      // and shaded below. The sheen fills the outline under the content.
      expect(
        find.byType(ds.Island),
        paints
          ..rrect(style: PaintingStyle.fill)
          ..something((method, args) {
            if (method != #drawRRect) return false;
            final paint = args[1] as Paint;
            return paint.style == PaintingStyle.stroke &&
                paint.strokeWidth == 1 &&
                paint.shader != null;
          }),
      );
    });
  }

  group('depth follows the morph', () {
    List<BoxShadow> shadowsOf(WidgetTester tester, Type of) =>
        (tester
                    .widget<DecoratedBox>(
                      find
                          .descendant(
                            of: find.byType(of),
                            matching: find.byType(DecoratedBox),
                          )
                          .first,
                    )
                    .decoration
                as BoxDecoration)
            .boxShadow!;
    final e = ds.DesignColors.light.islandElevation;
    final dot = e.shadowsAt(ds.DesignElevation.dotLift);

    testWidgets('the dot sits low; opening raises it, collapsing lowers it', (
      tester,
    ) async {
      await _pump(
        tester,
        ds.AppearanceMode.light,
        _island(state: ds.ChromeState.dot),
      );
      expect(shadowsOf(tester, ds.Island), dot);
      await _pump(tester, ds.AppearanceMode.light, _island(), settle: false);
      // Mid-way the shadow is between the two, never past either.
      await tester.pump(ds.DesignMotion.islandCollapse ~/ 2);
      final blur = shadowsOf(tester, ds.Island).first.blurRadius;
      expect(blur, greaterThan(dot.first.blurRadius));
      expect(blur, lessThan(e.shadows.first.blurRadius));
      await tester.pumpAndSettle();
      expect(shadowsOf(tester, ds.Island), e.shadows);
      // A HUD over a hidden island floats high too.
      await _pump(
        tester,
        ds.AppearanceMode.light,
        _island(
          state: ds.ChromeState.hidden,
          hud: const ds.IslandBrightnessHud(0.5, '50%'),
        ),
      );
      expect(shadowsOf(tester, ds.Island), e.shadows);
      await _pump(
        tester,
        ds.AppearanceMode.light,
        _island(state: ds.ChromeState.dot),
      );
      expect(shadowsOf(tester, ds.Island), dot);
    });

    testWidgets('reduced motion jumps straight to the new depth', (
      tester,
    ) async {
      await _pump(
        tester,
        ds.AppearanceMode.light,
        _island(state: ds.ChromeState.dot),
        disableAnimations: true,
      );
      await _pump(
        tester,
        ds.AppearanceMode.light,
        _island(),
        disableAnimations: true,
        settle: false,
      );
      await tester.pump();
      expect(shadowsOf(tester, ds.Island), e.shadows);
    });

    testWidgets('a corner button lifts with the island', (tester) async {
      Widget corner(ds.ChromeState state) => ds.CornerButton(
        state: state,
        icon: Icons.settings_outlined,
        tooltip: 'Settings',
        onPressed: () {},
        corner: Alignment.topRight,
      );
      await _pump(tester, ds.AppearanceMode.light, corner(ds.ChromeState.dot));
      expect(shadowsOf(tester, ds.CornerButton), dot);
      await _pump(
        tester,
        ds.AppearanceMode.light,
        corner(ds.ChromeState.expanded),
      );
      expect(shadowsOf(tester, ds.CornerButton), e.shadows);
    });
  });

  group('corners follow the one app corner', () {
    double islandRadius(WidgetTester tester) =>
        ((tester
                            .widget<DecoratedBox>(
                              find
                                  .descendant(
                                    of: find.byType(ds.Island),
                                    matching: find.byType(DecoratedBox),
                                  )
                                  .first,
                            )
                            .decoration
                        as BoxDecoration)
                    .borderRadius!
                as BorderRadius)
            .topLeft
            .x;
    double actionRadius(WidgetTester tester) =>
        ((tester
                            .widget<DecoratedBox>(
                              find
                                  .ancestor(
                                    of: find.text('5m'),
                                    matching: find.byType(DecoratedBox),
                                  )
                                  .first,
                            )
                            .decoration
                        as BoxDecoration)
                    .borderRadius!
                as BorderRadius)
            .topLeft
            .x;

    for (final corner in [0.0, 14.0, 24.0]) {
      testWidgets('at $corner', (tester) async {
        final shape = ds.DesignShape(corner);
        await _pump(
          tester,
          ds.AppearanceMode.black,
          _island(actions: _actions()),
          corner: corner,
        );
        // Two rows take the large role; items inside are capped at half
        // their height, so they never become more round than a pill.
        expect(islandRadius(tester), shape.lg);
        expect(actionRadius(tester), shape.forHeight(44));
        await _pump(tester, ds.AppearanceMode.black, _island(), corner: corner);
        expect(islandRadius(tester), shape.forHeight(60));
        await _pump(
          tester,
          ds.AppearanceMode.black,
          _island(state: ds.ChromeState.dot),
          corner: corner,
        );
        // The dot stays a dot (or a square at 0).
        expect(islandRadius(tester), corner == 0 ? 0 : 5);
      });
    }
  });

  group('corner button', () {
    var presses = 0;
    Widget corner(ds.ChromeState state) => ds.CornerButton(
      state: state,
      icon: Icons.settings_outlined,
      tooltip: 'Settings',
      onPressed: () => presses++,
      corner: Alignment.topRight,
    );
    final box = find.descendant(
      of: find.byType(ds.CornerButton),
      matching: find.byType(AnimatedContainer),
    );
    double radius(WidgetTester tester) =>
        ((tester
                            .widget<DecoratedBox>(
                              find
                                  .descendant(
                                    of: find.byType(ds.CornerButton),
                                    matching: find.byType(DecoratedBox),
                                  )
                                  .first,
                            )
                            .decoration
                        as BoxDecoration)
                    .borderRadius!
                as BorderRadius)
            .topLeft
            .x;
    double opacity(WidgetTester tester) => tester
        .widget<AnimatedOpacity>(
          find
              .descendant(
                of: find.byType(ds.CornerButton),
                matching: find.byType(AnimatedOpacity),
              )
              .first,
        )
        .opacity;

    setUp(() => presses = 0);

    for (final mode in [ds.AppearanceMode.black, ds.AppearanceMode.light]) {
      testWidgets('${mode.name}: taps only when expanded; dot in its corner', (
        tester,
      ) async {
        await _pump(tester, mode, corner(ds.ChromeState.expanded));
        expect(tester.getSize(box), const Size(44, 44));
        expect(find.byTooltip('Settings'), findsOneWidget);
        await tester.tap(find.byIcon(Icons.settings_outlined));
        expect(presses, 1);

        await _pump(tester, mode, corner(ds.ChromeState.dot));
        expect(
          tester.getSize(find.byType(ds.CornerButton)),
          const Size(44, 44),
        );
        expect(tester.getSize(box), const Size(6, 6));
        expect(
          tester.getTopRight(box),
          tester.getTopRight(find.byType(ds.CornerButton)),
        );
        await tester.tap(box, warnIfMissed: false);
        expect(presses, 1);

        await _pump(tester, mode, corner(ds.ChromeState.hidden));
        expect(opacity(tester), 0);
        await tester.tap(box, warnIfMissed: false);
        expect(presses, 1);
      });
    }

    testWidgets('hiding shrinks to the dot before it fades', (tester) async {
      await _pump(
        tester,
        ds.AppearanceMode.black,
        corner(ds.ChromeState.expanded),
      );
      await _pump(
        tester,
        ds.AppearanceMode.black,
        corner(ds.ChromeState.hidden),
        settle: false,
      );
      expect(
        tester.widget<AnimatedContainer>(box).curve,
        ds.DesignMotion.collapseCurve,
      );
      final fade = tester.widget<AnimatedOpacity>(
        find
            .descendant(
              of: find.byType(ds.CornerButton),
              matching: find.byType(AnimatedOpacity),
            )
            .first,
      );
      expect(fade.duration, ds.DesignMotion.islandCollapse);
      expect(fade.curve, ds.DesignMotion.collapseFade);
      await tester.pumpAndSettle();
      expect(tester.getSize(box), const Size(6, 6));

      // Growing back rides the spring.
      await _pump(
        tester,
        ds.AppearanceMode.black,
        corner(ds.ChromeState.expanded),
        settle: false,
      );
      expect(
        tester.widget<AnimatedContainer>(box).curve,
        ds.DesignMotion.islandCurve,
      );
      await tester.pumpAndSettle();
    });

    testWidgets('showing again after a hide fades in with the island', (
      tester,
    ) async {
      AnimatedOpacity fade() => tester.widget<AnimatedOpacity>(
        find
            .descendant(
              of: find.byType(ds.CornerButton),
              matching: find.byType(AnimatedOpacity),
            )
            .first,
      );
      await _pump(
        tester,
        ds.AppearanceMode.black,
        corner(ds.ChromeState.expanded),
      );
      await _pump(
        tester,
        ds.AppearanceMode.black,
        corner(ds.ChromeState.hidden),
      );
      await _pump(
        tester,
        ds.AppearanceMode.black,
        corner(ds.ChromeState.expanded),
        settle: false,
      );
      // Not the delayed fade-out timing: in step with the island's fade-in.
      expect(fade().duration, ds.DesignMotion.fade);
      expect(fade().curve, Curves.linear);
      await tester.pump(const Duration(milliseconds: 150));
      expect(opacity(tester), 1);
      final value = tester
          .renderObject<RenderAnimatedOpacity>(
            find
                .descendant(
                  of: find.byType(ds.CornerButton),
                  matching: find.byType(AnimatedOpacity),
                )
                .first,
          )
          .opacity
          .value;
      expect(value, greaterThan(0.5));
      await tester.pumpAndSettle();
    });

    for (final c in [0.0, 24.0]) {
      testWidgets('takes the app corner $c, never a circle', (tester) async {
        final shape = ds.DesignShape(c);
        await _pump(
          tester,
          ds.AppearanceMode.black,
          corner(ds.ChromeState.expanded),
          corner: c,
        );
        expect(radius(tester), shape.forHeight(44));
      });
    }

    testWidgets('reduced motion drops the morph', (tester) async {
      await _pump(
        tester,
        ds.AppearanceMode.black,
        corner(ds.ChromeState.dot),
        disableAnimations: true,
      );
      expect(tester.widget<AnimatedContainer>(box).duration, Duration.zero);
    });

    testWidgets('a theme switch mid-morph never lerps a shadow past 1', (
      tester,
    ) async {
      await _pump(tester, ds.AppearanceMode.light, corner(ds.ChromeState.dot));
      await _pump(
        tester,
        ds.AppearanceMode.light,
        corner(ds.ChromeState.expanded),
        settle: false,
      );
      await tester.pump(const Duration(milliseconds: 150));
      await _pump(
        tester,
        ds.AppearanceMode.black,
        corner(ds.ChromeState.expanded),
        settle: false,
      );
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.takeException(), isNull);
      }
    });
  });

  testWidgets('the island fits the box it is given', (tester) async {
    await _pump(
      tester,
      ds.AppearanceMode.black,
      SizedBox(
        width: 200,
        child: Center(child: _island(actions: _actions())),
      ),
      width: 800,
    );
    expect(
      tester.getSize(find.byType(ds.Island)).width,
      lessThanOrEqualTo(200),
    );
    expect(tester.takeException(), isNull);
  });

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

  group('sliding tab pill', () {
    const frame = Duration(milliseconds: 16);

    for (final scale in [1.0, 2.0]) {
      testWidgets('tabs share the widest label width at text scale $scale', (
        tester,
      ) async {
        await _pump(
          tester,
          ds.AppearanceMode.black,
          _island(),
          width: 800,
          textScale: scale,
        );
        final widths = {for (final t in _tabs) _tabRect(tester, t).width};
        expect(widths, hasLength(1));
        // The widest label (Stopwatch) plus the item padding both sides.
        expect(
          widths.single,
          closeTo(
            tester.getSize(find.text('Stopwatch')).width +
                2 * ds.DesignSpace.islandItemPadding,
            1,
          ),
        );
        expect(
          _tabRect(tester, 'Timer').left - _tabRect(tester, 'Clock').right,
          ds.DesignSpace.islandItemGap,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('tabs are measured again once the fonts load', (tester) async {
      await _pump(tester, ds.AppearanceMode.black, _island(), width: 800);
      await tester.runAsync(GoogleFonts.pendingFonts);
      await tester.pump();
      expect(
        _tabRect(tester, 'Clock').width,
        closeTo(
          tester.getSize(find.text('Stopwatch')).width +
              2 * ds.DesignSpace.islandItemPadding,
          1,
        ),
      );
      // Gone without a leaked font listener.
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });

    testWidgets('the pill slides on the spring while the tray swaps', (
      tester,
    ) async {
      final colors = ds.DesignColors.dark;
      await _pump(tester, ds.AppearanceMode.black, _island(), width: 800);
      final first = _pillRect(tester);
      final row = _tabRect(tester, 'Clock').left;
      final step =
          _tabRect(tester, 'Clock').width + ds.DesignSpace.islandItemGap;
      expect(first.left, closeTo(row + step, 0.01));
      final height = tester.getSize(find.byType(ds.Island)).height;

      // Stopwatch, with a tray: the slide, the colour fade and the height
      // morph all start in the same frame.
      await _pump(
        tester,
        ds.AppearanceMode.black,
        _island(selected: 2, actions: _actions()),
        width: 800,
        settle: false,
      );
      await tester.pump(frame);
      await tester.pump(frame);
      expect(_pillRect(tester).left, greaterThan(first.left));
      expect(_pillRect(tester).left, lessThan(row + 2 * step));
      expect(_pillRect(tester).width, first.width);
      expect(
        tester.getSize(find.byType(ds.Island)).height,
        greaterThan(height),
      );
      final mid = _labelColor(tester, 'Stopwatch');
      expect(mid, isNot(colors.islandInkMuted));
      expect(mid, isNot(colors.islandOnActive));

      await tester.pump(ds.DesignMotion.fade);
      expect(_labelColor(tester, 'Stopwatch'), colors.islandOnActive);
      expect(_labelColor(tester, 'Timer'), colors.islandInkMuted);

      await tester.pump(ds.DesignMotion.islandMorph);
      expect(_pillRect(tester).left, closeTo(row + 2 * step, 0.01));
      expect(
        tester.getSize(find.byType(ds.Island)).height,
        ds.Island.trayHeight,
      );
      await tester.pumpAndSettle();
    });

    testWidgets('with reduced motion the pill jumps and colours swap', (
      tester,
    ) async {
      final colors = ds.DesignColors.dark;
      await _pump(
        tester,
        ds.AppearanceMode.black,
        _island(),
        width: 800,
        disableAnimations: true,
      );
      final row = _tabRect(tester, 'Clock').left;
      await _pump(
        tester,
        ds.AppearanceMode.black,
        _island(selected: 0),
        width: 800,
        disableAnimations: true,
        settle: false,
      );
      await tester.pump();
      expect(_pillRect(tester).left, closeTo(row, 0.01));
      expect(_labelColor(tester, 'Clock'), colors.islandOnActive);
      expect(_labelColor(tester, 'Timer'), colors.islandInkMuted);
      expect(find.byType(AnimatedSize), findsNothing);
    });
  });
}
