import 'package:design_system/design_system.dart' as ds;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _long =
    'A deliberately long label that has to wrap onto several lines without '
    'overflowing the row';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ds.AppearanceMode mode = ds.AppearanceMode.black,
  double width = 375,
  double textScale = 1,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
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
            .ancestor(of: _inSidebar('Looks'), matching: find.byType(InkWell))
            .first;
        expect(tester.getSize(nav).height, ds.SettingsShell.desktopNavHeight);
        expect(
          tester.getSize(find.byType(ds.SettingsValueRow)).height,
          ds.SettingsShell.desktopRowHeight,
        );
        final label = tester.widget<Text>(find.text('Version'));
        expect(label.style?.fontSize, 14);
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

  for (final width in [375.0, 820.0]) {
    testWidgets('Done calls onDone at $width', (tester) async {
      var done = 0;
      await _pump(tester, _shell(onDone: () => done++), width: width);
      await tester.tap(find.text('Done'));
      expect(done, 1);
    });
  }

  testWidgets('groups: uppercase header, footer, hairline between rows', (
    tester,
  ) async {
    await _pump(tester, _shell(), width: 820);
    expect(find.text('BASICS'), findsOneWidget);
    expect(find.text('Basics'), findsNothing);
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
}
