import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

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
