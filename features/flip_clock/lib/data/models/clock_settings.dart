import 'package:design_system/design_system.dart';
import 'package:flip_clock/data/models/skin.dart';
import 'package:flutter/foundation.dart';

/// Theme the user picked in Settings.
enum ClockTheme { black, light }

/// The screen mode shown on launch (the last one used).
enum ClockMode { clock, timer, stopwatch }

/// Screen orientation lock (phones and tablets only).
enum ClockOrientation { auto, landscape, portrait }

/// Local display, sound and alert preferences.
class ClockSettings {
  const ClockSettings({
    this.theme = ClockTheme.black,
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
  });

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

    return ClockSettings(
      theme: pick(ClockTheme.values, 'theme', d.theme),
      use24h: flag('use24h', d.use24h),
      showSeconds: flag('showSeconds', d.showSeconds),
      flipSound: flag('flipSound', d.flipSound),
      alertSound: flag('alertSound', d.alertSound),
      systemAlerts: flag('systemAlerts', d.systemAlerts),
      keepAwake: flag('keepAwake', d.keepAwake),
      lastMode: pick(ClockMode.values, 'lastMode', d.lastMode),
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
  };

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
  }) => ClockSettings(
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
  );

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
      other.controlsIdle == controlsIdle;

  @override
  int get hashCode => Object.hash(
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
  );
}
