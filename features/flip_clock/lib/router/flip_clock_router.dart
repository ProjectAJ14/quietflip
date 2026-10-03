import 'dart:async';

import 'package:cloud_sync/cloud_sync.dart';
import 'package:core/core.dart';
import 'package:device_services/device_services.dart';
import 'package:di/di.dart';
import 'package:flip_clock/state/clock_controller.dart';
import 'package:flip_clock/state/countdown_controller.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flip_clock/state/stopwatch_controller.dart';
import 'package:flip_clock/ui/components/account_page.dart';
import 'package:flip_clock/ui/screens/index.dart';
import 'package:flip_clock/ui/screens/skins_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Routes of the clock feature. The app spreads [routes] into its router.
///
/// Sign-in lives in another feature, so the app passes [sync] and the
/// account callbacks in; without [sync] Settings shows no Account card.
class FlipClockRouter implements CoreRouter {
  const FlipClockRouter({
    this.sync,
    this.onSignIn,
    this.onSignOut,
    this.onDeleteAccount,
  });

  final CloudSync? sync;

  /// Opens sign-in.
  final void Function(BuildContext context)? onSignIn;

  /// Signs out (confirmed by the user), staying on Settings.
  final Future<void> Function(BuildContext context)? onSignOut;

  /// Deletes the synced documents and the account (confirmed by the user).
  final Future<AccountDeletion> Function(BuildContext context)? onDeleteAccount;

  /// Pomodoro / Clock / Stopwatch screen. The app launches here.
  static const String home = '/clock';

  /// Settings screen, stacked on [home] so going back restores it.
  static const String settings = '/clock/settings';

  /// Settings opened on the Timers category.
  static const String timerSettings = '$settings?category=timers';

  /// Settings opened on the Account page (where sign-in returns).
  static const String accountSettings = '$settings?category=account';

  /// Which Settings > Shortcuts groups [platform] gets: touch on iOS and
  /// Android (in a browser too: [defaultTargetPlatform] is the device's),
  /// keys too when the shortest side is a tablet's, keys only elsewhere.
  static ({bool touch, bool keyboard}) shortcutsFor(
    TargetPlatform platform,
    double shortestSide,
  ) => switch (platform) {
    TargetPlatform.iOS || TargetPlatform.android => (
      touch: true,
      keyboard: shortestSide >= tabletSide,
    ),
    _ => (touch: false, keyboard: true),
  };

  /// The shortest side from which a phone OS device counts as a tablet.
  static const double tabletSide = 600;

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: home,
      // Route names are the screen names analytics reports.
      name: 'clock',
      builder: (context, _) => FlipClockScreen(
        settings: di.get<SettingsController>(),
        clock: di.get<ClockController>(),
        countdown: di.get<CountdownController>(),
        stopwatch: di.get<StopwatchController>(),
        fullScreen: di.get<FullScreenController>(),
        wake: di.get<ScreenWake>(),
        sound: di.get<SoundPlayer>(),
        brightness: di.get<ScreenBrightness>(),
        logger: di.get<Logger>(),
        onOpenSettings: () => context.go(settings),
        onOpenTimerSettings: () => context.go(timerSettings),
        orientationSupported: di.get<OrientationLock>().supported,
      ),
      routes: [
        GoRoute(
          path: 'settings',
          name: 'settings',
          // A Builder so a resize (split screen, a rotated tablet) re-picks
          // the shortcut groups.
          builder: (context, state) =>
              Builder(builder: (context) => _settings(context, state)),
        ),
      ],
    ),
  ];

  Widget _settings(BuildContext context, GoRouterState state) {
    final shortcuts = shortcutsFor(
      defaultTargetPlatform,
      MediaQuery.sizeOf(context).shortestSide,
    );
    return SettingsScreen(
      settings: di.get<SettingsController>(),
      sound: di.get<SoundPlayer>(),
      category: state.uri.queryParameters['category'],
      sync: sync,
      onSignIn: switch (onSignIn) {
        final open? => () => open(context),
        null => null,
      },
      onSignOut: switch (onSignOut) {
        final signOut? => () => signOut(context),
        null => null,
      },
      onDeleteAccount: switch (onDeleteAccount) {
        final delete? => () => delete(context),
        null => null,
      },
      now: () => di.get<ClockController>().state,
      orientationSupported: di.get<OrientationLock>().supported,
      touchShortcuts: shortcuts.touch,
      keyboardShortcuts: shortcuts.keyboard,
      onDone: () => context.go(home),
      onSkins: () => unawaited(
        showSkins(
          context,
          settings: di.get<SettingsController>(),
          now: di.get<ClockController>().state,
        ),
      ),
      onCustomize: () => unawaited(
        customizeSkin(
          context,
          settings: di.get<SettingsController>(),
          now: di.get<ClockController>().state,
        ),
      ),
    );
  }
}
