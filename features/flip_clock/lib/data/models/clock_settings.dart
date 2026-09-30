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
    this.secondsHintSeen = false,
    this.digitBrightness = maxBrightness,
    this.subtleMovement = false,
    this.showDate = false,
    this.orientation = ClockOrientation.auto,
  });

  /// Dimmest and brightest [digitBrightness].
  static const double minBrightness = 0.2;
  static const double maxBrightness = 1;

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
      secondsHintSeen: flag('secondsHintSeen', d.secondsHintSeen),
      digitBrightness: switch (json['digitBrightness']) {
        final num v when !v.isNaN =>
          v.clamp(minBrightness, maxBrightness).toDouble(),
        _ => d.digitBrightness,
      },
      subtleMovement: flag('subtleMovement', d.subtleMovement),
      showDate: flag('showDate', d.showDate),
      orientation: pick(ClockOrientation.values, 'orientation', d.orientation),
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

  /// The one-time "tap the seconds button" hint was dismissed or acted on.
  final bool secondsHintSeen;

  /// Opacity of the digits, [minBrightness]..[maxBrightness]; the background
  /// and controls are never dimmed.
  final double digitBrightness;

  /// In full screen, shift the display a few pixels each minute.
  final bool subtleMovement;

  /// Shows today's date under the clock digits.
  final bool showDate;

  Map<String, Object?> toJson() => {
    'theme': theme.name,
    'use24h': use24h,
    'showSeconds': showSeconds,
    'flipSound': flipSound,
    'alertSound': alertSound,
    'systemAlerts': systemAlerts,
    'keepAwake': keepAwake,
    'lastMode': lastMode.name,
    'secondsHintSeen': secondsHintSeen,
    'digitBrightness': digitBrightness,
    'subtleMovement': subtleMovement,
    'showDate': showDate,
    'orientation': orientation.name,
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
    bool? secondsHintSeen,
    double? digitBrightness,
    bool? subtleMovement,
    bool? showDate,
    ClockOrientation? orientation,
  }) => ClockSettings(
    theme: theme ?? this.theme,
    use24h: use24h ?? this.use24h,
    showSeconds: showSeconds ?? this.showSeconds,
    flipSound: flipSound ?? this.flipSound,
    alertSound: alertSound ?? this.alertSound,
    systemAlerts: systemAlerts ?? this.systemAlerts,
    keepAwake: keepAwake ?? this.keepAwake,
    lastMode: lastMode ?? this.lastMode,
    secondsHintSeen: secondsHintSeen ?? this.secondsHintSeen,
    digitBrightness: digitBrightness ?? this.digitBrightness,
    subtleMovement: subtleMovement ?? this.subtleMovement,
    showDate: showDate ?? this.showDate,
    orientation: orientation ?? this.orientation,
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
      other.secondsHintSeen == secondsHintSeen &&
      other.digitBrightness == digitBrightness &&
      other.subtleMovement == subtleMovement &&
      other.showDate == showDate &&
      other.orientation == orientation;

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
    secondsHintSeen,
    digitBrightness,
    subtleMovement,
    showDate,
    orientation,
  );
}
