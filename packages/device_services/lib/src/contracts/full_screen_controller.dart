import 'package:flutter/foundation.dart';

/// Enters and leaves the largest display the platform allows.
///
/// Where the platform cannot go full screen (iPhone Safari), [toggle] only
/// flips [active] and the app hides its own chrome (full-viewport fallback).
abstract interface class FullScreenController {
  /// Whether full screen is on, including changes made outside the app
  /// (browser Esc, OS window controls).
  ValueListenable<bool> get active;

  /// Enters full screen when off, leaves it when on.
  Future<void> toggle();

  /// Leaves full screen; no-op when already off.
  Future<void> exit();
}
