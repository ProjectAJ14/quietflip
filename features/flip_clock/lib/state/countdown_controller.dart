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
    this.pomodoro,
  });

  final CountdownStatus status;
  final Duration duration;

  /// Time left, already rounded up to a whole second for display.
  final Duration remaining;

  /// The focus/break phase while a pomodoro cycle runs; null for a plain
  /// timer.
  final Pomodoro? pomodoro;

  @override
  bool operator ==(Object other) =>
      other is CountdownState &&
      other.status == status &&
      other.duration == duration &&
      other.remaining == remaining &&
      other.pomodoro == pomodoro;

  @override
  int get hashCode => Object.hash(status, duration, remaining, pomodoro);
}

/// Runs the single countdown: persists every transition, schedules the
/// system notification, plays the completion chime and recomputes the
/// remaining time from the wall-clock end on every tick and app resume.
///
/// Every transition changes the state at once and queues its side effects
/// (save, system alert, sound) behind those of earlier transitions. A queued
/// save reads the countdown when it runs, not when it was queued, and leaves
/// the system alert to a newer transition queued behind it, so the stored
/// snapshot and the scheduled alert always end at the latest transition,
/// however long a write takes.
///
/// A pomodoro cycle is the same countdown run once per phase: while the app
/// is open, a phase that ends chimes for [chimeFor] and the next phase starts
/// at once.
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
    Duration chimeFor = const Duration(seconds: 5),
  }) : _repository = repository,
       _alerts = alerts,
       _sound = sound,
       _settings = settings,
       _logger = logger,
       _now = now ?? DateTime.now,
       _notifyOnFinish = notifyOnFinish,
       _tickEvery = tick,
       _chimeFor = chimeFor,
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
  final Duration _chimeFor;
  late Countdown _countdown;
  Timer? _ticker;
  Timer? _end;
  Timer? _chime;

  /// The side effects queued so far, run one after another.
  Future<void> _effects = Future.value();

  /// Transitions queued so far; only the newest one sets the system alert.
  int _transitions = 0;

  /// The running cycle's phase; null for a plain timer.
  Pomodoro? _pomodoro;

  /// The timer's own duration, restored when a pomodoro cycle ends.
  Duration _timerDuration = Countdown.defaultDuration;

  /// Restores the saved countdown. A timer that ended while the app was
  /// closed shows as finished (silently: the system alert already fired);
  /// a pomodoro phase too, waiting for [startNextPhase].
  Future<void> load() async {
    final snapshot = await _repository.loadCountdown();
    if (snapshot != null) {
      _countdown = Countdown.fromJson(snapshot, now: _now);
      // An idle countdown has no phase to resume.
      if (_countdown.status != CountdownStatus.idle) {
        _pomodoro = Pomodoro.fromJson(snapshot['pomodoro']);
      }
      final timerMs = snapshot['timerMs'];
      if (_pomodoro != null && timerMs is int) {
        final d = Duration(milliseconds: timerMs);
        if (Countdown.isValid(d)) _timerDuration = d;
      }
    }
    if (_countdown.checkFinished()) {
      _logger.i('Countdown finished while the app was away');
      await _save();
    } else if (_countdown.status == CountdownStatus.running) {
      // Restoring may have rebased the end (clock set back while closed):
      // re-save it and move the system alert with it.
      await _running();
    }
    _publish();
  }

  /// Starts a new countdown of [duration]. Ignored when invalid or when a
  /// countdown is already running or paused.
  Future<void> start(Duration duration) async {
    final idle =
        _countdown.status == CountdownStatus.idle ||
        _countdown.status == CountdownStatus.finished;
    if (!idle || !_countdown.setDuration(duration)) return;
    _pomodoro = null;
    _countdown.start();
    await _running();
  }

  /// Runs a finished plain timer again for the same duration, silencing
  /// its alarm. Ignored otherwise (a finished phase has [startNextPhase]).
  Future<void> restart() async {
    if (_countdown.status != CountdownStatus.finished || _pomodoro != null) {
      return;
    }
    await Future.wait([_queue(_sound.stopAlarm), start(_countdown.duration)]);
  }

  /// Starts [preset]: the pomodoro cycle or a plain countdown.
  Future<void> startPreset(TimerPreset preset) => switch (preset) {
    PomodoroCycle() => startPomodoro(),
    Minutes(:final duration) => start(duration),
  };

  /// Starts a pomodoro cycle at focus, round 1. Ignored unless idle; the
  /// idle duration comes back when the cycle is [reset].
  Future<void> startPomodoro() async {
    if (_countdown.status != CountdownStatus.idle) return;
    _timerDuration = _countdown.duration;
    await _startPhase(const Pomodoro());
  }

  /// Starts the phase after a finished one (a phase that ended while the
  /// app was closed waits for this). Ignored otherwise.
  Future<void> startNextPhase() async {
    final done = _pomodoro;
    if (done == null || _countdown.status != CountdownStatus.finished) return;
    await Future.wait([_queue(_sound.stopAlarm), _startPhase(done.next())]);
  }

  Future<void> _startPhase(Pomodoro phase) async {
    _pomodoro = phase;
    _countdown
      ..setDuration(phase.duration)
      ..start();
    await _running();
  }

  Future<void> pause() async {
    if (_countdown.status != CountdownStatus.running) return;
    _countdown.pause();
    // Pausing at (or past) the end is ignored: it has finished instead.
    if (_countdown.status != CountdownStatus.paused) return check();
    _stopTicker();
    _publish();
    await _save();
  }

  Future<void> resume() async {
    if (_countdown.status != CountdownStatus.paused) return;
    _countdown.resume();
    await _running();
  }

  /// Back to idle with the same duration; also dismisses a finished alert
  /// and ends a pomodoro cycle, restoring the timer's own duration.
  Future<void> reset() async {
    _countdown.reset();
    if (_pomodoro != null) {
      _pomodoro = null;
      _countdown.setDuration(_timerDuration);
    }
    _chime?.cancel();
    _stopTicker();
    _publish();
    await _save(then: _sound.stopAlarm);
  }

  /// Space bar: pause a running timer, resume a paused one, dismiss a
  /// finished one (or start the next pomodoro phase). An idle one starts
  /// the default timer.
  Future<void> toggle() => switch (_countdown.status) {
    CountdownStatus.running => pause(),
    CountdownStatus.paused => resume(),
    CountdownStatus.finished => _pomodoro == null ? reset() : startNextPhase(),
    CountdownStatus.idle => startPreset(_settings().defaultTimer),
  };

  /// Recomputes from the wall clock (tick and app resume).
  Future<void> check() async {
    final endsAt = _countdown.endsAt;
    final finished = _countdown.checkFinished();
    _publish();
    if (!finished) {
      // The wall clock went back: the countdown rebased its end to a full
      // duration from now, so the end timer, snapshot and system alert
      // (still at the old instant) follow it.
      if (_countdown.endsAt != endsAt) await _running();
      return;
    }
    _stopTicker();
    final done = _pomodoro;
    // The next phase starts at once; it saves itself.
    final saved = done != null ? _startPhase(done.next()) : _save();
    final settings = _settings();
    final playing = settings.alertSound;
    if (playing && done != null) {
      // A short chime, not the 60 s alarm, while the next phase runs.
      _chime?.cancel();
      _chime = Timer(_chimeFor, () => unawaited(_queue(_sound.stopAlarm)));
    }
    final notify = _notifyOnFinish && settings.systemAlerts;
    final (title, body) = _alertText(done);
    final alarmed = _queue(() async {
      if (playing) await _sound.playAlarm(settings.alarmSound);
      if (notify) await _alerts.showNow(title: title, body: body);
    });
    await Future.wait([saved, alarmed]);
  }

  /// Title and body for the alert at the end of [phase] (null: the timer).
  (String, String) _alertText(Pomodoro? phase) => switch (phase?.phase) {
    null => (
      strings.clock.timer_finished_title,
      strings.clock.timer_finished_body,
    ),
    PomodoroPhase.focus => (
      strings.clock.pomodoro,
      strings.clock.pomodoro_focus_done,
    ),
    PomodoroPhase.rest => (
      strings.clock.pomodoro,
      strings.clock.pomodoro_break_done,
    ),
  };

  /// Brings the system alert in line with the System notifications setting
  /// after it changes: scheduled for a running countdown when on, cancelled
  /// when off.
  Future<void> syncAlert() async {
    if (_countdown.status != CountdownStatus.running) return;
    final latest = _transitions;
    await _queue(() async {
      // A newer transition queued meanwhile sets the alert itself.
      if (latest != _transitions) return;
      if (_settings().systemAlerts) return _alert();
      await _alerts.cancel(alertId);
    });
  }

  Future<void> _running() async {
    _startTicker();
    _publish();
    await _save();
  }

  /// Runs [effect] once every effect queued before it has finished; its
  /// error reaches the caller and does not stop the effects after it.
  Future<void> _queue(Future<void> Function() effect) {
    final run = _effects.then((_) => effect());
    _effects = run.then<void>((_) {}, onError: (Object _) {});
    return run;
  }

  /// Queues this transition's effects: save the countdown as it is when the
  /// save runs, bring the system alert in line with it unless a newer
  /// transition queued meanwhile will, then [then].
  Future<void> _save({Future<void> Function()? then}) {
    final transition = ++_transitions;
    return _queue(() async {
      await _persist();
      if (transition == _transitions) await _alert();
      await then?.call();
    });
  }

  /// The system alert for the countdown as it is now: scheduled at the end
  /// of a running one when System notifications is on ([syncAlert] cancels
  /// it when turned off), cancelled for a paused or idle one; a finished one
  /// keeps the alert it has just shown.
  Future<void> _alert() async {
    switch (_countdown.status) {
      case CountdownStatus.running:
        if (!_settings().systemAlerts) return;
        final (title, body) = _alertText(_pomodoro);
        await _alerts.schedule(
          id: alertId,
          at: _countdown.endsAt!,
          title: title,
          body: body,
        );
      case CountdownStatus.finished:
        return;
      case CountdownStatus.idle || CountdownStatus.paused:
        await _alerts.cancel(alertId);
    }
  }

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

  Future<void> _persist() => _repository.saveCountdown({
    ..._countdown.toJson(),
    if (_pomodoro case final p?) ...{
      'pomodoro': p.toJson(),
      'timerMs': _timerDuration.inMilliseconds,
    },
  });

  void _publish() {
    if (isClosed) return;
    emit(
      CountdownState(
        status: _countdown.status,
        duration: _countdown.duration,
        remaining: ceilToSecond(_countdown.remaining()),
        pomodoro: _pomodoro,
      ),
    );
  }

  @override
  Future<void> close() {
    _stopTicker();
    _chime?.cancel();
    return super.close();
  }
}
