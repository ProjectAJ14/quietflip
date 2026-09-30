import 'package:core/core.dart';
import 'package:device_services/src/contracts/index.dart';
import 'package:device_services/src/guarded.dart';
import 'package:flutter/foundation.dart';

/// The browser Fullscreen API, or null where the browser lacks it.
typedef BrowserFullScreen = ({
  Future<void> Function(bool on) apply,
  void Function() Function(void Function(bool on) onChange) listen,
});

/// [FullScreenController] over a platform [apply] function.
///
/// When [apply] is null (unsupported) or fails, [active] still flips so the
/// app can hide its own chrome (full-viewport fallback).
class PlatformFullScreenController implements FullScreenController {
  PlatformFullScreenController({
    required Logger logger,
    Future<void> Function(bool on)? apply,
  }) : _logger = logger,
       _apply = apply;

  final Logger _logger;
  final Future<void> Function(bool on)? _apply;
  final _active = ValueNotifier(false);

  @override
  ValueListenable<bool> get active => _active;

  /// Records a change made outside the app (browser Esc, window controls).
  void onExternalChange(bool on) => _active.value = on;

  @override
  Future<void> toggle() => _set(!_active.value);

  @override
  Future<void> exit() async {
    if (_active.value) await _set(false);
  }

  Future<void> _set(bool on) async {
    final apply = _apply;
    if (apply != null) {
      await guarded(_logger, 'full screen $on', () => apply(on), null);
    }
    _active.value = on;
  }

  void dispose() => _active.dispose();
}
