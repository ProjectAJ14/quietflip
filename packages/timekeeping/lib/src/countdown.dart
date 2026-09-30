/// Lifecycle of a [Countdown].
enum CountdownStatus { idle, running, paused, finished }

/// Countdown state machine whose remaining time is derived from the wall
/// clock (`endsAt`), never from counting ticks.
///
/// Invalid transitions are no-ops so the UI can call them from any state.
class Countdown {
  /// [now] is the wall clock; defaults to [DateTime.now].
  Countdown({DateTime Function()? now}) : _now = now ?? DateTime.now;

  /// Longest accepted duration: 99:59:59.
  static const Duration max = Duration(hours: 99, minutes: 59, seconds: 59);

  /// Duration of a fresh (or restored-from-corrupt) countdown.
  static const Duration defaultDuration = Duration(minutes: 5);

  final DateTime Function() _now;
  Duration _duration = defaultDuration;
  CountdownStatus _status = CountdownStatus.idle;
  DateTime? _endsAt;
  Duration _pausedRemaining = Duration.zero;

  /// The configured duration.
  Duration get duration => _duration;

  /// Current lifecycle state.
  CountdownStatus get status => _status;

  /// Wall-clock end while running; null otherwise.
  DateTime? get endsAt => _endsAt;

  /// True for 1 second through [max] inclusive.
  static bool isValid(Duration d) =>
      d >= const Duration(seconds: 1) && d <= max;

  /// Sets the duration; only from idle or finished (result: idle).
  /// Returns false and changes nothing when [d] is invalid or the state is
  /// running/paused.
  bool setDuration(Duration d) {
    if (!isValid(d) ||
        _status == CountdownStatus.running ||
        _status == CountdownStatus.paused) {
      return false;
    }
    _duration = d;
    _status = CountdownStatus.idle;
    return true;
  }

  /// Remaining time: derived from `endsAt` while running, frozen while
  /// paused, zero when finished, [duration] when idle.
  Duration remaining() => switch (_status) {
    CountdownStatus.idle => _duration,
    CountdownStatus.paused => _pausedRemaining,
    CountdownStatus.finished => Duration.zero,
    CountdownStatus.running => _untilEnd(),
  };

  /// Time to `endsAt`, never below zero and never above [duration]: if the
  /// wall clock was set back (or a snapshot is corrupt) the end is rebased
  /// to a full [duration] from now, so the timer still finishes.
  Duration _untilEnd() {
    final left = _endsAt!.difference(_now());
    if (left > _duration) {
      _endsAt = _now().add(_duration);
      return _duration;
    }
    return left.isNegative ? Duration.zero : left;
  }

  /// idle -> running.
  void start() {
    if (_status != CountdownStatus.idle) return;
    _run(_duration);
  }

  /// running -> paused. Ignored once the end has passed, so the pending
  /// [checkFinished] still reports completion.
  void pause() {
    if (_status != CountdownStatus.running) return;
    final left = _untilEnd();
    if (left == Duration.zero) return;
    _pausedRemaining = left;
    _endsAt = null;
    _status = CountdownStatus.paused;
  }

  /// paused -> running.
  void resume() {
    if (_status != CountdownStatus.paused) return;
    _run(_pausedRemaining);
  }

  void _run(Duration left) {
    _endsAt = _now().add(left);
    _status = CountdownStatus.running;
  }

  /// Any state -> idle, keeping [duration].
  void reset() {
    _status = CountdownStatus.idle;
    _endsAt = null;
  }

  /// Returns true only on the running -> finished transition.
  bool checkFinished() {
    if (_status != CountdownStatus.running || _now().isBefore(_endsAt!)) {
      return false;
    }
    _status = CountdownStatus.finished;
    _endsAt = null;
    return true;
  }

  /// Serialisable snapshot for persistence.
  Map<String, Object?> toJson() => {
    'durationMs': _duration.inMilliseconds,
    'status': _status.name,
    if (_endsAt != null) 'endsAtMs': _endsAt!.millisecondsSinceEpoch,
    if (_status == CountdownStatus.paused)
      'remainingMs': _pausedRemaining.inMilliseconds,
  };

  /// Restores a snapshot; corrupt input yields an idle default, never throws.
  ///
  /// A running snapshot whose end has already passed restores as running, so
  /// the caller's next [checkFinished] reports "finished while away".
  factory Countdown.fromJson(
    Map<String, Object?> json, {
    DateTime Function()? now,
  }) {
    final c = Countdown(now: now);
    final durationMs = json['durationMs'];
    final status = CountdownStatus.values.asNameMap()[json['status']];
    if (durationMs is! int || status == null) return c;
    final duration = Duration(milliseconds: durationMs);
    if (!isValid(duration)) return c;

    switch (status) {
      case CountdownStatus.idle:
      case CountdownStatus.finished:
        break;
      case CountdownStatus.running:
        final endsAtMs = json['endsAtMs'];
        // DateTime's range is +/- 8.64e15 ms; outside it would throw.
        if (endsAtMs is! int || endsAtMs.abs() > 8640000000000000) return c;
        c._endsAt = DateTime.fromMillisecondsSinceEpoch(endsAtMs, isUtc: true);
      case CountdownStatus.paused:
        final remainingMs = json['remainingMs'];
        if (remainingMs is! int ||
            remainingMs <= 0 ||
            remainingMs > durationMs) {
          return c;
        }
        c._pausedRemaining = Duration(milliseconds: remainingMs);
    }
    c
      .._duration = duration
      .._status = status;
    if (status == CountdownStatus.running) c._untilEnd();
    return c;
  }
}
