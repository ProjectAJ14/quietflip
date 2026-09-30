import 'package:core/core.dart' as core;
import 'package:core/core.dart' show Logger;
import 'package:di/di.dart';
import 'package:flip_clock/data/repositories/settings_repository_imp.dart';
import 'package:flip_clock/flip_clock.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  late FakeStore store;
  late SettingsRepositoryImp repo;

  setUp(() async {
    await core.init();
    store = FakeStore();
    repo = SettingsRepositoryImp(store: store, logger: di.get<Logger>());
  });
  tearDown(di.reset);

  test('loads defaults when nothing is stored', () async {
    expect(await repo.load(), const ClockSettings());
    expect(await repo.loadCountdown(), isNull);
  });

  test('saves and restores settings and the countdown snapshot', () async {
    const s = ClockSettings(theme: ClockTheme.light, showSeconds: true);
    await repo.save(s);
    await repo.saveCountdown({'status': 'paused'});
    expect(await repo.load(), s);
    expect(await repo.loadCountdown(), {'status': 'paused'});
    expect(store.data.keys, {
      SettingsRepositoryImp.settingsKey,
      SettingsRepositoryImp.countdownKey,
    });
  });

  test('corrupt or non-object json falls back to defaults', () async {
    store.data[SettingsRepositoryImp.settingsKey] = '{not json';
    store.data[SettingsRepositoryImp.countdownKey] = '[1, 2]';
    expect(await repo.load(), const ClockSettings());
    expect(await repo.loadCountdown(), isNull);
  });

  test('storage failures are logged, never thrown', () async {
    store.failure = PlatformException(code: 'io');
    expect(await repo.load(), const ClockSettings());
    await repo.save(const ClockSettings());
    await repo.saveCountdown(const {});
    expect(store.data, isEmpty);
  });
}
