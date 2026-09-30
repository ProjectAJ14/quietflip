import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localization/localization.dart';
import 'package:timekeeping/timekeeping.dart';

/// Hours / minutes / seconds entry (up to 99:59:59) with a Start button
/// that stays disabled while the entry is zero or out of range.
class TimerInput extends StatefulWidget {
  const TimerInput({
    super.key,
    required this.initial,
    required this.onStart,
    this.onChanged,
  });

  final Duration initial;
  final ValueChanged<Duration> onStart;

  /// Called on every edit: the entered duration, or null while it is
  /// zero or out of range.
  final ValueChanged<Duration?>? onChanged;

  @override
  State<TimerInput> createState() => _TimerInputState();
}

class _TimerInputState extends State<TimerInput> {
  late final List<TextEditingController> _fields = [
    widget.initial.inHours,
    widget.initial.inMinutes.remainder(60),
    widget.initial.inSeconds.remainder(60),
  ].map((v) => TextEditingController(text: _two(v))).toList();

  static String _two(int v) => v.toString().padLeft(2, '0');

  /// The entered duration, or null when out of range or zero.
  Duration? get _value {
    final [h, m, s] = [for (final f in _fields) int.tryParse(f.text) ?? 0];
    final d = Duration(hours: h, minutes: m, seconds: s);
    return m < 60 && s < 60 && Countdown.isValid(d) ? d : null;
  }

  void _changed() {
    setState(() {});
    widget.onChanged?.call(_value);
  }

  void _start() {
    final value = _value;
    if (value != null) widget.onStart(value);
  }

  @override
  void dispose() {
    for (final f in _fields) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labels = [
      strings.clock.hours,
      strings.clock.minutes,
      strings.clock.seconds,
    ];
    final value = _value;
    // Only the digits scale down on narrow screens; the Start button keeps
    // its full tap target, and short windows scroll instead.
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 16,
                      ),
                      child: Text(
                        ':',
                        style: theme.textTheme.displaySmall!.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: 72,
                    child: TextField(
                      controller: _fields[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      textInputAction: i < 2
                          ? TextInputAction.next
                          : TextInputAction.done,
                      style: theme.textTheme.displaySmall,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      decoration: InputDecoration(labelText: labels[i]),
                      onTap: () => _fields[i].selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: _fields[i].text.length,
                      ),
                      onChanged: (_) => _changed(),
                      onSubmitted: (_) => _start(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 24,
            child: value == null
                ? Text(
                    strings.clock.invalid_duration,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: value == null ? null : _start,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(strings.clock.start),
          ),
        ],
      ),
    );
  }
}
