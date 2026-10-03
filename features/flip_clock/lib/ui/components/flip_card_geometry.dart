import 'dart:math' as math;
import 'dart:ui';

import 'package:design_system/design_system.dart';

/// Where every part of a flip card sits, measured from the app icon
/// (`apps/quietflip/assets/icon/quietflip-master.png`) as fractions of the
/// card height h. The only place these numbers exist.
///
/// The card is a rounded rectangle split at [axisY]. A notch is cut into
/// each side edge, centred on the axle, and a hinge pin sits inside it with
/// its outer face flush with the card edge, so nothing sticks out. Both
/// halves carry their half of each notch, so the flap does too.
class FlipCardGeometry {
  FlipCardGeometry(this.size, this.radius);

  final Size size;

  /// The card corner, from `DesignShape`.
  final double radius;

  /// Crack between the halves (icon: 5 of 608).
  static const double crackScale = 0.008;
  static const double minCrack = 1;

  /// The top flap's underside, darkened just above the crack (icon: 1 of
  /// 608).
  static const double undersideScale = 0.002;

  /// The bright lip under the crack (icon: 3 of 608).
  static const double lipScale = 0.005;
  static const double minLip = 0.5;

  /// The notch cut into each side edge (icon: 27 x 76 of 608).
  static const double notchWidthScale = 0.045;
  static const double notchHeightScale = 0.125;

  /// The notch's two inner, concave corners (icon: 9 of 608).
  static const double notchInnerRadiusScale = 0.015;

  /// Where the notch meets the side edge, rounded (icon: 4 of 608).
  static const double notchEdgeRadiusScale = 0.006;

  /// The pin in each notch (icon: 21 x 63 of 608).
  static const double pinWidthScale = 0.035;
  static const double pinHeightScale = 0.104;

  /// Pin corner relative to its width (icon: rounded ends of the rod).
  static const double pinRadiusScale = 0.3;

  /// Below this card height a pin is under 2.8 px and reads as dirt, so no
  /// notch and no pins are drawn; crack and lip only.
  static const double minHingeHeight = 80;

  double get _h => size.height;
  double get _w => size.width;

  /// Both flaps turn about this line.
  double get axisY => _h / 2;

  /// Notches and pins are drawn.
  bool get hasHinges => _h >= minHingeHeight;

  /// Inner edge of the left notch: the crack and lip start here.
  double get _inset => hasHinges ? _h * notchWidthScale : 0;

  double get _crackHeight => math.max(minCrack, _h * crackScale);

  /// The dark gap between the halves, from notch to notch.
  Rect get crack => Rect.fromLTRB(
    _inset,
    axisY - _crackHeight / 2,
    _w - _inset,
    axisY + _crackHeight / 2,
  );

  /// The last sliver of the top half above [crack]: the flap's underside.
  Rect get underside => Rect.fromLTRB(
    _inset,
    crack.top - _h * undersideScale,
    _w - _inset,
    crack.top,
  );

  /// The bottom half's top edge catching the light, directly under [crack].
  Rect get lip => Rect.fromLTWH(
    _inset,
    crack.bottom,
    _w - 2 * _inset,
    math.max(minLip, _h * lipScale),
  );

  RRect get notchLeft => _notch(left: true);
  RRect get notchRight => _notch(left: false);

  RRect _notch({required bool left}) {
    final w = _h * notchWidthScale;
    final h = _h * notchHeightScale;
    final rect = Rect.fromLTWH(left ? 0 : _w - w, axisY - h / 2, w, h);
    final inner = DesignShape.radius(_h * notchInnerRadiusScale);
    // Only the inner corners are part of the cavity; the side is open.
    return RRect.fromRectAndCorners(
      rect,
      topLeft: left ? Radius.zero : inner,
      bottomLeft: left ? Radius.zero : inner,
      topRight: left ? inner : Radius.zero,
      bottomRight: left ? inner : Radius.zero,
    );
  }

  RRect get pinLeft => _pin(left: true);
  RRect get pinRight => _pin(left: false);

  RRect _pin({required bool left}) {
    final w = _h * pinWidthScale;
    final h = _h * pinHeightScale;
    return RRect.fromRectAndRadius(
      Rect.fromLTWH(left ? 0 : _w - w, axisY - h / 2, w, h),
      DesignShape.radius(w * pinRadiusScale),
    );
  }

  /// Everything the notch on one side takes out of the card: the notch and
  /// the two small fillets that round the card edge into it.
  Path cavity({required bool left}) {
    final notch = left ? notchLeft : notchRight;
    final f = _h * notchEdgeRadiusScale;
    final x = left ? 0.0 : _w - f;
    final cx = left ? f : _w - f;
    Path fillet(double y, double cy) => Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(x, y, f, f)),
      Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: f)),
    );
    return Path()
      ..addRRect(notch)
      ..addPath(fillet(notch.top - f, notch.top - f), Offset.zero)
      ..addPath(fillet(notch.bottom, notch.bottom + f), Offset.zero);
  }

  /// The top or bottom half of the card face, in card coordinates: the
  /// rounded card cut at [axisY], minus its half of both notches. Empty
  /// for an empty card.
  Path halfPath({required bool top}) {
    if (_w <= 0 || _h <= 0) return Path();
    final card = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          DesignShape.radius(math.min(radius, math.min(_w, _h) / 2)),
        ),
      );
    final band = Path()
      ..addRect(
        top ? Rect.fromLTRB(0, 0, _w, axisY) : Rect.fromLTRB(0, axisY, _w, _h),
      );
    final half = Path.combine(PathOperation.intersect, card, band);
    if (!hasHinges) return half;
    return Path.combine(
      PathOperation.difference,
      half,
      Path()
        ..addPath(cavity(left: true), Offset.zero)
        ..addPath(cavity(left: false), Offset.zero),
    );
  }
}
