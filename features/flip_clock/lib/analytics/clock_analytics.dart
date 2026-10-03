import 'dart:async';

import 'package:analytics/analytics.dart';
import 'package:cloud_sync/cloud_sync.dart';
import 'package:flip_clock/data/models/clock_settings.dart';
import 'package:flip_clock/data/skins.dart';
import 'package:flip_clock/state/countdown_controller.dart';
import 'package:flip_clock/state/stopwatch_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:timekeeping/timekeeping.dart';

/// Every analytics event and user property of the clock, in one place.
///
/// The controllers report their own transitions here (a timer started, a
/// lap, a setting changed), so an event is logged once whatever started it:
/// a tray button, a key, a gesture or the Space bar. Restored state (a saved
/// countdown, saved settings, a cloud copy) is never logged as a user action.
///
/// Events carry only what the user picked (mode, theme, skin, sound, a
/// duration in seconds), never an email, a uid or a custom skin's name. A
/// custom skin is reported as `custom`. Without a [client] (Firebase off)
/// every call is a no-op. Client failures are logged by the client itself.
class ClockAnalytics {
  ClockAnalytics({
    AnalyticsClient? client,
    Duration settle = const Duration(seconds: 1),
  }) : _client = client,
       _settle = settle;

  final AnalyticsClient? _client;

  /// How long settings must stay still before their changes are logged, so
  /// a slider drag is one event, not forty.
  final Duration _settle;

  ClockSettings? _from;
  ClockSettings? _to;
  Timer? _pending;
  bool _closed = false;
  final List<VoidCallback> _unfollow = [];

  // Events.
  static const String modeChanged = 'mode_changed';
  static const String settingChanged = 'setting_changed';
  static const String settingsFromCloud = 'settings_from_cloud';
  static const String skinSelected = 'skin_selected';
  static const String skinCreated = 'skin_created';
  static const String skinEdited = 'skin_edited';
  static const String skinDeleted = 'skin_deleted';
  static const String timerPresetAdded = 'timer_preset_added';
  static const String timerPresetRemoved = 'timer_preset_removed';
  static const String timerStarted = 'timer_started';
  static const String timerPaused = 'timer_paused';
  static const String timerResumed = 'timer_resumed';
  static const String timerFinished = 'timer_finished';
  static const String timerCancelled = 'timer_cancelled';
  static const String timerDismissed = 'timer_dismissed';
  static const String pomodoroPhaseStarted = 'pomodoro_phase_started';
  static const String stopwatchStarted = 'stopwatch_started';
  static const String stopwatchPaused = 'stopwatch_paused';
  static const String stopwatchResumed = 'stopwatch_resumed';
  static const String stopwatchLap = 'stopwatch_lap';
  static const String stopwatchReset = 'stopwatch_reset';
  static const String fullScreenChanged = 'full_screen_changed';
  static const String notificationPermission = 'notification_permission';
  static const String syncFailed = 'sync_failed';

  /// Reported in place of a custom skin's id.
  static const String customSkin = 'custom';

  /// Sets every settings user property (theme, skin, sounds, ...), so each
  /// user is counted under what they use now. Call after loading settings.
  void identify(ClockSettings settings) {
    for (final MapEntry(:key, :value) in properties(settings).entries) {
      _property(key, value);
    }
  }

  /// The user properties for [settings]: at most 24-character names and
  /// short values, as Firebase requires.
  @visibleForTesting
  static Map<String, String> properties(ClockSettings settings) => {
    'theme': settings.theme.name,
    'skin': skinOf(settings.skinId),
    'clock_format': switch (settings.use24h) {
      null => 'device',
      true => '24h',
      false => '12h',
    },
    'show_seconds': '${settings.showSeconds}',
    'show_date': '${settings.showDate}',
    'card_size': settings.cardSize.name,
    'tick_sound': settings.flipSound ? settings.tickSound.name : 'off',
    'alarm_sound': settings.alertSound ? settings.alarmSound.name : 'off',
    'system_alerts': '${settings.systemAlerts}',
    'keep_awake': '${settings.keepAwake}',
    'subtle_movement': '${settings.subtleMovement}',
    'default_timer': _timerOf(settings.defaultTimer),
    'timer_presets': '${settings.timerPresets.length}',
    'custom_skins': '${settings.customSkins.length}',
  };

  /// A skin id as reported: built-in ids as they are, custom ones as
  /// [customSkin].
  @visibleForTesting
  static String skinOf(String id) => Skins.isCustomId(id) ? customSkin : id;

  static String _timerOf(TimerPreset preset) => switch (preset) {
    PomodoroCycle() => 'pomodoro',
    Minutes(:final duration) => '${duration.inSeconds}s',
  };

  /// The user changed settings from [before] to [after]. Logged once they
  /// have been still for the settle time, as the difference between the
  /// first and the last, together with fresh user properties.
  void settingsChanged(ClockSettings before, ClockSettings after) {
    if (_closed || _client == null) return;
    _from ??= before;
    _to = after;
    _pending?.cancel();
    _pending = Timer(_settle, _flush);
  }

  /// A newer copy of the settings came from the cloud: no user action, so
  /// only the properties change.
  void settingsFromCloudApplied(ClockSettings settings) {
    _event(settingsFromCloud);
    identify(settings);
  }

  void _flush() {
    _pending?.cancel();
    _pending = null;
    final (from, to) = (_from, _to);
    _from = null;
    _to = null;
    if (from == null || to == null) return;
    for (final (name, parameters) in changes(from, to)) {
      _event(name, parameters);
    }
    identify(to);
  }

  /// The events for a change from [from] to [to], in a stable order.
  @visibleForTesting
  static List<(String, Map<String, Object>)> changes(
    ClockSettings from,
    ClockSettings to,
  ) {
    final events = <(String, Map<String, Object>)>[];
    final before = from.toJson();
    final after = to.toJson();
    for (final key in after.keys) {
      if (_same(before[key], after[key])) continue;
      switch (key) {
        case 'lastMode':
          events.add((modeChanged, {'mode': to.lastMode.name}));
        case 'skinId':
          events.add((
            skinSelected,
            {
              'skin': skinOf(to.skinId),
              'skin_type': Skins.isCustomId(to.skinId) ? 'custom' : 'built_in',
            },
          ));
        case 'customSkins':
          events.addAll(_skinChanges(from, to));
        case 'timerPresetsMs':
          events.addAll(_presetChanges(from, to));
        default:
          events.add((
            settingChanged,
            {'setting': _snake(key), 'value': _valueOf(key, to)},
          ));
      }
    }
    return events;
  }

  static Iterable<(String, Map<String, Object>)> _skinChanges(
    ClockSettings from,
    ClockSettings to,
  ) sync* {
    final before = {for (final s in from.customSkins) s.id: s.toJson()};
    final after = {for (final s in to.customSkins) s.id: s.toJson()};
    final count = {'custom_skins': to.customSkins.length};
    for (final id in after.keys) {
      if (!before.containsKey(id)) {
        yield (skinCreated, count);
      } else if (!_same(before[id], after[id])) {
        yield (skinEdited, count);
      }
    }
    for (final id in before.keys) {
      if (!after.containsKey(id)) yield (skinDeleted, count);
    }
  }

  static Iterable<(String, Map<String, Object>)> _presetChanges(
    ClockSettings from,
    ClockSettings to,
  ) sync* {
    for (final d in to.timerPresets) {
      if (!from.timerPresets.contains(d)) {
        yield (timerPresetAdded, {'duration_s': d.inSeconds});
      }
    }
    for (final d in from.timerPresets) {
      if (!to.timerPresets.contains(d)) {
        yield (timerPresetRemoved, {'duration_s': d.inSeconds});
      }
    }
  }

  /// A setting's new value as reported: enum names, booleans as text,
  /// numbers rounded, durations in seconds.
  static Object _valueOf(String key, ClockSettings s) => switch (key) {
    'use24h' => switch (s.use24h) {
      null => 'device',
      true => '24h',
      false => '12h',
    },
    'controlsIdleMs' => s.controlsIdle.inSeconds,
    'defaultTimerMs' => _timerOf(s.defaultTimer),
    'digitBrightness' => (s.digitBrightness * 100).round(),
    _ => switch (s.toJson()[key]) {
      final num n => n,
      final value => '$value',
    },
  };

  /// `tickSound` -> `tick_sound`, `controlsIdleMs` -> `controls_idle`.
  static String _snake(String key) => key
      .replaceFirst(RegExp(r'Ms$'), '')
      .replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');

  static bool _same(Object? a, Object? b) =>
      a is List || a is Map ? '$a' == '$b' : a == b;

  /// The countdown moved from [before] to [after]. Ticks (only the time
  /// left changes) are ignored.
  void countdownChanged(CountdownState before, CountdownState after) {
    if (before.status == after.status) return;
    final kind = after.pomodoro ?? before.pomodoro;
    final common = <String, Object>{
      'kind': kind == null ? 'timer' : 'pomodoro',
    };
    switch ((before.status, after.status)) {
      case (CountdownStatus.paused, CountdownStatus.running):
        _event(timerResumed, {
          ...common,
          'remaining_s': after.remaining.inSeconds,
        });
      case (_, CountdownStatus.running):
        if (before.pomodoro != null && after.pomodoro != null) {
          _event(pomodoroPhaseStarted, _phase(after.pomodoro!));
        } else {
          _event(timerStarted, {
            ...common,
            'duration_s': after.duration.inSeconds,
          });
        }
      case (_, CountdownStatus.paused):
        _event(timerPaused, {
          ...common,
          'remaining_s': after.remaining.inSeconds,
        });
      case (_, CountdownStatus.finished):
        _event(timerFinished, {
          ...common,
          'duration_s': after.duration.inSeconds,
          if (after.pomodoro case final p?) ..._phase(p),
        });
      case (CountdownStatus.finished, CountdownStatus.idle):
        _event(timerDismissed, common);
      case (_, CountdownStatus.idle):
        _event(timerCancelled, {
          ...common,
          'remaining_s': before.remaining.inSeconds,
        });
    }
  }

  static Map<String, Object> _phase(Pomodoro p) => {
    'phase': p.phase == PomodoroPhase.focus ? 'focus' : 'break',
    'round': p.round,
  };

  /// The stopwatch moved from [before] to [after]. Ticks are ignored.
  void stopwatchChanged(StopwatchState before, StopwatchState after) {
    final summary = {
      'elapsed_s': before.elapsed.inSeconds,
      'laps': before.laps.length,
    };
    if (after.isIdle && !before.isIdle) {
      _event(stopwatchReset, summary);
    } else if (after.running && !before.running) {
      _event(before.isIdle ? stopwatchStarted : stopwatchResumed);
    } else if (!after.running && before.running) {
      _event(stopwatchPaused, {
        'elapsed_s': after.elapsed.inSeconds,
        'laps': after.laps.length,
      });
    } else if (after.laps.length > before.laps.length) {
      _event(stopwatchLap, {'lap': after.laps.length});
    }
  }

  /// The answer to the notification permission prompt.
  void notificationPermissionAnswered({required bool granted}) =>
      _event(notificationPermission, {'granted': '$granted'});

  /// Logs every time full screen turns on or off, from any source (the F
  /// key, a double tap, the browser's Esc).
  void followFullScreen(ValueListenable<bool> active) {
    void changed() => _event(fullScreenChanged, {'on': '${active.value}'});
    active.addListener(changed);
    _unfollow.add(() => active.removeListener(changed));
  }

  /// Keeps the `account` (provider or `guest`) and `cloud_sync` (on/off)
  /// user properties current and logs failed syncs with their reason.
  void followSync(CloudSync sync) {
    void account() =>
        _property('account', sync.account.value?.provider.name ?? 'guest');
    void status() {
      final status = sync.status.value;
      _property('cloud_sync', status is SyncOff ? 'off' : 'on');
      if (status is SyncFailed) {
        _event(syncFailed, {'reason': status.reason.name});
      }
    }

    account();
    status();
    sync.account.addListener(account);
    sync.status.addListener(status);
    _unfollow.add(() {
      sync.account.removeListener(account);
      sync.status.removeListener(status);
    });
  }

  void _event(String name, [Map<String, Object>? parameters]) {
    if (_closed) return;
    unawaited(_client?.logEvent(name: name, parameters: parameters));
  }

  void _property(String name, String value) {
    if (_closed) return;
    unawaited(_client?.setUserProperty(name: name, value: value));
  }

  /// Logs settings changes still settling, then stops listening; later calls
  /// are no-ops.
  void close() {
    _flush();
    for (final unfollow in _unfollow) {
      unfollow();
    }
    _unfollow.clear();
    _closed = true;
  }
}
