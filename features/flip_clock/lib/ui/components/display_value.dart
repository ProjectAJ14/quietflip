import 'package:flip_clock/data/models/skin.dart';

/// What a `FlipDisplay` shows: its cards, the small corner text and AM/PM.
typedef DisplayValue = ({List<String> cards, String? badge, String? meridiem});

String _two(int n) => n.toString().padLeft(2, '0');

/// The clock at [t]: hour and minute cards, seconds in [skin]'s style when
/// [showSeconds] (their own cards when the skin has none, so Show seconds
/// always shows them), AM/PM in 12-hour time.
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
      use24h ? _two(t.hour) : '$hour12',
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
