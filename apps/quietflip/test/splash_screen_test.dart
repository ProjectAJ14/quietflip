import 'package:design_system/design_system.dart';
import 'package:flip_clock/flip_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:quietflip/ui/splash_screen.dart';

void main() {
  GoRouter router() => GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: FlipClockRouter.home,
        builder: (_, _) => const Text('clock'),
      ),
    ],
  );

  testWidgets('draws the launch logo centred on black, then opens the clock', (
    tester,
  ) async {
    final r = router();
    addTearDown(r.dispose);
    // Light theme on purpose: the splash stays black like the native screen.
    await tester.pumpWidget(
      MaterialApp.router(theme: ThemeData.light(), routerConfig: r),
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, DesignColors.dark.bg);
    final logo = tester.widget<AppAssetImage>(find.byType(AppAssetImage));
    expect(logo.assetPath, SplashScreen.logoAsset);
    expect(logo.width, SplashScreen.logoWidth);
    expect(
      tester.getCenter(find.byType(AppAssetImage)),
      tester.getCenter(find.byType(Scaffold)),
    );
    expect(find.bySemanticsLabel(strings.app.name), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('clock'), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
  });
}
