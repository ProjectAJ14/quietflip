import 'package:core/core.dart';
import 'package:device_services/src/contracts/index.dart';
import 'package:device_services/src/guarded.dart';

/// [ScreenWake] over `WakelockPlus.toggle`.
class WakelockScreenWake implements ScreenWake {
  WakelockScreenWake({
    required Logger logger,
    required Future<void> Function({required bool enable}) toggle,
  }) : _logger = logger,
       _toggle = toggle;

  final Logger _logger;
  final Future<void> Function({required bool enable}) _toggle;

  @override
  Future<void> setEnabled(bool on) =>
      guarded(_logger, 'wake lock $on', () => _toggle(enable: on), null);
}
