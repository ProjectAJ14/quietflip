import 'dart:math' as math;

import 'package:flutter/material.dart';

/// True when the user asked for less motion: Android "Remove animations" and
/// web `prefers-reduced-motion` (`disableAnimations`), or iOS Reduce Motion
/// (`reduceMotion`, which does not set `disableAnimations`).
bool reducedMotion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context) ||
    View.of(context).platformDispatcher.accessibilityFeatures.reduceMotion;

/// Split-flap text: one card per digit; everything else (`:`, `.`, space,
/// the letters of AM/PM) drawn plain. Only cards whose character changed fold (rotateX, about
/// 300 ms); the new value is authoritative at once (top half and semantics
/// update immediately). Reduced motion swaps instantly. Scales down to any
/// box without clipping.
class FlipDisplay extends StatefulWidget {
  const FlipDisplay({
    super.key,
    required this.text,
    required this.semanticsLabel,
    this.onFlip,
  });

  final String text;

  /// Read by screen readers instead of the individual cards.
  final String semanticsLabel;

  /// Called once whenever [text] changes (for the flip sound).
  final VoidCallback? onFlip;

  /// Fold duration of one card.
  static const Duration flipDuration = Duration(milliseconds: 300);

  /// Key of the folding half while a card animates (for tests).
  static const Key flapKey = ValueKey('flip-flap');

  @override
  State<FlipDisplay> createState() => _FlipDisplayState();
}

class _FlipDisplayState extends State<FlipDisplay> {
  @override
  void didUpdateWidget(FlipDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) widget.onFlip?.call();
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.displayLarge!;
    final fontSize = MediaQuery.textScalerOf(context).scale(style.fontSize!);
    final text = widget.text;
    return Semantics(
      label: widget.semanticsLabel,
      container: true,
      child: ExcludeSemantics(
        // Fill the space the parent offers: a FittedBox under loose
        // constraints only shrinks, so the digits would stay text-sized.
        child: SizedBox.expand(
          child: FittedBox(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < text.length; i++)
                  _isSeparator(text[i])
                      ? _Separator(char: text[i], fontSize: fontSize)
                      // Keyed from the right, so "9:59" -> "10:00" keeps the
                      // minute cards in place.
                      : _FlipCard(
                          key: ValueKey(text.length - i),
                          char: text[i],
                          fontSize: fontSize,
                        ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Anything but a digit: letters are wider than a card.
  static bool _isSeparator(String c) => !'0123456789'.contains(c);
}

class _Separator extends StatelessWidget {
  const _Separator({required this.char, required this.fontSize});

  final String char;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    if (char == ' ') return SizedBox(width: fontSize * 0.3);
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: fontSize * 0.06),
      child: Text(
        char,
        style: theme.textTheme.displayLarge!.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _FlipCard extends StatefulWidget {
  const _FlipCard({super.key, required this.char, required this.fontSize});

  final String char;
  final double fontSize;

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
  late String _previous = widget.char;

  @override
  void didUpdateWidget(_FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.char == widget.char) return;
    _previous = oldWidget.char;
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
    final width = widget.fontSize * 0.78;
    final halfHeight = widget.fontSize * 0.64;
    final gap = math.max(1.0, widget.fontSize * 0.025);
    Widget half(String char, {required bool top}) => _Half(
      char: char,
      top: top,
      width: width,
      height: halfHeight,
      fontSize: widget.fontSize,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.fontSize * 0.04),
      child: AnimatedBuilder(
        animation: _fold,
        builder: (context, _) {
          final t = _fold.value;
          final folding = t < 1;
          final firstHalf = t < 0.5;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  half(widget.char, top: true),
                  if (folding && firstHalf)
                    _Fold(
                      angle: t * math.pi,
                      top: true,
                      child: half(_previous, top: true),
                    ),
                ],
              ),
              SizedBox(height: gap),
              Stack(
                children: [
                  half(folding ? _previous : widget.char, top: false),
                  if (folding && !firstHalf)
                    _Fold(
                      angle: (1 - t) * math.pi,
                      top: false,
                      child: half(widget.char, top: false),
                    ),
                ],
              ),
            ],
          );
        },
      ),
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

/// Top or bottom half of a card face showing [char].
class _Half extends StatelessWidget {
  const _Half({
    required this.char,
    required this.top,
    required this.width,
    required this.height,
    required this.fontSize,
  });

  final String char;
  final bool top;
  final double width;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = Radius.circular(fontSize * 0.12);
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: top
            ? BorderRadius.vertical(top: radius)
            : BorderRadius.vertical(bottom: radius),
      ),
      child: OverflowBox(
        maxHeight: height * 2,
        alignment: top ? Alignment.topCenter : Alignment.bottomCenter,
        child: SizedBox(
          height: height * 2,
          child: Center(
            child: Text(
              char,
              style: theme.textTheme.displayLarge!.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
