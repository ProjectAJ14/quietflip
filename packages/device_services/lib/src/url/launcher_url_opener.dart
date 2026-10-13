import 'package:core/core.dart';
import 'package:device_services/src/contracts/index.dart';
import 'package:device_services/src/guarded.dart';

/// [UrlOpener] over `launchUrl` in an external application.
class LauncherUrlOpener implements UrlOpener {
  LauncherUrlOpener({
    required Logger logger,
    required Future<bool> Function(Uri url) launch,
  }) : _logger = logger,
       _launch = launch;

  final Logger _logger;
  final Future<bool> Function(Uri url) _launch;

  @override
  Future<bool> open(Uri url) =>
      guarded(_logger, 'open $url', () => _launch(url), false);
}
