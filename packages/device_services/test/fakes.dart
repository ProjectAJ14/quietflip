import 'package:core/core.dart';

/// Records log calls so tests can assert failures were logged, not thrown.
class FakeLogger implements Logger {
  final errors = <String>[];
  final warnings = <String>[];

  @override
  Object get logger => this;

  @override
  void d(String message) {}

  @override
  void i(String message) {}

  @override
  void w(String message) => warnings.add(message);

  @override
  void e(String message, [Object? error, StackTrace? stackTrace]) =>
      errors.add(message);
}
