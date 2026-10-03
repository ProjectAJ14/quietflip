/// Lifecycle of a [Countdown].
enum CountdownStatus { idle, running, paused, finished }

/// Countdown state machine whose remaining time is derived from clocks,
/// never from counting ticks.
///
/// While running it reads two clocks and trusts whichever has less time
/// left: the wall clock (`endsAt`, which also moves forward across device
/// sleep) and a monotonic one (which a user or network time correction
/// cannot set back). So setting the clock back never adds time; the wall
/// end is rebased instead, keeping the progress made.
///
/// Invalid transitions are no-ops so the UI can call them from any state.
class Countdown {
  /// [now] is the wall clock; defaults to [DateTime.now]. [elapsed] is a
  /// monotonic reading (only differences matter); defaults to a
  /// [Stopwatch] started here.
  Countdown({DateTime Function()? now, Duration Function()? elapsed})
    : _now = now ?? DateTime.now,
      _elapsed = elapsed ?? _monotonic();

  /// Longest accepted duration: 99:59:59.
  static const Duration max = Duration(hours: 99, minutes: 59, seconds: 59);

  /// Duration of a fresh (or restored-from-corrupt) countdown.
  static const Duration defaultDuration = Duration(minutes: 5);

  /// How far the wall end may lag the monotonic one before it is rebased:
  /// below a second the display cannot tell, and the end (with the saved
  /// snapshot and the system alert that follow it) stays put.
  static const Duration _slack = Duration(seconds: 1);

  static Duration Function() _monotonic() {
    final watch = Stopwatch()..start();
    return () => watch.elapsed;
  }

  final DateTime Function() _now;
  final Duration Function() _elapsed;
  Duration _duration = defaultDuration;
  CountdownStatus _status = CountdownStatus.idle;
  DateTime? _endsAt;
  Duration _pausedRemaining = Duration.zero;

  /// Time left at the last read while running, and the monotonic reading
  /// then.
  Duration _left = Duration.zero;
  Duration _readAt = Duration.zero;

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

  /// Remaining time: the lesser of the wall and the monotonic clock while
  /// running, frozen while paused, zero when finished, [duration] when idle.
  Duration remaining() => switch (_status) {
    CountdownStatus.idle => _duration,
    CountdownStatus.paused => _pausedRemaining,
    CountdownStatus.finished => Duration.zero,
    CountdownStatus.running => _untilEnd(),
  };

  /// Time left, never below zero: the lesser of the time to `endsAt` and
  /// the time left at the last read minus the monotonic time since. A wall
  /// clock moved forward (or a device that slept) shortens it; one set back
  /// cannot lengthen it, and `endsAt` is rebased to now plus the time left
  /// once it lags by more than [_slack].
  Duration _untilEnd() {
    final wall = _now();
    final mono = _elapsed();
    final byWall = _endsAt!.difference(wall);
    final byMono = _left - (mono - _readAt);
    var left = byWall < byMono ? byWall : byMono;
    if (left.isNegative) left = Duration.zero;
    if (byWall - left > _slack) _endsAt = wall.add(left);
    _left = left;
    _readAt = mono;
    return left;
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
    _left = left;
    _readAt = _elapsed();
    _status = CountdownStatus.running;
  }

  /// Any state -> idle, keeping [duration].
  void reset() {
    _status = CountdownStatus.idle;
    _endsAt = null;
  }

  /// Returns true only on the running -> finished transition.
  bool checkFinished() {
    if (_status != CountdownStatus.running || _untilEnd() > Duration.zero) {
      return false;
    }
    _status = CountdownStatus.finished;
    _endsAt = null;
    return true;
  }

  /// Serialisable snapshot for persistence. A running one also records
  /// when it was taken (`savedAtMs`), the floor for a relaunch whose clock
  /// was set back while the app was closed.
  Map<String, Object?> toJson() => {
    'durationMs': _duration.inMilliseconds,
    'status': _status.name,
    if (_endsAt != null) ...{
      'endsAtMs': _endsAt!.millisecondsSinceEpoch,
      'savedAtMs': _now().millisecondsSinceEpoch,
    },
    if (_status == CountdownStatus.paused)
      'remainingMs': _pausedRemaining.inMilliseconds,
  };

  /// Restores a snapshot; corrupt input yields an idle default, never throws.
  ///
  /// A running snapshot whose end has already passed restores as running, so
  /// the caller's next [checkFinished] reports "finished while away".
  ///
  /// No monotonic clock survives a relaunch, so a running one counts from
  /// the wall clock, but never from before `savedAtMs`: a clock set back
  /// past the save resumes with the time left at the save (the time spent
  /// closed is unknown and not deducted), and nothing restores with more
  /// than [duration] left. Either case rebases `endsAt`.
  factory Countdown.fromJson(
    Map<String, Object?> json, {
    DateTime Function()? now,
    Duration Function()? elapsed,
  }) {
    final c = Countdown(now: now, elapsed: elapsed);
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
        final endsAt = DateTime.fromMillisecondsSinceEpoch(
          endsAtMs,
          isUtc: true,
        );
        final wall = c._now();
        final savedAtMs = json['savedAtMs'];
        // Older snapshots have no savedAtMs; one after the end is corrupt
        // (a running snapshot is saved before its end) and ignored.
        final setBack =
            savedAtMs is int &&
            savedAtMs > wall.millisecondsSinceEpoch &&
            savedAtMs <= endsAtMs;
        final from = setBack
            ? DateTime.fromMillisecondsSinceEpoch(savedAtMs, isUtc: true)
            : wall;
        var left = endsAt.difference(from);
        if (left > duration) left = duration;
        c
          .._endsAt = left == endsAt.difference(wall) ? endsAt : wall.add(left)
          .._left = left
          .._readAt = c._elapsed();
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
    return c;
  }
}
