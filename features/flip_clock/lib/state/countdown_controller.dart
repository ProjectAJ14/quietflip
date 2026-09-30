import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:device_services/device_services.dart';
import 'package:flip_clock/data/models/clock_settings.dart';
import 'package:flip_clock/data/repositories/settings_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:localization/localization.dart';
import 'package:timekeeping/timekeeping.dart';

/// What the timer shows.
class CountdownState {
  const CountdownState({
    this.status = CountdownStatus.idle,
    this.duration = Duration.zero,
    this.remaining = Duration.zero,
  });

  final CountdownStatus status;
  final Duration duration;

  /// Time left, already rounded up to a whole second for display.
  final Duration remaining;

  @override
  bool operator ==(Object other) =>
      other is CountdownState &&
      other.status == status &&
      other.duration == duration &&
      other.remaining == remaining;

  @override
  int get hashCode => Object.hash(status, duration, remaining);
}

/// Runs the single countdown: persists every transition, schedules the
/// system notification, plays the completion chime and recomputes the
/// remaining time from the wall-clock end on every tick and app resume.
class CountdownController extends Cubit<CountdownState> {
  CountdownController({
    required SettingsRepository repository,
    required LocalAlerts alerts,
    required SoundPlayer sound,
    required ClockSettings Function() settings,
    required Logger logger,
    DateTime Function()? now,
    bool notifyOnFinish = kIsWeb,
    Duration tick = const Duration(milliseconds: 250),
  }) : _repository = repository,
       _alerts = alerts,
       _sound = sound,
       _settings = settings,
       _logger = logger,
       _now = now ?? DateTime.now,
       _notifyOnFinish = notifyOnFinish,
       _tickEvery = tick,
       super(const CountdownState()) {
    _countdown = Countdown(now: _now);
    _publish();
  }

  /// Notification id of the timer alert.
  static const int alertId = 1;

  final SettingsRepository _repository;
  final LocalAlerts _alerts;
  final SoundPlayer _sound;
  final ClockSettings Function() _settings;
  final Logger _logger;
  final DateTime Function() _now;

  /// Web cannot schedule notifications, so it shows one at completion
  /// while the tab is open.
  final bool _notifyOnFinish;
  final Duration _tickEvery;
  late Countdown _countdown;
  Timer? _ticker;
  Timer? _end;

  /// False while the timer input holds an invalid or zero entry, so the
  /// Space bar cannot start the last valid duration behind the user's back.
  bool _entryValid = true;

  /// Restores the saved countdown. A timer that ended while the app was
  /// closed shows as finished (silently: the system alert already fired).
  Future<void> load() async {
    final snapshot = await _repository.loadCountdown();
    if (snapshot != null) _countdown = Countdown.fromJson(snapshot, now: _now);
    if (_countdown.checkFinished()) {
      _logger.i('Countdown finished while the app was away');
      await _persist();
    } else if (_countdown.status == CountdownStatus.running) {
      _startTicker();
    }
    _publish();
  }

  /// Remembers the entered [duration] while idle (or finished); ignored
  /// when invalid or while running/paused. Null (or an invalid duration)
  /// marks the entry invalid: [toggle] then does not start.
  Future<void> setDuration(Duration? duration) async {
    _entryValid = duration != null && Countdown.isValid(duration);
    if (duration == null || !_countdown.setDuration(duration)) return;
    _publish();
    await _persist();
  }

  /// Starts a new countdown of [duration]. Ignored when invalid or when a
  /// countdown is already running or paused.
  Future<void> start(Duration duration) async {
    final idle =
        _countdown.status == CountdownStatus.idle ||
        _countdown.status == CountdownStatus.finished;
    if (!idle || !_countdown.setDuration(duration)) return;
    _entryValid = true;
    _countdown.start();
    await _running();
  }

  Future<void> pause() async {
    if (_countdown.status != CountdownStatus.running) return;
    _countdown.pause();
    // Pausing at (or past) the end is ignored: it has finished instead.
    if (_countdown.status != CountdownStatus.paused) return check();
    _stopTicker();
    _publish();
    await _persist();
    await _alerts.cancel(alertId);
  }

  Future<void> resume() async {
    if (_countdown.status != CountdownStatus.paused) return;
    _countdown.resume();
    await _running();
  }

  /// Back to idle with the same duration; also dismisses a finished alert.
  Future<void> reset() async {
    _countdown.reset();
    // The input reappears showing the (valid) duration.
    _entryValid = true;
    _stopTicker();
    _publish();
    await _persist();
    await _alerts.cancel(alertId);
    await _sound.stopAlarm();
  }

  /// Space bar: pause a running timer, resume a paused one, dismiss a
  /// finished one. An idle timer is started from its input instead.
  Future<void> toggle() => switch (_countdown.status) {
    CountdownStatus.running => pause(),
    CountdownStatus.paused => resume(),
    CountdownStatus.finished => reset(),
    CountdownStatus.idle =>
      _entryValid ? start(_countdown.duration) : Future<void>.value(),
  };

  /// Recomputes from the wall clock (tick and app resume).
  Future<void> check() async {
    final finished = _countdown.checkFinished();
    _publish();
    if (!finished) return;
    _stopTicker();
    await _persist();
    final settings = _settings();
    if (settings.alertSound) await _sound.playAlarm();
    if (_notifyOnFinish && settings.systemAlerts) {
      await _alerts.showNow(
        title: strings.clock.timer_finished_title,
        body: strings.clock.timer_finished_body,
      );
    }
  }

  /// Brings the system alert in line with the System notifications setting
  /// after it changes: scheduled for a running countdown when on, cancelled
  /// when off.
  Future<void> syncAlert() async {
    if (_countdown.status != CountdownStatus.running) return;
    if (_settings().systemAlerts) return _schedule();
    await _alerts.cancel(alertId);
  }

  Future<void> _running() async {
    _startTicker();
    _publish();
    await _persist();
    if (_settings().systemAlerts) await _schedule();
  }

  Future<void> _schedule() => _alerts.schedule(
    id: alertId,
    at: _countdown.endsAt!,
    title: strings.clock.timer_finished_title,
    body: strings.clock.timer_finished_body,
  );

  void _startTicker() {
    _stopTicker();
    _ticker = Timer.periodic(_tickEvery, (_) => check());
    // Also one timer at the end itself: browsers throttle repeating timers
    // in hidden tabs to about once a minute, a single timeout only to ~1 s.
    _end = Timer(_countdown.endsAt!.difference(_now()), () => check());
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
    _end?.cancel();
    _end = null;
  }

  Future<void> _persist() => _repository.saveCountdown(_countdown.toJson());

  void _publish() {
    if (isClosed) return;
    emit(
      CountdownState(
        status: _countdown.status,
        duration: _countdown.duration,
        remaining: ceilToSecond(_countdown.remaining()),
      ),
    );
  }

  @override
  Future<void> close() {
    _stopTicker();
    return super.close();
  }
}
