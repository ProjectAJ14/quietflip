import 'package:analytics/analytics.dart';
import 'package:auth/auth.dart' as auth;
import 'package:cloud_sync/cloud_sync.dart';
import 'package:core/core.dart' as core;
import 'package:dashboard/dashboard.dart';
import 'package:design_system/design_system.dart';
import 'package:developer/developer.dart' as developer;
import 'package:di/di.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flip_clock/flip_clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:notifications/notifications.dart';
import 'package:quietflip/ui/splash_screen.dart';

/// The app's single [GoRouter].
///
/// Feature packages expose their own `routes` list and are spliced in here, so
/// adding a feature is one import plus one spread - no route table to merge.
abstract final class AppRouter {
  static GoRouter createRouter({String? initialLocation}) {
    final router = GoRouter(
      debugLogDiagnostics: kDebugMode,
      initialLocation: initialLocation ?? core.CoreRoutes.root,
      observers: [
        core.CoreRouteObserver(),
        if (di.has<AnalyticsClient>())
          AnalyticsRouteObserver(
            client: di.get<AnalyticsClient>(),
            logger: di.get<core.Logger>(),
          ),
      ],
      errorBuilder: (context, state) => ErrorScreen(
        title: strings.errors.page_not_found,
        message: strings.errors.page_not_found_description,
        onGoHome: () => context.go(core.CoreRoutes.root),
        error: state.uri.toString(),
      ),
      routes: [
        GoRoute(
          path: core.CoreRoutes.root,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: core.CoreRoutes.home,
          redirect: (context, state) => FlipClockRouter.home,
        ),
        ...FlipClockRouter(
          sync: di.has<CloudSync>() ? di.get<CloudSync>() : null,
          onSignIn: (context) => context.go(auth.AuthRoutes.signIn),
          onSignOut: (_) => _signOutHere(),
          onDeleteAccount: (_) => _deleteAccount(),
        ).routes,
        // Sign-in is reached only from Settings > Account (and only when
        // Firebase is configured). Dashboard and developer stay registered
        // for future scope but nothing in the UI links to them.
        DashboardRouter.createShellRoute(
          // Demo tabs open before Firebase is configured; configured apps
          // require sign-in. Never allow unconfigured access to real data.
          redirect: auth.authRedirect(allowUnconfigured: true),
          onSignOut: signOut,
        ),
        ...auth.AuthRouter(
          onSignedIn: _onAuthenticated,
          onSignedUp: _onAuthenticated,
        ).routes,
        ...developer.DeveloperRouter().routes,
        GoRoute(
          path: core.CoreRoutes.error,
          builder: (context, state) => ErrorScreen(
            title:
                state.uri.queryParameters[core.Keys.title] ??
                strings.generic.error,
            message:
                state.uri.queryParameters[core.Keys.message] ??
                strings.errors.unexpected_error,
            error: state.uri.queryParameters[core.Keys.error],
            onGoHome: () => context.go(core.CoreRoutes.root),
          ),
        ),
      ],
    );

    return router;
  }

  /// Signs out after removing this device's push token, so a signed-out
  /// device stops receiving the previous user's notifications. A backend
  /// failure is logged and never blocks sign-out.
  @visibleForTesting
  static Future<void> signOut(BuildContext context) async {
    await _unregisterDevice();
    if (context.mounted) await auth.signOut(context);
  }

  static Future<void> _unregisterDevice() async {
    if (!di.has<NotificationClient>()) return;
    try {
      await di.get<NotificationClient>().unregisterDevice();
    } catch (error, stackTrace) {
      di.get<core.Logger>().e(
        'Could not unregister the device token',
        error,
        stackTrace,
      );
    }
  }

  /// Settings > Account > Sign out: like [signOut], but stays on the page,
  /// which turns to its signed-out look. A failure is already logged by
  /// `AuthService` and leaves the user signed in.
  static Future<void> _signOutHere() async {
    await _unregisterDevice();
    try {
      await di.get<auth.AuthService>().signOut();
    } on FirebaseException {
      return;
    }
  }

  /// Settings > Account > Delete account: the synced documents first (the
  /// rules need the account), then the account. Firebase may want a recent
  /// sign-in: signing out makes the next sign-in fresh, so sync resumes.
  /// Failures are logged by `CloudSync` / `AuthService`.
  static Future<AccountDeletion> _deleteAccount() async {
    try {
      await di.get<CloudSync>().deleteAll();
      await _unregisterDevice();
      await di.get<auth.AuthService>().deleteAccount();
      return AccountDeletion.deleted;
    } on FirebaseException catch (error) {
      if (error.code != 'requires-recent-login') return AccountDeletion.failed;
      await _signOutHere();
      return AccountDeletion.needsSignIn;
    }
  }

  /// Where a user lands once sign-in or sign-up succeeds: back on the
  /// Account page, which shows "Syncing…" then the last sync.
  static Future<void> _onAuthenticated(BuildContext context) async {
    await AnalyticsHelper.logEvent(AnalyticsEvents.user.authenticatedRedirect);
    if (context.mounted) {
      context.go(FlipClockRouter.accountSettings);
    }
  }
}
