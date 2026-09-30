/// Flip clock, countdown timer and stopwatch.
library;

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:device_services/device_services.dart';
import 'package:di/di.dart';
import 'package:flip_clock/data/repositories/settings_repository.dart';
import 'package:flip_clock/data/repositories/settings_repository_imp.dart';
import 'package:flip_clock/state/clock_controller.dart';
import 'package:flip_clock/state/countdown_controller.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flip_clock/state/stopwatch_controller.dart';
import 'package:flutter/foundation.dart';

export 'data/models/clock_settings.dart';
export 'router/flip_clock_router.dart';

/// Registers the settings repository and controllers with `di`, restoring
/// saved settings and any saved countdown.
///
/// Call after `core.init()` and `device_services.init()`.
Future<void> init() async {
  final logger = di.get<Logger>();
  final alerts = di.get<LocalAlerts>();
  final repository = SettingsRepositoryImp(
    store: di.get<KeyValueStore>(),
    logger: logger,
  );
  final settings = SettingsController(repository: repository, alerts: alerts);
  await settings.load();
  final countdown = CountdownController(
    repository: repository,
    alerts: alerts,
    sound: di.get<SoundPlayer>(),
    settings: () => settings.state,
    logger: logger,
  );
  await countdown.load();
  // Switching System notifications mid-countdown schedules or cancels its
  // alert. Ends when the settings controller closes.
  settings.stream
      .map((s) => s.systemAlerts)
      .distinct()
      .listen((_) => unawaited(countdown.syncAlert()));

  di.register<SettingsRepository>(repository);
  di.register<SettingsController>(settings, dispose: _close);
  di.register<CountdownController>(countdown, dispose: _close);
  di.register<StopwatchController>(
    StopwatchController(stopwatch: Stopwatch()),
    dispose: _close,
  );
  di.register<ClockController>(ClockController(), dispose: _close);
  logger.i('Flip clock module initialized');
}

Future<void> _close(Object? cubit) async => (cubit! as Closable).close();

/// The theme the user chose (Black by default) for the app to pass to
/// `DesignSystemWrapper(mode:)`. Valid after [init].
ValueListenable<AppearanceMode> appearance() =>
    di.get<SettingsController>().appearance;
