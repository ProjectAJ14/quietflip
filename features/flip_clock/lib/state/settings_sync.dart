import 'dart:async';
import 'dart:convert';

import 'package:cloud_sync/cloud_sync.dart';
import 'package:device_services/device_services.dart';
import 'package:flip_clock/data/models/clock_settings.dart';
import 'package:flip_clock/state/settings_controller.dart';

/// Keeps the clock settings in step with the cloud.
///
/// The device copy is always saved first by [SettingsController] and never
/// waits for the network; this only mirrors it. The last change wins, by the
/// time it was made on its device ([updatedAtKey]).
class SettingsSync {
  SettingsSync({
    required SettingsController settings,
    required CloudSync sync,
    required KeyValueStore store,
    DateTime Function() now = DateTime.now,
    Duration debounce = const Duration(seconds: 1),
  }) : _settings = settings,
       _sync = sync,
       _store = store,
       _now = now,
       _debounce = debounce;

  static const String documentName = 'clock_settings';
  static const String updatedAtKey = 'flip_clock.settings_updated_at';

  /// Never synced: OS permission, the screen this device was on, rotation
  /// and brightness differ per device. (The running countdown is saved
  /// under its own key and never synced either.)
  static const Set<String> deviceOnly = {
    'systemAlerts',
    'lastMode',
    'orientation',
    'digitBrightness',
  };

  final SettingsController _settings;
  final CloudSync _sync;
  final KeyValueStore _store;
  final DateTime Function() _now;
  final Duration _debounce;

  StreamSubscription<ClockSettings>? _changes;
  StreamSubscription<SyncedDocument?>? _remote;
  Timer? _pending;

  /// When the synced part last changed on this device or was taken from the
  /// cloud; 0 when never (every install before sync).
  int _updatedAt = 0;

  /// The synced part as last seen, so device-only changes and applied cloud
  /// copies are not pushed.
  String _last = '';

  /// Restores the stamp, then follows local changes and the cloud copy.
  Future<void> start() async {
    _updatedAt = int.tryParse(await _store.read(updatedAtKey) ?? '') ?? 0;
    _last = _encode(_settings.state);
    _changes = _settings.stream.listen(_onChange);
    _remote = _sync.watch(documentName).listen(_onRemote);
  }

  static Map<String, Object?> _payload(ClockSettings settings) =>
      settings.toJson()..removeWhere((key, _) => deviceOnly.contains(key));

  static String _encode(ClockSettings settings) =>
      jsonEncode(_payload(settings));

  void _onChange(ClockSettings next) {
    final encoded = _encode(next);
    if (encoded == _last) return;
    _last = encoded;
    unawaited(_stamp(_now().millisecondsSinceEpoch));
    // Trailing debounce: a slider drag sends one write, not forty.
    _pending?.cancel();
    _pending = Timer(_debounce, () => unawaited(_push()));
  }

  Future<void> _onRemote(SyncedDocument? remote) async {
    if (remote != null && remote.updatedAt > _updatedAt) {
      _pending?.cancel();
      // A JSON round trip gives the plain maps `fromJson` reads, whatever
      // map types the platform decoded.
      final data = jsonDecode(jsonEncode(remote.data)) as Map<String, Object?>;
      final next = ClockSettings.fromJson({
        ..._settings.state.toJson(),
        ...(data..removeWhere((key, _) => deviceOnly.contains(key))),
      });
      _last = _encode(next);
      await _stamp(remote.updatedAt);
      await _settings.update(next);
    } else if (remote == null || remote.updatedAt < _updatedAt) {
      if (_updatedAt == 0) await _stamp(_now().millisecondsSinceEpoch);
      _pending?.cancel();
      await _push();
    }
    // Equal: already in step.
  }

  Future<void> _stamp(int updatedAt) async {
    _updatedAt = updatedAt;
    await _store.write(updatedAtKey, '$updatedAt');
  }

  Future<void> _push() => _sync.push(
    documentName,
    _payload(_settings.state),
    updatedAt: _updatedAt,
  );

  /// Cancels the pending push and both subscriptions.
  Future<void> close() async {
    _pending?.cancel();
    await Future.wait([?_changes?.cancel(), ?_remote?.cancel()]);
  }
}
