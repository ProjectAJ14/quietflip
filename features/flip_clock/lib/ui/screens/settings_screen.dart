import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:device_services/device_services.dart';
import 'package:flip_clock/data/models/clock_settings.dart';
import 'package:flip_clock/data/models/skin.dart';
import 'package:flip_clock/data/skins.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flip_clock/ui/components/display_value.dart';
import 'package:flip_clock/ui/components/flip_display.dart';
import 'package:flip_clock/ui/components/skin_picker.dart';
import 'package:flip_clock/ui/components/sound_wave.dart';
import 'package:flip_clock/ui/components/timer_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
    required this.sound,
    this.isWeb = kIsWeb,
    this.orientationSupported = false,
    this.desktop,
    this.onDone,
    this.onSkins,
    this.onCustomize,
    this.openTimers = false,
    this.now = DateTime.now,
  });

  final SettingsController settings;

  /// Plays the previews in Sound & alerts.
  final SoundPlayer sound;

  /// Shows the note that a closed browser tab cannot alert.
  final bool isWeb;

  /// Shows the Orientation control (phones and tablets only).
  final bool orientationSupported;

  /// Pointer density. Null: on desktop and web.
  final bool? desktop;

  /// Closes Settings (the Done button).
  final VoidCallback? onDone;

  /// Opens the Skins sheet (Appearance > Skins > View all).
  final VoidCallback? onSkins;

  /// Opens the customizer on the selected skin (its tile's Customize).
  final VoidCallback? onCustomize;

  /// Opens straight on the Timers category (the island's tune icon).
  final bool openTimers;

  /// The time the skin thumbnails show.
  final DateTime Function() now;

  /// Skin thumbnails in Appearance before "View all".
  static const int skinStrip = 5;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _denied = false;

  // One sound preview at a time: the sound, when it started, its timers,
  // and whether an alarm it started may still be looping.
  Enum? _previewing;
  DateTime? _previewSince;
  final List<Timer> _previewTimers = [];
  bool _previewAlarm = false;

  @override
  void dispose() {
    _stopPreview();
    super.dispose();
  }

  /// Cancels the preview. Stops the alarm only if the preview started it
  /// and it is still running, so a real alarm behind Settings keeps ringing.
  void _stopPreview() {
    for (final timer in _previewTimers) {
      timer.cancel();
    }
    _previewTimers.clear();
    if (_previewAlarm) {
      _previewAlarm = false;
      unawaited(widget.sound.stopAlarm());
    }
  }

  void _startPreview(Enum sound, Duration length) {
    final tail = Duration(milliseconds: (SoundWave.tail * 1000).round());
    _previewTimers.add(
      Timer(length + tail, () {
        if (mounted) setState(() => _previewing = _previewSince = null);
      }),
    );
    setState(() {
      _previewing = sound;
      _previewSince = DateTime.now();
    });
  }

  /// Selects [tick] (turning Tick sound on) and plays it three times, a
  /// second apart, the way the clock ticks.
  void _pickTick(ClockSettings s, TickSound tick) {
    _update(s.copyWith(tickSound: tick, flipSound: true));
    _stopPreview();
    unawaited(widget.sound.playTick(tick));
    for (final second in [1, 2]) {
      _previewTimers.add(
        Timer(
          Duration(seconds: second),
          () => unawaited(widget.sound.playTick(tick)),
        ),
      );
    }
    _startPreview(tick, SoundWave.tickPreview);
  }

  /// Selects [alarm] (turning Alarm sound on) and plays two loops of it.
  void _pickAlarm(ClockSettings s, AlarmSound alarm) {
    _update(s.copyWith(alarmSound: alarm, alertSound: true));
    _stopPreview();
    unawaited(widget.sound.playAlarm(alarm));
    _previewAlarm = true;
    final length = SoundWave.alarmPreview(alarm);
    _previewTimers.add(
      Timer(length, () {
        _previewAlarm = false;
        unawaited(widget.sound.stopAlarm());
      }),
    );
    _startPreview(alarm, length);
  }

  DateTime? _since(Enum sound) => _previewing == sound ? _previewSince : null;

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
        builder: (context, s) {
          final timers = _timers(s);
          final categories = [
            _appearance(s),
            _clock(s),
            _gestures(s),
            timers,
            _sound(s),
            _awake(s),
            _shortcuts(),
            _about(context),
          ];
          return SettingsShell(
            title: strings.clock.settings,
            doneLabel: widget.onDone == null ? null : strings.generic.done,
            onDone: widget.onDone,
            desktop: _desktop,
            initialCategory: widget.openTimers ? categories.indexOf(timers) : 0,
            openInitialCategory: widget.openTimers,
            categories: categories,
          );
        },
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
          header: c.skins_title,
          rows: [
            _SkinStrip(
              skins: _strip(s),
              selectedId: widget.settings.skin.id,
              now: widget.now(),
              use24h: s.use24h,
              onSelect: (skin) =>
                  unawaited(widget.settings.selectSkin(skin.id)),
              onCustomize: widget.onCustomize,
            ),
            SettingsValueRow(label: c.skins_view_all, onTap: widget.onSkins),
          ],
        ),
        SettingsGroup(
          rows: [
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
        SettingsGroup(
          header: c.settings_corners,
          rows: [
            _CornerSample(skin: widget.settings.skin),
            SettingsSliderRow(
              label: c.settings_corners,
              value: s.corner,
              min: DesignShape.minCorner,
              max: DesignShape.maxCorner,
              divisions:
                  (DesignShape.maxCorner - DesignShape.minCorner) ~/
                  ClockSettings.cornerStep,
              valueLabel: c.corners_value('${s.corner.round()}'),
              minLabel: c.corners_square,
              maxLabel: c.corners_round,
              onChanged: (v) => _update(s.copyWith(corner: v)),
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

  /// The first [SettingsScreen.skinStrip] skins (yours first, as in the
  /// picker), always including the selected one.
  List<Skin> _strip(ClockSettings s) {
    final all = [...s.customSkins, ...Skins.builtIn()];
    final first = all.take(SettingsScreen.skinStrip).toList();
    final selected = widget.settings.skin;
    if (first.any((skin) => skin.id == selected.id)) return first;
    return [selected, ...first.take(SettingsScreen.skinStrip - 1)];
  }

  Future<void> _addPreset() async {
    final picked = await showTimerPicker(
      context,
      existing: widget.settings.state.timerPresets,
    );
    if (picked == null || !mounted) return;
    // Settings may have changed while the dialog was open.
    final now = widget.settings.state;
    _update(now.copyWith(timerPresets: [...now.timerPresets, picked]));
  }

  SettingsCategory _timers(ClockSettings s) {
    final c = strings.clock;
    final full = s.timerPresets.length >= ClockSettings.maxTimerPresets;
    return SettingsCategory(
      icon: Icons.timer_outlined,
      label: c.settings_timers,
      groups: [
        SettingsGroup(
          header: c.timers_default,
          rows: [
            SettingsSegmentedRow<TimerPreset>(
              label: c.timers_start_runs,
              options: [
                (const PomodoroCycle(), c.preset_pomodoro),
                for (final p in s.timerPresets) (Minutes(p), presetLabel(p)),
              ],
              selected: s.defaultTimer,
              onChanged: (v) => _update(s.copyWith(defaultTimer: v)),
            ),
          ],
        ),
        SettingsGroup(
          header: c.timers_presets,
          footer: full ? c.timers_limit_footer : null,
          rows: [
            for (final p in s.timerPresets)
              SettingsValueRow(
                label: presetLabel(p),
                semanticsLabel: presetSpoken(p),
                trailing: IconButton(
                  tooltip: c.timers_delete(presetSpoken(p)),
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () => _update(
                    s.copyWith(
                      timerPresets: [
                        for (final q in s.timerPresets)
                          if (q != p) q,
                      ],
                    ),
                  ),
                ),
              ),
            SettingsValueRow(
              label: c.timers_add,
              onTap: full ? null : () => unawaited(_addPreset()),
            ),
          ],
        ),
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
    final ink = DesignColors.of(context).ink;
    return SettingsCategory(
      icon: Icons.volume_up_outlined,
      label: c.settings_sound,
      groups: [
        SettingsGroup(
          header: c.sound_tick_group,
          hint: c.sound_tick_hint,
          rows: [
            SettingsSwitchRow(
              label: c.tick_sound,
              subtitle: c.tick_sound_description,
              value: s.flipSound,
              onChanged: (v) => _update(s.copyWith(flipSound: v)),
            ),
            _SoundTiles(
              enabled: s.flipSound,
              tiles: [
                for (final tick in TickSound.values)
                  _SoundTile(
                    text: _tickText(tick),
                    selected: tick == s.tickSound,
                    playing: _previewing == tick,
                    onTap: () => _pickTick(s, tick),
                    wave: SoundWave.tick(
                      tick,
                      playing: _since(tick),
                      color: ink,
                    ),
                  ),
              ],
            ),
          ],
        ),
        SettingsGroup(
          header: c.sound_alarm_group,
          hint: c.sound_alarm_hint,
          rows: [
            SettingsSwitchRow(
              label: c.alarm_sound,
              subtitle: c.alarm_sound_description,
              value: s.alertSound,
              onChanged: (v) => _update(s.copyWith(alertSound: v)),
            ),
            _SoundTiles(
              enabled: s.alertSound,
              tiles: [
                for (final alarm in AlarmSound.values)
                  _SoundTile(
                    text: _alarmText(alarm),
                    selected: alarm == s.alarmSound,
                    playing: _previewing == alarm,
                    onTap: () => _pickAlarm(s, alarm),
                    wave: SoundWave.alarm(
                      alarm,
                      playing: _since(alarm),
                      color: ink,
                    ),
                  ),
              ],
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

  /// A tick's name and mood word.
  static (String, String) _tickText(TickSound tick) {
    final c = strings.clock;
    return switch (tick) {
      TickSound.classic => (c.tick_classic, c.tick_classic_mood),
      TickSound.splitFlap => (c.tick_split_flap, c.tick_split_flap_mood),
      TickSound.clockwork => (c.tick_clockwork, c.tick_clockwork_mood),
      TickSound.woodblock => (c.tick_woodblock, c.tick_woodblock_mood),
      TickSound.digital => (c.tick_digital, c.tick_digital_mood),
    };
  }

  /// An alarm's name and mood word.
  static (String, String) _alarmText(AlarmSound alarm) {
    final c = strings.clock;
    return switch (alarm) {
      AlarmSound.chime => (c.alarm_chime, c.alarm_chime_mood),
      AlarmSound.bell => (c.alarm_bell, c.alarm_bell_mood),
      AlarmSound.beeps => (c.alarm_beeps, c.alarm_beeps_mood),
      AlarmSound.rising => (c.alarm_rising, c.alarm_rising_mood),
      AlarmSound.ring => (c.alarm_ring, c.alarm_ring_mood),
    };
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
              if (widget.orientationSupported) (c.key_rotation, c.keycap_r),
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

/// A row of skin thumbnails that scrolls sideways; tapping one applies it.
/// A button, a chip and a mini flip card in the app's current corner, so
/// the Corners slider shows its effect as it moves. Look only: not
/// tappable, not announced.
class _CornerSample extends StatelessWidget {
  const _CornerSample({required this.skin});

  final Skin skin;

  /// Size of the mini flip card.
  static const double card = 48;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.all(DesignSpace.s4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: DesignSpace.s4,
          children: [
            FilledButton(
              onPressed: () {},
              child: Text(strings.clock.action_start),
            ),
            Chip(label: Text(presetLabel(const Duration(minutes: 5)))),
            SizedBox.square(
              dimension: card,
              child: FlipDisplay(
                cards: const ['12'],
                skin: skin,
                semanticsLabel: '',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SkinStrip extends StatelessWidget {
  const _SkinStrip({
    required this.skins,
    required this.selectedId,
    required this.now,
    required this.use24h,
    required this.onSelect,
    required this.onCustomize,
  });

  final List<Skin> skins;
  final String selectedId;
  final DateTime now;
  final bool use24h;
  final ValueChanged<Skin> onSelect;
  final VoidCallback? onCustomize;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    // Room for the selected tile's ring.
    padding: const EdgeInsets.all(DesignSpace.s3),
    child: Row(
      spacing: DesignSpace.s3,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final skin in skins)
          SizedBox(
            width: SkinPicker.minTileWidth,
            child: SkinTile(
              skin: skin,
              selected: skin.id == selectedId,
              now: now,
              use24h: use24h,
              onTap: () => onSelect(skin),
              onCustomize: onCustomize,
            ),
          ),
      ],
    ),
  );
}

/// One kind's sound tiles: five across when each gets
/// [_SoundTiles.minFiveWidth], else three (3 + 2 on a phone). Dimmed while
/// the kind's switch is off, still tappable (a tap turns it back on).
class _SoundTiles extends StatelessWidget {
  const _SoundTiles({required this.enabled, required this.tiles});

  final bool enabled;
  final List<_SoundTile> tiles;

  static const double minFiveWidth = 80;
  static const double dimmed = 0.45;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(DesignSpace.s3),
    child: LayoutBuilder(
      builder: (context, constraints) {
        double width(int columns) =>
            (constraints.maxWidth - (columns - 1) * DesignSpace.s3) / columns;
        final tile = width(5) >= minFiveWidth ? width(5) : width(3);
        return Opacity(
          opacity: enabled ? 1 : dimmed,
          child: Semantics(
            role: SemanticsRole.radioGroup,
            child: Wrap(
              spacing: DesignSpace.s3,
              runSpacing: DesignSpace.s3,
              children: [
                for (final t in tiles)
                  SizedBox(width: tile.floorToDouble(), child: t),
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// A square wave over the sound's name and mood word; a radio ("Woodblock,
/// hollow knock") with the skin tiles' ring and check when selected.
class _SoundTile extends StatelessWidget {
  const _SoundTile({
    required this.text,
    required this.selected,
    required this.playing,
    required this.onTap,
    required this.wave,
  });

  final (String, String) text;
  final bool selected;
  final bool playing;
  final VoidCallback onTap;
  final SoundWave wave;

  @override
  Widget build(BuildContext context) {
    final colors = DesignColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final corner = DesignShape.circular(DesignShape.of(context).sm);
    final (name, mood) = text;
    return Semantics(
      container: true,
      inMutuallyExclusiveGroup: true,
      checked: selected,
      label: '$name, $mood',
      child: InkWell(
        onTap: onTap,
        borderRadius: corner,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaceRaised,
                  borderRadius: corner,
                  boxShadow: selectionRing(colors, selected: selected),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(borderRadius: corner, child: wave),
                    ),
                    if (selected)
                      const Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.all(DesignSpace.s1),
                          child: SelectionCheck(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DesignSpace.s2),
            ExcludeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.ink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    mood,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      color: playing ? colors.ink : colors.inkSubtle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
