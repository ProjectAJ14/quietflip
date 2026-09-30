import 'package:device_services/device_services.dart';
import 'package:device_services/src/brightness/plugin_screen_brightness.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  late FakeLogger logger;
  late List<String> calls;
  setUp(() {
    logger = FakeLogger();
    calls = [];
  });

  PluginScreenBrightness brightness({bool supported = true, Object? fail}) =>
      PluginScreenBrightness(
        logger: logger,
        supported: supported,
        read: () async {
          calls.add('read');
          if (fail != null) throw fail;
          return 0.4;
        },
        write: (value) async {
          calls.add('write $value');
          if (fail != null) throw fail;
        },
        restore: () async {
          calls.add('restore');
          if (fail != null) throw fail;
        },
      );

  test(
    'unsupported: current is 1.0, set and reset never call the plugin',
    () async {
      final subject = brightness(supported: false);
      expect(subject.supported, isFalse);
      expect(await subject.current(), 1.0);
      await subject.set(0.2);
      await subject.reset();
      expect(calls, isEmpty);
    },
  );

  test('supported: reads, clamps writes to 0..1 and restores', () async {
    final subject = brightness();
    expect(subject.supported, isTrue);
    expect(await subject.current(), 0.4);
    await subject.set(-0.5);
    await subject.set(1.7);
    await subject.set(0.3);
    await subject.reset();
    expect(calls, ['read', 'write 0.0', 'write 1.0', 'write 0.3', 'restore']);
    expect(logger.errors, isEmpty);
  });

  test('each failing call is logged and rethrown typed', () async {
    final cause = StateError('no activity');
    final subject = brightness(fail: cause);
    for (final (operation, run) in <(String, Future<void> Function())>[
      ('current', subject.current),
      ('set', () => subject.set(0.5)),
      ('reset', subject.reset),
    ]) {
      await expectLater(
        run(),
        throwsA(
          isA<ScreenBrightnessException>()
              .having((e) => e.operation, 'operation', operation)
              .having((e) => e.cause, 'cause', cause),
        ),
      );
    }
    expect(logger.errors, [
      'device_services: brightness current failed',
      'device_services: brightness set failed',
      'device_services: brightness reset failed',
    ]);
  });

  test('exception toString names the operation and cause', () {
    expect(
      const ScreenBrightnessException('set', 'boom').toString(),
      'ScreenBrightnessException(set): boom',
    );
    expect(
      const ScreenBrightnessException('reset').toString(),
      'ScreenBrightnessException(reset): null',
    );
  });
}
