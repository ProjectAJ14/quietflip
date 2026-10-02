import 'dart:async';
import 'dart:convert';

import 'package:cloud_sync/cloud_sync.dart';
import 'package:core/core.dart' as core;
import 'package:core/core.dart' show Logger;
import 'package:device_services/device_services.dart';
import 'package:di/di.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flip_clock/data/models/skin.dart';
import 'package:flip_clock/data/repositories/settings_repository_imp.dart';
import 'package:flip_clock/flip_clock.dart' as flip_clock;
import 'package:flip_clock/flip_clock.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flip_clock/state/settings_sync.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// One device: its store, settings controller, a cloud double and the
/// coordinator, all on a controllable clock.
class _Device {
  _Device(this.time, {Map<String, String> saved = const {}}) {
    store.data.addAll(saved);
    repository = SettingsRepositoryImp(store: store, logger: logger);
    settings = SettingsController(repository: repository, alerts: FakeAlerts());
    sync = SettingsSync(
      settings: settings,
      sync: cloud,
      store: store,
      now: () => now,
    );
  }

  final FakeAsync time;
  final store = FakeStore();
  final cloud = FakeCloudSync();
  final logger = _Logger();
  late final SettingsRepositoryImp repository;
  late final SettingsController settings;
  late final SettingsSync sync;
  DateTime now = DateTime(2026, 10, 2, 9);

  int get stamp => int.parse(store.data[SettingsSync.updatedAtKey]!);

  ClockSettings get saved => ClockSettings.fromJson(
    jsonDecode(store.data[SettingsRepositoryImp.settingsKey]!)
        as Map<String, Object?>,
  );

  void start() {
    unawaited(settings.load());
    unawaited(sync.start());
    time.flushMicrotasks();
  }

  void change(ClockSettings Function(ClockSettings) edit) {
    unawaited(settings.update(edit(settings.state)));
    time.flushMicrotasks();
  }

  void remote(Map<String, Object?>? data, int updatedAt) {
    cloud.remote.add(
      data == null ? null : SyncedDocument(data: data, updatedAt: updatedAt),
    );
    time.flushMicrotasks();
  }

  void close() {
    unawaited(sync.close());
    unawaited(settings.close());
    time.flushMicrotasks();
  }
}

class _Logger implements Logger {
  @override
  Object get logger => this;

  @override
  void d(String message) {}

  @override
  void i(String message) {}

  @override
  void w(String message) {}

  @override
  void e(String message, [Object? error, StackTrace? stackTrace]) {}
}

const _second = Duration(seconds: 1);

void main() {
  test('a change is pushed once, 1 s later, with its stamp', () {
    fakeAsync((time) {
      final d = _Device(time)..start();
      d.change((s) => s.copyWith(theme: ClockTheme.light));
      expect(d.stamp, d.now.millisecondsSinceEpoch);
      time.elapse(const Duration(milliseconds: 999));
      expect(d.cloud.pushes, isEmpty);
      time.elapse(const Duration(milliseconds: 1));
      final push = d.cloud.pushes.single;
      expect(push.name, SettingsSync.documentName);
      expect(push.updatedAt, d.now.millisecondsSinceEpoch);
      expect(push.data['theme'], 'light');
      d.close();
    });
  });

  test('quick changes (a slider drag) send one write', () {
    fakeAsync((time) {
      final d = _Device(time)..start();
      for (var corner = 0; corner <= 20; corner += 2) {
        d.change((s) => s.copyWith(corner: corner.toDouble()));
        time.elapse(const Duration(milliseconds: 200));
      }
      time.elapse(_second);
      expect(d.cloud.pushes.single.data['corner'], 20.0);
      d.close();
    });
  });

  test('device-only keys never reach the cloud, and changing only them '
      'pushes nothing', () {
    fakeAsync((time) {
      final d = _Device(time)..start();
      d.change(
        (s) => s.copyWith(
          systemAlerts: true,
          lastMode: ClockMode.stopwatch,
          orientation: ClockOrientation.portrait,
          digitBrightness: 0.5,
        ),
      );
      time.elapse(_second * 2);
      expect(d.cloud.pushes, isEmpty);
      expect(d.store.data, isNot(contains(SettingsSync.updatedAtKey)));
      d.change((s) => s.copyWith(use24h: false));
      time.elapse(_second);
      final data = d.cloud.pushes.single.data;
      for (final key in SettingsSync.deviceOnly) {
        expect(data, isNot(contains(key)), reason: key);
      }
      expect(data['use24h'], isFalse);
      expect(data, contains('customSkins'));
      d.close();
    });
  });

  test('a newer cloud copy is applied, keeps device-only fields, is saved '
      'with its stamp and is not echoed back', () {
    fakeAsync((time) {
      final d = _Device(
        time,
        saved: {
          SettingsRepositoryImp.settingsKey: jsonEncode(
            const ClockSettings(
              digitBrightness: 0.4,
              orientation: ClockOrientation.landscape,
              lastMode: ClockMode.stopwatch,
            ).toJson(),
          ),
          SettingsSync.updatedAtKey: '100',
        },
      )..start();
      final remote = const ClockSettings(
        theme: ClockTheme.light,
        corner: 6,
        digitBrightness: 1,
        systemAlerts: true,
      ).toJson();
      d.remote(remote, 200);
      expect(d.settings.state.theme, ClockTheme.light);
      expect(d.settings.state.corner, 6);
      expect(d.settings.state.digitBrightness, 0.4);
      expect(d.settings.state.orientation, ClockOrientation.landscape);
      expect(d.settings.state.lastMode, ClockMode.stopwatch);
      expect(d.settings.state.systemAlerts, isFalse);
      expect(d.saved.theme, ClockTheme.light);
      expect(d.stamp, 200);
      time.elapse(_second * 2);
      expect(d.cloud.pushes, isEmpty);
      // A later local change still syncs.
      d.change((s) => s.copyWith(use24h: false));
      time.elapse(_second);
      expect(d.cloud.pushes, hasLength(1));
      d.close();
    });
  });

  test('an older cloud copy is answered with the local one; an equal one '
      'with nothing', () {
    fakeAsync((time) {
      final d = _Device(
        time,
        saved: {
          SettingsRepositoryImp.settingsKey: jsonEncode(
            const ClockSettings(theme: ClockTheme.light).toJson(),
          ),
          SettingsSync.updatedAtKey: '300',
        },
      )..start();
      d.remote(const ClockSettings().toJson(), 200);
      expect(d.settings.state.theme, ClockTheme.light);
      final push = d.cloud.pushes.single;
      expect(push.updatedAt, 300);
      expect(push.data['theme'], 'light');
      d.remote(push.data, 300);
      expect(d.cloud.pushes, hasLength(1));
      d.close();
    });
  });

  test(
    'a device that never stamped adopts the cloud copy on first sign-in',
    () {
      fakeAsync((time) {
        final d = _Device(
          time,
          saved: {
            SettingsRepositoryImp.settingsKey: jsonEncode(
              const ClockSettings(theme: ClockTheme.light).toJson(),
            ),
          },
        )..start();
        d.remote(const ClockSettings(skinId: 'bold').toJson(), 5);
        expect(d.settings.state.skinId, 'bold');
        expect(d.settings.state.theme, ClockTheme.dark);
        expect(d.stamp, 5);
        expect(d.cloud.pushes, isEmpty);
        d.close();
      });
    },
  );

  test('the first device with nothing in the cloud uploads, stamped now', () {
    fakeAsync((time) {
      final d = _Device(time)..start();
      d.remote(null, 0);
      final push = d.cloud.pushes.single;
      expect(push.updatedAt, d.now.millisecondsSinceEpoch);
      expect(d.stamp, d.now.millisecondsSinceEpoch);
      d.close();
    });
  });

  test('custom skins sync, including maps decoded loosely (web)', () {
    fakeAsync((time) {
      final d = _Device(time)..start();
      const skin = Skin(
        id: 'custom-1',
        name: 'Mine',
        digitColor: Color(0xFF112233),
      );
      final settings = const ClockSettings(
        skinId: 'custom-1',
        customSkins: [skin],
      ).toJson();
      // Nested maps as Map<Object?, Object?>, numbers as doubles.
      final loose = <String, Object?>{
        ...settings,
        'customSkins': [
          <Object?, Object?>{...skin.toJson()},
        ],
      };
      d.remote(loose, 9);
      expect(d.settings.state.customSkins.single.name, 'Mine');
      expect(d.settings.state.customSkins.single.digitColor, skin.digitColor);
      d.change((s) => s.copyWith(use24h: false));
      time.elapse(_second);
      expect(
        (d.cloud.pushes.single.data['customSkins']! as List).single,
        skin.toJson(),
      );
      d.close();
    });
  });

  test('the device copy is saved even when the push fails', () {
    fakeAsync((time) {
      final d = _Device(time)..start();
      d.cloud.onPush = () => SyncFailed(DateTime(2026), SyncFailure.offline);
      d.change((s) => s.copyWith(theme: ClockTheme.light));
      expect(d.saved.theme, ClockTheme.light);
      time.elapse(_second);
      expect(d.cloud.status.value, isA<SyncFailed>());
      expect(d.saved.theme, ClockTheme.light);
      d.close();
    });
  });

  test('close cancels the pending push and both subscriptions', () {
    fakeAsync((time) {
      final d = _Device(time)..start();
      expect(d.cloud.remote.hasListener, isTrue);
      d.change((s) => s.copyWith(theme: ClockTheme.light));
      unawaited(d.sync.close());
      time.flushMicrotasks();
      expect(d.cloud.remote.hasListener, isFalse);
      time.elapse(_second * 2);
      expect(d.cloud.pushes, isEmpty);
      expect(time.pendingTimers, isEmpty);
      d.change((s) => s.copyWith(use24h: false));
      time.elapse(_second * 2);
      expect(d.cloud.pushes, isEmpty);
      unawaited(d.settings.close());
      time.flushMicrotasks();
    });
  });

  group('init', () {
    setUp(() async {
      await core.init();
      di
        ..register<KeyValueStore>(FakeStore())
        ..register<LocalAlerts>(FakeAlerts())
        ..register<SoundPlayer>(FakeSound())
        ..register<OrientationLock>(FakeOrientation());
    });
    tearDown(di.reset);

    test('without a cloud sync nothing syncs', () async {
      await flip_clock.init();
      expect(di.has<SettingsSync>(), isFalse);
    });

    test(
      'with a cloud sync, changes are pushed and di.reset closes it',
      () async {
        final cloud = FakeCloudSync();
        await flip_clock.init(sync: cloud);
        expect(di.has<SettingsSync>(), isTrue);
        expect(cloud.remote.hasListener, isTrue);
        await di.reset();
        expect(cloud.remote.hasListener, isFalse);
      },
    );
  });
}
