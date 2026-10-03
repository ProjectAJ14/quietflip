import 'dart:async';

import 'package:cloud_sync/cloud_sync.dart';
import 'package:device_services/device_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeStore implements KeyValueStore {
  final Map<String, String> data = {};
  Exception? failure;

  /// While set, every write waits for it before landing.
  Completer<void>? hold;

  @override
  Future<String?> read(String key) async {
    if (failure case final e?) throw e;
    return data[key];
  }

  @override
  Future<void> write(String key, String value) async {
    if (failure case final e?) throw e;
    await hold?.future;
    data[key] = value;
  }

  @override
  Future<void> delete(String key) async => data.remove(key);
}

class FakeAlerts implements LocalAlerts {
  bool grant = true;
  int permissionRequests = 0;
  final Map<int, DateTime> scheduled = {};
  final List<int> cancelled = [];
  final List<String> shown = [];

  /// Every instant [schedule] was called with, in order.
  final List<DateTime> history = [];

  /// Thrown by the next [schedule], then cleared.
  Exception? failure;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return grant;
  }

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
  }) async {
    if (failure case final e?) {
      failure = null;
      throw e;
    }
    history.add(at);
    scheduled[id] = at;
  }

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    scheduled.remove(id);
  }

  @override
  Future<void> showNow({required String title, required String body}) async =>
      shown.add(title);
}

class FakeSound implements SoundPlayer {
  /// Every tick and alarm played, in order.
  final List<TickSound> ticks = [];
  final List<AlarmSound> played = [];

  /// Every tick loaded ahead with [warmTick], in order.
  final List<TickSound> warmed = [];
  int stops = 0;

  /// Every alarm previewed with [previewAlarm], in order, and the
  /// [stopPreview] calls.
  final List<AlarmSound> previewed = [];
  int previewStops = 0;

  int get flips => ticks.length;
  int get alarms => played.length;

  @override
  Future<void> playTick(TickSound sound) async => ticks.add(sound);

  @override
  Future<void> warmTick(TickSound sound) async => warmed.add(sound);

  @override
  Future<void> playAlarm(AlarmSound sound) async => played.add(sound);

  @override
  Future<void> stopAlarm() async => stops++;

  @override
  Future<void> previewAlarm(AlarmSound sound) async => previewed.add(sound);

  @override
  Future<void> stopPreview() async => previewStops++;
}

class FakeFullScreen implements FullScreenController {
  final ValueNotifier<bool> value = ValueNotifier(false);
  int toggles = 0;
  int exits = 0;

  @override
  ValueListenable<bool> get active => value;

  @override
  Future<void> toggle() async {
    toggles++;
    value.value = !value.value;
  }

  @override
  Future<void> exit() async {
    exits++;
    value.value = false;
  }
}

class FakeWake implements ScreenWake {
  final List<bool> calls = [];

  @override
  Future<void> setEnabled(bool on) async => calls.add(on);
}

class FakeOrientation implements OrientationLock {
  FakeOrientation({this.supported = true});

  final List<ScreenOrientation> calls = [];

  @override
  final bool supported;

  @override
  Future<void> set(ScreenOrientation orientation) async =>
      calls.add(orientation);
}

/// Screen brightness whose [failing] operations throw.
class FakeScreenBrightness implements ScreenBrightness {
  FakeScreenBrightness({this.supported = true, this.level = 0.5});

  @override
  final bool supported;

  double level;

  /// Every call in order: `current`, `set`, `reset`.
  final List<String> calls = [];

  /// Operations (`current`, `set`, `reset`) that throw.
  final Set<String> failing = {};

  /// While set, `set` waits for it: a platform call still in flight.
  Completer<void>? hold;

  void _call(String operation) {
    calls.add(operation);
    if (failing.contains(operation)) {
      throw ScreenBrightnessException(operation);
    }
  }

  @override
  Future<double> current() async {
    _call('current');
    return level;
  }

  @override
  Future<void> set(double value) async {
    _call('set');
    await hold?.future;
    level = value;
  }

  @override
  Future<void> reset() async => _call('reset');
}

/// A wall clock tests move by hand.
class FakeClock {
  FakeClock([DateTime? start]) : now = start ?? DateTime(2026, 9, 29, 9, 41);

  DateTime now;

  DateTime call() => now;

  void advance(Duration d) => now = now.add(d);
}

/// Monotonic stopwatch whose reading tests set by hand.
class FakeStopwatch implements Stopwatch {
  Duration reading = Duration.zero;
  bool _running = false;

  @override
  Duration get elapsed => reading;

  @override
  bool get isRunning => _running;

  @override
  void start() => _running = true;

  @override
  void stop() => _running = false;

  @override
  void reset() => reading = Duration.zero;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A [CloudSync] whose account, status and cloud copy the test drives.
class FakeCloudSync implements CloudSync {
  final ValueNotifier<SyncAccount?> accountValue = ValueNotifier(null);
  final ValueNotifier<SyncStatus> statusValue = ValueNotifier(const SyncOff());
  final StreamController<SyncedDocument?> remote =
      StreamController<SyncedDocument?>.broadcast();
  final List<({String name, Map<String, Object?> data, int updatedAt})> pushes =
      [];
  final List<bool> switches = [];
  bool enabledValue = true;
  DateTime? lastSyncedValue;
  int retries = 0;
  int deletes = 0;
  Exception? deleteFailure;

  /// What each push leaves in [status]; done by default.
  SyncStatus Function() onPush = () => SyncDone(DateTime(2026));

  @override
  ValueListenable<SyncAccount?> get account => accountValue;

  @override
  ValueListenable<SyncStatus> get status => statusValue;

  @override
  DateTime? get lastSynced => lastSyncedValue;

  @override
  bool get enabled => enabledValue;

  @override
  Future<void> setEnabled(bool on) async {
    switches.add(on);
    enabledValue = on;
  }

  @override
  Future<void> push(
    String name,
    Map<String, Object?> data, {
    required int updatedAt,
  }) async {
    pushes.add((name: name, data: data, updatedAt: updatedAt));
    statusValue.value = onPush();
  }

  @override
  Stream<SyncedDocument?> watch(String name) => remote.stream;

  @override
  Future<void> retry() async => retries++;

  @override
  Future<void> deleteAll() async {
    deletes++;
    if (deleteFailure case final e?) throw e;
  }
}

/// Sets the test device's 24-hour switch on, so a clock style left unpicked
/// reads 24-hour (the English test locale alone reads 12-hour).
/// The root `MediaQuery` outlives a test and only re-reads the device on a
/// platform callback, so this fires one.
void deviceOn24h(WidgetTester tester) {
  final dispatcher = tester.platformDispatcher;
  dispatcher.alwaysUse24HourFormatTestValue = true;
  dispatcher.onMetricsChanged?.call();
  addTearDown(() {
    dispatcher.clearAlwaysUse24HourTestValue();
    dispatcher.onMetricsChanged?.call();
  });
}
