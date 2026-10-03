import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flip_clock/data/models/skin.dart';
import 'package:flip_clock/ui/components/flip_card_geometry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Split-flap cards styled entirely by [skin]: one card per entry of
/// [cards] (usually a pair of digits). Every card is shaped as on the app
/// icon ([FlipCardGeometry]): a crack across the middle and a hinge pin in a
/// notch at each end, inside the card edge. Only cards whose value changed
/// fold: one turn about the axle over [flipDuration], the top half falling
/// then the bottom half landing, shaded as they tip; the new value is
/// authoritative at once. Reduced motion swaps instantly.
///
/// Card height fills the space given, times [size]; digits are
/// [digitScale] x card height and never text-scaled, so the display never
/// clips at large text sizes. AM/PM ([meridiem]) and small seconds
/// ([badge]) are plain text in the skin's face, never cards, and grow with
/// the card. The skin is drawn [Skin.forTheme] the current theme.
///
/// [stackable] displays (the clock screen's panels) stack the cards top to
/// bottom, centred, when that makes them at least [stackGain] times bigger
/// than one row, and go back to the row only once the row is [stackGain]
/// times bigger; switching cross-fades. The display is as big as its cards,
/// so a parent can centre it with a line above or below.
class FlipDisplay extends StatefulWidget {
  const FlipDisplay({
    super.key,
    required this.cards,
    required this.skin,
    required this.semanticsLabel,
    this.badge,
    this.meridiem,
    this.onFlip,
    this.size = 1,
    this.stackable = false,
  });

  final List<String> cards;
  final Skin skin;

  /// Read by screen readers instead of the individual cards.
  final String semanticsLabel;

  /// Small text in the last card's bottom-right corner (seconds).
  final String? badge;

  /// AM/PM, placed where [Skin.meridiem] says (not drawn when hidden).
  final String? meridiem;

  /// Called once whenever [cards] change (for the flip sound).
  final VoidCallback? onFlip;

  /// Card height relative to the largest card that fits, 0.1..1
  /// (`CardSize.factor`).
  final double size;

  /// May stack the cards when the space is tall (skin tiles and previews
  /// stay in one row).
  final bool stackable;

  /// How much bigger the other layout's cards must be before it is used:
  /// the 15% band stops flicker near square windows and during a resize.
  static const double stackGain = 1.15;

  /// One card flip, top fold then bottom fold, 50/50.
  static const Duration flipDuration = DesignMotion.flip;

  /// The flip's one curve, from the top half upright (0) to the bottom half
  /// landed (1): the flap speeds up as it falls and slows as it lands, with
  /// no change of speed where the halves hand over.
  static const Curve flipCurve = Curves.easeInOut;

  /// Perspective strength times the card height, so every card size bends
  /// the same (0.002 on a 200px card).
  static const double perspective = 0.4;

  /// Darkest ground-colour shade on a flap edge-on, and on the shadow it
  /// casts on the half below.
  static const double maxShade = 0.35;

  /// Digit size relative to the card height.
  static const double digitScale = 0.78;

  /// AM/PM, badge and corner padding relative to the card height. They scale
  /// with the card, so they sit in its bottom margin at every size: at
  /// 150px AM/PM reaches the `meridiem` token's 18px, a 130px card gives the
  /// badge `seconds-badge`'s 13px, and a small tile never has them over the
  /// digits.
  static const double meridiemScale = 0.12;
  static const double badgeScale = 0.1;
  static const double cornerScale = 0.05;

  /// Key of the folding half while a card animates (for tests).
  static const Key flapKey = ValueKey('flip-flap');

  /// Key of each card's painter of pins and crack (for tests).
  static const Key hingeKey = ValueKey('flip-hinge');

  @override
  State<FlipDisplay> createState() => _FlipDisplayState();
}

class _FlipDisplayState extends State<FlipDisplay> {
  /// The layout in use; kept while the space sits inside the band.
  bool _stacked = false;

  @override
  void didUpdateWidget(FlipDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.cards, widget.cards)) widget.onFlip?.call();
  }

  @override
  Widget build(BuildContext context) {
    final skin = widget.skin.forTheme(DesignColors.of(context));
    final soft = skin.digitColor.withValues(alpha: 0.7);
    final meridiem = skin.meridiem == SkinMeridiem.hidden
        ? null
        : widget.meridiem;
    final n = widget.cards.length;
    final ratio = skin.face.monospaced ? 1.3 : 1.0;
    return Semantics(
      label: widget.semanticsLabel,
      container: true,
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, box) {
            const gap = DesignSpace.s6;
            final width = box.maxWidth.isFinite ? box.maxWidth : 1000.0;
            final fit = (width - gap * (n - 1)) / (n * ratio);
            final tall = box.maxHeight.isFinite;
            // The largest card each layout fits, before the size choice.
            final row = tall ? math.min(box.maxHeight, fit) : fit;
            final stack = tall
                ? math.min((box.maxHeight - gap * (n - 1)) / n, width / ratio)
                : 0.0;
            if (!widget.stackable || !tall || n < 2) {
              _stacked = false;
            } else if (_stacked
                ? row >= stack * FlipDisplay.stackGain
                : stack >= row * FlipDisplay.stackGain) {
              _stacked = !_stacked;
            }
            final stacked = _stacked;
            final height =
                math.max(0.0, stacked ? stack : row) *
                widget.size.clamp(0.1, 1);
            final tag = skin.face.style(
              color: soft,
              fontSize: height * FlipDisplay.meridiemScale,
            );
            final badge = skin.face
                .style(color: soft, fontSize: height * FlipDisplay.badgeScale)
                .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
            final pad = height * FlipDisplay.cornerScale;
            // The app's corner: md cards become lg once digits reach digit-l.
            final large = height * FlipDisplay.digitScale >= 160;
            final shape = DesignShape.of(context);
            final radius = shape.forHeight(
              height,
              role: large ? shape.lg : shape.md,
            );
            Widget card(int i) => _FlipCard(
              // Keyed from the right, so gaining an hour card keeps the
              // minute cards in place.
              key: ValueKey(n - i),
              value: widget.cards[i],
              skin: skin,
              height: height,
              width: height * ratio,
              radius: radius,
              bottomLeft: i == 0 && skin.meridiem == SkinMeridiem.left
                  ? _Corner(meridiem, tag, pad)
                  : null,
              bottomRight: i == n - 1
                  ? _Corner(widget.badge, badge, pad)
                  : null,
            );
            final right =
                meridiem != null && skin.meridiem == SkinMeridiem.right
                ? Padding(
                    padding: EdgeInsets.only(left: pad),
                    child: Text(
                      meridiem,
                      style: tag,
                      textScaler: TextScaler.noScaling,
                    ),
                  )
                : null;
            final Widget cards = stacked
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    // AM/PM beside the last card keeps the cards aligned.
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: gap,
                    children: [
                      for (var i = 0; i < n - 1; i++) card(i),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [card(n - 1), ?right],
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < n; i++) ...[
                        if (i > 0) const SizedBox(width: gap),
                        card(i),
                      ],
                      ?right,
                    ],
                  );
            return Center(
              widthFactor: 1,
              heightFactor: 1,
              child: AnimatedSwitcher(
                duration: reducedMotion(context)
                    ? Duration.zero
                    : DesignMotion.fade,
                // Only an AM/PM beside the cards can exceed the width.
                child: FittedBox(
                  key: ValueKey(stacked),
                  fit: BoxFit.scaleDown,
                  child: cards,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Plain text in a card corner; nothing when [text] is null.
class _Corner extends StatelessWidget {
  const _Corner(this.text, this.style, this.padding);

  final String? text;
  final TextStyle style;
  final double padding;

  @override
  Widget build(BuildContext context) => text == null
      ? const SizedBox.shrink()
      : Padding(
          padding: EdgeInsets.all(padding),
          child: Text(
            text!,
            style: style,
            maxLines: 1,
            softWrap: false,
            textScaler: TextScaler.noScaling,
          ),
        );
}

class _FlipCard extends StatefulWidget {
  const _FlipCard({
    super.key,
    required this.value,
    required this.skin,
    required this.height,
    required this.width,
    required this.radius,
    this.bottomLeft,
    this.bottomRight,
  });

  final String value;
  final Skin skin;
  final double height;
  final double width;
  final double radius;
  final Widget? bottomLeft;
  final Widget? bottomRight;

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fold = AnimationController(
    vsync: this,
    duration: FlipDisplay.flipDuration,
    value: 1,
  );
  late String _previous = widget.value;

  @override
  void didUpdateWidget(_FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value) return;
    if (reducedMotion(context)) {
      _previous = oldWidget.value;
      _fold.value = 1;
    } else if (!_fold.isAnimating || _fold.value >= 0.5) {
      // Still or landing: finish that flip at once and fall again from the
      // value it showed, so the top half never jumps. While the top half is
      // still falling it keeps falling and lands on the newest value,
      // instead of snapping back up.
      _previous = oldWidget.value;
      _fold.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _fold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = widget.skin;
    final geometry = FlipCardGeometry(
      Size(widget.width, widget.height),
      widget.radius,
    );
    Widget half(
      String value, {
      required bool top,
      double shade = 0,
      double shadow = 0,
    }) => _Half(
      value: value,
      top: top,
      skin: skin,
      geometry: geometry,
      fontSize: widget.height * FlipDisplay.digitScale,
      shade: shade,
      shadow: shadow,
    );

    return RepaintBoundary(
      // Over the halves and the flap, so the flaps turn between the pins
      // as on an axle.
      child: CustomPaint(
        key: FlipDisplay.hingeKey,
        foregroundPainter: _CardPainter(geometry: geometry, skin: skin),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _fold,
              builder: (context, _) {
                final folding = _fold.value < 1;
                // One turn about the axle: 0 upright, pi/2 edge-on, pi
                // landed.
                final turn =
                    FlipDisplay.flipCurve.transform(_fold.value) * math.pi;
                final falling = turn < math.pi / 2;
                // Darkest edge-on, for both flaps and the shadow they cast.
                final shade = folding
                    ? FlipDisplay.maxShade * math.sin(turn)
                    : 0.0;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        half(widget.value, top: true),
                        if (folding && falling)
                          _Fold(
                            angle: turn,
                            top: true,
                            height: widget.height,
                            child: half(_previous, top: true, shade: shade),
                          ),
                      ],
                    ),
                    Stack(
                      children: [
                        half(
                          folding ? _previous : widget.value,
                          top: false,
                          shadow: shade,
                        ),
                        if (folding && !falling)
                          _Fold(
                            angle: math.pi - turn,
                            top: false,
                            height: widget.height,
                            child: half(widget.value, top: false, shade: shade),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
            if (widget.bottomLeft != null)
              Positioned(left: 0, bottom: 0, child: widget.bottomLeft!),
            if (widget.bottomRight != null)
              Positioned(right: 0, bottom: 0, child: widget.bottomRight!),
          ],
        ),
      ),
    );
  }
}

/// The moving flap: the top half falls about its bottom edge, then the
/// bottom half lands about its top edge; both edges are the axle. Perspective
/// follows the card [height].
class _Fold extends StatelessWidget {
  const _Fold({
    required this.angle,
    required this.top,
    required this.height,
    required this.child,
  });

  final double angle;
  final bool top;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) => Transform(
    key: FlipDisplay.flapKey,
    alignment: top ? Alignment.bottomCenter : Alignment.topCenter,
    transform: Matrix4.identity()
      ..setEntry(3, 2, height > 0 ? FlipDisplay.perspective / height : 0)
      ..rotateX(top ? -angle : angle),
    child: child,
  );
}

/// Over each card: the crack and the lip under it, the notch cavities and
/// the pins in them, pins last, from the card's [geometry].
class _CardPainter extends CustomPainter {
  const _CardPainter({required this.geometry, required this.skin});

  final FlipCardGeometry geometry;
  final Skin skin;

  @override
  void paint(Canvas canvas, Size size) {
    final ground = skin.groundColor;
    canvas
      ..drawRect(geometry.crack, Paint()..color = ground)
      ..drawRect(
        geometry.lip,
        Paint()..color = Color.lerp(ground, skin.digitColor, 0.12)!,
      );
    if (!geometry.hasHinges) return;
    final light = Color.lerp(skin.cardColor, skin.digitColor, 0.25)!;
    final body = Color.lerp(skin.cardColor, ground, 0.45)!;
    for (final left in [true, false]) {
      canvas.drawPath(geometry.cavity(left: left), Paint()..color = ground);
    }
    for (final pin in [geometry.pinLeft, geometry.pinRight]) {
      canvas.drawRRect(
        pin,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [light, body, ground],
            stops: const [0, 0.55, 1],
          ).createShader(pin.outerRect),
      );
    }
  }

  @override
  bool shouldRepaint(_CardPainter old) =>
      old.geometry.size != geometry.size ||
      old.geometry.radius != geometry.radius ||
      old.skin != skin;
}

/// Clips a half to its part of the card: rounded corners on the outside,
/// its half of each notch.
class _HalfClipper extends CustomClipper<Path> {
  const _HalfClipper(this.geometry, {required this.top});

  final FlipCardGeometry geometry;
  final bool top;

  @override
  Path getClip(Size size) =>
      geometry.halfPath(top: top).shift(Offset(0, top ? 0 : -geometry.axisY));

  @override
  bool shouldReclip(_HalfClipper old) =>
      old.top != top ||
      old.geometry.size != geometry.size ||
      old.geometry.radius != geometry.radius;
}

/// Top or bottom half of a card face showing [value].
class _Half extends StatelessWidget {
  const _Half({
    required this.value,
    required this.top,
    required this.skin,
    required this.geometry,
    required this.fontSize,
    this.shade = 0,
    this.shadow = 0,
  });

  final String value;
  final bool top;
  final Skin skin;

  /// The whole card; this half is its top or bottom, cut at the axle.
  final FlipCardGeometry geometry;
  final double fontSize;

  /// Ground-colour alpha over the whole half (a flap tipping away).
  final double shade;

  /// Ground-colour alpha at the top edge, fading down (the shadow a flap
  /// casts on the bottom half).
  final double shadow;

  @override
  Widget build(BuildContext context) {
    final ground = skin.groundColor;
    final width = geometry.size.width;
    final cardHeight = geometry.size.height;
    // The path owns the shape, so the flap carries the notches too.
    return ClipPath(
      clipper: _HalfClipper(geometry, top: top),
      child: Container(
        width: width,
        height: geometry.axisY,
        color: skin.cardColor,
        foregroundDecoration: shade > 0 || shadow > 0
            ? BoxDecoration(
                color: shade > 0 ? ground.withValues(alpha: shade) : null,
                gradient: shadow > 0
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          ground.withValues(alpha: shadow),
                          ground.withValues(alpha: 0),
                        ],
                        stops: const [0, 0.6],
                      )
                    : null,
              )
            : null,
        // A box the full card's height, so both halves share one axle.
        child: OverflowBox(
          maxHeight: cardHeight,
          alignment: top ? Alignment.topCenter : Alignment.bottomCenter,
          child: SizedBox(
            width: width,
            height: cardHeight,
            // Wide faces shrink to the card instead of clipping sideways,
            // about the axle, so the digits stay centred on it.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                height: cardHeight,
                // Placed by baseline, not by line box: the digits' centre
                // lands on the axle whatever the face's leading.
                child: Baseline(
                  baseline: geometry.axisY + skin.face.digitCentre * fontSize,
                  baselineType: TextBaseline.alphabetic,
                  child: Text(
                    value,
                    maxLines: 1,
                    softWrap: false,
                    textScaler: TextScaler.noScaling,
                    style: skin.face.style(
                      color: skin.digitColor,
                      fontSize: fontSize,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
