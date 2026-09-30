/// Which way the screen may turn.
enum ScreenOrientation { auto, landscape, portrait }

/// Locks the screen to an orientation where the platform allows it.
abstract interface class OrientationLock {
  /// False on web and desktop, where [set] does nothing.
  bool get supported;

  /// Applies [orientation]. Never throws; failures are logged.
  Future<void> set(ScreenOrientation orientation);
}
