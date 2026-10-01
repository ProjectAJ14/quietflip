import 'package:design_system/design_system.dart';
import 'package:flip_clock/data/models/skin.dart';
import 'package:flutter/foundation.dart';
import 'package:timekeeping/timekeeping.dart';

/// The chrome theme picked in Settings: Mono Dark (the default, even when
/// the OS is light), Mono Light, or following the OS.
enum ClockTheme { dark, light, system }

/// The screen modes in panel order; the one shown on launch is the last
/// one used. Pomodoro also runs the plain timer presets.
enum ClockMode { pomodoro, clock, stopwatch }

/// What Start runs on an idle Pomodoro panel.
sealed class TimerPreset {
  const TimerPreset();
}

/// The 25 / 5 min focus and break cycle.
final class PomodoroCycle extends TimerPreset {
  const PomodoroCycle();

  @override
  bool operator ==(Object other) => other is PomodoroCycle;

  @override
  int get hashCode => (PomodoroCycle).hashCode;
}

/// A plain countdown of [duration], one of the timer presets.
final class Minutes extends TimerPreset {
  const Minutes(this.duration);

  final Duration duration;

  @override
  bool operator ==(Object other) =>
      other is Minutes && other.duration == duration;

  @override
  int get hashCode => duration.hashCode;
}

/// Screen orientation lock (phones and tablets only).
enum ClockOrientation { auto, landscape, portrait }

/// How much of the space the flip cards fill.
enum CardSize {
  small(0.6),
  medium(0.8),
  large(1);

  const CardSize(this.factor);

  /// Card height relative to the largest card that fits.
  final double factor;
}

/// Local display, sound and alert preferences.
class ClockSettings {
  const ClockSettings({
    this.theme = ClockTheme.dark,
    this.use24h = true,
    this.showSeconds = false,
    this.flipSound = false,
    this.alertSound = true,
    this.systemAlerts = false,
    this.keepAwake = false,
    this.lastMode = ClockMode.clock,
    this.digitBrightness = maxBrightness,
    this.subtleMovement = false,
    this.showDate = false,
    this.orientation = ClockOrientation.auto,
    this.skinId = 'mono',
    this.customSkins = const [],
    this.tapToggleControls = true,
    this.controlsIdle = defaultControlsIdle,
    this.gestureBrightness = true,
    this.gestureModes = true,
    this.cardSize = CardSize.large,
    this.timerPresets = defaultTimerPresets,
    this.defaultTimer = const PomodoroCycle(),
    this.corner = DesignShape.defaultCorner,
  });

  /// The presets a fresh install offers.
  static const List<Duration> defaultTimerPresets = [
    Duration(minutes: 5),
    Duration(minutes: 10),
    Duration(minutes: 15),
  ];

  /// Most presets the island tray fits.
  static const int maxTimerPresets = 6;

  /// [presets] as stored: valid for a countdown, no duplicates, ascending,
  /// at most [maxTimerPresets].
  static List<Duration> normalizePresets(Iterable<Duration> presets) =>
      List.unmodifiable(
        (presets.where(Countdown.isValid).toSet().toList()..sort()).take(
          maxTimerPresets,
        ),
      );

  /// [preset] if it is still offered by [presets], else the cycle.
  static TimerPreset _offered(TimerPreset preset, List<Duration> presets) =>
      switch (preset) {
        Minutes(:final duration) when !presets.contains(duration) =>
          const PomodoroCycle(),
        _ => preset,
      };

  /// Settings steps [corner] by this much.
  static const double cornerStep = 2;

  /// Dimmest and brightest [digitBrightness].
  static const double minBrightness = 0.2;
  static const double maxBrightness = 1;

  /// How long the controls stay before collapsing, by default.
  static const Duration defaultControlsIdle = DesignMotion.controlsIdle;

  /// The [controlsIdle] values Settings offers; [Duration.zero] means Never
  /// (the controls stay until hidden).
  static const List<Duration> controlsIdleChoices = [
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
    Duration.zero,
  ];

  /// The quick-dim step after [current]: 100% -> 50% -> 20% -> 100%.
  /// A slider value in between steps down to the next preset.
  static double nextDim(double current) => current > 0.5
      ? 0.5
      : current > minBrightness
      ? minBrightness
      : maxBrightness;

  /// Restores saved settings; any missing or mistyped field keeps its
  /// default, so corrupt storage never blocks launch.
  factory ClockSettings.fromJson(Map<String, Object?> json) {
    const d = ClockSettings();
    bool flag(String key, bool fallback) =>
        json[key] is bool ? json[key]! as bool : fallback;
    T pick<T extends Enum>(List<T> values, String key, T fallback) {
      final name = json[key];
      for (final value in values) {
        if (value.name == name) return value;
      }
      return fallback;
    }

    final presets = json['timerPresetsMs'] is List
        ? normalizePresets([
            for (final ms in json['timerPresetsMs']! as List)
              if (ms is int) Duration(milliseconds: ms),
          ])
        : d.timerPresets;
    return ClockSettings(
      // Earlier releases saved the dark theme as 'black'.
      theme: json['theme'] == 'black'
          ? ClockTheme.dark
          : pick(ClockTheme.values, 'theme', d.theme),
      use24h: flag('use24h', d.use24h),
      showSeconds: flag('showSeconds', d.showSeconds),
      flipSound: flag('flipSound', d.flipSound),
      alertSound: flag('alertSound', d.alertSound),
      systemAlerts: flag('systemAlerts', d.systemAlerts),
      keepAwake: flag('keepAwake', d.keepAwake),
      // The Timer panel merged into Pomodoro.
      lastMode: json['lastMode'] == 'timer'
          ? ClockMode.pomodoro
          : pick(ClockMode.values, 'lastMode', d.lastMode),
      digitBrightness: switch (json['digitBrightness']) {
        final num v when !v.isNaN =>
          v.clamp(minBrightness, maxBrightness).toDouble(),
        _ => d.digitBrightness,
      },
      subtleMovement: flag('subtleMovement', d.subtleMovement),
      showDate: flag('showDate', d.showDate),
      orientation: pick(ClockOrientation.values, 'orientation', d.orientation),
      skinId: json['skinId'] is String ? json['skinId']! as String : d.skinId,
      // A skin that cannot be read is dropped; the others survive.
      customSkins: json['customSkins'] is List
          ? [
              for (final raw in json['customSkins']! as List)
                ?Skin.fromJson(raw),
            ]
          : d.customSkins,
      tapToggleControls: flag('tapToggleControls', d.tapToggleControls),
      controlsIdle: switch (json['controlsIdleMs']) {
        final int ms
            when controlsIdleChoices.contains(Duration(milliseconds: ms)) =>
          Duration(milliseconds: ms),
        _ => d.controlsIdle,
      },
      gestureBrightness: flag('gestureBrightness', d.gestureBrightness),
      gestureModes: flag('gestureModes', d.gestureModes),
      cardSize: pick(CardSize.values, 'cardSize', d.cardSize),
      timerPresets: presets,
      defaultTimer: switch (json['defaultTimerMs']) {
        final int ms => _offered(Minutes(Duration(milliseconds: ms)), presets),
        _ => d.defaultTimer,
      },
      corner: switch (json['corner']) {
        final num v when !v.isNaN =>
          v.clamp(DesignShape.minCorner, DesignShape.maxCorner).toDouble(),
        _ => d.corner,
      },
    );
  }

  final ClockTheme theme;
  final bool use24h;
  final bool showSeconds;
  final bool flipSound;
  final bool alertSound;
  final bool systemAlerts;
  final bool keepAwake;
  final ClockMode lastMode;
  final ClockOrientation orientation;

  /// Opacity of the digits, [minBrightness]..[maxBrightness]; the background
  /// and controls are never dimmed.
  final double digitBrightness;

  /// In full screen, shift the display a few pixels each minute.
  final bool subtleMovement;

  /// Shows today's date under the clock digits.
  final bool showDate;

  /// The selected skin; an unknown id shows Mono.
  final String skinId;

  /// Skins the user made, first in the picker.
  final List<Skin> customSkins;

  /// A tap on the display shows or hides the controls.
  final bool tapToggleControls;

  /// Idle time before the controls collapse, one of [controlsIdleChoices];
  /// [Duration.zero] means never.
  final Duration controlsIdle;

  /// A vertical drag on the display (and the Up/Down keys) changes the
  /// brightness.
  final bool gestureBrightness;

  /// A horizontal swipe on the display switches between modes.
  final bool gestureModes;

  /// How large the flip cards are.
  final CardSize cardSize;

  /// The user's quick-start timers, as [normalizePresets] keeps them.
  final List<Duration> timerPresets;

  /// What Start runs on an idle Pomodoro panel: the cycle or one of
  /// [timerPresets].
  final TimerPreset defaultTimer;

  /// The one corner radius every shape in the app follows
  /// (`DesignShape.corner`), [DesignShape.minCorner] (square) to
  /// [DesignShape.maxCorner].
  final double corner;

  Map<String, Object?> toJson() => {
    'theme': theme.name,
    'use24h': use24h,
    'showSeconds': showSeconds,
    'flipSound': flipSound,
    'alertSound': alertSound,
    'systemAlerts': systemAlerts,
    'keepAwake': keepAwake,
    'lastMode': lastMode.name,
    'digitBrightness': digitBrightness,
    'subtleMovement': subtleMovement,
    'showDate': showDate,
    'orientation': orientation.name,
    'skinId': skinId,
    'customSkins': [for (final skin in customSkins) skin.toJson()],
    'tapToggleControls': tapToggleControls,
    'controlsIdleMs': controlsIdle.inMilliseconds,
    'gestureBrightness': gestureBrightness,
    'gestureModes': gestureModes,
    'cardSize': cardSize.name,
    'timerPresetsMs': [for (final p in timerPresets) p.inMilliseconds],
    'defaultTimerMs': switch (defaultTimer) {
      PomodoroCycle() => null,
      Minutes(:final duration) => duration.inMilliseconds,
    },
    'corner': corner,
  };

  /// A copy; new [timerPresets] are normalized, and a [defaultTimer] no
  /// longer among them falls back to the cycle.

  ClockSettings copyWith({
    ClockTheme? theme,
    bool? use24h,
    bool? showSeconds,
    bool? flipSound,
    bool? alertSound,
    bool? systemAlerts,
    bool? keepAwake,
    ClockMode? lastMode,
    double? digitBrightness,
    bool? subtleMovement,
    bool? showDate,
    ClockOrientation? orientation,
    String? skinId,
    List<Skin>? customSkins,
    bool? tapToggleControls,
    Duration? controlsIdle,
    bool? gestureBrightness,
    bool? gestureModes,
    CardSize? cardSize,
    List<Duration>? timerPresets,
    TimerPreset? defaultTimer,
    double? corner,
  }) {
    final presets = timerPresets == null
        ? this.timerPresets
        : normalizePresets(timerPresets);
    return ClockSettings(
      theme: theme ?? this.theme,
      use24h: use24h ?? this.use24h,
      showSeconds: showSeconds ?? this.showSeconds,
      flipSound: flipSound ?? this.flipSound,
      alertSound: alertSound ?? this.alertSound,
      systemAlerts: systemAlerts ?? this.systemAlerts,
      keepAwake: keepAwake ?? this.keepAwake,
      lastMode: lastMode ?? this.lastMode,
      digitBrightness: digitBrightness ?? this.digitBrightness,
      subtleMovement: subtleMovement ?? this.subtleMovement,
      showDate: showDate ?? this.showDate,
      orientation: orientation ?? this.orientation,
      skinId: skinId ?? this.skinId,
      customSkins: customSkins ?? this.customSkins,
      tapToggleControls: tapToggleControls ?? this.tapToggleControls,
      controlsIdle: controlsIdle ?? this.controlsIdle,
      gestureBrightness: gestureBrightness ?? this.gestureBrightness,
      gestureModes: gestureModes ?? this.gestureModes,
      cardSize: cardSize ?? this.cardSize,
      timerPresets: presets,
      defaultTimer: _offered(defaultTimer ?? this.defaultTimer, presets),
      corner: corner ?? this.corner,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ClockSettings &&
      other.theme == theme &&
      other.use24h == use24h &&
      other.showSeconds == showSeconds &&
      other.flipSound == flipSound &&
      other.alertSound == alertSound &&
      other.systemAlerts == systemAlerts &&
      other.keepAwake == keepAwake &&
      other.lastMode == lastMode &&
      other.digitBrightness == digitBrightness &&
      other.subtleMovement == subtleMovement &&
      other.showDate == showDate &&
      other.orientation == orientation &&
      other.skinId == skinId &&
      listEquals(other.customSkins, customSkins) &&
      other.tapToggleControls == tapToggleControls &&
      other.controlsIdle == controlsIdle &&
      other.gestureBrightness == gestureBrightness &&
      other.gestureModes == gestureModes &&
      other.cardSize == cardSize &&
      listEquals(other.timerPresets, timerPresets) &&
      other.defaultTimer == defaultTimer &&
      other.corner == corner;

  @override
  int get hashCode => Object.hashAll([
    theme,
    use24h,
    showSeconds,
    flipSound,
    alertSound,
    systemAlerts,
    keepAwake,
    lastMode,
    digitBrightness,
    subtleMovement,
    showDate,
    orientation,
    skinId,
    Object.hashAll(customSkins),
    tapToggleControls,
    controlsIdle,
    gestureBrightness,
    gestureModes,
    cardSize,
    Object.hashAll(timerPresets),
    defaultTimer,
    corner,
  ]);
}
