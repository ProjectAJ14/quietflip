/// Theme the user picked in Settings.
enum ClockTheme { black, light }

/// The screen mode shown on launch (the last one used).
enum ClockMode { clock, timer, stopwatch }

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
  });

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

  Map<String, Object?> toJson() => {
    'theme': theme.name,
    'use24h': use24h,
    'showSeconds': showSeconds,
    'flipSound': flipSound,
    'alertSound': alertSound,
    'systemAlerts': systemAlerts,
    'keepAwake': keepAwake,
    'lastMode': lastMode.name,
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
  }) => ClockSettings(
    theme: theme ?? this.theme,
    use24h: use24h ?? this.use24h,
    showSeconds: showSeconds ?? this.showSeconds,
    flipSound: flipSound ?? this.flipSound,
    alertSound: alertSound ?? this.alertSound,
    systemAlerts: systemAlerts ?? this.systemAlerts,
    keepAwake: keepAwake ?? this.keepAwake,
    lastMode: lastMode ?? this.lastMode,
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
      other.lastMode == lastMode;

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
  );
}
