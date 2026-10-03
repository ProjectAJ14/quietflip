import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// [c] darkened by [k]: its lightness times (1 - k), as the card painters
/// shade it.
Color shadeOf(Color c, double k) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness(hsl.lightness * (1 - k)).toColor();
}

/// [c] lightened by [k]: its lightness moved k of the way to white.
Color lightOf(Color c, double k) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness(hsl.lightness + (1 - hsl.lightness) * k).toColor();
}

/// The card halves painted from [card] (each half's background painter).
Finder cardFace(Color card) => find.byWidgetPredicate(
  (w) =>
      w is CustomPaint &&
      '${w.painter.runtimeType}' == '_FacePainter' &&
      // ignore: avoid_dynamic_calls
      (w.painter! as dynamic).card == card,
);

/// The corner radius of [card] (a flip card), read off its top half's clip: the
/// diagonal distance from the corner to the curve is r x (1 - 1/sqrt 2).
double cardCorner(WidgetTester tester, Finder card) {
  final clip = find.descendant(of: card, matching: find.byType(ClipPath)).first;
  final path = tester
      .widget<ClipPath>(clip)
      .clipper!
      .getClip(tester.getSize(clip));
  // Step along the diagonal to the first point on the card, then binary
  // search the curve between it and the last miss.
  var inside = 0.0;
  while (!path.contains(Offset(inside, inside))) {
    inside += 1;
  }
  var outside = inside - 1;
  for (var i = 0; i < 30; i++) {
    final mid = (inside + outside) / 2;
    if (path.contains(Offset(mid, mid))) {
      inside = mid;
    } else {
      outside = mid;
    }
  }
  return inside / (1 - 1 / math.sqrt2);
}
