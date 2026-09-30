import 'package:device_services/device_services.dart';
import 'package:flutter/foundation.dart';

class FakeStore implements KeyValueStore {
  final Map<String, String> data = {};
  Exception? failure;

  @override
  Future<String?> read(String key) async {
    if (failure case final e?) throw e;
    return data[key];
  }

  @override
  Future<void> write(String key, String value) async {
    if (failure case final e?) throw e;
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
  }) async => scheduled[id] = at;

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
  int flips = 0;
  int alarms = 0;
  int stops = 0;

  @override
  Future<void> playFlip() async => flips++;

  @override
  Future<void> playAlarm() async => alarms++;

  @override
  Future<void> stopAlarm() async => stops++;
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
