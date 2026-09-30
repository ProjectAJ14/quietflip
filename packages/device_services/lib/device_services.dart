/// Platform adapters behind small contracts: full screen, screen wake, local
/// alerts, sounds and key-value storage.
library;

import 'package:audioplayers/audioplayers.dart';
import 'package:core/core.dart';
import 'package:device_services/src/contracts/index.dart';
import 'package:device_services/src/full_screen/browser_full_screen.dart'
    if (dart.library.js_interop) 'package:device_services/src/full_screen/browser_full_screen_web.dart'
    as browser;
import 'package:device_services/src/full_screen/platform_full_screen_controller.dart';
import 'package:device_services/src/full_screen/window_full_screen_listener.dart';
import 'package:device_services/src/guarded.dart';
import 'package:device_services/src/local_alerts/local_alerts_config.dart';
import 'package:device_services/src/local_alerts/notification_local_alerts.dart';
import 'package:device_services/src/screen_wake/wakelock_screen_wake.dart';
import 'package:device_services/src/sound/audio_sound_player.dart';
import 'package:device_services/src/storage/preferences_key_value_store.dart';
import 'package:di/di.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:window_manager/window_manager.dart';

export 'src/contracts/index.dart';
export 'src/full_screen/platform_full_screen_controller.dart'
    show BrowserFullScreen;
export 'src/local_alerts/local_alerts_config.dart';

/// Registers every contract's platform implementation with `di`.
///
/// Call after `core.init()` (needs `Logger`) and after
/// `WidgetsFlutterBinding.ensureInitialized()`. The optional parameters exist
/// so tests can inject fakes; the app passes only [alerts].
Future<void> init({
  LocalAlertsConfig alerts = const LocalAlertsConfig(),
  bool isWeb = kIsWeb,
  TargetPlatform? platform,
  BrowserFullScreen? Function() browserFullScreen = browser.browserFullScreen,
  WindowManager? windowManager,
  Future<void> Function({required bool enable}) wakelock = WakelockPlus.toggle,
  FlutterLocalNotificationsPlugin? notifications,
  SharedPreferencesAsync? preferences,
  AudioPlayer Function() audioPlayer = AudioPlayer.new,
}) async {
  final logger = di.get<Logger>();
  final target = platform ?? defaultTargetPlatform;

  await _registerFullScreen(
    logger,
    isWeb: isWeb,
    platform: target,
    browserFullScreen: browserFullScreen,
    windowManager: windowManager ?? WindowManager.instance,
  );
  di.register<ScreenWake>(WakelockScreenWake(logger: logger, toggle: wakelock));
  di.register<LocalAlerts>(
    NotificationLocalAlerts(
      plugin: notifications ?? FlutterLocalNotificationsPlugin(),
      logger: logger,
      isWeb: isWeb,
      platform: target,
      config: alerts,
    ),
  );
  final sounds = AudioSoundPlayer(
    flip: audioPlayer(),
    alarm: audioPlayer(),
    logger: logger,
  );
  di.register<SoundPlayer>(sounds, dispose: (_) => sounds.dispose());
  di.register<KeyValueStore>(
    PreferencesKeyValueStore(
      preferences: preferences ?? SharedPreferencesAsync(),
      logger: logger,
    ),
  );
  logger.i('device_services initialized');
}

Future<void> _registerFullScreen(
  Logger logger, {
  required bool isWeb,
  required TargetPlatform platform,
  required BrowserFullScreen? Function() browserFullScreen,
  required WindowManager windowManager,
}) async {
  if (isWeb) {
    // Prefixed-only browsers (older iPad Safari) can throw here: treat as
    // unsupported so the full-viewport fallback still works.
    final api = await guarded(
      logger,
      'browser full screen',
      () async => browserFullScreen(),
      null,
    );
    final controller = PlatformFullScreenController(
      logger: logger,
      apply: api?.apply,
    );
    final cancel = api?.listen(controller.onExternalChange);
    di.register<FullScreenController>(
      controller,
      dispose: (_) {
        cancel?.call();
        controller.dispose();
      },
    );
    return;
  }
  switch (platform) {
    case TargetPlatform.macOS || TargetPlatform.windows || TargetPlatform.linux:
      final ready = await guarded(logger, 'window manager init', () async {
        await windowManager.ensureInitialized();
        return true;
      }, false);
      final controller = PlatformFullScreenController(
        logger: logger,
        apply: ready ? windowManager.setFullScreen : null,
      );
      final listener = WindowFullScreenListener(controller.onExternalChange);
      if (ready) windowManager.addListener(listener);
      di.register<FullScreenController>(
        controller,
        dispose: (_) {
          if (ready) windowManager.removeListener(listener);
          controller.dispose();
        },
      );
    case TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.fuchsia:
      final controller = PlatformFullScreenController(
        logger: logger,
        apply: (on) => SystemChrome.setEnabledSystemUIMode(
          on ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
        ),
      );
      di.register<FullScreenController>(
        controller,
        dispose: (_) => controller.dispose(),
      );
  }
}
