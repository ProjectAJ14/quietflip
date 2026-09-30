import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flip_clock/data/models/clock_settings.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';
import 'package:timekeeping/timekeeping.dart';

/// The settings content in the adaptive `SettingsShell`: Appearance, Clock,
/// Gestures, Timers, Sound & alerts, Keep awake, Shortcuts, About. Every
/// change is saved at once. No account section until sign-in exists.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    this.isWeb = kIsWeb,
    this.orientationSupported = false,
    this.desktop,
    this.onDone,
    this.onSkins,
  });

  final SettingsController settings;

  /// Shows the note that a closed browser tab cannot alert.
  final bool isWeb;

  /// Shows the Orientation control (phones and tablets only).
  final bool orientationSupported;

  /// Pointer density. Null: on desktop and web.
  final bool? desktop;

  /// Closes Settings (the Done button).
  final VoidCallback? onDone;

  /// Opens the Skins sheet (Appearance > Skin).
  final VoidCallback? onSkins;

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

  bool get _desktop =>
      widget.desktop ??
      (widget.isWeb ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: BlocBuilder<SettingsController, ClockSettings>(
        bloc: widget.settings,
        builder: (context, s) => SettingsShell(
          title: strings.clock.settings,
          doneLabel: widget.onDone == null ? null : strings.generic.done,
          onDone: widget.onDone,
          desktop: _desktop,
          categories: [
            _appearance(s),
            _clock(s),
            _gestures(s),
            _timers(),
            _sound(s),
            _awake(s),
            _shortcuts(),
            _about(context),
          ],
        ),
      ),
    ),
  );

  SettingsCategory _appearance(ClockSettings s) {
    final c = strings.clock;
    return SettingsCategory(
      icon: Icons.palette_outlined,
      label: c.settings_appearance,
      groups: [
        SettingsGroup(
          rows: [
            SettingsValueRow(
              label: c.settings_skin,
              value: widget.settings.skin.name,
              onTap: widget.onSkins,
            ),
            SettingsSegmentedRow<ClockTheme>(
              label: c.theme,
              options: [
                (ClockTheme.dark, c.theme_dark),
                (ClockTheme.light, c.theme_light),
                (ClockTheme.system, c.theme_system),
              ],
              selected: s.theme,
              onChanged: (v) => _update(s.copyWith(theme: v)),
            ),
            SettingsSegmentedRow<CardSize>(
              label: c.settings_card_size,
              options: [
                (CardSize.small, c.card_size_small),
                (CardSize.medium, c.card_size_medium),
                (CardSize.large, c.card_size_large),
              ],
              selected: s.cardSize,
              onChanged: (v) => _update(s.copyWith(cardSize: v)),
            ),
            SettingsSliderRow(
              label: c.digit_brightness,
              value: s.digitBrightness,
              min: ClockSettings.minBrightness,
              max: ClockSettings.maxBrightness,
              divisions: 8,
              valueLabel: c.percent(_percent(s.digitBrightness)),
              onChanged: (v) => _update(s.copyWith(digitBrightness: v)),
            ),
          ],
        ),
      ],
    );
  }

  SettingsCategory _clock(ClockSettings s) {
    final c = strings.clock;
    return SettingsCategory(
      icon: Icons.schedule_outlined,
      label: c.settings_clock,
      groups: [
        SettingsGroup(
          rows: [
            SettingsSwitchRow(
              label: c.use_24h,
              value: s.use24h,
              onChanged: (v) => _update(s.copyWith(use24h: v)),
            ),
            SettingsSwitchRow(
              label: c.show_seconds,
              value: s.showSeconds,
              onChanged: (v) => _update(s.copyWith(showSeconds: v)),
            ),
            SettingsSwitchRow(
              label: c.show_date,
              value: s.showDate,
              onChanged: (v) => _update(s.copyWith(showDate: v)),
            ),
            if (widget.orientationSupported)
              SettingsSegmentedRow<ClockOrientation>(
                label: c.orientation,
                options: [
                  (ClockOrientation.auto, c.orientation_auto),
                  (ClockOrientation.landscape, c.orientation_landscape),
                  (ClockOrientation.portrait, c.orientation_portrait),
                ],
                selected: s.orientation,
                onChanged: (v) => _update(s.copyWith(orientation: v)),
              ),
          ],
        ),
      ],
    );
  }

  SettingsCategory _gestures(ClockSettings s) {
    final c = strings.clock;
    return SettingsCategory(
      icon: Icons.swipe_outlined,
      label: c.settings_gestures,
      groups: [
        SettingsGroup(
          header: c.gesture_swipes,
          rows: [
            SettingsSwitchRow(
              label: c.gesture_brightness,
              value: s.gestureBrightness,
              onChanged: (v) => _update(s.copyWith(gestureBrightness: v)),
            ),
            SettingsSwitchRow(
              label: c.gesture_modes,
              value: s.gestureModes,
              onChanged: (v) => _update(s.copyWith(gestureModes: v)),
            ),
          ],
          footer: c.gesture_footer,
        ),
        SettingsGroup(
          header: c.gesture_controls,
          rows: [
            SettingsSwitchRow(
              label: c.gesture_tap,
              value: s.tapToggleControls,
              onChanged: (v) => _update(s.copyWith(tapToggleControls: v)),
            ),
            SettingsSegmentedRow<Duration>(
              label: c.gesture_idle,
              options: [
                for (final d in ClockSettings.controlsIdleChoices)
                  (
                    d,
                    d == Duration.zero
                        ? c.gesture_idle_never
                        : c.gesture_idle_seconds(d.inSeconds),
                  ),
              ],
              selected: s.controlsIdle,
              onChanged: (v) => _update(s.copyWith(controlsIdle: v)),
            ),
          ],
          footer: c.gesture_controls_footer,
        ),
      ],
    );
  }

  SettingsCategory _timers() {
    final c = strings.clock;
    return SettingsCategory(
      icon: Icons.timer_outlined,
      label: c.settings_timers,
      groups: [
        SettingsGroup(
          header: c.mode_pomodoro,
          rows: [
            SettingsValueRow(
              label: c.timers_pomodoro_focus,
              value: c.timers_minutes(PomodoroPhase.focus.duration.inMinutes),
            ),
            SettingsValueRow(
              label: c.timers_pomodoro_break,
              value: c.timers_minutes(PomodoroPhase.rest.duration.inMinutes),
            ),
          ],
        ),
      ],
    );
  }

  SettingsCategory _sound(ClockSettings s) {
    final c = strings.clock;
    return SettingsCategory(
      icon: Icons.volume_up_outlined,
      label: c.settings_sound,
      groups: [
        SettingsGroup(
          rows: [
            SettingsSwitchRow(
              label: c.flip_sound,
              value: s.flipSound,
              onChanged: (v) => _update(s.copyWith(flipSound: v)),
            ),
            SettingsSwitchRow(
              label: c.alert_sound,
              value: s.alertSound,
              onChanged: (v) => _update(s.copyWith(alertSound: v)),
            ),
            SettingsSwitchRow(
              label: c.system_notifications,
              subtitle: c.system_notifications_description,
              value: s.systemAlerts,
              onChanged: (v) => unawaited(_setSystemAlerts(v)),
            ),
            if (_denied) SettingsNoteRow(text: c.permission_denied),
            if (widget.isWeb) SettingsNoteRow(text: c.web_closed_tab_note),
          ],
          footer: c.sound_footer,
        ),
      ],
    );
  }

  SettingsCategory _awake(ClockSettings s) {
    final c = strings.clock;
    return SettingsCategory(
      icon: Icons.visibility_outlined,
      label: c.settings_awake,
      groups: [
        SettingsGroup(
          rows: [
            SettingsSwitchRow(
              label: c.keep_screen_awake,
              subtitle: c.keep_screen_awake_description,
              value: s.keepAwake,
              onChanged: (v) => _update(s.copyWith(keepAwake: v)),
            ),
            SettingsSwitchRow(
              label: c.subtle_movement,
              subtitle: c.subtle_movement_description,
              value: s.subtleMovement,
              onChanged: (v) => _update(s.copyWith(subtleMovement: v)),
            ),
          ],
          footer: c.full_screen_note,
        ),
      ],
    );
  }

  SettingsCategory _shortcuts() {
    final c = strings.clock;
    return SettingsCategory(
      icon: Icons.keyboard_outlined,
      label: c.settings_shortcuts,
      groups: [
        SettingsGroup(
          rows: [
            for (final (label, key) in [
              (c.key_start_pause, c.keycap_space),
              (c.key_change_mode, c.keycap_left_right),
              (c.key_brightness, c.keycap_up_down),
              (c.key_show_seconds, c.keycap_s),
              (c.key_dim, c.keycap_d),
              (c.key_lap, c.keycap_l),
              (c.key_full_screen, c.keycap_f),
              (c.key_hide_controls, c.keycap_esc),
            ])
              SettingsKeyRow(label: label, keycap: key),
          ],
        ),
      ],
    );
  }

  SettingsCategory _about(BuildContext context) {
    final c = strings.clock;
    return SettingsCategory(
      icon: Icons.info_outline_rounded,
      label: c.settings_about,
      groups: [
        SettingsGroup(
          rows: [
            SettingsValueRow(
              label: c.about_licenses,
              onTap: () => showLicensePage(context: context),
            ),
            SettingsValueRow(
              label: c.about_privacy,
              value: c.about_privacy_value,
            ),
          ],
        ),
      ],
    );
  }
}
