import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<BuildContext> _pump(
  WidgetTester tester,
  Widget child, {
  AppearanceMode mode = AppearanceMode.black,
  double corner = DesignShape.defaultCorner,
  double textScale = 1,
}) async {
  late BuildContext context;
  await tester.pumpWidget(
    DesignSystemWrapper(
      mode: mode,
      corner: corner,
      builder: (_, theme) => MaterialApp(
        theme: theme,
        builder: (context, app) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: app!,
        ),
        home: Scaffold(
          body: Center(
            child: Builder(
              builder: (c) {
                context = c;
                return child;
              },
            ),
          ),
        ),
      ),
    ),
  );
  return context;
}

ShapeDecoration _decoration(WidgetTester tester) =>
    tester
            .widget<DecoratedBox>(
              find
                  .descendant(
                    of: find.byType(AppButton),
                    matching: find.byType(DecoratedBox),
                  )
                  .first,
            )
            .decoration
        as ShapeDecoration;

EdgeInsets _padding(WidgetTester tester) => tester
    .widget<Padding>(
      find
          .descendant(
            of: find.byType(AppButton),
            matching: find.byType(Padding),
          )
          .first,
    )
    .padding
    .resolve(TextDirection.ltr);

/// What a text style draws, without its debug label.
Object _look(TextStyle s) => (
  s.fontFamily,
  s.fontSize,
  s.fontWeight,
  s.height,
  s.letterSpacing,
  s.color,
);

/// The layer every ink splash, ripple and sparkle paints on.
RenderObject _inkFeatures(WidgetTester tester) => tester.allRenderObjects
    .firstWhere((r) => r.runtimeType.toString() == '_RenderInkFeatures');

/// The old Material button (labelled "Old") and the [AppButton] ("Go")
/// that replaces it.
typedef _Case = ({
  String name,
  Type type,
  Widget Function(VoidCallback? onPressed, bool icon) material,
  AppButton Function(VoidCallback? onPressed, bool icon) app,
});

const _oldIcon = Icon(Icons.remove);
const _oldLabel = Text('Old');

final _cases = <_Case>[
  (
    name: 'text',
    type: TextButton,
    material: (onPressed, icon) => icon
        ? TextButton.icon(
            onPressed: onPressed,
            icon: _oldIcon,
            label: _oldLabel,
          )
        : TextButton(onPressed: onPressed, child: _oldLabel),
    app: (onPressed, icon) => AppButton.text(
      label: 'Go',
      icon: icon ? Icons.add : null,
      onPressed: onPressed,
    ),
  ),
  (
    name: 'filled',
    type: FilledButton,
    material: (onPressed, icon) => icon
        ? FilledButton.icon(
            onPressed: onPressed,
            icon: _oldIcon,
            label: _oldLabel,
          )
        : FilledButton(onPressed: onPressed, child: _oldLabel),
    app: (onPressed, icon) => AppButton.filled(
      label: 'Go',
      icon: icon ? Icons.add : null,
      onPressed: onPressed,
    ),
  ),
  (
    name: 'outlined',
    type: OutlinedButton,
    material: (onPressed, icon) => icon
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: _oldIcon,
            label: _oldLabel,
          )
        : OutlinedButton(onPressed: onPressed, child: _oldLabel),
    app: (onPressed, icon) => AppButton.outlined(
      label: 'Go',
      icon: icon ? Icons.add : null,
      onPressed: onPressed,
    ),
  ),
];

/// What the old [type] button actually drew: its `Material` (fill, shape
/// with side), label style, padding and icon theme.
({
  Color? fill,
  ShapeBorder? shape,
  TextStyle text,
  EdgeInsets padding,
  IconThemeData? icon,
})
_old(WidgetTester tester, Type type) {
  Finder inOld(Type t) =>
      find.descendant(of: find.byType(type), matching: find.byType(t)).first;
  final material = tester.widget<Material>(inOld(Material));
  final fill = material.color;
  return (
    fill: fill == null || fill.a == 0 ? null : fill,
    shape: material.shape,
    text: DefaultTextStyle.of(tester.element(find.text('Old'))).style,
    padding: tester
        .widget<Padding>(inOld(Padding))
        .padding
        .resolve(TextDirection.ltr),
    icon: find.byIcon(Icons.remove).evaluate().isEmpty
        ? null
        : IconTheme.of(tester.element(find.byIcon(Icons.remove))),
  );
}

void main() {
  for (final mode in [AppearanceMode.black, AppearanceMode.light]) {
    for (final corner in [DesignShape.minCorner, DesignShape.maxCorner]) {
      for (final c in _cases) {
        for (final icon in [false, true]) {
          for (final enabled in [true, false]) {
            testWidgets(
              '${c.name}${icon ? ' with icon' : ''}${enabled ? '' : ' disabled'}'
              ' matches the old theme in ${mode.name} at corner $corner',
              (tester) async {
                final onPressed = enabled ? () {} : null;
                await _pump(
                  tester,
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      c.app(onPressed, icon),
                      c.material(onPressed, icon),
                    ],
                  ),
                  mode: mode,
                  corner: corner,
                );
                final old = _old(tester, c.type);
                final decoration = _decoration(tester);
                expect(decoration.color, old.fill);
                expect(decoration.shape, old.shape);
                final text = tester.widget<Text>(find.text('Go')).style!;
                expect(_look(text), _look(old.text));
                expect(_padding(tester), old.padding);
                if (icon) {
                  final glyph = tester.widget<Icon>(find.byIcon(Icons.add));
                  expect(glyph.color, old.icon!.color);
                  expect(glyph.size, old.icon!.size);
                }
              },
            );
          }
        }
      }

      for (final enabled in [true, false]) {
        testWidgets(
          'icon${enabled ? '' : ' disabled'} matches the old theme in '
          '${mode.name} at corner $corner',
          (tester) async {
            final onPressed = enabled ? () {} : null;
            final context = await _pump(
              tester,
              AppButton.icon(
                icon: Icons.close,
                tooltip: 'Close',
                onPressed: onPressed,
              ),
              mode: mode,
              corner: corner,
            );
            final theme = Theme.of(context);
            final old = theme.iconButtonTheme.style!;
            final states = {if (!enabled) WidgetState.disabled};
            final glyph = tester.widget<Icon>(find.byIcon(Icons.close));
            // The theme sets only the shape; the old IconButton test below
            // pins the Material defaults this colour and padding come from.
            expect(
              glyph.color,
              enabled
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onSurface.withAlpha((0.38 * 255).round()),
            );
            expect(glyph.size, 24);
            final decoration = _decoration(tester);
            expect(decoration.color, isNull);
            final shape = DesignShape(corner);
            expect(
              (decoration.shape as RoundedRectangleBorder).borderRadius,
              (old.shape!.resolve(states)! as RoundedRectangleBorder)
                  .borderRadius,
            );
            expect(
              (decoration.shape as RoundedRectangleBorder).borderRadius,
              DesignShape.circular(shape.forHeight(44, role: shape.sm)),
            );
            expect(_padding(tester), const EdgeInsets.all(8));
            expect(tester.getSize(find.byType(AppButton)), const Size(44, 44));
          },
        );
      }
    }
  }

  for (final enabled in [true, false]) {
    testWidgets(
      'the old IconButton${enabled ? '' : ' disabled'} draws what the icon '
      'test assumes',
      (tester) async {
        final context = await _pump(
          tester,
          IconButton(
            onPressed: enabled ? () {} : null,
            icon: const Icon(Icons.close),
          ),
        );
        final scheme = Theme.of(context).colorScheme;
        final glyph = tester.element(find.byIcon(Icons.close));
        expect(
          IconTheme.of(glyph).color,
          enabled
              ? scheme.onSurfaceVariant
              : scheme.onSurface.withAlpha((0.38 * 255).round()),
        );
        expect(IconTheme.of(glyph).size, 24);
        expect(
          tester
              .widget<Padding>(
                find
                    .descendant(
                      of: find.byType(IconButton),
                      matching: find.byType(Padding),
                    )
                    .first,
              )
              .padding,
          const EdgeInsets.all(8),
        );
      },
    );
  }

  testWidgets('every variant fires once on tap and draws no ink', (
    tester,
  ) async {
    for (final c in _cases) {
      var taps = 0;
      await _pump(tester, c.app(() => taps++, true));
      await tester.tap(find.byType(AppButton));
      await tester.pump(const Duration(milliseconds: 50));
      expect(taps, 1, reason: c.name);
      for (final type in [InkWell, Ink, Material]) {
        expect(
          find.descendant(
            of: find.byType(AppButton),
            matching: find.byType(type),
          ),
          findsNothing,
        );
      }
      expect(_inkFeatures(tester), paintsExactlyCountTimes(#drawCircle, 0));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('is at least 64 x 44 and presses down', (tester) async {
    await _pump(tester, AppButton.text(label: 'Go', onPressed: () {}));
    final size = tester.getSize(find.byType(AppButton));
    expect(size.width, greaterThanOrEqualTo(64));
    expect(size.height, DesignSize.cornerButton);
    expect(find.byType(Pressable), findsOneWidget);
  });

  testWidgets('a danger text button uses the danger colour', (tester) async {
    await _pump(
      tester,
      AppButton.text(label: 'Go', danger: true, onPressed: () {}),
      mode: AppearanceMode.light,
    );
    expect(
      tester.widget<Text>(find.text('Go')).style!.color,
      DesignColors.light.danger,
    );
  });

  testWidgets('semantics: a named button; the icon speaks its tooltip', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pump(
      tester,
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton.filled(
            label: 'Edit',
            semanticsLabel: 'Edit Paper',
            onPressed: () {},
          ),
          AppButton.icon(icon: Icons.close, tooltip: 'Close', onPressed: () {}),
        ],
      ),
    );
    expect(
      tester.getSemantics(find.byType(Pressable).first),
      isSemantics(label: 'Edit Paper', isButton: true, hasTapAction: true),
    );
    expect(
      tester.getSemantics(find.byType(Pressable).last),
      isSemantics(label: 'Close', isButton: true, hasTapAction: true),
    );
    await tester.longPress(find.byType(AppButton).last);
    await tester.pumpAndSettle();
    expect(find.text('Close'), findsOneWidget, reason: 'tooltip shows');
    handle.dispose();
  });

  testWidgets('text scale 2: grows with the text, padding scales down', (
    tester,
  ) async {
    await _pump(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton.outlined(label: 'Go', icon: Icons.add, onPressed: () {}),
          _cases[2].material(() {}, true),
        ],
      ),
      textScale: 2,
    );
    expect(_padding(tester), _old(tester, OutlinedButton).padding);
    // The text doubles (20 px line to 40) and the button holds it.
    expect(tester.getSize(find.text('Go')).height, 40);
    final box = tester.getRect(find.byType(AppButton));
    final text = tester.getRect(find.text('Go'));
    expect(box.contains(text.topLeft) && box.contains(text.bottomRight), true);
    final row = tester.widget<Row>(
      find.descendant(of: find.byType(AppButton), matching: find.byType(Row)),
    );
    expect(row.spacing, 4);
    expect(tester.takeException(), isNull);
  });

  for (final mode in [AppearanceMode.black, AppearanceMode.light]) {
    testWidgets('the ${mode.name} theme draws no ink on stock widgets', (
      tester,
    ) async {
      final context = await _pump(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(onTap: () {}, child: const Text('Row')),
            TextButton(onPressed: () {}, child: const Text('Old')),
            IconButton(onPressed: () {}, icon: const Icon(Icons.close)),
          ],
        ),
        mode: mode,
      );
      final theme = Theme.of(context);
      expect(theme.splashFactory, NoSplash.splashFactory);
      expect(theme.highlightColor, Colors.transparent);
      expect(theme.splashColor, Colors.transparent);
      expect(theme.hoverColor, Colors.transparent);
      const pressed = {WidgetState.pressed};
      for (final overlay in [
        theme.switchTheme.overlayColor,
        theme.segmentedButtonTheme.style!.overlayColor,
        theme.textButtonTheme.style!.overlayColor,
        theme.filledButtonTheme.style!.overlayColor,
        theme.outlinedButtonTheme.style!.overlayColor,
        theme.elevatedButtonTheme.style!.overlayColor,
        theme.iconButtonTheme.style!.overlayColor,
        theme.navigationBarTheme.overlayColor,
      ]) {
        expect(overlay!.resolve(pressed), Colors.transparent);
      }
      expect(theme.sliderTheme.overlayColor, Colors.transparent);
      for (final target in ['Row', 'Old']) {
        final gesture = await tester.startGesture(
          tester.getCenter(find.text(target)),
        );
        await tester.pump(const Duration(milliseconds: 200));
        expect(_inkFeatures(tester), paintsExactlyCountTimes(#drawCircle, 0));
        await gesture.up();
        await tester.pumpAndSettle();
      }
    });
  }
}
