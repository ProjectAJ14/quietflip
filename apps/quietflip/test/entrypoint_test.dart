import 'package:cloud_sync/cloud_sync.dart';
import 'package:device_services/device_services.dart';
import 'package:flip_clock/flip_clock.dart';
import 'package:di/di.dart';
import 'package:flip_clock/ui/screens/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:network/network.dart';

import 'package:quietflip/bootstrap.dart' as bootstrap;
import 'package:quietflip/main.dart' as entrypoint;

import 'clock_support.dart';

void main() {
  tearDown(di.reset);
  testWidgets('real entrypoint starts offline without Firebase credentials', (
    tester,
  ) async {
    useInMemoryStorage();
    // The unconfigured placeholder throws; the app boots without Firebase.
    final options = bootstrap.defaultFirebaseOptions;
    bootstrap.defaultFirebaseOptions = () =>
        throw UnsupportedError('Firebase has not been configured');
    addTearDown(() => bootstrap.defaultFirebaseOptions = options);
    // Real async: cubits created in fake time never finish closing in
    // tearDown (see features/flip_clock/CLAUDE.md).
    await tester.runAsync(entrypoint.main);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(di.has<NetworkClient>(), isTrue);
    expect(di.has<FullScreenController>(), isTrue);
    expect(di.has<LocalAlerts>(), isTrue);
    expect(di.has<GoRouter>(), isTrue);

    // Launches straight into the clock, Black even though the OS is light.
    final clock = find.byType(FlipClockScreen);
    expect(clock, findsOneWidget);
    final theme = Theme.of(tester.element(clock));
    expect(theme.colorScheme.surface, Colors.black);

    final router = di.get<GoRouter>();
    // Firebase off: no settings sync, so Settings has no Account card.
    expect(di.has<CloudSync>(), isFalse);
    router.go(FlipClockRouter.settings);
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text(strings.sync.card_title_signed_out), findsNothing);

    router.go('/home');
    await tester.pumpAndSettle();
    expect(find.byType(FlipClockScreen), findsOneWidget);

    router.go('/unknown');
    await tester.pumpAndSettle();
    expect(find.text(strings.generic.retry), findsOneWidget);
    await tester.tap(find.text(strings.generic.retry));
    await tester.pumpAndSettle();
    expect(find.byType(FlipClockScreen), findsOneWidget);
    router.go('/error?title=Test&message=Try%20later&error=Details');
    await tester.pumpAndSettle();
    expect(find.text('Try later'), findsOneWidget);
    await tester.tap(find.text(strings.generic.retry));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
