import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localization/localization.dart';

/// Asks for a new timer preset's length in minutes and seconds; null when
/// cancelled. Only a length from 0:01 to 99:59 that is not one of
/// [existing] can be confirmed.
Future<Duration?> showTimerPicker(
  BuildContext context, {
  required List<Duration> existing,
}) => showDialog<Duration>(
  context: context,
  builder: (_) => TimerPicker(existing: existing),
);

/// The dialog behind [showTimerPicker].
class TimerPicker extends StatefulWidget {
  const TimerPicker({super.key, required this.existing});

  /// The presets already saved; picking one again is refused.
  final List<Duration> existing;

  @override
  State<TimerPicker> createState() => _TimerPickerState();
}

class _TimerPickerState extends State<TimerPicker> {
  final _minutes = TextEditingController(text: '5');
  final _seconds = TextEditingController(text: '0');

  Duration get _entry => Duration(
    minutes: int.tryParse(_minutes.text) ?? 0,
    seconds: int.tryParse(_seconds.text) ?? 0,
  );

  bool get _duplicate => widget.existing.contains(_entry);

  /// The entry, or null when it is zero, has 60 or more seconds, or is
  /// already a preset.
  Duration? get _value {
    final d = _entry;
    final seconds = int.tryParse(_seconds.text) ?? 0;
    return seconds < 60 && d > Duration.zero && !_duplicate ? d : null;
  }

  @override
  void dispose() {
    _minutes.dispose();
    _seconds.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = strings.clock;
    final value = _value;
    Widget field(TextEditingController controller, String label) => Expanded(
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
        ],
        decoration: InputDecoration(labelText: label),
        onChanged: (_) => setState(() {}),
      ),
    );
    return AlertDialog(
      title: Text(c.timers_add),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DesignSpace.s3,
        children: [
          Row(
            spacing: DesignSpace.s4,
            children: [
              field(_minutes, c.timers_picker_minutes),
              field(_seconds, c.timers_picker_seconds),
            ],
          ),
          // Says why OK is off, and is read out when it appears.
          if (_duplicate)
            Semantics(
              liveRegion: true,
              child: Text(
                c.timers_duplicate,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.generic.cancel),
        ),
        TextButton(
          onPressed: value == null ? null : () => Navigator.pop(context, value),
          child: Text(strings.generic.ok),
        ),
      ],
    );
  }
}
