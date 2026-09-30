import 'package:core/core.dart';
import 'package:device_services/device_services.dart';
import 'package:flip_clock/data/models/clock_settings.dart';
import 'package:flip_clock/state/settings_controller.dart';

/// Drives brightness from the vertical drag and the Up/Down keys: the
/// screen brightness where the device supports it, otherwise the digit
/// brightness in [ClockSettings] (saved). After the first
/// [ScreenBrightnessException] it dims the app for the rest of its life.
class BrightnessControl {
  BrightnessControl({
    required ScreenBrightness device,
    required SettingsController settings,
    required Logger logger,
  }) : _device = device,
       _settings = settings,
       _logger = logger;

  /// How much one Up/Down key press changes the brightness.
  static const double keyStep = 0.1;

  final ScreenBrightness _device;
  final SettingsController _settings;
  final Logger _logger;

  bool _failed = false;
  bool _changed = false;
  double? _level;

  /// True while the screen brightness is driven (supported, no failure yet).
  bool get usesDevice => _device.supported && !_failed;

  /// The level being driven: the screen's while [usesDevice], otherwise the
  /// digit brightness.
  double get value =>
      usesDevice ? _level ?? 1 : _settings.state.digitBrightness;

  /// Reads the screen brightness at gesture start.
  Future<void> begin() async {
    if (!usesDevice) return;
    try {
      _level = await _device.current();
    } on ScreenBrightnessException catch (e) {
      _fallBack(e);
    }
  }

  /// Moves the level by [delta] and returns the new one.
  Future<double> change(double delta) async {
    if (usesDevice && _level == null) await begin();
    if (usesDevice) {
      final next = (_level! + delta).clamp(0.0, 1.0);
      try {
        await _device.set(next);
        _level = next;
        _changed = true;
        return next;
      } on ScreenBrightnessException catch (e) {
        _fallBack(e);
      }
    }
    final next = (_settings.state.digitBrightness + delta).clamp(
      ClockSettings.minBrightness,
      ClockSettings.maxBrightness,
    );
    await _settings.update(_settings.state.copyWith(digitBrightness: next));
    return next;
  }

  /// Returns the screen to the system brightness if this object changed it
  /// (app paused or detached, screen disposed). Never throws.
  Future<void> reset() async {
    if (!_changed) return;
    _changed = false;
    _level = null;
    try {
      await _device.reset();
    } on ScreenBrightnessException catch (e) {
      _logger.w('Screen brightness reset failed: $e');
    }
  }

  void _fallBack(ScreenBrightnessException e) {
    _failed = true;
    _logger.w('Screen brightness unavailable, dimming the app instead: $e');
  }
}
