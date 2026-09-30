import 'package:device_services/src/full_screen/browser_full_screen.dart';
import 'package:device_services/src/full_screen/platform_full_screen_controller.dart';
import 'package:device_services/src/full_screen/window_full_screen_listener.dart';
import 'package:device_services/src/screen_wake/wakelock_screen_wake.dart';
import 'package:device_services/src/storage/preferences_key_value_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

class _MockPreferences extends Mock implements SharedPreferencesAsync {}

void main() {
  late FakeLogger logger;
  setUp(() => logger = FakeLogger());

  group('PlatformFullScreenController', () {
    test('toggle applies and flips active; exit leaves', () async {
      final applied = <bool>[];
      final controller = PlatformFullScreenController(
        logger: logger,
        apply: (on) async => applied.add(on),
      );
      await controller.exit();
      expect(applied, isEmpty);
      await controller.toggle();
      expect(controller.active.value, isTrue);
      await controller.exit();
      expect(controller.active.value, isFalse);
      expect(applied, [true, false]);
      controller.dispose();
    });

    test('unsupported platform only flips active', () async {
      final controller = PlatformFullScreenController(logger: logger);
      await controller.toggle();
      expect(controller.active.value, isTrue);
    });

    test('failing platform call is logged and falls back', () async {
      final controller = PlatformFullScreenController(
        logger: logger,
        apply: (_) => Future.error(StateError('denied')),
      );
      await controller.toggle();
      expect(controller.active.value, isTrue);
      expect(logger.errors, hasLength(1));
    });

    test('external changes update active', () {
      final controller = PlatformFullScreenController(logger: logger);
      controller.onExternalChange(true);
      expect(controller.active.value, isTrue);
    });

    test('browser API is absent off the web', () {
      expect(browserFullScreen(), isNull);
    });

    test('window listener forwards enter and leave', () {
      final changes = <bool>[];
      WindowFullScreenListener(changes.add)
        ..onWindowEnterFullScreen()
        ..onWindowLeaveFullScreen();
      expect(changes, [true, false]);
    });
  });

  group('WakelockScreenWake', () {
    test('passes the flag through', () async {
      bool? enabled;
      await WakelockScreenWake(
        logger: logger,
        toggle: ({required enable}) async => enabled = enable,
      ).setEnabled(true);
      expect(enabled, isTrue);
    });

    test('logs instead of throwing when unsupported', () async {
      await WakelockScreenWake(
        logger: logger,
        toggle: ({required enable}) => Future.error(UnsupportedError('no')),
      ).setEnabled(true);
      expect(logger.errors, hasLength(1));
    });
  });

  group('PreferencesKeyValueStore', () {
    late _MockPreferences preferences;
    late PreferencesKeyValueStore store;
    setUp(() {
      preferences = _MockPreferences();
      store = PreferencesKeyValueStore(
        preferences: preferences,
        logger: logger,
      );
    });

    test('reads, writes and deletes', () async {
      when(() => preferences.getString('k')).thenAnswer((_) async => 'v');
      when(() => preferences.setString('k', 'v')).thenAnswer((_) async {});
      when(() => preferences.remove('k')).thenAnswer((_) async {});
      expect(await store.read('k'), 'v');
      await store.write('k', 'v');
      await store.delete('k');
      verify(() => preferences.setString('k', 'v')).called(1);
      verify(() => preferences.remove('k')).called(1);
    });

    test('storage failure reads as absent and is logged', () async {
      when(() => preferences.getString(any())).thenThrow(StateError('io'));
      when(
        () => preferences.setString(any(), any()),
      ).thenThrow(StateError('io'));
      when(() => preferences.remove(any())).thenThrow(StateError('io'));
      expect(await store.read('k'), isNull);
      await store.write('k', 'v');
      await store.delete('k');
      expect(logger.errors, hasLength(3));
    });
  });
}
