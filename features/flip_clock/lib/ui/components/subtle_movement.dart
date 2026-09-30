import 'package:flip_clock/state/clock_controller.dart';
import 'package:flip_clock/ui/components/flip_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shifts [child] by a few pixels once per minute so the same pixels are not
/// lit all night (lowers, does not prevent, burn-in). Driven by the screen's
/// [ClockController]; this widget owns no timer.
///
/// The shift is padding that always sums to 2 * [maxShift] per axis, so the
/// child's space never changes with the offset and nothing clips or overflows.
/// Disabled, it sits centred (zero offset, same padding): callers keep it in
/// the tree either way, so toggling it never rebuilds the child's state.
class SubtleMovement extends StatelessWidget {
  const SubtleMovement({
    super.key,
    required this.clock,
    required this.enabled,
    required this.child,
  });

  final ClockController clock;

  /// Off: centred and still.
  final bool enabled;
  final Widget child;

  /// Largest shift from centre on each axis, in logical pixels.
  static const double maxShift = 8;

  /// A fixed walk around the centre, one step per minute.
  static const List<Offset> _steps = [
    Offset.zero,
    Offset(6, -4),
    Offset(-5, 6),
    Offset(8, 3),
    Offset(-7, -6),
    Offset(3, 8),
    Offset(-8, 1),
    Offset(4, -8),
  ];

  /// The shift shown during the minute of [time].
  static Offset offsetAt(DateTime time) =>
      _steps[(time.hour * 60 + time.minute) % _steps.length];

  @override
  Widget build(BuildContext context) => BlocBuilder<ClockController, DateTime>(
    bloc: clock,
    buildWhen: (a, b) => enabled && offsetAt(a) != offsetAt(b),
    builder: (context, now) {
      final o = enabled ? offsetAt(now) : Offset.zero;
      return AnimatedPadding(
        duration: !enabled || reducedMotion(context)
            ? Duration.zero
            : const Duration(seconds: 1),
        curve: Curves.easeInOut,
        padding: EdgeInsets.fromLTRB(
          maxShift + o.dx,
          maxShift + o.dy,
          maxShift - o.dx,
          maxShift - o.dy,
        ),
        child: child,
      );
    },
  );
}
