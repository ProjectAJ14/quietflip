import 'package:design_system/constants/design_shape.dart';
import 'package:design_system/constants/design_tokens.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// The one tap in the app: [child] shrinks while the finger is down and
/// springs back when it lifts. No ink, no highlight, no hover wash.
///
/// The press shows on pointer down ([DesignMotion.pressIn]) and releases
/// over [DesignMotion.pressOut]. [onTap] fires on pointer up inside the tap
/// slop; moving past the slop (dragging off, or a scroll taking over)
/// releases without firing. Focusable: Enter and Space fire it with a short
/// press-and-release, and keyboard focus draws a 2 px `accent` ring at
/// [focusRadius] (the child's corner; `sm` by default). Reduced motion dips
/// the opacity instead of scaling. A null [onTap] disables it: no press, no
/// focus, `enabled: false` semantics.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.semanticsLabel,
    this.selected = false,
    this.role,
    this.focusRadius,
  });

  final Widget child;

  /// Fires on release inside the tap slop, or on Enter / Space. Null
  /// disables the whole control.
  final VoidCallback? onTap;

  final VoidCallback? onLongPress;

  /// Spoken name; merged with the child's own semantics.
  final String? semanticsLabel;

  /// Spoken selected state (tabs, radios, tiles).
  final bool selected;

  /// Replaces the default button role, such as [SemanticsRole.tab].
  final SemanticsRole? role;

  /// The child's corner, for the focus ring (from `DesignShape`).
  final BorderRadius? focusRadius;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: DesignMotion.pressIn,
    reverseDuration: DesignMotion.pressOut,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _press,
    curve: DesignMotion.pressInCurve,
    // A reverse curve runs from 1 to 0; flipped keeps it easing out.
    reverseCurve: DesignMotion.pressOutCurve.flipped,
  );

  /// The pointer down the innermost Pressable under the finger took. A down
  /// reaches the deepest hit first, so an outer Pressable (a tile around a
  /// Customize button) sees it is taken and stays still.
  static (int, Duration)? _claimed;

  int? _pointer;
  Offset _downAt = Offset.zero;
  double _slop = kTouchSlop;
  double _target = DesignMotion.pressScale;
  bool _focused = false;

  bool get _enabled => widget.onTap != null;

  @override
  void didUpdateWidget(Pressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled) {
      _pointer = null;
      _press.value = 0;
    }
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  TickerFuture _pressIn() {
    final size = context.size!;
    _target = size.longestSide <= 48
        ? DesignMotion.pressScaleSmall
        : DesignMotion.pressScale;
    return _press.forward();
  }

  void _release() {
    _pointer = null;
    _press.reverse();
  }

  void _down(PointerDownEvent event) {
    final down = (event.pointer, event.timeStamp);
    if (!_enabled || _pointer != null || _claimed == down) return;
    _claimed = down;
    _pointer = event.pointer;
    _downAt = event.position;
    _slop = computeHitSlop(event.kind, MediaQuery.gestureSettingsOf(context));
    _pressIn();
  }

  void _move(PointerMoveEvent event) {
    if (event.pointer != _pointer) return;
    if ((event.position - _downAt).distance > _slop) _release();
  }

  void _up(PointerEvent event) {
    if (event.pointer == _pointer) _release();
  }

  void _activate(Intent _) {
    widget.onTap!();
    _pressIn().then((_) => _press.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final reduced = reducedMotion(context);
    final ring = _focused
        ? DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              border: Border.all(
                color: DesignColors.of(context).accent,
                width: 2,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
              borderRadius:
                  widget.focusRadius ??
                  DesignShape.circular(DesignShape.of(context).sm),
            ),
            child: widget.child,
          )
        : widget.child;
    final action = CallbackAction<Intent>(onInvoke: _activate);
    return Semantics(
      container: true,
      button: widget.role == null,
      role: widget.role,
      enabled: _enabled,
      selected: widget.selected || widget.role != null ? widget.selected : null,
      label: widget.semanticsLabel,
      onTap: widget.onTap,
      onLongPress: _enabled ? widget.onLongPress : null,
      child: FocusableActionDetector(
        enabled: _enabled,
        mouseCursor: _enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onShowFocusHighlight: (focused) => setState(() => _focused = focused),
        actions: {ActivateIntent: action, ButtonActivateIntent: action},
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _down,
          onPointerMove: _move,
          onPointerUp: _up,
          onPointerCancel: _up,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: widget.onTap,
            onLongPress: _enabled ? widget.onLongPress : null,
            child: AnimatedBuilder(
              animation: _curve,
              builder: (context, child) => Opacity(
                opacity: reduced
                    ? 1 - (1 - DesignMotion.pressOpacity) * _curve.value
                    : 1,
                child: Transform.scale(
                  scale: reduced ? 1 : 1 - (1 - _target) * _curve.value,
                  child: child,
                ),
              ),
              child: ring,
            ),
          ),
        ),
      ),
    );
  }
}
