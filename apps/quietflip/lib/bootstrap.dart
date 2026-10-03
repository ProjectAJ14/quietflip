import 'package:analytics/analytics.dart' as analytics;

import 'package:auth/auth.dart' as auth;

import 'package:bloc/bloc.dart';
import 'package:cloud_sync/cloud_sync.dart' as cloud_sync;
import 'package:core/core.dart' as core;
import 'package:core/developer/emulators.dart' as emulators;

import 'package:core/logger/logger.dart';
import 'package:crashlytics/crashlytics.dart' as crashlytics;

import 'package:di/di.dart';
import 'package:design_system/toast/toasts.dart';
import 'package:device_services/device_services.dart' as device_services;

import 'package:feature_flags/feature_flags.dart' as feature_flags;

import 'package:firebase_core/firebase_core.dart';

import 'package:flip_clock/flip_clock.dart' as flip_clock;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:localization/localization.dart';
import 'package:network/network.dart' as network;

import 'package:notifications/notifications.dart' as notifications;

import 'package:quietflip/firebase_options.dart';

/// Where [init] reads the Firebase options when none are passed. Tests swap
/// in the placeholder's `UnsupportedError` to boot with Firebase off.
@visibleForTesting
FirebaseOptions Function() defaultFirebaseOptions = () =>
    DefaultFirebaseOptions.currentPlatform;

/// Whether Firebase Analytics has an SDK here: Android, iOS, macOS and the
/// web. On Windows and Linux the app runs without analytics.
@visibleForTesting
bool analyticsSupported({bool isWeb = kIsWeb}) =>
    isWeb ||
    switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS => true,
      _ => false,
    };

/// Brings every module up, in dependency order, before the first frame.
///
/// Order matters: the logger is registered first so everything after it can
/// report failures, and Firebase must be live before any Firebase-backed
/// module initialises. If `flutterfire configure` has not been run yet, those
/// modules are skipped so the rest of the app still boots.
Future<void> init({
  void Function(String route)? onOpenRoute,
  FirebaseOptions? firebaseOptions,
  bool useEmulators = core.Environment.useEmulators,
  bool isWeb = kIsWeb,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final stopwatch = Stopwatch()..start();

  await core.init();
  final logger = di.get<Logger>();
  logger.i('Core ready in ${stopwatch.elapsedMilliseconds} ms');

  Bloc.observer = core.CoreBlocObserver();

  var firebaseReady = false;
  FirebaseOptions? resolvedOptions;
  try {
    resolvedOptions = firebaseOptions ?? defaultFirebaseOptions();
    await Firebase.initializeApp(options: resolvedOptions);
    firebaseReady = true;
    if (useEmulators) {
      await emulators.init();
    }
  } on UnsupportedError catch (error) {
    logger.w('$error');
  }
  logger.i(
    firebaseReady
        ? 'Firebase ready'
        : 'Firebase not configured yet; skipping Firebase modules',
  );

  // Crashlytics has no web SDK; on web its init asserts.
  if (firebaseReady && !isWeb) await crashlytics.init();

  // Usage analytics: on wherever Firebase is configured and has an SDK.
  // Debug builds log each event name, never its parameters.
  if (firebaseReady && analyticsSupported(isWeb: isWeb)) {
    await analytics.init(
      config: const analytics.DefaultAnalyticsConfig(
        enableDebugLogging: kDebugMode,
      ),
    );
  }

  if (firebaseReady) await feature_flags.init();

  if (firebaseReady) {
    final clientId =
        resolvedOptions!.iosClientId ?? resolvedOptions.androidClientId ?? '';
    await auth.init(auth.DefaultAuthConfig(clientId: clientId));
  }

  await network.init(
    config: network.DefaultNetworkConfig(baseUrl: core.Environment.baseUrl),
  );

  if (firebaseReady) {
    await notifications.init(
      config: notifications.NotificationConfig(
        onForeground: (title, body) =>
            Toast.notification(title: title, body: body),
        onOpenRoute: onOpenRoute,
      ),
    );
  }

  // Needs only the logger and the Flutter binding, never Firebase.
  await device_services.init(
    alerts: device_services.LocalAlertsConfig(
      appName: strings.app.name,
      channelName: strings.clock.alerts_channel,
      // Windows toast identity: app-specific, never change once shipped.
      windowsAppUserModelId: 'live.iajaykumar.quietflip',
      windowsGuid: '8ddafda9-e2f2-475f-a8d7-68b19e8223da',
    ),
  );
  // Settings sync needs Firebase and the device store; without it Settings
  // shows no Account card.
  if (firebaseReady) await cloud_sync.init();
  await flip_clock.init(
    sync: di.has<cloud_sync.CloudSync>()
        ? di.get<cloud_sync.CloudSync>()
        : null,
  );

  stopwatch.stop();
  logger.i('Bootstrap completed in ${stopwatch.elapsedMilliseconds} ms');

  if (firebaseReady) {
    await analytics.AnalyticsHelper.logAppOpen(
      parameters: {'bootstrap_duration': stopwatch.elapsedMilliseconds},
    );
  }
}
