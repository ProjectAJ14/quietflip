import 'dart:io';

import 'package:auth/auth.dart' as auth;
import 'package:core/core.dart' as core;
import 'package:design_system/design_system.dart';
import 'package:di/di.dart';
import 'package:flip_clock/flip_clock.dart';
import 'package:flip_clock/ui/screens/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:notifications/notifications.dart';
import 'package:quietflip/app.dart';
import 'package:quietflip/router/router.dart';

import 'clock_support.dart';

class _Notifications implements NotificationClient {
  _Notifications({required this.fails});
  final bool fails;
  int unregistered = 0;

  @override
  Future<void> unregisterDevice() async {
    unregistered++;
    if (fails) throw Exception('backend down');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Auth implements auth.AuthService {
  int signOuts = 0;

  @override
  Future<void> signOut() async => signOuts++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(core.init);
  tearDown(di.reset);

  testWidgets('renders an injected router and follows the chosen appearance', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('Test destination')),
      ],
    );
    addTearDown(router.dispose);
    final appearance = ValueNotifier(AppearanceMode.black);
    addTearDown(appearance.dispose);
    await tester.pumpWidget(App(router: router, appearance: appearance));
    await tester.pumpAndSettle();
    final text = find.text('Test destination');
    expect(text, findsOneWidget);
    expect(Theme.of(tester.element(text)).brightness, Brightness.dark);

    appearance.value = AppearanceMode.light;
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(text)).brightness, Brightness.light);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the whole app follows the skin face', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('Test destination')),
      ],
    );
    addTearDown(router.dispose);
    final appearance = ValueNotifier(AppearanceMode.black);
    final face = ValueNotifier<DisplayFace?>(null);
    addTearDown(appearance.dispose);
    addTearDown(face.dispose);
    await tester.pumpWidget(
      App(router: router, appearance: appearance, face: face),
    );
    await tester.pumpAndSettle();
    TextStyle body() => Theme.of(
      tester.element(find.text('Test destination')),
    ).textTheme.bodyLarge!;
    expect(body().fontFamily, startsWith('Geist'));
    face.value = DisplayFace.orbitron;
    await tester.pumpAndSettle();
    expect(body().fontFamily, startsWith('Orbitron'));
  });

  testWidgets('the whole app follows the one corner setting', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('Test destination')),
      ],
    );
    addTearDown(router.dispose);
    final appearance = ValueNotifier(AppearanceMode.black);
    final corner = ValueNotifier<double>(14);
    addTearDown(appearance.dispose);
    addTearDown(corner.dispose);
    await tester.pumpWidget(
      App(router: router, appearance: appearance, corner: corner),
    );
    await tester.pumpAndSettle();
    DesignShape shape() =>
        DesignShape.of(tester.element(find.text('Test destination')));
    expect(shape().corner, 14);
    corner.value = 0;
    await tester.pumpAndSettle();
    expect(shape().corner, 0);
  });

  testWidgets('real routes boot without Firebase; the clock is home', (
    tester,
  ) async {
    await tester.runAsync(initClock);
    final router = AppRouter.createRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(App(router: router, appearance: appearance()));
    await tester.pumpAndSettle();
    expect(find.byType(FlipClockScreen), findsOneWidget);
    router.go(core.CoreRoutes.home);
    await tester.pumpAndSettle();
    expect(find.byType(FlipClockScreen), findsOneWidget);
    // Dashboard stays registered for future scope, just unlinked.
    router.go(core.CoreRoutes.dashboard);
    await tester.pumpAndSettle();
    expect(find.text(strings.nav.explore), findsWidgets);
    await tester.tap(find.text(strings.nav.explore).first);
    await tester.pumpAndSettle();
    router.go('/error');
    await tester.pumpAndSettle();
    expect(find.text(strings.generic.error), findsWidgets);
    expect(find.text(strings.errors.unexpected_error), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  for (final fails in [false, true]) {
    testWidgets('sign-out unregisters the device first (failure: $fails)', (
      tester,
    ) async {
      final notifications = _Notifications(fails: fails);
      final service = _Auth();
      di.register<NotificationClient>(notifications);
      di.register<auth.AuthService>(service);
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, _) => TextButton(
              onPressed: () => AppRouter.signOut(context),
              child: const Text('out'),
            ),
          ),
          GoRoute(
            path: auth.AuthRoutes.signIn,
            builder: (_, _) => const Text('login'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.tap(find.text('out'));
      await tester.pumpAndSettle();
      expect(notifications.unregistered, 1);
      expect(service.signOuts, 1);
      expect(find.text('login'), findsOneWidget);
    });
  }

  test(
    'web never downloads Roboto: the name is bundled Geist with its OFL',
    () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('- family: Roboto'));
      expect(pubspec, contains('asset: assets/fonts/Geist-Regular.ttf'));
      expect(File('assets/fonts/Geist-Regular.ttf').existsSync(), isTrue);
      expect(
        File('assets/fonts/OFL-Geist.txt').readAsStringSync(),
        contains('SIL Open Font License'),
      );
    },
  );
}
