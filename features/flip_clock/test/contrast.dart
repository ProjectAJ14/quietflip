import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG contrast of two opaque colours, 1..21.
double contrastOf(Color a, Color b) {
  final x = a.computeLuminance();
  final y = b.computeLuminance();
  return (x > y ? x + 0.05 : y + 0.05) / (x > y ? y + 0.05 : x + 0.05);
}

/// The colour [text] is drawn in, blended over what is behind it.
Color inkOf(WidgetTester tester, Finder text) {
  final rich = tester.widget<RichText>(
    find.descendant(of: text, matching: find.byType(RichText)).first,
  );
  final color = rich.text.style!.color!;
  return Color.alphaBlend(color, backdropOf(tester, text));
}

/// The nearest opaque fill behind [f]: a Material, DecoratedBox,
/// ColoredBox or Scaffold ancestor with a visible colour.
Color backdropOf(WidgetTester tester, Finder f) =>
    backdropOfElement(tester.element(f.first));

/// [backdropOf] for an element.
Color backdropOfElement(Element element) {
  Color? found;
  element.visitAncestorElements((e) {
    final w = e.widget;
    final Color? c = switch (w) {
      Material(type: final t, :final color)
          when t != MaterialType.transparency =>
        color,
      DecoratedBox(decoration: BoxDecoration(:final color)) => color,
      ColoredBox(:final color) => color,
      Scaffold(:final backgroundColor) => backgroundColor,
      _ => null,
    };
    if (c == null || c.a == 0) return true;
    found = c;
    return false;
  });
  return found!;
}
