// Protected delegate methods are the FlutterFire platform mocking seam.
// ignore_for_file: invalid_use_of_protected_member
import 'package:analytics/analytics.dart';

import 'package:auth/auth.dart' as auth;

import 'package:core/developer/emulators.dart' as emulators;

import 'package:crashlytics/crashlytics.dart';

import 'package:dashboard/dashboard.dart';
import 'package:device_services/device_services.dart';

import 'package:di/di.dart';
import 'package:feature_flags/feature_flags.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';

import 'package:firebase_crashlytics_platform_interface/firebase_crashlytics_platform_interface.dart';

import 'package:firebase_remote_config_platform_interface/firebase_remote_config_platform_interface.dart';

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';

import 'package:flip_clock/flip_clock.dart' as flip_clock;
import 'package:flip_clock/flip_clock.dart' show FlipClockRouter;
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flip_clock/state/settings_sync.dart';
import 'package:flip_clock/ui/screens/index.dart';
import 'package:cloud_sync/cloud_sync.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:localization/localization.dart';
import 'package:notifications/notifications.dart';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:quietflip/bootstrap.dart' as bootstrap;
import 'package:quietflip/main.dart' as entrypoint;
import 'package:quietflip/app.dart';
import 'package:quietflip/router/router.dart';

import 'clock_support.dart';

class _Core extends MockFirebaseApp {
  @override
  Future<List<CoreInitializeResponse>> initializeCore() async {
    final apps = await super.initializeCore();
    apps.first.pluginConstants['plugins.flutter.io/firebase_crashlytics'] = {
      'isCrashlyticsCollectionEnabled': false,
    };
    return apps;
  }
}

class _Auth extends Mock
    with MockPlatformInterfaceMixin
    implements FirebaseAuthPlatform {}

class _Analytics extends Mock
    with MockPlatformInterfaceMixin
    implements FirebaseAnalyticsPlatform {}

class _Crash extends Mock
    with MockPlatformInterfaceMixin
    implements FirebaseCrashlyticsPlatform {}

class _Flags extends Mock
    with MockPlatformInterfaceMixin
    implements FirebaseRemoteConfigPlatform {}

class _Messaging extends Mock
    with MockPlatformInterfaceMixin
    implements FirebaseMessagingPlatform {}

class _User extends Mock
    with MockPlatformInterfaceMixin
    implements UserPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // FlutterFire caches each SDK's delegate per app, so both runs share one
  // set of platform doubles.
  final identity = _Auth();
  final analytics = _Analytics();
  final crash = _Crash();
  final flags = _Flags();
  final messaging = _Messaging();
  // Crashlytics has no web SDK: on web it is skipped, everything else runs.
  for (final web in [false, true]) {
    testWidgets(
      'configured bootstrap composes all modules against offline platform '
      'doubles (web: $web)',
      (tester) async {
        TestFirebaseCoreHostApi.setUp(_Core());
        final app = await Firebase.initializeApp();
        registerFallbackValue(app);
        registerFallbackValue(
          RemoteConfigSettings(
            fetchTimeout: const Duration(seconds: 1),
            minimumFetchInterval: Duration.zero,
          ),
        );
        FirebaseAuthPlatform.instance = identity;

        FirebaseAnalyticsPlatform.instance = analytics;

        FirebaseCrashlyticsPlatform.instance = crash;

        FirebaseRemoteConfigPlatform.instance = flags;

        FirebaseMessagingPlatform.instance = messaging;

        when(
          () => identity.delegateFor(app: any(named: 'app')),
        ).thenReturn(identity);
        when(
          () => identity.setInitialValues(
            currentUser: any(named: 'currentUser'),
            languageCode: any(named: 'languageCode'),
          ),
        ).thenReturn(identity);
        when(
          identity.idTokenChanges,
        ).thenAnswer((_) => const Stream<UserPlatform?>.empty());
        when(
          identity.authStateChanges,
        ).thenAnswer((_) => const Stream<UserPlatform?>.empty());
        when(
          identity.userChanges,
        ).thenAnswer((_) => const Stream<UserPlatform?>.empty());
        when(
          () => identity.useAuthEmulator(any(), any()),
        ).thenAnswer((_) async {});
        when(
          () => analytics.delegateFor(
            app: any(named: 'app'),
            webOptions: any(named: 'webOptions'),
          ),
        ).thenReturn(analytics);
        when(
          () => analytics.setAnalyticsCollectionEnabled(any()),
        ).thenAnswer((_) async {});
        when(
          () => analytics.logEvent(
            name: any(named: 'name'),
            parameters: any(named: 'parameters'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => crash.setInitialValues(
            isCrashlyticsCollectionEnabled: any(
              named: 'isCrashlyticsCollectionEnabled',
            ),
          ),
        ).thenReturn(crash);
        when(
          () => crash.setCrashlyticsCollectionEnabled(any()),
        ).thenAnswer((_) async {});
        when(crash.checkForUnsentReports).thenAnswer((_) async => false);
        when(() => flags.delegateFor(app: any(named: 'app'))).thenReturn(flags);
        when(
          () => flags.setInitialValues(
            remoteConfigValues: any(named: 'remoteConfigValues'),
          ),
        ).thenReturn(flags);
        when(() => flags.setConfigSettings(any())).thenAnswer((_) async {});
        when(() => flags.setDefaults(any())).thenAnswer((_) async {});
        when(flags.fetchAndActivate).thenAnswer((_) async => false);
        when(() => flags.lastFetchTime).thenReturn(DateTime(2026));
        when(
          () => flags.lastFetchStatus,
        ).thenReturn(RemoteConfigFetchStatus.success);
        when(
          () => messaging.delegateFor(app: any(named: 'app')),
        ).thenReturn(messaging);
        when(
          () => messaging.setInitialValues(
            isAutoInitEnabled: any(named: 'isAutoInitEnabled'),
          ),
        ).thenReturn(messaging);
        addTearDown(di.reset);
        useInMemoryStorage();
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        // Real async: cubits created in fake time never finish closing in
        // tearDown (see features/flip_clock/CLAUDE.md).
        await tester.runAsync(
          () => bootstrap.init(
            firebaseOptions: app.options,
            useEmulators: true,
            isWeb: web,
          ),
        );
        debugDefaultTargetPlatformOverride = null;
        expect(di.has<AnalyticsClient>(), isTrue);

        expect(di.has<CrashlyticsClient>(), !web);

        expect(di.has<FeatureFlag>(), isTrue);

        expect(di.has<auth.AuthService>(), isTrue);

        expect(di.has<NotificationClient>(), isTrue);

        expect(di.has<KeyValueStore>(), isTrue);

        expect(di.has<SettingsController>(), isTrue);

        // Settings sync is on: the cloud sync and the clock's coordinator.
        expect(di.get<CloudSync>(), isA<FirestoreCloudSync>());
        expect(di.has<SettingsSync>(), isTrue);

        expect(di.get<NotificationTokenManager>(), isA<FirebaseTokenManager>());

        expect(
          di.get<NotificationPermissionManager>(),
          isA<FirebasePermissionManager>(),
        );

        verify(
          () => analytics.logEvent(
            name: 'app_open',
            parameters: any(named: 'parameters'),
          ),
        ).called(1);
        when(
          () => identity.useAuthEmulator(any(), any()),
        ).thenThrow(StateError('offline'));
        await expectLater(emulators.init(), throwsStateError);
        when(
          () => identity.useAuthEmulator(any(), any()),
        ).thenAnswer((_) async {});
        late Widget composed;
        await entrypoint.startApp(
          initialize: (_) async {},
          mount: (app) => composed = app,
        );
        expect(composed, isA<Widget>());
        final router = AppRouter.createRouter(initialLocation: '/error');
        addTearDown(router.dispose);
        await tester.pumpWidget(
          App(router: router, appearance: flip_clock.appearance()),
        );
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(OutlinedButton));
        final route = router.configuration.routes
            .whereType<GoRoute>()
            .firstWhere((r) => r.path == auth.AuthRoutes.signIn);
        final screen =
            route.builder!(context, GoRouterState.of(context))
                as auth.SignInScreen;
        when(() => identity.currentUser).thenReturn(_User());
        await screen.onSignedIn(context);
        await tester.pumpAndSettle();
        // Signing in lands back on Settings > Account, not the dashboard.
        expect(
          router.routeInformationProvider.value.uri.toString(),
          FlipClockRouter.accountSettings,
        );
        expect(
          tester.widget<SettingsScreen>(find.byType(SettingsScreen)).category,
          'account',
        );
        // Sign in to sync opens sign-in.
        await tester.tap(find.text(strings.sync.sign_in));
        await tester.pumpAndSettle();
        expect(find.byType(auth.SignInScreen), findsOneWidget);

        await di.get<NotificationConfig>().onForeground!('Notice', 'Details');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('Notice'), findsOneWidget);
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();
        when(() => identity.currentUser).thenReturn(null);
        router.go(DashboardRouter.home);
        await tester.pumpAndSettle();
        expect(find.byType(auth.SignInScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
