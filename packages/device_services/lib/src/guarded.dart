import 'package:core/core.dart';

/// Runs [action]; on any error logs [what] through [logger] and returns
/// [fallback]. Device features are best-effort: a failing plugin must never
/// break the timer.
Future<T> guarded<T>(
  Logger logger,
  String what,
  Future<T> Function() action,
  T fallback,
) async {
  try {
    return await action();
  } catch (error, stackTrace) {
    logger.e('device_services: $what failed', error, stackTrace);
    return fallback;
  }
}
