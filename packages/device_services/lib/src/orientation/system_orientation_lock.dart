import 'package:core/core.dart';
import 'package:device_services/src/contracts/index.dart';
import 'package:device_services/src/guarded.dart';
import 'package:flutter/services.dart';

/// [OrientationLock] over `SystemChrome.setPreferredOrientations`.
///
/// `init()` makes it [supported] only on Android and iOS; elsewhere [set] is
/// a no-op.
class SystemOrientationLock implements OrientationLock {
  SystemOrientationLock({
    required Logger logger,
    required this.supported,
    required Future<void> Function(List<DeviceOrientation>) apply,
  }) : _logger = logger,
       _apply = apply;

  final Logger _logger;
  final Future<void> Function(List<DeviceOrientation>) _apply;

  @override
  final bool supported;

  @override
  Future<void> set(ScreenOrientation orientation) async {
    if (!supported) return;
    await guarded(
      _logger,
      'orientation ${orientation.name}',
      () => _apply(switch (orientation) {
        // Empty means the platform default: follow the device.
        ScreenOrientation.auto => const [],
        ScreenOrientation.landscape => const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        ScreenOrientation.portrait => const [DeviceOrientation.portraitUp],
      }),
      null,
    );
  }
}
