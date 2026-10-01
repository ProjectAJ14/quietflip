import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _radius(ShapeBorder? shape) =>
    ((shape! as RoundedRectangleBorder).borderRadius as BorderRadius).topLeft.x;

double _styleRadius(ButtonStyle? style) =>
    _radius(style!.shape!.resolve({})! as ShapeBorder);

void main() {
  test('the roles keep the token ratios of the one corner', () {
    const shape = DesignShape();
    expect(shape.corner, 14);
    expect(shape.xs, 6);
    expect(shape.sm, 10);
    expect(shape.md, 14);
    expect(shape.lg, 22);
    const square = DesignShape(0);
    expect([square.xs, square.sm, square.md, square.lg], [0, 0, 0, 0]);
    const round = DesignShape(24);
    expect(round.lg, closeTo(24 * 22 / 14, 1e-9));
    expect(round.xs, closeTo(24 * 6 / 14, 1e-9));
  });

  test('forHeight never rounds past half the height', () {
    const shape = DesignShape(24);
    expect(shape.forHeight(10), 5);
    expect(shape.forHeight(100), 24);
    expect(shape.forHeight(100, role: shape.lg), shape.lg);
    expect(shape.forHeight(20, role: shape.lg), 10);
    expect(const DesignShape(0).forHeight(44), 0);
  });

  test('value semantics, copy and lerp', () {
    const shape = DesignShape(10);
    expect(shape, const DesignShape(10));
    expect(shape.hashCode, const DesignShape(10).hashCode);
    expect(shape, isNot(const DesignShape(12)));
    expect(shape.copyWith(), shape);
    expect(shape.copyWith(corner: 2).corner, 2);
    expect(shape.lerp(const DesignShape(20), 0.5).corner, 15);
    expect(shape.lerp(null, 0.5), shape);
    expect(DesignShape.radius(3), const Radius.circular(3));
    expect(DesignShape.circular(3), BorderRadius.circular(3));
    expect(
      DesignShape.rounded(3, side: const BorderSide()).side,
      const BorderSide(),
    );
  });

  testWidgets('of(context) falls back to the default corner', (tester) async {
    late DesignShape shape;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          shape = DesignShape.of(context);
          return const SizedBox();
        },
      ),
    );
    expect(shape, const DesignShape());
  });

  for (final corner in [0.0, 14.0, 24.0]) {
    testWidgets('every Material component shape follows corner $corner', (
      tester,
    ) async {
      late ThemeData theme;
      await tester.pumpWidget(
        DesignSystemWrapper(
          mode: AppearanceMode.black,
          corner: corner,
          builder: (context, t) {
            theme = t;
            return const SizedBox();
          },
        ),
      );
      final shape = DesignShape(corner);
      expect(theme.extension<DesignShape>(), shape);
      expect(_styleRadius(theme.filledButtonTheme.style), shape.sm);
      expect(_styleRadius(theme.textButtonTheme.style), shape.sm);
      expect(_styleRadius(theme.outlinedButtonTheme.style), shape.sm);
      expect(_styleRadius(theme.elevatedButtonTheme.style), shape.sm);
      expect(_styleRadius(theme.segmentedButtonTheme.style), shape.sm);
      expect(
        _styleRadius(theme.iconButtonTheme.style),
        shape.forHeight(40, role: shape.sm),
      );
      expect(_radius(theme.chipTheme.shape), shape.sm);
      expect(_radius(theme.cardTheme.shape), shape.md);
      expect(_radius(theme.dialogTheme.shape), shape.lg);
      expect(_radius(theme.snackBarTheme.shape), shape.sm);
      expect(_radius(theme.listTileTheme.shape), shape.sm);
      expect(_radius(theme.navigationBarTheme.indicatorShape), shape.xs);
      final sheet =
          (theme.bottomSheetTheme.shape! as RoundedRectangleBorder).borderRadius
              as BorderRadius;
      expect(sheet.topLeft.x, shape.lg);
      expect(sheet.bottomLeft.x, 0);
      final tooltip = theme.tooltipTheme.decoration! as BoxDecoration;
      expect((tooltip.borderRadius! as BorderRadius).topLeft.x, shape.xs);
      final input = theme.inputDecorationTheme.border! as UnderlineInputBorder;
      expect(input.borderRadius.topLeft.x, shape.xs);
    });
  }
}
