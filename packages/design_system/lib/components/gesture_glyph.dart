import 'dart:async';
import 'dart:ui' as ui;

import 'package:design_system/components/settings_shell.dart';
import 'package:design_system/constants/design_shape.dart';
import 'package:design_system/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// The touch gesture a [GestureGlyph] acts out.
enum GestureKind {
  /// A fingertip presses and a ring spreads from it.
  tap,

  /// A fingertip swipes right, then left on the next loop.
  swipeHorizontal,

  /// A fingertip swipes up, then down on the next loop.
  swipeVertical,
}

/// One drawn moment of a [GestureGlyph]. Offsets are from the tile centre.
typedef GestureFrame = ({
  /// The fingertip's centre.
  Offset dot,

  /// The fingertip's scale (pressed below 1).
  double scale,

  /// The fingertip's (and its trail's) opacity.
  double opacity,

  /// The tap ring's diameter; 0 draws none.
  double ring,

  /// The tap ring's opacity.
  double ringOpacity,

  /// Where a swipe's fading trail starts; null draws none.
  Offset? trail,

  /// The still frame's arrow direction (a unit vector); null draws none.
  Offset? arrow,
});

/// A [SettingsShell.iconTileSize] tile acting out a touch gesture with a
/// [dot] fingertip in `ink` on `surfaceRaised`, on a
/// [DesignMotion.gestureLoop] loop:
///
/// - [GestureKind.tap]: the fingertip presses (scale 1 to 0.7 over
///   [DesignMotion.gestureFade]) and springs back while a ring grows from
///   [dot] to [ringMax] and fades over [DesignMotion.gestureRing]; rest.
/// - Swipes: the fingertip fades in, travels [travel] on
///   [DesignMotion.gestureTravelCurve] over [DesignMotion.gestureTravel]
///   with a trail lagging [DesignMotion.gestureFade] behind, fades out;
///   rest. Each loop reverses the direction.
///
/// It animates only while its `TickerMode` is on (offstage pages and
/// covered routes stop it). Under reduced motion it draws [still]. Not
/// announced: the row's label says what the gesture does.
class GestureGlyph extends StatefulWidget {
  const GestureGlyph(this.kind, {super.key});

  final GestureKind kind;

  /// The fingertip's diameter.
  static const double dot = 10;

  /// The tap ring's widest diameter.
  static const double ringMax = 28;

  /// How far a swipe's fingertip travels, centred in the tile.
  static const double travel = 18;

  /// The fingertip at its lowest, mid-press.
  static const double _pressed = 0.7;

  /// How much of the fingertip's opacity the trail's head keeps.
  static const double _trailOpacity = 0.35;

  /// The frame of [kind] at [elapsed] into two loops (one each way).
  static GestureFrame frameAt(GestureKind kind, Duration elapsed) {
    final loop = DesignMotion.gestureLoop.inMicroseconds;
    final total = elapsed.inMicroseconds % (2 * loop);
    final t = total % loop;
    final fade = DesignMotion.gestureFade.inMicroseconds;
    double phase(int start, int length) =>
        ((t - start) / length).clamp(0.0, 1.0);
    if (kind == GestureKind.tap) {
      final ring = DesignMotion.gestureRing.inMicroseconds;
      final ringing = t >= fade && t < fade + ring;
      final u = phase(fade, ring);
      return (
        dot: Offset.zero,
        // Down over the first fade, back up over the next.
        scale:
            1 -
            (1 - _pressed) *
                (t < fade ? phase(0, fade) : 1 - phase(fade, fade)),
        opacity: 1,
        ring: ringing ? dot + (ringMax - dot) * u : 0,
        ringOpacity: ringing ? 1 - u : 0,
        trail: null,
        arrow: null,
      );
    }
    final away = _direction(kind);
    final d = total < loop ? away : -away;
    final travelTime = DesignMotion.gestureTravel.inMicroseconds;
    Offset at(double p) =>
        d *
        (travel * DesignMotion.gestureTravelCurve.transform(p) - travel / 2);
    final arrived = fade + travelTime;
    final moving = t >= fade && t < arrived + fade;
    return (
      dot: at(phase(fade, travelTime)),
      scale: 1,
      opacity: t < fade
          ? phase(0, fade)
          : t < arrived
          ? 1
          : 1 - phase(arrived, fade),
      ring: 0,
      ringOpacity: 0,
      trail: moving ? at(phase(2 * fade, travelTime)) : null,
      arrow: null,
    );
  }

  /// The reduced-motion frame: a tap's ring at mid size; a swipe's
  /// fingertip just behind the centre with an arrow on its first way.
  static GestureFrame still(GestureKind kind) {
    if (kind == GestureKind.tap) {
      return (
        dot: Offset.zero,
        scale: 1,
        opacity: 1,
        ring: (dot + ringMax) / 2,
        ringOpacity: 0.5,
        trail: null,
        arrow: null,
      );
    }
    final d = _direction(kind);
    return (
      dot: d * -(travel / 4),
      scale: 1,
      opacity: 1,
      ring: 0,
      ringOpacity: 0,
      trail: null,
      arrow: d,
    );
  }

  /// A swipe's first way: right, or up.
  static Offset _direction(GestureKind kind) =>
      kind == GestureKind.swipeHorizontal
      ? const Offset(1, 0)
      : const Offset(0, -1);

  @override
  State<GestureGlyph> createState() => _GestureGlyphState();
}

class _GestureGlyphState extends State<GestureGlyph>
    with SingleTickerProviderStateMixin {
  // Two loops, so a swipe knows which way this one goes.
  late final _loops = AnimationController(
    vsync: this,
    duration: DesignMotion.gestureLoop * 2,
  );
  bool _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = reducedMotion(context);
    if (_still) {
      _loops.stop();
    } else if (!_loops.isAnimating) {
      unawaited(_loops.repeat());
    }
  }

  @override
  void dispose() {
    _loops.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = DesignColors.of(context);
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: DesignShape.circular(DesignShape.of(context).xs),
        ),
        child: SizedBox.square(
          dimension: SettingsShell.iconTileSize,
          child: CustomPaint(
            painter: GestureGlyphPainter(
              kind: widget.kind,
              color: colors.ink,
              still: _still,
              progress: _loops,
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints [frame]: the trail, the ring, the fingertip and the still arrow,
/// in [color]. Repaints as [progress] (0..1 over two loops) moves.
class GestureGlyphPainter extends CustomPainter {
  GestureGlyphPainter({
    required this.kind,
    required this.color,
    required this.still,
    required this.progress,
  }) : super(repaint: progress);

  final GestureKind kind;
  final Color color;

  /// Draws [GestureGlyph.still] instead of following [progress].
  final bool still;
  final Animation<double> progress;

  /// The ring's and the arrow's stroke.
  static const double strokeWidth = 1.5;

  /// The arrow's half-width and depth.
  static const double _arrowArm = 3;

  /// The current frame.
  GestureFrame get frame => still
      ? GestureGlyph.still(kind)
      : GestureGlyph.frameAt(
          kind,
          Duration(
            microseconds:
                (progress.value * 2 * DesignMotion.gestureLoop.inMicroseconds)
                    .round(),
          ),
        );

  @override
  void paint(Canvas canvas, Size size) {
    final f = frame;
    final centre = size.center(Offset.zero);
    final dot = centre + f.dot;
    final radius = GestureGlyph.dot / 2 * f.scale;
    if (f.trail case final trail? when trail != f.dot) {
      final from = centre + trail;
      canvas.drawLine(
        from,
        dot,
        Paint()
          ..strokeWidth = radius * 2
          ..strokeCap = StrokeCap.round
          ..shader = ui.Gradient.linear(from, dot, [
            color.withValues(alpha: 0),
            color.withValues(alpha: GestureGlyph._trailOpacity * f.opacity),
          ]),
      );
    }
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    if (f.ring > 0) {
      canvas.drawCircle(
        dot,
        f.ring / 2,
        stroke..color = color.withValues(alpha: f.ringOpacity),
      );
    }
    canvas.drawCircle(
      dot,
      radius,
      Paint()..color = color.withValues(alpha: f.opacity),
    );
    if (f.arrow case final a?) {
      final tip = centre + a * (GestureGlyph.travel / 2 + 1);
      final back = tip - a * _arrowArm;
      final side = Offset(-a.dy, a.dx) * _arrowArm;
      canvas.drawPath(
        Path()
          ..moveTo(back.dx + side.dx, back.dy + side.dy)
          ..lineTo(tip.dx, tip.dy)
          ..lineTo(back.dx - side.dx, back.dy - side.dy),
        stroke..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(GestureGlyphPainter old) =>
      old.kind != kind ||
      old.color != color ||
      old.still != still ||
      old.progress != progress;
}
