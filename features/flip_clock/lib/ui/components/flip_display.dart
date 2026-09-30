import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flip_clock/data/models/skin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// True when the user asked for less motion: Android "Remove animations" and
/// web `prefers-reduced-motion` (`disableAnimations`), or iOS Reduce Motion
/// (`reduceMotion`, which does not set `disableAnimations`).
bool reducedMotion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context) ||
    View.of(context).platformDispatcher.accessibilityFeatures.reduceMotion;

/// Split-flap cards styled entirely by [skin]: one card per entry of
/// [cards] (usually a pair of digits). Only cards whose value changed fold
/// (top half down, then bottom half, [flipDuration]); the new value is
/// authoritative at once. Reduced motion swaps instantly.
///
/// Card height fills the space given; digits are [digitScale] x card height
/// and never text-scaled, so the display never clips at large text sizes.
/// AM/PM ([meridiem]) and small seconds ([badge]) are plain text, never
/// cards.
class FlipDisplay extends StatefulWidget {
  const FlipDisplay({
    super.key,
    required this.cards,
    required this.skin,
    required this.semanticsLabel,
    this.badge,
    this.meridiem,
    this.onFlip,
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

  /// One card flip, top fold then bottom fold, 50/50.
  static const Duration flipDuration = DesignMotion.flip;

  /// Digit size relative to the card height.
  static const double digitScale = 0.78;

  /// Height of the seam line.
  static const double seamHeight = 2;

  /// Key of the folding half while a card animates (for tests).
  static const Key flapKey = ValueKey('flip-flap');

  @override
  State<FlipDisplay> createState() => _FlipDisplayState();
}

class _FlipDisplayState extends State<FlipDisplay> {
  @override
  void didUpdateWidget(FlipDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.cards, widget.cards)) widget.onFlip?.call();
  }

  @override
  Widget build(BuildContext context) {
    final skin = widget.skin;
    final theme = Theme.of(context);
    final soft = skin.digitColor.withValues(alpha: 0.7);
    final meridiem = skin.meridiem == SkinMeridiem.hidden
        ? null
        : widget.meridiem;
    final n = widget.cards.length;
    final ratio = skin.face.monospaced ? 1.3 : 1.0;
    final tag = theme.textTheme.titleSmall!.copyWith(color: soft);
    final badge = theme.textTheme.labelMedium!.copyWith(color: soft);
    return Semantics(
      label: widget.semanticsLabel,
      container: true,
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, box) {
            const gap = DesignSpace.s6;
            final width = box.maxWidth.isFinite ? box.maxWidth : 1000.0;
            final fit = (width - gap * (n - 1)) / (n * ratio);
            final height = math.max(
              0.0,
              box.maxHeight.isFinite ? math.min(box.maxHeight, fit) : fit,
            );
            // radius-md cards become radius-lg once digits reach digit-l.
            final large = height * FlipDisplay.digitScale >= 160;
            final radius = math.min(
              height / 2,
              skin.cardRadius * (large ? DesignRadius.lg / DesignRadius.md : 1),
            );
            return Center(
              // Only an AM/PM beside the cards can exceed the width.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < n; i++) ...[
                      if (i > 0) const SizedBox(width: gap),
                      // Keyed from the right, so gaining an hour card keeps
                      // the minute cards in place.
                      _FlipCard(
                        key: ValueKey(n - i),
                        value: widget.cards[i],
                        skin: skin,
                        height: height,
                        width: height * ratio,
                        radius: radius,
                        bottomLeft: i == 0 && skin.meridiem == SkinMeridiem.left
                            ? _Corner(meridiem, tag)
                            : null,
                        bottomRight: i == n - 1
                            ? _Corner(widget.badge, badge)
                            : null,
                      ),
                    ],
                    if (meridiem != null && skin.meridiem == SkinMeridiem.right)
                      Padding(
                        padding: const EdgeInsets.only(left: DesignSpace.s3),
                        child: Text(meridiem, style: tag),
                      ),
                  ],
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
  const _Corner(this.text, this.style);

  final String? text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => text == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.all(DesignSpace.s3),
          child: Text(text!, style: style, maxLines: 1, softWrap: false),
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
    _previous = oldWidget.value;
    if (reducedMotion(context)) {
      _fold.value = 1;
    } else {
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
    final seam = skin.seam ? FlipDisplay.seamHeight : 0.0;
    final halfHeight = math.max(0.0, (widget.height - seam) / 2);
    Widget half(String value, {required bool top}) => _Half(
      value: value,
      top: top,
      skin: skin,
      width: widget.width,
      height: halfHeight,
      fontSize: widget.height * FlipDisplay.digitScale,
      radius: widget.radius,
    );

    return AnimatedBuilder(
      animation: _fold,
      builder: (context, _) {
        final t = _fold.value;
        final folding = t < 1;
        final firstHalf = t < 0.5;
        return Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    half(widget.value, top: true),
                    if (folding && firstHalf)
                      _Fold(
                        // The top half falls (ease-in) over the first 50%.
                        angle: Curves.easeIn.transform(t * 2) * math.pi / 2,
                        top: true,
                        child: half(_previous, top: true),
                      ),
                  ],
                ),
                // The seam shows the ground through the card.
                Container(
                  width: widget.width,
                  height: seam,
                  color: skin.groundColor,
                ),
                Stack(
                  children: [
                    half(folding ? _previous : widget.value, top: false),
                    if (folding && !firstHalf)
                      _Fold(
                        // The bottom half lands (ease-out) over the last 50%.
                        angle:
                            (1 - Curves.easeOut.transform((t - 0.5) * 2)) *
                            math.pi /
                            2,
                        top: false,
                        child: half(widget.value, top: false),
                      ),
                  ],
                ),
              ],
            ),
            if (widget.bottomLeft != null)
              Positioned(left: 0, bottom: 0, child: widget.bottomLeft!),
            if (widget.bottomRight != null)
              Positioned(right: 0, bottom: 0, child: widget.bottomRight!),
          ],
        );
      },
    );
  }
}

/// The moving flap: the top half falls about its bottom edge, then the
/// bottom half lands about its top edge.
class _Fold extends StatelessWidget {
  const _Fold({required this.angle, required this.top, required this.child});

  final double angle;
  final bool top;
  final Widget child;

  @override
  Widget build(BuildContext context) => Transform(
    key: FlipDisplay.flapKey,
    alignment: top ? Alignment.bottomCenter : Alignment.topCenter,
    transform: Matrix4.identity()
      ..setEntry(3, 2, 0.002)
      ..rotateX(top ? -angle : angle),
    child: child,
  );
}

/// Top or bottom half of a card face showing [value].
class _Half extends StatelessWidget {
  const _Half({
    required this.value,
    required this.top,
    required this.skin,
    required this.width,
    required this.height,
    required this.fontSize,
    required this.radius,
  });

  final String value;
  final bool top;
  final Skin skin;
  final double width;
  final double height;
  final double fontSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final r = Radius.circular(radius);
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: skin.cardColor,
        borderRadius: top
            ? BorderRadius.vertical(top: r)
            : BorderRadius.vertical(bottom: r),
      ),
      child: OverflowBox(
        maxHeight: height * 2,
        alignment: top ? Alignment.topCenter : Alignment.bottomCenter,
        child: SizedBox(
          height: height * 2,
          child: Center(
            // Wide faces shrink to the card instead of clipping sideways.
            child: FittedBox(
              fit: BoxFit.scaleDown,
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
    );
  }
}
