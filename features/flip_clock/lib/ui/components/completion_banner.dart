import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

/// "Time's up" with a Dismiss button, announced to screen readers.
class CompletionBanner extends StatelessWidget {
  const CompletionBanner({super.key, required this.onDismiss, this.action});

  final VoidCallback onDismiss;

  /// Shown before Dismiss (start the next pomodoro phase); it should take
  /// the focus itself, so Dismiss only autofocuses without one.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Semantics(
        liveRegion: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.alarm_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  strings.clock.times_up,
                  style: theme.textTheme.titleLarge!.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 24),
                if (action case final a?) ...[a, const SizedBox(width: 12)],
                FilledButton(
                  autofocus: action == null,
                  onPressed: onDismiss,
                  child: Text(strings.clock.dismiss),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
