import 'dart:ui';

import 'package:flip_clock/ui/components/flip_card_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The icon's card, in icon units: 608 high, corner 45.
  final icon = FlipCardGeometry(const Size(608, 608), 45);

  void near(double actual, double expected) =>
      expect(actual, closeTo(expected, 0.5));

  test('at the icon size every part matches the icon', () {
    expect(icon.axisY, 304);
    expect(icon.hasHinges, isTrue);
    near(icon.crack.height, 5);
    expect(icon.crack.center.dy, 304);
    near(icon.lip.height, 3);
    near(icon.underside.height, 1);
    expect(icon.underside.bottom, icon.crack.top);
    expect(icon.underside.left, icon.crack.left);
    expect(icon.lip.top, icon.crack.bottom);
    near(icon.notchLeft.width, 27);
    near(icon.notchLeft.height, 76);
    near(icon.notchLeft.trRadiusX, 9);
    expect(icon.notchLeft.tlRadiusX, 0);
    expect(icon.notchLeft.center.dy, 304);
    near(icon.pinLeft.width, 21);
    near(icon.pinLeft.height, 63);
    near(icon.pinLeft.tlRadiusX, 21 * 0.3);
    expect(icon.pinLeft.center.dy, 304);
  });

  test('pins sit in their notches, flush with the card sides', () {
    final card = Offset.zero & icon.size;
    for (final (pin, notch) in [
      (icon.pinLeft, icon.notchLeft),
      (icon.pinRight, icon.notchRight),
    ]) {
      expect(card.contains(pin.outerRect.topLeft), isTrue);
      expect(pin.outerRect.right, lessThanOrEqualTo(card.right));
      // Clearance: 0.010h on the inner side, 0.0105h top and bottom.
      near(pin.top - notch.top, 0.0105 * 608);
      near(notch.bottom - pin.bottom, 0.0105 * 608);
    }
    expect(icon.pinLeft.left, 0);
    expect(icon.pinRight.right, 608);
    expect(icon.notchLeft.left, 0);
    expect(icon.notchRight.right, 608);
    near(icon.notchLeft.right - icon.pinLeft.right, 0.010 * 608);
    near(icon.pinRight.left - icon.notchRight.left, 0.010 * 608);
  });

  test('the crack and lip run from notch to notch, never through a pin', () {
    expect(icon.crack.left, icon.notchLeft.right);
    expect(icon.crack.right, icon.notchRight.left);
    expect(icon.lip.left, icon.crack.left);
    expect(icon.lip.right, icon.crack.right);
    expect(icon.crack.overlaps(icon.pinLeft.outerRect), isFalse);
    expect(icon.crack.overlaps(icon.pinRight.outerRect), isFalse);
  });

  test('hinges from an 80px card; below it crack and lip only', () {
    final small = FlipCardGeometry(const Size(79, 79), 6);
    expect(small.hasHinges, isFalse);
    expect(small.crack.left, 0);
    expect(small.crack.right, 79);
    // The crack and lip never vanish.
    expect(small.crack.height, FlipCardGeometry.minCrack);
    expect(small.lip.height, FlipCardGeometry.minLip);
    expect(FlipCardGeometry(const Size(80, 80), 6).hasHinges, isTrue);
    // A small card is not cut by notches.
    expect(
      small.halfPath(top: true).contains(Offset(1, small.axisY - 1)),
      true,
    );
  });

  test('each half is the rounded card cut at the axle, minus the notches', () {
    final top = icon.halfPath(top: true);
    final bottom = icon.halfPath(top: false);
    // Just above and below the axle, in the middle.
    expect(top.contains(const Offset(304, 303)), isTrue);
    expect(top.contains(const Offset(304, 305)), isFalse);
    expect(bottom.contains(const Offset(304, 305)), isTrue);
    expect(bottom.contains(const Offset(304, 303)), isFalse);
    // Inside a notch is not card, on either half or side.
    for (final p in const [Offset(5, 300), Offset(603, 300)]) {
      expect(top.contains(p), isFalse);
    }
    for (final p in const [Offset(5, 308), Offset(603, 308)]) {
      expect(bottom.contains(p), isFalse);
    }
    // Beside the notch, outside the crack line, it is card again.
    expect(top.contains(Offset(5, icon.notchLeft.top - 5)), isTrue);
    expect(bottom.contains(Offset(603, icon.notchRight.bottom + 5)), isTrue);
    // The card corners are round.
    expect(top.contains(const Offset(2, 2)), isFalse);
    expect(top.contains(const Offset(45, 2)), isTrue);
    expect(bottom.contains(const Offset(606, 606)), isFalse);
    // The edge rounds into the notch: the corner point itself is cut.
    expect(top.contains(Offset(0.3, icon.notchLeft.top - 0.3)), isFalse);
  });

  test('the cavity is the notch plus the fillets into the side edge', () {
    final cavity = icon.cavity(left: true);
    expect(cavity.contains(icon.notchLeft.center), isTrue);
    expect(cavity.contains(Offset(0.3, icon.notchLeft.top - 0.3)), isTrue);
    expect(cavity.contains(Offset(0.3, icon.notchLeft.bottom + 0.3)), isTrue);
    final right = icon.cavity(left: false);
    expect(right.contains(Offset(607.7, icon.notchRight.top - 0.3)), isTrue);
    expect(right.contains(icon.notchLeft.center), isFalse);
  });

  test('empty and tiny cards give empty or small paths without throwing', () {
    expect(
      FlipCardGeometry(Size.zero, 14).halfPath(top: true).getBounds(),
      Rect.zero,
    );
    expect(
      FlipCardGeometry(const Size(0, 100), 14).halfPath(top: false).getBounds(),
      Rect.zero,
    );
    final tiny = FlipCardGeometry(const Size(0.5, 0.5), 14);
    final bounds = tiny.halfPath(top: false).getBounds();
    expect((Offset.zero & tiny.size).contains(bounds.topLeft), isTrue);
    expect(bounds.bottom, lessThanOrEqualTo(0.5));
  });
}
