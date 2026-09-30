import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

/// What the stopwatch shows.
class StopwatchState {
  const StopwatchState({
    this.elapsed = Duration.zero,
    this.running = false,
    this.laps = const [],
  });

  final Duration elapsed;
  final bool running;

  /// Split times, newest first: each lap's own length.
  final List<Duration> laps;

  /// Never started, or reset.
  bool get isIdle => !running && elapsed == Duration.zero;

  @override
  bool operator ==(Object other) =>
      other is StopwatchState &&
      other.elapsed == elapsed &&
      other.running == running &&
      listEquals(other.laps, laps);

  @override
  int get hashCode => Object.hash(elapsed, running, Object.hashAll(laps));
}

/// Start/pause/resume/lap/reset over an injected monotonic [Stopwatch], so
/// a system clock change never moves the reading. Ticks only while
/// running. Laps live in memory only, like the reading.
class StopwatchController extends Cubit<StopwatchState> {
  StopwatchController({
    required Stopwatch stopwatch,
    Duration tick = const Duration(milliseconds: 100),
  }) : _stopwatch = stopwatch,
       _tickEvery = tick,
       super(const StopwatchState());

  final Stopwatch _stopwatch;
  final Duration _tickEvery;
  Timer? _timer;
  List<Duration> _laps = const [];

  /// Starts or resumes.
  void start() {
    if (_stopwatch.isRunning) return;
    _stopwatch.start();
    _timer = Timer.periodic(_tickEvery, (_) => _emit());
    _emit();
  }

  /// Pauses, keeping the elapsed time.
  void pause() {
    _stopwatch.stop();
    _stopTimer();
    _emit();
  }

  /// While running, records the time since the previous lap (or the
  /// start); ignored otherwise.
  void lap() {
    if (!_stopwatch.isRunning) return;
    final before = _laps.fold(Duration.zero, (sum, lap) => sum + lap);
    _laps = List.unmodifiable([_stopwatch.elapsed - before, ..._laps]);
    _emit();
  }

  /// Start when stopped, pause when running.
  void toggle() => _stopwatch.isRunning ? pause() : start();

  /// Stops and clears to zero, laps too.
  void reset() {
    _stopwatch
      ..stop()
      ..reset();
    _laps = const [];
    _stopTimer();
    _emit();
  }

  void _emit() => emit(
    StopwatchState(
      elapsed: _stopwatch.elapsed,
      running: _stopwatch.isRunning,
      laps: _laps,
    ),
  );

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() {
    _stopTimer();
    return super.close();
  }
}
