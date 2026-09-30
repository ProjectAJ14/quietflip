import 'dart:async';

import 'package:flip_clock/data/models/clock_settings.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';

/// Display, Sound & alerts and Keep screen awake, plus the keyboard
/// shortcut list. Every change is saved at once. No account section until
/// sign-in exists.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    this.isWeb = kIsWeb,
  });

  final SettingsController settings;

  /// Shows the note that a closed browser tab cannot alert.
  final bool isWeb;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _denied = false;

  void _update(ClockSettings next) => unawaited(widget.settings.update(next));

  static String _percent(double v) => (v * 100).round().toString();

  Future<void> _setSystemAlerts(bool on) async {
    final granted = await widget.settings.setSystemAlerts(on);
    if (mounted) setState(() => _denied = !granted);
  }

  @override
  Widget build(BuildContext context) {
    final c = strings.clock;
    return Scaffold(
      appBar: AppBar(title: Text(c.settings)),
      body: BlocBuilder<SettingsController, ClockSettings>(
        bloc: widget.settings,
        builder: (context, s) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _Section(c.display),
                ListTile(
                  title: Text(c.theme),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SegmentedButton<ClockTheme>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(
                            value: ClockTheme.black,
                            label: Text(c.theme_black),
                          ),
                          ButtonSegment(
                            value: ClockTheme.light,
                            label: Text(c.theme_light),
                          ),
                        ],
                        selected: {s.theme},
                        onSelectionChanged: (v) =>
                            _update(s.copyWith(theme: v.single)),
                      ),
                    ),
                  ),
                ),
                SwitchListTile(
                  title: Text(c.use_24h),
                  value: s.use24h,
                  onChanged: (v) => _update(s.copyWith(use24h: v)),
                ),
                SwitchListTile(
                  title: Text(c.show_seconds),
                  value: s.showSeconds,
                  onChanged: (v) => _update(s.copyWith(showSeconds: v)),
                ),
                ListTile(
                  title: Text(c.digit_brightness),
                  trailing: Text(c.percent(_percent(s.digitBrightness))),
                  // The slider itself is named for screen readers; the
                  // percentage beside the title is the visible value.
                  subtitle: MergeSemantics(
                    child: Semantics(
                      label: c.digit_brightness,
                      child: Slider(
                        value: s.digitBrightness,
                        min: ClockSettings.minBrightness,
                        max: ClockSettings.maxBrightness,
                        divisions: 8,
                        semanticFormatterCallback: (v) =>
                            c.percent(_percent(v)),
                        onChanged: (v) =>
                            _update(s.copyWith(digitBrightness: v)),
                      ),
                    ),
                  ),
                ),
                SwitchListTile(
                  title: Text(c.subtle_movement),
                  subtitle: Text(c.subtle_movement_description),
                  isThreeLine: true,
                  value: s.subtleMovement,
                  onChanged: (v) => _update(s.copyWith(subtleMovement: v)),
                ),
                SwitchListTile(
                  title: Text(c.show_date),
                  value: s.showDate,
                  onChanged: (v) => _update(s.copyWith(showDate: v)),
                ),
                _Section(c.sound_and_alerts),
                SwitchListTile(
                  title: Text(c.flip_sound),
                  value: s.flipSound,
                  onChanged: (v) => _update(s.copyWith(flipSound: v)),
                ),
                SwitchListTile(
                  title: Text(c.alert_sound),
                  value: s.alertSound,
                  onChanged: (v) => _update(s.copyWith(alertSound: v)),
                ),
                SwitchListTile(
                  title: Text(c.system_notifications),
                  subtitle: _Notes([
                    c.system_notifications_description,
                    if (_denied) c.permission_denied,
                    if (widget.isWeb) c.web_closed_tab_note,
                  ]),
                  isThreeLine: _denied || widget.isWeb,
                  value: s.systemAlerts,
                  onChanged: _setSystemAlerts,
                ),
                const Divider(height: 32),
                SwitchListTile(
                  title: Text(c.keep_screen_awake),
                  subtitle: Text(c.keep_screen_awake_description),
                  value: s.keepAwake,
                  onChanged: (v) => _update(s.copyWith(keepAwake: v)),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  subtitle: Text(c.full_screen_note),
                ),
                _Section(c.keyboard_shortcuts),
                for (final line in [
                  c.shortcut_full_screen,
                  c.shortcut_exit_full_screen,
                  c.shortcut_start_pause,
                  c.shortcut_modes,
                  c.shortcut_seconds,
                  c.shortcut_dim,
                ])
                  ListTile(dense: true, title: Text(line)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: theme.textTheme.titleSmall!.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _Notes extends StatelessWidget {
  const _Notes(this.lines);

  final List<String> lines;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final line in lines)
        Padding(padding: const EdgeInsets.only(top: 4), child: Text(line)),
    ],
  );
}
