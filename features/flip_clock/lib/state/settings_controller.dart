import 'package:bloc/bloc.dart';
import 'package:design_system/design_system.dart';
import 'package:device_services/device_services.dart';
import 'package:flip_clock/analytics/clock_analytics.dart';
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
    ClockAnalytics? analytics,
  }) : _repository = repository,
       _alerts = alerts,
       _analytics = analytics,
       super(const ClockSettings());

  final SettingsRepository _repository;
  final LocalAlerts _alerts;
  final ClockAnalytics? _analytics;
  final ValueNotifier<AppearanceMode> _appearance = ValueNotifier(
    AppearanceMode.black,
  );

  /// The theme to force on the app, following [ClockSettings.theme].
  ValueListenable<AppearanceMode> get appearance => _appearance;

  final ValueNotifier<DisplayFace?> _face = ValueNotifier(null);

  /// The face the whole app is set in, following the selected skin: null
  /// (Geist) for the default Barlow Condensed face, so Mono and the Classic
  /// skins keep the design system's interface font.
  ValueListenable<DisplayFace?> get face => _face;

  final ValueNotifier<double> _corner = ValueNotifier(
    DesignShape.defaultCorner,
  );

  /// The corner every shape in the app follows ([ClockSettings.corner]).
  ValueListenable<double> get corner => _corner;

  /// Restores saved settings (defaults when none) and reports them as the
  /// user's properties.
  Future<void> load() async {
    final saved = await _repository.load();
    if (isClosed) return;
    emit(saved);
    _analytics?.identify(saved);
  }

  /// Applies and saves [next]. [fromCloud] marks a copy taken from another
  /// device, which analytics does not count as this user's change.
  Future<void> update(ClockSettings next, {bool fromCloud = false}) async {
    final before = state;
    emit(next);
    if (fromCloud) {
      _analytics?.settingsFromCloudApplied(next);
    } else {
      _analytics?.settingsChanged(before, next);
    }
    await _repository.save(next);
  }

  /// The selected skin (Mono when the saved id is unknown).
  Skin get skin => Skins.resolve(state.skinId, state.customSkins);

  /// Applies the skin [id] and its seconds preset: Show seconds turns on
  /// when the skin shows seconds, off when it does not (the user can still
  /// toggle it after).
  Future<void> selectSkin(String id) {
    final skin = Skins.resolve(id, state.customSkins);
    return update(
      state.copyWith(skinId: id, showSeconds: skin.seconds != SkinSeconds.off),
    );
  }

  /// Saves [skin] and selects it. A custom skin is replaced in place; any
  /// other skin (a built-in, or a new copy) is added under a fresh id, so
  /// built-ins never change. Custom skins keep their explicit colours in
  /// every theme (never `themed`); Show seconds follows the saved skin.
  Future<void> saveSkin(Skin skin) {
    final custom = state.customSkins;
    final replaces = custom.any((s) => s.id == skin.id);
    final saved = skin.copyWith(
      id: replaces ? skin.id : Skins.nextCustomId(custom),
      themed: false,
    );
    return update(
      state.copyWith(
        skinId: saved.id,
        showSeconds: saved.seconds != SkinSeconds.off,
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
    if (on) _analytics?.notificationPermissionAnswered(granted: granted);
    if (isClosed) return granted;
    await update(state.copyWith(systemAlerts: on && granted));
    return granted;
  }

  @override
  void onChange(Change<ClockSettings> change) {
    super.onChange(change);
    _appearance.value = switch (change.nextState.theme) {
      ClockTheme.dark => AppearanceMode.black,
      ClockTheme.light => AppearanceMode.light,
      ClockTheme.system => AppearanceMode.system,
    };
    final face = Skins.resolve(
      change.nextState.skinId,
      change.nextState.customSkins,
    ).face;
    _face.value = face == DisplayFace.barlowCondensed ? null : face;
    _corner.value = change.nextState.corner;
  }

  @override
  Future<void> close() {
    _appearance.dispose();
    _face.dispose();
    _corner.dispose();
    return super.close();
  }
}
