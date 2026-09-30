import 'dart:convert';

import 'package:core/core.dart';
import 'package:device_services/device_services.dart';
import 'package:flip_clock/data/models/clock_settings.dart';
import 'package:flip_clock/data/repositories/settings_repository.dart';

/// [SettingsRepository] stored as JSON strings in a [KeyValueStore].
///
/// Storage failures are logged and never block the clock: a failed read
/// yields defaults, a failed write keeps the in-memory value.
class SettingsRepositoryImp implements SettingsRepository {
  SettingsRepositoryImp({required KeyValueStore store, required Logger logger})
    : _store = store,
      _logger = logger;

  static const String settingsKey = 'flip_clock.settings';
  static const String countdownKey = 'flip_clock.countdown';

  final KeyValueStore _store;
  final Logger _logger;

  @override
  Future<ClockSettings> load() async =>
      ClockSettings.fromJson(await _readJson(settingsKey) ?? const {});

  @override
  Future<void> save(ClockSettings settings) =>
      _write(settingsKey, settings.toJson());

  @override
  Future<Map<String, Object?>?> loadCountdown() => _readJson(countdownKey);

  @override
  Future<void> saveCountdown(Map<String, Object?> snapshot) =>
      _write(countdownKey, snapshot);

  Future<Map<String, Object?>?> _readJson(String key) async {
    try {
      final raw = await _store.read(key);
      if (raw == null) return null;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, Object?>) return decoded;
      _logger.w('Ignoring non-object value stored under $key');
    } on FormatException catch (error, stack) {
      _logger.e('Ignoring corrupt value stored under $key', error, stack);
    } on Exception catch (error, stack) {
      _logger.e('Could not read $key', error, stack);
    }
    return null;
  }

  Future<void> _write(String key, Map<String, Object?> value) async {
    try {
      await _store.write(key, jsonEncode(value));
    } on Exception catch (error, stack) {
      _logger.e('Could not save $key', error, stack);
    }
  }
}
