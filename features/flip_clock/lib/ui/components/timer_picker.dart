import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localization/localization.dart';

/// Asks for a new timer preset's length in minutes and seconds; null when
/// cancelled. Only a length from 0:01 to 99:59 can be confirmed.
Future<Duration?> showTimerPicker(BuildContext context) =>
    showDialog<Duration>(context: context, builder: (_) => const TimerPicker());

/// The dialog behind [showTimerPicker].
class TimerPicker extends StatefulWidget {
  const TimerPicker({super.key});

  @override
  State<TimerPicker> createState() => _TimerPickerState();
}

class _TimerPickerState extends State<TimerPicker> {
  final _minutes = TextEditingController(text: '5');
  final _seconds = TextEditingController(text: '0');

  /// The entry, or null when it is zero or has 60 or more seconds.
  Duration? get _value {
    final m = int.tryParse(_minutes.text) ?? 0;
    final s = int.tryParse(_seconds.text) ?? 0;
    final d = Duration(minutes: m, seconds: s);
    return s < 60 && d > Duration.zero ? d : null;
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
      content: Row(
        spacing: DesignSpace.s4,
        children: [
          field(_minutes, c.timers_picker_minutes),
          field(_seconds, c.timers_picker_seconds),
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
