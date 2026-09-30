import 'package:flip_clock/ui/components/flip_display.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

/// Fades controls in and out; hidden controls take no taps or focus.
class Reveal extends StatelessWidget {
  const Reveal({super.key, required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    opacity: visible ? 1 : 0,
    duration: reducedMotion(context)
        ? Duration.zero
        : const Duration(milliseconds: 200),
    child: IgnorePointer(
      ignoring: !visible,
      child: ExcludeFocus(excluding: !visible, child: child),
    ),
  );
}

/// Start / Pause / Resume plus Reset, in one small row.
class RunControls extends StatelessWidget {
  const RunControls({
    super.key,
    required this.running,
    required this.started,
    required this.onPrimary,
    required this.onReset,
  });

  /// Currently counting.
  final bool running;

  /// Has a value to pause/resume/reset (not idle).
  final bool started;
  final VoidCallback onPrimary;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, String label) = running
        ? (Icons.pause_rounded, strings.clock.pause)
        : started
        ? (Icons.play_arrow_rounded, strings.clock.resume)
        : (Icons.play_arrow_rounded, strings.clock.start);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton.tonalIcon(
            onPressed: onPrimary,
            icon: Icon(icon),
            label: Text(label),
          ),
          const SizedBox(width: 12),
          TextButton.icon(
            onPressed: started ? onReset : null,
            icon: const Icon(Icons.restart_alt_rounded),
            label: Text(strings.clock.reset),
          ),
        ],
      ),
    );
  }
}
