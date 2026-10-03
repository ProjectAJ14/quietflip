String _two(int n) => n.toString().padLeft(2, '0');

Duration _nonNegative(Duration d) => d.isNegative ? Duration.zero : d;

/// The 12-hour markers in the display language: `AM` / `PM` in English,
/// `午前` / `午後` in Japanese, `a. m.` / `p. m.` in Spanish.
typedef Meridiem = ({String am, String pm});

/// [meridiem]'s marker for [t]: [Meridiem.am] before noon.
String meridiemFor(DateTime t, Meridiem meridiem) =>
    t.hour < 12 ? meridiem.am : meridiem.pm;

/// Clock face text: "09:41", "09:41:07" (24h) or "9:41 AM" (12h, with
/// [meridiem]'s marker; "12:05 AM" at midnight, "12:30 PM" at noon).
String formatClock(
  DateTime t, {
  required bool use24h,
  required bool showSeconds,
  required Meridiem meridiem,
}) {
  final seconds = showSeconds ? ':${_two(t.second)}' : '';
  if (use24h) return '${_two(t.hour)}:${_two(t.minute)}$seconds';
  final hour12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return '$hour12:${_two(t.minute)}$seconds ${meridiemFor(t, meridiem)}';
}

/// "HH:MM:SS" for a countdown; callers pass [ceilToSecond] of the remaining
/// time so 0.4s left still reads 00:00:01. Negative input reads as zero.
String formatHms(Duration d) {
  final v = _nonNegative(d);
  return '${_two(v.inHours)}:${_two(v.inMinutes % 60)}:'
      '${_two(v.inSeconds % 60)}';
}

/// Rounds [d] up to the next whole second; non-positive input gives zero.
Duration ceilToSecond(Duration d) {
  final us = d.inMicroseconds;
  if (us <= 0) return Duration.zero;
  const perSecond = Duration.microsecondsPerSecond;
  return Duration(seconds: (us + perSecond - 1) ~/ perSecond);
}

/// Stopwatch text "H:MM:SS.t" (tenths truncated; hours unbounded).
/// Negative input reads as zero.
String formatStopwatch(Duration d) {
  final v = _nonNegative(d);
  final tenths = v.inMilliseconds % 1000 ~/ 100;
  return '${v.inHours}:${_two(v.inMinutes % 60)}:'
      '${_two(v.inSeconds % 60)}.$tenths';
}
