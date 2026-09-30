import 'package:bloc/bloc.dart';
import 'package:design_system/design_system.dart';
import 'package:device_services/device_services.dart';
import 'package:flip_clock/data/models/clock_settings.dart';
import 'package:flip_clock/data/models/skin.dart';
import 'package:flip_clock/data/repositories/settings_repository.dart';
import 'package:flip_clock/data/skins.dart';
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

  /// The selected skin (Mono when the saved id is unknown).
  Skin get skin => Skins.resolve(state.skinId, state.customSkins);

  /// Applies the skin [id].
  Future<void> selectSkin(String id) => update(state.copyWith(skinId: id));

  /// Saves [skin] and selects it. A custom skin is replaced in place; any
  /// other skin (a built-in, or a new copy) is added under a fresh id, so
  /// built-ins never change.
  Future<void> saveSkin(Skin skin) {
    final custom = state.customSkins;
    final replaces = custom.any((s) => s.id == skin.id);
    final saved = replaces
        ? skin
        : skin.copyWith(id: Skins.nextCustomId(custom));
    return update(
      state.copyWith(
        skinId: saved.id,
        customSkins: replaces
            ? [for (final s in custom) s.id == skin.id ? saved : s]
            : [saved, ...custom],
      ),
    );
  }

  /// Removes the custom skin [id]; if it was selected, Mono is selected.
  Future<void> deleteSkin(String id) => update(
    state.copyWith(
      skinId: state.skinId == id ? Skins.monoId : state.skinId,
      customSkins: [
        for (final s in state.customSkins)
          if (s.id != id) s,
      ],
    ),
  );

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
