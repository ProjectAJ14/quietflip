import 'package:flip_clock/data/models/skin.dart';
import 'package:localization/localization.dart';

/// What a `FlipDisplay` shows: its cards, the small corner text and AM/PM.
typedef DisplayValue = ({List<String> cards, String? badge, String? meridiem});

String _two(int n) => n.toString().padLeft(2, '0');

/// How a screen reader names a preset: `5 minute timer`, `90 second
/// timer` under a minute, `1 minute 30 second timer`.
String presetSpoken(Duration preset) {
  final minutes = preset.inMinutes;
  final seconds = preset.inSeconds.remainder(60);
  final c = strings.clock;
  if (seconds == 0) return c.preset_spoken_minutes(minutes);
  if (minutes == 0) return c.preset_spoken_seconds(seconds);
  return c.preset_spoken_both(minutes, seconds);
}

/// A timer preset's short name: `5m` for whole minutes, else `1:30`.
String presetLabel(Duration preset) {
  final seconds = preset.inSeconds.remainder(60);
  return seconds == 0
      ? strings.clock.preset_minutes(preset.inMinutes)
      : strings.clock.preset_minutes_seconds(preset.inMinutes, _two(seconds));
}

/// The clock at [t]: hour and minute cards, seconds in [skin]'s style when
/// [showSeconds] (their own cards when the skin has none, so Show seconds
/// always shows them), AM/PM in 12-hour time. The hour is two digits in
/// both (`09`), so its card is never half empty.
DisplayValue clockValue(
  DateTime t, {
  required bool use24h,
  required bool showSeconds,
  required Skin skin,
}) {
  final hour12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final seconds = _two(t.second);
  final style = !showSeconds
      ? SkinSeconds.off
      : skin.seconds == SkinSeconds.badge
      ? SkinSeconds.badge
      : SkinSeconds.cards;
  return (
    cards: [
      _two(use24h ? t.hour : hour12),
      _two(t.minute),
      if (style == SkinSeconds.cards) seconds,
    ],
    badge: style == SkinSeconds.badge ? seconds : null,
    meridiem: use24h ? null : (t.hour < 12 ? 'AM' : 'PM'),
  );
}

/// A duration as mm ss cards, with an hours card from one hour up.
/// Negative input reads as zero.
DisplayValue durationValue(Duration d, {String? badge}) {
  final v = d.isNegative ? Duration.zero : d;
  return (
    cards: [
      if (v.inHours > 0) _two(v.inHours),
      _two(v.inMinutes % 60),
      _two(v.inSeconds % 60),
    ],
    badge: badge,
    meridiem: null,
  );
}

/// The stopwatch: [durationValue] with tenths as the corner text.
DisplayValue stopwatchValue(Duration elapsed) => durationValue(
  elapsed,
  badge: '${(elapsed.isNegative ? 0 : elapsed.inMilliseconds) % 1000 ~/ 100}',
);
