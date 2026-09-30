import 'dart:async';

import 'package:bloc/bloc.dart';

/// Emits the wall-clock time once per second, aligned to the second
/// boundary, while [start]ed. Reads the injected [now] on every tick, so a
/// time or time-zone change shows up on the next update.
class ClockController extends Cubit<DateTime> {
  ClockController({DateTime Function()? now})
    : _now = now ?? DateTime.now,
      super((now ?? DateTime.now)());

  final DateTime Function() _now;
  Timer? _timer;

  /// Starts ticking (idempotent); also refreshes immediately.
  void start() => _tick();

  /// Re-reads the clock now, e.g. after the app resumes.
  void refresh() {
    if (_timer != null) _tick();
  }

  /// Stops ticking.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    _timer?.cancel();
    final now = _now();
    emit(now);
    final intoSecond = now.millisecond * 1000 + now.microsecond;
    _timer = Timer(Duration(microseconds: 1000000 - intoSecond), _tick);
  }

  @override
  Future<void> close() {
    stop();
    return super.close();
  }
}
