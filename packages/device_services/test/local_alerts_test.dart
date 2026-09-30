import 'package:device_services/src/local_alerts/notification_local_alerts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/timezone.dart' as tz;

import 'fakes.dart';

class _MockPlugin extends Mock implements FlutterLocalNotificationsPlugin {}

class _MockAndroid extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

class _MockIos extends Mock implements IOSFlutterLocalNotificationsPlugin {}

class _MockMacOs extends Mock implements MacOSFlutterLocalNotificationsPlugin {}

class _MockWeb extends Mock implements WebFlutterLocalNotificationsPlugin {}

void main() {
  late FakeLogger logger;
  late _MockPlugin plugin;
  late _MockAndroid android;
  final at = DateTime.utc(2030, 1, 1, 12);

  setUpAll(() {
    registerFallbackValue(const InitializationSettings());
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(tz.TZDateTime.utc(2030));
    registerFallbackValue(AndroidScheduleMode.exact);
  });

  setUp(() {
    logger = FakeLogger();
    plugin = _MockPlugin();
    android = _MockAndroid();
    when(
      () => plugin.initialize(settings: any(named: 'settings')),
    ).thenAnswer((_) async => true);
    when(
      () => plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >(),
    ).thenReturn(android);
    when(
      () => plugin.zonedSchedule(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
      ),
    ).thenAnswer((_) async {});
    when(() => plugin.cancel(id: any(named: 'id'))).thenAnswer((_) async {});
    when(
      () => plugin.show(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        notificationDetails: any(named: 'notificationDetails'),
      ),
    ).thenAnswer((_) async {});
  });

  NotificationLocalAlerts build({
    TargetPlatform platform = TargetPlatform.android,
    bool isWeb = false,
  }) => NotificationLocalAlerts(
    plugin: plugin,
    logger: logger,
    isWeb: isWeb,
    platform: platform,
  );

  AndroidScheduleMode scheduledMode() =>
      verify(
            () => plugin.zonedSchedule(
              id: 7,
              title: 'T',
              body: 'B',
              scheduledDate: tz.TZDateTime.from(at, tz.UTC),
              notificationDetails: any(named: 'notificationDetails'),
              androidScheduleMode: captureAny(named: 'androidScheduleMode'),
            ),
          ).captured.single
          as AndroidScheduleMode;

  group('requestPermission', () {
    test('android asks the system and initialises once', () async {
      when(
        android.requestNotificationsPermission,
      ).thenAnswer((_) async => true);
      final alerts = build();
      expect(await alerts.requestPermission(), isTrue);
      expect(await alerts.requestPermission(), isTrue);
      final settings =
          verify(
                () =>
                    plugin.initialize(settings: captureAny(named: 'settings')),
              ).captured.single
              as InitializationSettings;
      expect(settings.iOS?.requestAlertPermission, isFalse);
      expect(settings.windows?.appName, 'App');
    });

    test('iOS and macOS ask for alert and sound', () async {
      final ios = _MockIos();
      final mac = _MockMacOs();
      when(
        () => plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >(),
      ).thenReturn(ios);
      when(
        () => plugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >(),
      ).thenReturn(mac);
      when(
        () => ios.requestPermissions(alert: true, sound: true),
      ).thenAnswer((_) async => true);
      when(
        () => mac.requestPermissions(alert: true, sound: true),
      ).thenAnswer((_) async => false);
      expect(
        await build(platform: TargetPlatform.iOS).requestPermission(),
        isTrue,
      );
      expect(
        await build(platform: TargetPlatform.macOS).requestPermission(),
        isFalse,
      );
      expect(logger.warnings, hasLength(1));
    });

    test('web asks the browser', () async {
      final web = _MockWeb();
      when(
        () => plugin
            .resolvePlatformSpecificImplementation<
              WebFlutterLocalNotificationsPlugin
            >(),
      ).thenReturn(web);
      when(web.requestNotificationsPermission).thenAnswer((_) async => true);
      expect(await build(isWeb: true).requestPermission(), isTrue);
      // Asked before the (slow) service-worker registration.
      verifyInOrder([
        web.requestNotificationsPermission,
        () => plugin.initialize(settings: any(named: 'settings')),
      ]);
    });

    test('web with a failed registration reports denied', () async {
      when(
        () => plugin.initialize(settings: any(named: 'settings')),
      ).thenThrow(StateError('no service worker'));
      expect(await build(isWeb: true).requestPermission(), isFalse);
    });

    test('windows needs no permission', () async {
      expect(
        await build(platform: TargetPlatform.windows).requestPermission(),
        isTrue,
      );
    });

    test('missing platform plugin means denied', () async {
      when(
        () => plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >(),
      ).thenReturn(null);
      expect(await build().requestPermission(), isFalse);
    });

    test('a throwing plugin is logged and means denied', () async {
      when(android.requestNotificationsPermission).thenThrow(StateError('x'));
      expect(await build().requestPermission(), isFalse);
      expect(logger.errors, hasLength(1));
    });
  });

  group('schedule', () {
    test('android uses exact alarms when allowed', () async {
      when(android.canScheduleExactNotifications).thenAnswer((_) async => true);
      await build().schedule(id: 7, at: at, title: 'T', body: 'B');
      expect(scheduledMode(), AndroidScheduleMode.exactAllowWhileIdle);
    });

    test('android falls back to inexact alarms', () async {
      when(
        android.canScheduleExactNotifications,
      ).thenAnswer((_) async => false);
      await build().schedule(id: 7, at: at, title: 'T', body: 'B');
      expect(scheduledMode(), AndroidScheduleMode.inexactAllowWhileIdle);
    });

    test('android without its plugin schedules inexact', () async {
      when(
        () => plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >(),
      ).thenReturn(null);
      await build().schedule(id: 7, at: at, title: 'T', body: 'B');
      expect(scheduledMode(), AndroidScheduleMode.inexactAllowWhileIdle);
    });

    test('other platforms schedule without asking android', () async {
      await build(
        platform: TargetPlatform.iOS,
      ).schedule(id: 7, at: at, title: 'T', body: 'B');
      expect(scheduledMode(), AndroidScheduleMode.exactAllowWhileIdle);
      verifyNever(android.canScheduleExactNotifications);
    });

    test('web does nothing', () async {
      await build(isWeb: true).schedule(id: 7, at: at, title: 'T', body: 'B');
      verifyZeroInteractions(plugin);
    });

    test('a rejected schedule (past date) is logged', () async {
      when(
        () => plugin.zonedSchedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        ),
      ).thenThrow(ArgumentError('past'));
      await build(
        platform: TargetPlatform.windows,
      ).schedule(id: 7, at: at, title: 'T', body: 'B');
      expect(logger.errors, hasLength(1));
    });
  });

  test('cancel and showNow reach the plugin', () async {
    final alerts = build();
    await alerts.cancel(7);
    await alerts.showNow(title: 'T', body: 'B');
    verify(() => plugin.cancel(id: 7)).called(1);
    final details =
        verify(
              () => plugin.show(
                id: NotificationLocalAlerts.showNowId,
                title: 'T',
                body: 'B',
                notificationDetails: captureAny(named: 'notificationDetails'),
              ),
            ).captured.single
            as NotificationDetails;
    expect(details.android?.channelId, 'alerts');
  });

  test('web cancel also closes the notification shown at completion', () async {
    await build(isWeb: true).cancel(7);
    verify(() => plugin.cancel(id: 7)).called(1);
    verify(
      () => plugin.cancel(id: NotificationLocalAlerts.showNowId),
    ).called(1);
  });

  test('failed initialisation turns every call into a no-op', () async {
    when(
      () => plugin.initialize(settings: any(named: 'settings')),
    ).thenThrow(ArgumentError('no settings for this platform'));
    final alerts = build();
    expect(await alerts.requestPermission(), isFalse);
    await alerts.schedule(id: 7, at: at, title: 'T', body: 'B');
    await alerts.cancel(7);
    await alerts.showNow(title: 'T', body: 'B');
    verify(() => plugin.initialize(settings: any(named: 'settings'))).called(1);
    verifyNoMoreInteractions(plugin);
    expect(logger.errors, hasLength(1));
  });
}
