import 'package:flutter/material.dart';
import 'package:core/core.dart';

import 'package:di/di.dart';
import 'package:flip_clock/flip_clock.dart' as flip_clock;
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:notifications/notifications.dart';

import 'package:quietflip/app.dart';
import 'package:quietflip/bootstrap.dart' as bootstrap;
import 'package:quietflip/notification_lifecycle.dart';

import 'package:quietflip/router/router.dart';

Future<void> main() => startApp();

/// Composition root. Queue cold-start notification routes until routing exists.
Future<void> startApp({
  Future<void> Function(void Function(String) onOpenRoute)? initialize,
  void Function(Widget) mount = runApp,
}) async {
  GoRouter? activeRouter;
  String? pendingRoute;
  void onOpenRoute(String route) {
    if (activeRouter == null) {
      pendingRoute = route;
    } else {
      activeRouter.go(route);
    }
  }

  // The device language, before bootstrap names the notification channel.
  LocalizationProvider.select(
    WidgetsFlutterBinding.ensureInitialized().platformDispatcher.locales,
  );
  // Fonts are bundled in design_system; never download them at launch.
  GoogleFonts.config.allowRuntimeFetching = false;
  if (initialize == null) {
    await bootstrap.init(onOpenRoute: onOpenRoute);
  } else {
    await initialize(onOpenRoute);
  }
  final router = AppRouter.createRouter(initialLocation: pendingRoute);
  activeRouter = router;
  di.register<GoRouter>(router, dispose: (router) => router.dispose());
  mount(
    NotificationLifecycle(
      logger: di.get<Logger>(),
      client: di.has<NotificationClient>()
          ? di.get<NotificationClient>()
          : null,
      child: App(
        router: router,
        appearance: flip_clock.appearance(),
        face: flip_clock.appFace(),
        corner: flip_clock.appCorner(),
      ),
    ),
  );
}
