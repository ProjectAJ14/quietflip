import 'package:core/core.dart';
import 'package:device_services/src/contracts/index.dart';
import 'package:device_services/src/guarded.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [KeyValueStore] over [SharedPreferencesAsync]. A storage failure is logged
/// and reads as absent, so callers fall back to defaults.
class PreferencesKeyValueStore implements KeyValueStore {
  PreferencesKeyValueStore({
    required SharedPreferencesAsync preferences,
    required Logger logger,
  }) : _preferences = preferences,
       _logger = logger;

  final SharedPreferencesAsync _preferences;
  final Logger _logger;

  @override
  Future<String?> read(String key) =>
      guarded(_logger, 'read $key', () => _preferences.getString(key), null);

  @override
  Future<void> write(String key, String value) => guarded(
    _logger,
    'write $key',
    () => _preferences.setString(key, value),
    null,
  );

  @override
  Future<void> delete(String key) =>
      guarded(_logger, 'delete $key', () => _preferences.remove(key), null);
}
