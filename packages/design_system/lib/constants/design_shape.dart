import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Every rounded shape in the app, from one user-chosen [corner] (the
/// `radius-md` value). Read with `DesignShape.of(context)`. The roles keep
/// the `tokens.json` ratios, so the default corner of 14 reproduces
/// `radius-xs` 6, `radius-sm` 10, `radius-md` 14 and `radius-lg` 22; at 0
/// every shape is square. Nothing is a circle or a stadium: a short element
/// takes [forHeight], which never rounds past half its height.
///
/// This file is the only place a radius becomes a shape ([circular],
/// [radius], [rounded]); `features/flip_clock/test/corner_rule_test.dart`
/// fails on `Radius.circular(`, `StadiumBorder`, `BoxShape.circle` and the
/// like anywhere else in `design_system` and `flip_clock`.
@immutable
class DesignShape extends ThemeExtension<DesignShape> {
  const DesignShape([this.corner = defaultCorner]);

  /// Today's cards.
  static const double defaultCorner = 14;

  /// The squarest corner.
  static const double minCorner = 0;

  /// The roundest corner.
  static const double maxCorner = 24;

  /// The base radius (`radius-md`).
  final double corner;

  /// Small details: keycaps, icon tiles, face chips.
  double get xs => corner * 6 / 14;

  /// Controls: buttons, chips, inputs, grouped cells, sidebar pills.
  double get sm => corner * 10 / 14;

  /// Cards: skin tiles, flip cards.
  double get md => corner;

  /// Large surfaces: sheets, dialogs, big flip cards, the two-row island.
  double get lg => corner * 22 / 14;

  /// [role] (default [md]) capped at half of [height], so a short element
  /// is at most as round as a pill and a dot stays a dot.
  double forHeight(double height, {double? role}) =>
      math.max(0, math.min(role ?? md, height / 2));

  /// The shape of the current theme; the default corner when it has none.
  static DesignShape of(BuildContext context) =>
      Theme.of(context).extension<DesignShape>() ?? const DesignShape();

  /// All four corners at [r].
  static BorderRadius circular(double r) => BorderRadius.circular(r);

  /// One corner at [r].
  static Radius radius(double r) => Radius.circular(r);

  /// A rounded rectangle at [r], optionally outlined by [side].
  static RoundedRectangleBorder rounded(
    double r, {
    BorderSide side = BorderSide.none,
  }) => RoundedRectangleBorder(borderRadius: circular(r), side: side);

  @override
  DesignShape copyWith({double? corner}) => DesignShape(corner ?? this.corner);

  @override
  DesignShape lerp(DesignShape? other, double t) =>
      other == null ? this : DesignShape(lerpDouble(corner, other.corner, t)!);

  @override
  bool operator ==(Object other) =>
      other is DesignShape && other.corner == corner;

  @override
  int get hashCode => corner.hashCode;
}
