import 'dart:async';

import 'package:bloc/bloc.dart';

/// What the stopwatch shows.
class StopwatchState {
  const StopwatchState({this.elapsed = Duration.zero, this.running = false});

  final Duration elapsed;
  final bool running;

  /// Never started, or reset.
  bool get isIdle => !running && elapsed == Duration.zero;

  @override
  bool operator ==(Object other) =>
      other is StopwatchState &&
      other.elapsed == elapsed &&
      other.running == running;

  @override
  int get hashCode => Object.hash(elapsed, running);
}

/// Start/pause/resume/reset over an injected monotonic [Stopwatch], so a
/// system clock change never moves the reading. Ticks only while running.
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

  /// Start when stopped, pause when running.
  void toggle() => _stopwatch.isRunning ? pause() : start();

  /// Stops and clears to zero.
  void reset() {
    _stopwatch
      ..stop()
      ..reset();
    _stopTimer();
    _emit();
  }

  void _emit() => emit(
    StopwatchState(elapsed: _stopwatch.elapsed, running: _stopwatch.isRunning),
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
