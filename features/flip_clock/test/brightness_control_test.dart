import 'dart:convert';

import 'package:core/core.dart' as core;
import 'package:core/core.dart' show Logger;
import 'package:di/di.dart';
import 'package:flip_clock/data/models/clock_settings.dart';
import 'package:flip_clock/data/repositories/settings_repository_imp.dart';
import 'package:flip_clock/state/brightness_control.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

class _Logger implements Logger {
  final List<String> warnings = [];

  @override
  Object get logger => this;

  @override
  void d(String message) {}

  @override
  void i(String message) {}

  @override
  void w(String message) => warnings.add(message);

  @override
  void e(String message, [Object? error, StackTrace? stackTrace]) {}
}

void main() {
  late FakeStore store;
  late SettingsController settings;
  late _Logger logger;

  setUp(() async {
    await core.init();
    store = FakeStore();
    logger = _Logger();
    settings = SettingsController(
      repository: SettingsRepositoryImp(store: store, logger: di.get<Logger>()),
      alerts: FakeAlerts(),
    );
  });
  tearDown(() async {
    await settings.close();
    await di.reset();
  });

  BrightnessControl build(FakeScreenBrightness device) =>
      BrightnessControl(device: device, settings: settings, logger: logger);

  double saved() =>
      (jsonDecode(store.data['flip_clock.settings']!)
              as Map<String, Object?>)['digitBrightness']!
          as double;

  test('key step is 10%', () => expect(BrightnessControl.keyStep, 0.1));

  group('device supported', () {
    test('begin reads current; change adds and clamps 0..1', () async {
      final device = FakeScreenBrightness(level: 0.9);
      final c = build(device);
      expect(c.usesDevice, isTrue);
      await c.begin();
      expect(c.value, 0.9);
      expect(await c.change(0.3), 1.0);
      expect(device.level, 1.0);
      device.level = 0.1;
      await c.begin();
      expect(await c.change(-0.5), 0.0);
      expect(c.value, 0.0);
      expect(settings.state.digitBrightness, 1.0);
      expect(store.data, isEmpty);
      expect(device.calls, ['current', 'set', 'current', 'set']);
    });

    test('change without begin reads current first', () async {
      final device = FakeScreenBrightness(level: 0.4);
      final c = build(device);
      expect(c.value, 1.0);
      expect(await c.change(0.1), closeTo(0.5, 1e-9));
      expect(device.calls, ['current', 'set']);
    });

    test(
      'set failing falls back to in-app for this and later changes',
      () async {
        final device = FakeScreenBrightness(level: 0.5)..failing.add('set');
        final c = build(device);
        await c.begin();
        expect(await c.change(-0.3), closeTo(0.7, 1e-9));
        expect(c.usesDevice, isFalse);
        expect(settings.state.digitBrightness, closeTo(0.7, 1e-9));
        device.failing.clear();
        await c.begin();
        expect(await c.change(-0.9), 0.2);
        expect(c.value, 0.2);
        expect(device.calls, ['current', 'set']);
        expect(logger.warnings, hasLength(1));
        expect(logger.warnings.single, contains('dimming the app'));
      },
    );

    test('current failing on begin falls back', () async {
      final device = FakeScreenBrightness()..failing.add('current');
      final c = build(device);
      await c.begin();
      expect(c.usesDevice, isFalse);
      expect(c.value, 1.0);
      expect(await c.change(-0.2), closeTo(0.8, 1e-9));
      expect(device.calls, ['current']);
      expect(logger.warnings, hasLength(1));
    });

    test('reset after a change calls device.reset once', () async {
      final device = FakeScreenBrightness();
      final c = build(device);
      await c.change(0.1);
      await c.reset();
      await c.reset();
      expect(device.calls.where((call) => call == 'reset'), hasLength(1));
    });

    test('reset without a change does nothing', () async {
      final device = FakeScreenBrightness();
      final c = build(device);
      await c.begin();
      await c.reset();
      expect(device.calls, ['current']);
    });

    test('reset failing is swallowed and logged', () async {
      final device = FakeScreenBrightness()..failing.add('reset');
      final c = build(device);
      await c.change(0.1);
      await expectLater(c.reset(), completes);
      expect(logger.warnings.single, contains('reset failed'));
    });
  });

  group('device unsupported', () {
    test('change drives digitBrightness clamped 0.2..1 and saves', () async {
      final device = FakeScreenBrightness(supported: false);
      final c = build(device);
      expect(c.usesDevice, isFalse);
      await c.begin();
      expect(await c.change(0.5), 1.0);
      expect(await c.change(-0.3), closeTo(0.7, 1e-9));
      expect(saved(), closeTo(0.7, 1e-9));
      expect(await c.change(-2), ClockSettings.minBrightness);
      expect(c.value, 0.2);
      expect(saved(), 0.2);
      await c.reset();
      expect(device.calls, isEmpty);
      expect(logger.warnings, isEmpty);
    });
  });
}
