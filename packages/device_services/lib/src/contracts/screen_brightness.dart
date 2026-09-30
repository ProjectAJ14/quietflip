/// App-scoped screen brightness (iOS and Android). Where it is not
/// [supported] (macOS, Windows, Linux, web) callers dim the app instead.
abstract interface class ScreenBrightness {
  /// False where the platform cannot set the screen brightness.
  bool get supported;

  /// The current brightness, 0..1. Throws [ScreenBrightnessException].
  Future<double> current();

  /// Sets the brightness for this app, clamped to 0..1. Throws
  /// [ScreenBrightnessException].
  Future<void> set(double value);

  /// Returns the screen to the system brightness. Throws
  /// [ScreenBrightnessException].
  Future<void> reset();
}

/// A brightness call failed on the platform. Already logged; callers fall
/// back to dimming the app.
class ScreenBrightnessException implements Exception {
  const ScreenBrightnessException(this.operation, [this.cause]);

  /// `current`, `set` or `reset`.
  final String operation;

  /// The platform error.
  final Object? cause;

  @override
  String toString() => 'ScreenBrightnessException($operation): $cause';
}
