import 'package:device_services/device_services.dart' as device_services;
import 'package:flip_clock/flip_clock.dart' as flip_clock;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Flutter tests register no plugins. Storage gets an in-memory store and the
/// audio channels answer with nothing (audioplayers creates its players in the
/// constructor and would otherwise report an unawaited error). The device
/// info channel answers with nothing too: on iOS, `device_services.init()`
/// asks for the model (iPad check), and a missing plugin there made the
/// players' event streams fail in the bootstrap test. Notifications,
/// wake lock and full screen stay missing, so these tests also prove the clock
/// boots when those services are unavailable.
void useInMemoryStorage() {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  for (final channel in [
    'xyz.luan/audioplayers',
    'xyz.luan/audioplayers.global',
    'dev.fluttercommunity.plus/device_info',
  ]) {
    messenger.setMockMethodCallHandler(
      MethodChannel(channel),
      (_) async => null,
    );
  }
}

/// The two bootstrap steps the clock needs; call after `core.init()`.
Future<void> initClock() async {
  useInMemoryStorage();
  await device_services.init();
  await flip_clock.init();
}
