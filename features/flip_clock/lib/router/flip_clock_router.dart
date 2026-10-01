import 'dart:async';

import 'package:core/core.dart';
import 'package:device_services/device_services.dart';
import 'package:di/di.dart';
import 'package:flip_clock/state/clock_controller.dart';
import 'package:flip_clock/state/countdown_controller.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flip_clock/state/stopwatch_controller.dart';
import 'package:flip_clock/ui/screens/index.dart';
import 'package:flip_clock/ui/screens/skins_sheet.dart';
import 'package:go_router/go_router.dart';

/// Routes of the clock feature. The app spreads [routes] into its router.
class FlipClockRouter implements CoreRouter {
  const FlipClockRouter();

  /// Pomodoro / Clock / Stopwatch screen. The app launches here.
  static const String home = '/clock';

  /// Settings screen, stacked on [home] so going back restores it.
  static const String settings = '/clock/settings';

  /// Settings opened on the Timers category.
  static const String timerSettings = '$settings?category=timers';

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: home,
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
      ),
      routes: [
        GoRoute(
          path: 'settings',
          builder: (context, state) => SettingsScreen(
            settings: di.get<SettingsController>(),
            openTimers: state.uri.queryParameters['category'] == 'timers',
            now: () => di.get<ClockController>().state,
            orientationSupported: di.get<OrientationLock>().supported,
            onDone: () => context.go(home),
            onSkins: () => unawaited(
              showSkins(
                context,
                settings: di.get<SettingsController>(),
                now: di.get<ClockController>().state,
              ),
            ),
          ),
        ),
      ],
    ),
  ];
}
