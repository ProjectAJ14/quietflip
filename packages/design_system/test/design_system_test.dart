import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DesignSystemWrapper hands the builder a themed context', (
    tester,
  ) async {
    late ThemeData built;

    await tester.pumpWidget(
      MaterialApp(
        home: DesignSystemWrapper(
          builder: (context, theme) {
            built = theme;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(built.useMaterial3, isTrue);
    expect(built.colorScheme.primary, isNot(Colors.transparent));
  });

  testWidgets('DesignSystemWrapper adds the Arabic fallback only when asked', (
    tester,
  ) async {
    bool hasArabic(ThemeData theme) =>
        theme.textTheme.bodyLarge!.fontFamilyFallback?.any(
          (family) => family.startsWith('NotoSansArabic'),
        ) ??
        false;
    late ThemeData built;
    Widget wrapper({required bool arabic}) => MaterialApp(
      home: DesignSystemWrapper(
        arabic: arabic,
        builder: (context, theme) {
          built = theme;
          return const SizedBox.shrink();
        },
      ),
    );

    await tester.pumpWidget(wrapper(arabic: false));
    expect(hasArabic(built), isFalse);
    await tester.pumpWidget(wrapper(arabic: true));
    expect(hasArabic(built), isTrue);
  });
}
