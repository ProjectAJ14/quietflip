import 'package:design_system/design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// The clock screen's only gesture handler: taps, an optional double tap,
/// vertical drags (brightness) and horizontal swipes (mode pages).
///
/// A drag locks to one axis once it has moved [axisLock] pixels and keeps
/// that axis until the finger lifts. Horizontal swipes drive [pages] directly
/// (the screen's `PageView` has `NeverScrollableScrollPhysics`), settling on a
/// neighbour page past [pageThreshold] of the width or [flingVelocity].
/// Controls inside [child] keep their own taps: the innermost recognizer wins.
class GestureLayer extends StatefulWidget {
  const GestureLayer({
    super.key,
    required this.child,
    required this.pages,
    required this.pageCount,
    this.enabled = true,
    this.brightness = true,
    this.modes = true,
    this.onTap,
    this.onDoubleTap,
    this.onGestureStart,
    this.onBrightness,
    this.onBrightnessEnd,
    this.onPage,
    this.onSwipeEnd,
  });

  final Widget child;
  final PageController pages;
  final int pageCount;

  /// False while something covers the clock: no recognizers at all.
  final bool enabled;

  /// Whether vertical drags change brightness.
  final bool brightness;

  /// Whether horizontal swipes change the mode page.
  final bool modes;

  final VoidCallback? onTap;

  /// Null means no double-tap recognizer, so single taps are not delayed.
  final VoidCallback? onDoubleTap;

  /// Once per drag, when it locks to an enabled axis.
  final VoidCallback? onGestureStart;

  /// Per vertical update: `-dy / height`, so a full-height drag up is +1.0.
  final ValueChanged<double>? onBrightness;
  final VoidCallback? onBrightnessEnd;

  /// The page a swipe settles on, once per swipe; not called when it springs
  /// back to the page it started on.
  final ValueChanged<int>? onPage;
  final VoidCallback? onSwipeEnd;

  /// Distance in pixels after which a drag commits to an axis.
  static const double axisLock = 12;

  /// Fraction of the width a swipe must travel to change page.
  static const double pageThreshold = 0.25;

  /// Horizontal speed in pixels per second that changes page on its own.
  static const double flingVelocity = 600;

  @override
  State<GestureLayer> createState() => _GestureLayerState();
}

class _GestureLayerState extends State<GestureLayer> {
  Offset _total = Offset.zero;
  Axis? _axis;
  bool _active = false;
  double _startOffset = 0;

  double get _width => widget.pages.position.viewportDimension;

  /// The page view runs right to left in right-to-left text, so there a
  /// swipe to the right moves forward: [x] in reading direction, where a
  /// negative value moves toward the next page.
  double _reading(double x) =>
      Directionality.of(context) == TextDirection.rtl ? -x : x;

  void _start(DragStartDetails _) {
    _total = Offset.zero;
    _axis = null;
    _active = false;
    _startOffset = widget.pages.offset;
  }

  void _update(DragUpdateDetails details) {
    _total += details.delta;
    var delta = details.delta;
    if (_axis == null) {
      if (_total.distance <= GestureLayer.axisLock) return;
      _axis = _total.dx.abs() >= _total.dy.abs()
          ? Axis.horizontal
          : Axis.vertical;
      _active = _axis == Axis.horizontal ? widget.modes : widget.brightness;
      if (_active) widget.onGestureStart?.call();
      // Report the movement made before the lock too, so sums stay exact.
      delta = _total;
    }
    if (!_active) return;
    if (_axis == Axis.vertical) {
      widget.onBrightness?.call(-delta.dy / context.size!.height);
    } else {
      final max = (widget.pageCount - 1) * _width;
      widget.pages.jumpTo((_startOffset - _reading(_total.dx)).clamp(0, max));
    }
  }

  void _end(DragEndDetails details) {
    if (!_active) return;
    if (_axis == Axis.vertical) {
      widget.onBrightnessEnd?.call();
      return;
    }
    final fraction = _reading(_total.dx) / _width;
    final velocity = _reading(details.velocity.pixelsPerSecond.dx);
    final current = (_startOffset / _width).round();
    var target = current;
    if (fraction >= GestureLayer.pageThreshold ||
        velocity > GestureLayer.flingVelocity) {
      target = current - 1;
    } else if (fraction <= -GestureLayer.pageThreshold ||
        velocity < -GestureLayer.flingVelocity) {
      target = current + 1;
    }
    target = target.clamp(0, widget.pageCount - 1);
    widget.pages.animateToPage(
      target,
      duration: DesignMotion.islandMorph,
      curve: DesignMotion.islandCurve,
    );
    // A swipe that snaps back changes nothing.
    if (target != current) widget.onPage?.call(target);
    widget.onSwipeEnd?.call();
  }

  Map<Type, GestureRecognizerFactory> _gestures() => {
    TapGestureRecognizer:
        GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
          TapGestureRecognizer.new,
          (r) => r.onTap = widget.onTap,
        ),
    if (widget.onDoubleTap != null)
      DoubleTapGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
            DoubleTapGestureRecognizer.new,
            (r) => r.onDoubleTap = widget.onDoubleTap,
          ),
    PanGestureRecognizer:
        GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
          PanGestureRecognizer.new,
          (r) => r
            // From the down position, so the slop distance is not lost.
            ..dragStartBehavior = DragStartBehavior.down
            ..onStart = _start
            ..onUpdate = _update
            ..onEnd = _end,
        ),
  };

  @override
  Widget build(BuildContext context) => RawGestureDetector(
    behavior: HitTestBehavior.translucent,
    gestures: widget.enabled ? _gestures() : const {},
    child: widget.child,
  );
}
