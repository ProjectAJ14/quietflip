import 'package:bloc/bloc.dart';
import 'package:design_system/design_system.dart';
import 'package:device_services/device_services.dart';
import 'package:flip_clock/data/models/clock_settings.dart';
import 'package:flip_clock/data/repositories/settings_repository.dart';
import 'package:flutter/foundation.dart';

/// Holds the user's preferences and saves every change.
class SettingsController extends Cubit<ClockSettings> {
  SettingsController({
    required SettingsRepository repository,
    required LocalAlerts alerts,
  }) : _repository = repository,
       _alerts = alerts,
       super(const ClockSettings());

  final SettingsRepository _repository;
  final LocalAlerts _alerts;
  final ValueNotifier<AppearanceMode> _appearance = ValueNotifier(
    AppearanceMode.black,
  );

  /// The theme to force on the app, following [ClockSettings.theme].
  ValueListenable<AppearanceMode> get appearance => _appearance;

  /// Restores saved settings (defaults when none).
  Future<void> load() async {
    final saved = await _repository.load();
    if (!isClosed) emit(saved);
  }

  /// Applies and saves [next].
  Future<void> update(ClockSettings next) async {
    emit(next);
    await _repository.save(next);
  }

  /// Turns system notifications on or off. Turning them on asks for
  /// permission first; returns false when it was denied (the setting then
  /// stays off).
  Future<bool> setSystemAlerts(bool on) async {
    final granted = !on || await _alerts.requestPermission();
    if (isClosed) return granted;
    await update(state.copyWith(systemAlerts: on && granted));
    return granted;
  }

  @override
  void onChange(Change<ClockSettings> change) {
    super.onChange(change);
    _appearance.value = switch (change.nextState.theme) {
      ClockTheme.black => AppearanceMode.black,
      ClockTheme.light => AppearanceMode.light,
    };
  }

  @override
  Future<void> close() {
    _appearance.dispose();
    return super.close();
  }
}
