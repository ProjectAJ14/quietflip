import 'package:core/core.dart';
import 'package:device_services/src/contracts/index.dart';

/// [ScreenBrightness] over the `screen_brightness` plugin's app-scoped calls.
///
/// `init()` makes it [supported] only on Android and iOS; elsewhere [current]
/// returns 1.0 and [set] / [reset] are no-ops.
///
/// Unlike the package's other adapters, a failing plugin call is not swallowed:
/// it is logged and rethrown as [ScreenBrightnessException] so the caller can
/// fall back to dimming the app. Callers must catch it.
class PluginScreenBrightness implements ScreenBrightness {
  PluginScreenBrightness({
    required Logger logger,
    required this.supported,
    required Future<double> Function() read,
    required Future<void> Function(double) write,
    required Future<void> Function() restore,
  }) : _logger = logger,
       _read = read,
       _write = write,
       _restore = restore;

  final Logger _logger;
  final Future<double> Function() _read;
  final Future<void> Function(double) _write;
  final Future<void> Function() _restore;

  @override
  final bool supported;

  @override
  Future<double> current() async => supported ? _call('current', _read) : 1.0;

  @override
  Future<void> set(double value) async {
    if (supported) await _call('set', () => _write(value.clamp(0.0, 1.0)));
  }

  @override
  Future<void> reset() async {
    if (supported) await _call('reset', _restore);
  }

  Future<T> _call<T>(String operation, Future<T> Function() action) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      _logger.e(
        'device_services: brightness $operation failed',
        error,
        stackTrace,
      );
      throw ScreenBrightnessException(operation, error);
    }
  }
}
