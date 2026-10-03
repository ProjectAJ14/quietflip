import 'package:audioplayers/audioplayers.dart';
import 'package:core/core.dart' show Logger;
import 'package:device_services/device_services.dart';
import 'package:di/di.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:window_manager/window_manager.dart';

import 'fakes.dart';

class _MockWindowManager extends Mock implements WindowManager {}

class _MockPlayer extends Mock implements AudioPlayer {}

class _MockPreferences extends Mock implements SharedPreferencesAsync {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeLogger logger;
  late _MockWindowManager windowManager;
  late List<_MockPlayer> players;

  setUpAll(() => registerFallbackValue(WindowFullScreenListenerFallback()));

  setUp(() {
    logger = FakeLogger();
    di.register<Logger>(logger);
    windowManager = _MockWindowManager();
    when(windowManager.ensureInitialized).thenAnswer((_) async {});
    when(() => windowManager.setFullScreen(any())).thenAnswer((_) async {});
    players = [];
  });

  tearDown(di.reset);

  Future<void> run({
    bool isWeb = false,
    TargetPlatform platform = TargetPlatform.android,
    BrowserFullScreen? browser,
    bool Function()? wakeCalled,
    Future<void> Function(List<DeviceOrientation>)? orientations,
    Future<bool> Function()? isIPad,
    List<String>? brightness,
  }) => init(
    orientations: orientations ?? (_) async {},
    isIPad: isIPad ?? () async => false,
    readBrightness: () async {
      brightness?.add('read');
      return 0.5;
    },
    writeBrightness: (value) async => brightness?.add('write $value'),
    restoreBrightness: () async => brightness?.add('restore'),
    isWeb: isWeb,
    platform: platform,
    browserFullScreen: () => browser,
    windowManager: windowManager,
    wakelock: ({required enable}) async {},
    preferences: _MockPreferences(),
    audioPlayer: () {
      final player = _MockPlayer();
      when(player.dispose).thenAnswer((_) async {});
      players.add(player);
      return player;
    },
  );

  test('registers every contract', () async {
    await run();
    expect(di.get<FullScreenController>(), isNotNull);
    expect(di.get<ScreenWake>(), isNotNull);
    expect(di.get<LocalAlerts>(), isNotNull);
    expect(di.get<SoundPlayer>(), isNotNull);
    expect(di.get<KeyValueStore>(), isNotNull);
    expect(di.get<OrientationLock>(), isNotNull);
    expect(di.get<ScreenBrightness>(), isNotNull);
    await di.get<ScreenWake>().setEnabled(true);
    await di.reset();
    di.register<Logger>(logger);
    expect(players, hasLength(2), reason: 'alarm and preview players');
    for (final player in players) {
      verify(player.dispose).called(1);
    }
  });

  test('orientation lock is supported only on Android and iOS', () async {
    final applied = <List<DeviceOrientation>>[];
    for (final (web, platform, supported) in [
      (false, TargetPlatform.android, true),
      (false, TargetPlatform.iOS, true),
      (false, TargetPlatform.macOS, false),
      (true, TargetPlatform.android, false),
    ]) {
      await run(
        isWeb: web,
        platform: platform,
        orientations: (o) async => applied.add(o),
      );
      final lock = di.get<OrientationLock>();
      expect(lock.supported, supported, reason: '$platform web=$web');
      await lock.set(ScreenOrientation.portrait);
      await di.reset();
      di.register<Logger>(logger);
    }
    expect(applied, hasLength(2));
  });

  test('orientation lock is unsupported on iPad', () async {
    var checks = 0;
    final applied = <List<DeviceOrientation>>[];
    await run(
      platform: TargetPlatform.iOS,
      isIPad: () async {
        checks++;
        return true;
      },
      orientations: (o) async => applied.add(o),
    );
    final lock = di.get<OrientationLock>();
    expect(lock.supported, isFalse);
    await lock.set(ScreenOrientation.landscape);
    expect(applied, isEmpty);
    expect(checks, 1);
  });

  test('the iPad check runs only on native iOS', () async {
    for (final (web, platform) in [
      (false, TargetPlatform.android),
      (true, TargetPlatform.iOS),
    ]) {
      await run(
        isWeb: web,
        platform: platform,
        isIPad: () => fail('checked on $platform web=$web'),
      );
      await di.reset();
      di.register<Logger>(logger);
    }
  });

  test('a failing iPad check is logged and keeps the lock', () async {
    await run(
      platform: TargetPlatform.iOS,
      isIPad: () => Future.error(PlatformException(code: 'no')),
    );
    expect(di.get<OrientationLock>().supported, isTrue);
    expect(logger.errors, hasLength(1));
  });

  test('the default iPad check reads the device model', () async {
    // No native device_info side in tests: the lookup fails, is logged and
    // the lock stays supported.
    await init(
      platform: TargetPlatform.iOS,
      preferences: _MockPreferences(),
      audioPlayer: () {
        final player = _MockPlayer();
        when(player.dispose).thenAnswer((_) async {});
        return player;
      },
    );
    expect(di.get<OrientationLock>().supported, isTrue);
    expect(logger.errors, hasLength(1));
  });

  test('screen brightness is supported only on Android and iOS', () async {
    final calls = <String>[];
    for (final (web, platform, supported) in [
      (false, TargetPlatform.android, true),
      (false, TargetPlatform.iOS, true),
      (false, TargetPlatform.windows, false),
      (true, TargetPlatform.iOS, false),
    ]) {
      await run(isWeb: web, platform: platform, brightness: calls);
      final brightness = di.get<ScreenBrightness>();
      expect(brightness.supported, supported, reason: '$platform web=$web');
      expect(await brightness.current(), supported ? 0.5 : 1.0);
      await brightness.set(0.2);
      await brightness.reset();
      await di.reset();
      di.register<Logger>(logger);
    }
    expect(calls, [
      ...['read', 'write 0.2', 'restore'],
      ...['read', 'write 0.2', 'restore'],
    ]);
  });

  test('defaults to the real SDK objects', () async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    await init(audioPlayer: _MockPlayer.new);
    final store = di.get<KeyValueStore>();
    await store.write('k', 'v');
    expect(await store.read('k'), 'v');
    // The real brightness plugin has no native side in tests: typed failure.
    await expectLater(
      di.get<ScreenBrightness>().current(),
      throwsA(isA<ScreenBrightnessException>()),
    );
  });

  test('mobile full screen uses immersive system UI', () async {
    final modes = <Object?>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'SystemChrome.setEnabledSystemUIMode') {
            modes.add(call.arguments);
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await run(platform: TargetPlatform.iOS);
    final controller = di.get<FullScreenController>();
    await controller.toggle();
    await controller.toggle();
    expect(modes, [
      SystemUiMode.immersiveSticky.toString(),
      SystemUiMode.edgeToEdge.toString(),
    ]);
  });

  test('desktop full screen drives the window and follows it', () async {
    await run(platform: TargetPlatform.macOS);
    final controller = di.get<FullScreenController>();
    await controller.toggle();
    verify(() => windowManager.setFullScreen(true)).called(1);
    final listener =
        verify(() => windowManager.addListener(captureAny())).captured.single
            as WindowListener;
    listener.onWindowLeaveFullScreen();
    expect(controller.active.value, isFalse);
    await di.reset();
    di.register<Logger>(logger);
    verify(() => windowManager.removeListener(listener)).called(1);
  });

  test('desktop without a window manager falls back to app chrome', () async {
    when(windowManager.ensureInitialized).thenThrow(MissingPluginException());
    await run(platform: TargetPlatform.windows);
    await di.get<FullScreenController>().toggle();
    verifyNever(() => windowManager.setFullScreen(any()));
    verifyNever(() => windowManager.addListener(any()));
    expect(logger.errors, hasLength(1));
    await di.reset();
    di.register<Logger>(logger);
    verifyNever(() => windowManager.removeListener(any()));
  });

  test('web full screen uses the browser API and its events', () async {
    final applied = <bool>[];
    void Function(bool)? onChange;
    var cancelled = false;
    await run(
      isWeb: true,
      browser: (
        apply: (on) async => applied.add(on),
        listen: (callback) {
          onChange = callback;
          return () => cancelled = true;
        },
      ),
    );
    final controller = di.get<FullScreenController>();
    await controller.toggle();
    expect(applied, [true]);
    onChange!(false);
    expect(controller.active.value, isFalse);
    await di.reset();
    di.register<Logger>(logger);
    expect(cancelled, isTrue);
  });

  test('web without the browser API still toggles', () async {
    await run(isWeb: true);
    final controller = di.get<FullScreenController>();
    await controller.toggle();
    expect(controller.active.value, isTrue);
  });

  test(
    'a throwing browser API lookup is logged and means unsupported',
    () async {
      await init(
        isWeb: true,
        browserFullScreen: () => throw StateError('fullscreenEnabled'),
        preferences: _MockPreferences(),
        audioPlayer: () {
          final player = _MockPlayer();
          when(player.dispose).thenAnswer((_) async {});
          return player;
        },
      );
      expect(logger.errors, hasLength(1));
      final controller = di.get<FullScreenController>();
      await controller.toggle();
      expect(controller.active.value, isTrue);
    },
  );
}

class WindowFullScreenListenerFallback with WindowListener {}
