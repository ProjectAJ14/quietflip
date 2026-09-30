import 'package:core/core.dart';
import 'package:device_services/src/contracts/index.dart';
import 'package:device_services/src/guarded.dart';
import 'package:device_services/src/local_alerts/local_alerts_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// [LocalAlerts] over `flutter_local_notifications` (all platforms, web
/// included through its service-worker plugin).
///
/// The plugin is initialised on first use, never at startup, so no permission
/// prompt appears until the user asks for alerts.
class NotificationLocalAlerts implements LocalAlerts {
  NotificationLocalAlerts({
    required FlutterLocalNotificationsPlugin plugin,
    required Logger logger,
    required bool isWeb,
    required TargetPlatform platform,
    LocalAlertsConfig config = const LocalAlertsConfig(),
  }) : _plugin = plugin,
       _logger = logger,
       _isWeb = isWeb,
       _platform = platform,
       _config = config;

  /// Id used by [showNow]; callers' [schedule] ids should differ.
  static const showNowId = 0x7FFFFFFF;

  final FlutterLocalNotificationsPlugin _plugin;
  final Logger _logger;
  final bool _isWeb;
  final TargetPlatform _platform;
  final LocalAlertsConfig _config;
  Future<bool>? _ready;

  Future<bool> _init() => _ready ??= guarded(_logger, 'alerts init', () async {
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: InitializationSettings(
        android: AndroidInitializationSettings(_config.androidIcon),
        iOS: darwin,
        macOS: darwin,
        windows: WindowsInitializationSettings(
          appName: _config.appName,
          appUserModelId: _config.windowsAppUserModelId,
          guid: _config.windowsGuid,
        ),
        web: const WebInitializationSettings(),
      ),
    );
    return true;
  }, false);

  NotificationDetails get _details => NotificationDetails(
    android: AndroidNotificationDetails(
      _config.channelId,
      _config.channelName,
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
    ),
    iOS: const DarwinNotificationDetails(),
    macOS: const DarwinNotificationDetails(),
  );

  @override
  Future<bool> requestPermission() async {
    // Web: ask first, while the tap's user activation is still valid; the
    // service-worker registration in _init can take longer than it lasts.
    if (!_isWeb && !await _init()) return false;
    return guarded(_logger, 'alerts permission', () async {
      final bool? granted;
      if (_isWeb) {
        granted = await _plugin
            .resolvePlatformSpecificImplementation<
              WebFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
        if (!await _init()) return false;
      } else {
        granted = switch (_platform) {
          TargetPlatform.android =>
            await _plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >()
                ?.requestNotificationsPermission(),
          TargetPlatform.iOS =>
            await _plugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, sound: true),
          TargetPlatform.macOS =>
            await _plugin
                .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, sound: true),
          // Windows and Linux have no runtime notification permission.
          _ => true,
        };
      }
      if (granted != true) _logger.w('device_services: alerts not permitted');
      return granted ?? false;
    }, false);
  }

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
  }) async {
    if (_isWeb) {
      // Browsers cannot schedule; the app calls showNow while the tab is open.
      _logger.d('device_services: web cannot schedule alert $id');
      return;
    }
    if (!await _init()) return;
    await guarded(_logger, 'schedule alert $id', () async {
      final exact =
          _platform != TargetPlatform.android ||
          (await _plugin
                  .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin
                  >()
                  ?.canScheduleExactNotifications() ??
              false);
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(at, tz.UTC),
        notificationDetails: _details,
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }, null);
  }

  @override
  Future<void> cancel(int id) async {
    if (!await _init()) return;
    await guarded(_logger, 'cancel alert $id', () async {
      await _plugin.cancel(id: id);
      // Web shows the alert with showNowId (it cannot schedule), so close
      // that one too.
      if (_isWeb) await _plugin.cancel(id: showNowId);
    }, null);
  }

  @override
  Future<void> showNow({required String title, required String body}) async {
    if (!await _init()) return;
    await guarded(
      _logger,
      'show alert',
      () => _plugin.show(
        id: showNowId,
        title: title,
        body: body,
        notificationDetails: _details,
      ),
      null,
    );
  }
}
