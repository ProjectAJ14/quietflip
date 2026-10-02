import 'package:design_system/design_system.dart' as ds;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _long =
    'A deliberately long label that has to wrap onto several lines without '
    'overflowing the row';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ds.AppearanceMode mode = ds.AppearanceMode.black,
  double width = 375,
  double height = 900,
  double sideInset = 0,
  double textScale = 1,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = FakeViewPadding(left: sideInset, right: sideInset);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ds.DesignSystemWrapper(
      mode: mode,
      builder: (_, theme) => MaterialApp(
        theme: theme,
        builder: (context, app) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: app!,
        ),
        home: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

ds.SettingsShell _shell({
  List<ds.SettingsCategory>? categories,
  VoidCallback? onDone,
  bool desktop = false,
}) => ds.SettingsShell(
  title: 'Settings',
  doneLabel: 'Done',
  onDone: onDone,
  desktop: desktop,
  categories:
      categories ??
      const [
        ds.SettingsCategory(
          icon: Icons.tune,
          label: 'General',
          groups: [
            ds.SettingsGroup(
              header: 'Basics',
              hint: 'kept as typed',
              rows: [
                ds.SettingsValueRow(label: 'Version', value: '1.0'),
                ds.SettingsKeyRow(label: 'Toggle', keycap: 'Space'),
              ],
              footer: 'Shown under the group',
            ),
            ds.SettingsGroup(rows: [ds.SettingsNoteRow(text: 'A note')]),
          ],
        ),
        ds.SettingsCategory(
          icon: Icons.palette_outlined,
          label: 'Looks',
          groups: [
            ds.SettingsGroup(
              rows: [ds.SettingsValueRow(label: 'Theme', value: 'Dark')],
            ),
          ],
        ),
      ],
);

/// A category with every row type and long labels.
List<ds.SettingsCategory> _everything({
  ValueChanged<bool>? onSwitch,
  VoidCallback? onValue,
  ValueChanged<int>? onSegment,
  ValueChanged<double>? onSlide,
}) => [
  ds.SettingsCategory(
    icon: Icons.tune,
    label: 'Everything',
    groups: [
      ds.SettingsGroup(
        header: _long,
        hint: _long,
        footer: _long,
        rows: [
          ds.SettingsSwitchRow(
            label: 'Chime',
            subtitle: _long,
            value: false,
            onChanged: onSwitch ?? (_) {},
          ),
          ds.SettingsValueRow(
            label: _long,
            value: _long,
            onTap: onValue ?? () {},
          ),
          ds.SettingsSegmentedRow<int>(
            label: _long,
            options: const [(0, 'Twelve hour'), (1, 'Twenty-four hour')],
            selected: 0,
            onChanged: onSegment ?? (_) {},
          ),
          ds.SettingsSliderRow(
            label: 'Brightness',
            value: 0.5,
            min: 0,
            max: 1,
            divisions: 10,
            valueLabel: '50%',
            minLabel: 'Dim',
            maxLabel: 'Bright',
            onChanged: onSlide ?? (_) {},
          ),
          const ds.SettingsKeyRow(label: _long, keycap: 'Space'),
          const ds.SettingsNoteRow(text: _long),
        ],
      ),
    ],
  ),
];

Finder get _sidebar => find
    .ancestor(of: find.text('Settings'), matching: find.byType(ListView))
    .first;

Finder _inSidebar(String text) =>
    find.descendant(of: _sidebar, matching: find.text(text));

void main() {
  for (final mode in [ds.AppearanceMode.black, ds.AppearanceMode.light]) {
    group('$mode', () {
      testWidgets('phone at 375: large title and category rows only', (
        tester,
      ) async {
        await _pump(tester, _shell(), mode: mode);
        final title = tester.widget<Text>(find.text('Settings'));
        expect(title.style?.fontSize, 34);
        expect(find.text('General'), findsOneWidget);
        expect(find.text('Looks'), findsOneWidget);
        expect(find.byType(VerticalDivider), findsNothing);
        expect(find.text('Version'), findsNothing);
      });

      testWidgets('split at 820: 300 sidebar and the first detail', (
        tester,
      ) async {
        await _pump(tester, _shell(), mode: mode, width: 820);
        expect(tester.getSize(_sidebar).width, ds.DesignSize.sidebarWidth);
        expect(find.text('General'), findsNWidgets(2));
        expect(find.text('Version'), findsOneWidget);
        expect(tester.getSize(find.byType(ds.SettingsValueRow)).height, 44);
        final detailTitle = tester.widget<Text>(find.text('General').last);
        expect(detailTitle.style?.fontSize, 24);
      });

      testWidgets('desktop at 1280: 230 sidebar, 30 nav rows, 36 rows', (
        tester,
      ) async {
        await _pump(tester, _shell(), mode: mode, width: 1280);
        expect(
          tester.getSize(_sidebar).width,
          ds.SettingsShell.desktopSidebarWidth,
        );
        final nav = find
            .ancestor(
              of: _inSidebar('Looks'),
              matching: find.byType(ds.Pressable),
            )
            .first;
        expect(tester.getSize(nav).height, ds.SettingsShell.desktopNavHeight);
        expect(
          tester.getSize(find.byType(ds.SettingsValueRow)).height,
          ds.SettingsShell.desktopRowHeight,
        );
        final label = tester.widget<Text>(find.text('Version'));
        expect(label.style?.fontSize, 14);
      });

      testWidgets('shell colours come from the theme', (tester) async {
        await _pump(tester, _shell(), mode: mode, width: 820);
        final colors = mode == ds.AppearanceMode.black
            ? ds.DesignColors.dark
            : ds.DesignColors.light;
        final page = tester.widget<Material>(
          find.ancestor(of: _sidebar, matching: find.byType(Material)).first,
        );
        expect(page.color, colors.bg);
        final sidebar = tester.widget<ColoredBox>(
          find.ancestor(of: _sidebar, matching: find.byType(ColoredBox)).first,
        );
        expect(sidebar.color, colors.surfaceSidebar);
        final cell = tester.widget<Material>(
          find
              .ancestor(
                of: find.text('Version'),
                matching: find.byType(Material),
              )
              .first,
        );
        expect(cell.color, colors.surfaceRaised);
        expect(
          tester.widget<Text>(find.text('Version')).style?.color,
          colors.ink,
        );
      });

      testWidgets('the selected sidebar row is an accent pill', (tester) async {
        await _pump(tester, _shell(), mode: mode, width: 820);
        final colors = mode == ds.AppearanceMode.black
            ? ds.DesignColors.dark
            : ds.DesignColors.light;
        Material pill(String label) => tester.widget<Material>(
          find
              .ancestor(of: _inSidebar(label), matching: find.byType(Material))
              .first,
        );
        expect(pill('General').color, colors.accent);
        expect(pill('Looks').color, Colors.transparent);
        expect(
          tester.widget<Text>(_inSidebar('General')).style?.color,
          colors.onAccent,
        );
      });
    });
  }

  for (final desktop in [false, true]) {
    testWidgets('segmented and slider rows keep s2 under the control '
        '(desktop $desktop)', (tester) async {
      await _pump(
        tester,
        ds.SettingsShell(
          title: 'Settings',
          desktop: desktop,
          categories: _everything(),
        ),
        width: 820,
      );
      for (final (row, control) in [
        (ds.SettingsSegmentedRow<int>, SegmentedButton<int>),
        (ds.SettingsSliderRow, Slider),
      ]) {
        final cell = tester.getRect(find.byType(row));
        final box = tester.getRect(find.byType(control));
        expect(
          cell.bottom - box.bottom,
          greaterThanOrEqualTo(ds.DesignSpace.s2),
          reason: '$control bottom gap',
        );
      }
      // s2 between the segmented label and its control.
      final label = tester.getRect(
        find.descendant(
          of: find.byType(ds.SettingsSegmentedRow<int>),
          matching: find.text(_long),
        ),
      );
      final segmented = tester.getRect(find.byType(SegmentedButton<int>));
      expect(
        segmented.top - label.bottom,
        greaterThanOrEqualTo(ds.DesignSpace.s2),
      );
    });
  }

  testWidgets('desktop: true at 820 gives desktop density', (tester) async {
    await _pump(tester, _shell(desktop: true), width: 820);
    expect(
      tester.getSize(_sidebar).width,
      ds.SettingsShell.desktopSidebarWidth,
    );
    expect(
      tester.getSize(find.byType(ds.SettingsValueRow)).height,
      ds.SettingsShell.desktopRowHeight,
    );
  });

  testWidgets('desktop: true under 600px still gets the phone stack', (
    tester,
  ) async {
    await _pump(tester, _shell(desktop: true), width: 375);
    // The category list spans the width: no 230px sidebar.
    expect(tester.getSize(_sidebar).width, 375);
    expect(tester.takeException(), isNull);
    // Rows keep phone density (44px targets).
    await tester.tap(find.text('General'));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(ds.SettingsValueRow).first).height,
      greaterThanOrEqualTo(ds.DesignSize.cornerButton),
    );
  });

  testWidgets('phone: a category opens its detail and back returns', (
    tester,
  ) async {
    await _pump(tester, _shell());
    await tester.tap(find.text('General'));
    await tester.pumpAndSettle();
    expect(find.text('Version'), findsOneWidget);
    expect(find.text('Looks'), findsNothing);
    expect(tester.widget<Text>(find.text('General')).style?.fontSize, 17);
    expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Looks'), findsOneWidget);
    expect(find.text('Version'), findsNothing);
  });

  testWidgets('phone: system back in a category returns to the root', (
    tester,
  ) async {
    await _pump(tester, _shell());
    await tester.tap(find.text('Looks'));
    await tester.pumpAndSettle();
    expect(find.text('Theme'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Theme'), findsNothing);
    expect(find.text('General'), findsOneWidget);
  });

  testWidgets('split: a sidebar row switches the detail', (tester) async {
    await _pump(tester, _shell(), width: 820);
    await tester.tap(_inSidebar('Looks'));
    await tester.pumpAndSettle();
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Version'), findsNothing);
  });

  testWidgets('initialCategory picks the first split selection', (
    tester,
  ) async {
    await _pump(
      tester,
      ds.SettingsShell(
        title: 'Settings',
        initialCategory: 1,
        categories: _shell().categories,
      ),
      width: 820,
    );
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Done'), findsNothing);
  });

  testWidgets('openInitialCategory: the phone starts on that page with Done', (
    tester,
  ) async {
    var done = 0;
    ds.SettingsShell shell() => ds.SettingsShell(
      title: 'Settings',
      doneLabel: 'Done',
      onDone: () => done++,
      initialCategory: 1,
      openInitialCategory: true,
      categories: _shell().categories,
    );
    await _pump(tester, shell());
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Looks'), findsOneWidget);
    await tester.tap(find.text('Done'));
    expect(done, 1);
    // Back reaches the root, whose Done stays; the page no longer has one.
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();
    expect(find.text('General'), findsOneWidget);
    await tester.tap(find.text('Looks'));
    await tester.pumpAndSettle();
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Done'), findsNothing);
    // Split layouts just select it.
    await _pump(tester, shell(), width: 820);
    expect(find.text('Theme'), findsOneWidget);
  });

  testWidgets('a value row can end with its own control', (tester) async {
    var taps = 0;
    await _pump(
      tester,
      Scaffold(
        body: ds.SettingsValueRow(
          label: '5m',
          semanticsLabel: '5 minute timer',
          trailing: IconButton(
            tooltip: 'Delete',
            onPressed: () => taps++,
            icon: const Icon(Icons.delete_outline),
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Delete'));
    expect(taps, 1);
    expect(find.bySemanticsLabel('5 minute timer'), findsOneWidget);
    expect(
      tester.getTopRight(find.byTooltip('Delete')).dx,
      greaterThan(tester.getTopRight(find.text('5m')).dx),
    );
  });

  testWidgets('a value row can start with a leading widget', (tester) async {
    await _pump(
      tester,
      const Scaffold(
        body: ds.SettingsValueRow(
          leading: Icon(Icons.touch_app_outlined),
          label: 'Show or hide controls',
          value: 'Off',
        ),
      ),
      textScale: 2,
    );
    expect(
      tester.getTopRight(find.byType(Icon)).dx,
      lessThan(tester.getTopLeft(find.text('Show or hide controls')).dx),
    );
    expect(find.text('Off'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a short value leaves the label the rest of the row', (
    tester,
  ) async {
    await _pump(
      tester,
      const Scaffold(
        body: Column(
          children: [
            ds.SettingsValueRow(
              leading: Icon(Icons.touch_app_outlined),
              label: 'Show or hide controls',
              value: 'Off',
            ),
            ds.SettingsValueRow(label: 'Change mode'),
          ],
        ),
      ),
    );
    final line = tester.getSize(find.text('Change mode')).height;
    expect(
      tester.getSize(find.text('Show or hide controls')).height,
      line,
      reason: 'one line: "Off" takes only its own width',
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a long value still stops at half the row', (tester) async {
    const long = 'A value long enough to need more than half the row';
    await _pump(
      tester,
      const Scaffold(
        body: ds.SettingsValueRow(label: 'Label', value: long),
      ),
    );
    final row = tester.getSize(find.byType(ds.SettingsValueRow)).width;
    expect(tester.getSize(find.text(long)).width, lessThanOrEqualTo(row / 2));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  for (final width in [375.0, 820.0]) {
    testWidgets('Done calls onDone at $width', (tester) async {
      var done = 0;
      await _pump(tester, _shell(onDone: () => done++), width: width);
      await tester.tap(find.text('Done'));
      expect(done, 1);
    });
  }

  testWidgets('groups: uppercase header, hint, footer, hairline between rows', (
    tester,
  ) async {
    await _pump(tester, _shell(), width: 820);
    expect(find.text('BASICS'), findsOneWidget);
    expect(find.text('Basics'), findsNothing);
    expect(
      find.text('kept as typed'),
      findsOneWidget,
      reason: 'not uppercased',
    );
    expect(
      tester.getTopLeft(find.text('kept as typed')).dx,
      greaterThan(tester.getTopRight(find.text('BASICS')).dx),
      reason: 'the hint sits at the end of the header line',
    );
    expect(find.text('Shown under the group'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
    expect(find.text('Space'), findsOneWidget);
    expect(find.text('A note'), findsOneWidget);
  });

  testWidgets('every row type calls its callback', (tester) async {
    final switches = <bool>[];
    final segments = <int>[];
    final slides = <double>[];
    var taps = 0;
    final handle = tester.ensureSemantics();
    await _pump(
      tester,
      ds.SettingsShell(
        title: 'Settings',
        categories: _everything(
          onSwitch: switches.add,
          onValue: () => taps++,
          onSegment: segments.add,
          onSlide: slides.add,
        ),
      ),
      width: 1280,
    );

    await tester.tap(find.text('Chime'));
    await tester.tap(find.byType(Switch));
    expect(switches, [true, true]);
    expect(find.bySemanticsLabel(RegExp('^Chime')), findsOneWidget);

    await tester.tap(find.byType(ds.SettingsValueRow));
    expect(taps, 1);
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);

    await tester.tap(find.text('Twenty-four hour'));
    expect(segments, [1]);

    await tester.drag(find.byType(Slider), const Offset(200, 0));
    expect(slides, isNotEmpty);
    expect(tester.getSemantics(find.byType(Slider)).label, 'Brightness');
    // Stop labels sit under the two ends of the track.
    final track = tester.getRect(find.byType(Slider));
    expect(tester.getRect(find.text('Dim')).top, greaterThan(track.center.dy));
    expect(
      tester.getRect(find.text('Bright')).right,
      greaterThan(tester.getRect(find.text('Dim')).right),
    );

    expect(find.text('Space'), findsOneWidget);
    handle.dispose();
  });

  testWidgets(
    'rows work standalone; a value row without onTap has no chevron',
    (tester) async {
      // Not const, so the constructors run at test time.
      final keycap = 'K';
      await _pump(
        tester,
        Material(
          child: Column(
            children: [
              const ds.SettingsValueRow(label: 'Version'),
              ds.SettingsKeyRow(label: 'Key', keycap: keycap),
              ds.SettingsNoteRow(text: keycap),
            ],
          ),
        ),
      );
      expect(find.text('Version'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
      // Standalone rows use phone density.
      expect(tester.getSize(find.byType(ds.SettingsValueRow)).height, 44);
    },
  );

  for (final width in [375.0, 1280.0]) {
    testWidgets('text scale 2 at $width does not overflow', (tester) async {
      await _pump(
        tester,
        ds.SettingsShell(title: 'Settings', categories: _everything()),
        width: width,
        textScale: 2,
      );
      if (width < 600) {
        await tester.tap(find.text('Everything'));
        await tester.pumpAndSettle();
      }
      await tester.scrollUntilVisible(
        find.byType(ds.SettingsNoteRow),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.byType(ds.SettingsSwitchRow), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('switches and values sit at the row end', (tester) async {
    await _pump(
      tester,
      Scaffold(
        body: Column(
          children: [
            ds.SettingsSwitchRow(label: 'On', value: true, onChanged: (_) {}),
            ds.SettingsValueRow(label: 'Skin', value: 'Mono', onTap: () {}),
          ],
        ),
      ),
      width: 1200,
    );
    // Row padding is space-4 on phone density.
    expect(
      tester.getRect(find.byType(Switch)).right,
      closeTo(1200 - ds.DesignSpace.s4, 1),
    );
    expect(
      tester.getRect(find.byIcon(Icons.chevron_right_rounded)).right,
      closeTo(1200 - ds.DesignSpace.s4, 1),
    );
  });

  testWidgets('the selected segment is an accent pill', (tester) async {
    late ThemeData theme;
    await _pump(
      tester,
      Builder(
        builder: (context) {
          theme = Theme.of(context);
          return const SizedBox();
        },
      ),
    );
    final style = theme.segmentedButtonTheme.style!;
    expect(
      style.backgroundColor!.resolve({WidgetState.selected}),
      theme.colorScheme.primary,
    );
    expect(
      style.foregroundColor!.resolve({WidgetState.selected}),
      theme.colorScheme.onPrimary,
    );
    expect(style.foregroundColor!.resolve({}), theme.colorScheme.onSurface);
  });

  group('side insets (iPhone landscape, 59 each side)', () {
    testWidgets('split: the sidebar fills to the left edge, the detail to the '
        'right; the inset replaces the detail padding', (tester) async {
      await _pump(
        tester,
        _pinnedShell(),
        width: 852,
        height: 393,
        sideInset: 59,
      );
      final fill = tester.getRect(
        find.ancestor(of: _sidebar, matching: find.byType(ColoredBox)).first,
      );
      expect(fill.left, 0);
      expect(fill.width, ds.DesignSize.sidebarWidth + 59);
      expect(
        tester.getRect(_inSidebar('Settings')).left,
        59 + ds.DesignSpace.s3 + ds.DesignSpace.s2,
      );
      final card = tester.getRect(
        find
            .ancestor(
              of: find.text('Card body'),
              matching: find.byType(ds.Pressable),
            )
            .first,
      );
      expect(card.left, 59 + ds.DesignSpace.s4);
      expect(card.right, fill.right - ds.DesignSpace.s4);
      final cell = _cell(tester, 'Version');
      expect(cell.right, 852 - 59);
      expect(cell.left, fill.right + 1 + ds.DesignSpace.s8);
    });

    testWidgets('phone: lists take the larger of s4 and the inset', (
      tester,
    ) async {
      await _pump(tester, _pinnedShell(), width: 500, sideInset: 59);
      final root = _cell(tester, 'General');
      expect(root.left, 59);
      expect(root.right, 500 - 59);
      final card = tester.getRect(
        find
            .ancestor(
              of: find.text('Card body'),
              matching: find.byType(ds.Pressable),
            )
            .first,
      );
      expect(card.left, 59);
      expect(card.right, 500 - 59);
      expect(tester.getRect(find.text('Done')).left, greaterThan(59));
      await tester.tap(find.text('General'));
      await tester.pumpAndSettle();
      final detail = _cell(tester, 'Version');
      expect(detail.left, 59);
      expect(detail.right, 500 - 59);
      expect(
        tester.getRect(find.byIcon(Icons.chevron_left_rounded)).left,
        greaterThan(59),
      );
    });

    testWidgets('phone: an inset under s4 keeps s4', (tester) async {
      await _pump(tester, _pinnedShell(), width: 500, sideInset: 10);
      final root = _cell(tester, 'General');
      expect(root.left, ds.DesignSpace.s4);
      expect(root.right, 500 - ds.DesignSpace.s4);
    });
  });

  group('pinned category', () {
    testWidgets('phone: its own card after the list, opening its page', (
      tester,
    ) async {
      await _pump(tester, _pinnedShell());
      final card = tester.getRect(find.text('Card body'));
      final row = tester.getRect(find.text('General'));
      expect(card.top, greaterThan(row.bottom + ds.DesignSpace.s6));
      final cardBox = tester.getSize(
        find
            .ancestor(
              of: find.text('Card body'),
              matching: find.byType(ds.Pressable),
            )
            .first,
      );
      expect(
        cardBox.height,
        greaterThanOrEqualTo(ds.SettingsShell.pinnedCardHeight),
      );
      expect(_cardSide(tester).color, ds.DesignColors.dark.hairline);
      await tester.tap(find.text('Card body'));
      await tester.pumpAndSettle();
      expect(find.text('Account page'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Card body'), findsOneWidget);
    });

    testWidgets('split: pinned to the sidebar bottom, selected with the '
        'accent ring', (tester) async {
      await _pump(tester, _pinnedShell(), width: 820);
      final card = tester.getRect(
        find
            .ancestor(
              of: find.text('Card body'),
              matching: find.byType(ds.Pressable),
            )
            .first,
      );
      expect(card.bottom, closeTo(900 - ds.DesignSpace.s4, 1));
      expect(card.left, closeTo(ds.DesignSpace.s4, 1));
      expect(find.text('Account page'), findsNothing);
      await tester.tap(find.text('Card body'));
      await tester.pumpAndSettle();
      expect(find.text('Account page'), findsOneWidget);
      final side = _cardSide(tester);
      expect(side.color, ds.DesignColors.dark.accent);
      expect(side.width, 2);
      await tester.tap(find.text('General'));
      await tester.pumpAndSettle();
      expect(find.text('Account page'), findsNothing);
      expect(_cardSide(tester).width, 1);
    });

    testWidgets('Enter and Space open it from the keyboard', (tester) async {
      for (final (width, key) in [
        (375.0, LogicalKeyboardKey.enter),
        (820.0, LogicalKeyboardKey.space),
      ]) {
        await _pump(tester, _pinnedShell(), width: width);
        Focus.of(tester.element(find.text('Card body'))).requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(key);
        await tester.pumpAndSettle();
        expect(find.text('Account page'), findsOneWidget, reason: '$key');
        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('initialCategory past the list addresses it', (tester) async {
      await _pump(tester, _pinnedShell(initialCategory: 1, open: true));
      expect(find.text('Account page'), findsOneWidget);
      await _pump(tester, _pinnedShell(initialCategory: 1), width: 1280);
      expect(find.text('Account page'), findsOneWidget);
      expect(_cardSide(tester).width, 2);
    });

    testWidgets('fits at text scale 2 in Mono Light', (tester) async {
      await _pump(
        tester,
        _pinnedShell(),
        mode: ds.AppearanceMode.light,
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      expect(_cardSide(tester).color, ds.DesignColors.light.hairline);
      await _pump(
        tester,
        _pinnedShell(),
        mode: ds.AppearanceMode.light,
        width: 820,
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });
}

ds.SettingsShell _pinnedShell({int initialCategory = 0, bool open = false}) =>
    ds.SettingsShell(
      title: 'Settings',
      initialCategory: initialCategory,
      openInitialCategory: open,
      doneLabel: 'Done',
      categories: const [
        ds.SettingsCategory(
          icon: Icons.tune,
          label: 'General',
          groups: [
            ds.SettingsGroup(
              rows: [ds.SettingsValueRow(label: 'Version', value: '1.0')],
            ),
          ],
        ),
      ],
      pinned: const ds.SettingsCategory(
        icon: Icons.cloud_outlined,
        label: 'Account',
        groups: [
          ds.SettingsGroup(rows: [ds.SettingsNoteRow(text: 'Account page')]),
        ],
      ),
      pinnedCard: const Text('Card body'),
    );

/// The pinned card's outline.
BorderSide _cardSide(WidgetTester tester) =>
    (tester
                .widget<Material>(
                  find
                      .ancestor(
                        of: find.text('Card body'),
                        matching: find.byType(Material),
                      )
                      .first,
                )
                .shape!
            as RoundedRectangleBorder)
        .side;

/// The grouped cell around [text] (the raised `Material`).
Rect _cell(WidgetTester tester, String text) => tester.getRect(
  find.ancestor(of: find.text(text), matching: find.byType(Material)).first,
);
