import 'package:flutter_test/flutter_test.dart';
import 'package:timekeeping/timekeeping.dart';

void main() {
  late DateTime clock;
  DateTime now() => clock;
  void advance(Duration d) => clock = clock.add(d);
  Countdown make() => Countdown(now: now);

  setUp(() => clock = DateTime.utc(2026, 1, 1, 12));

  group('defaults and validation', () {
    test('starts idle with the default duration', () {
      final c = make();
      expect(c.status, CountdownStatus.idle);
      expect(c.duration, Countdown.defaultDuration);
      expect(c.endsAt, isNull);
      expect(c.remaining(), Countdown.defaultDuration);
      expect(
        Countdown.max,
        const Duration(hours: 99, minutes: 59, seconds: 59),
      );
    });

    test('default constructor uses the real clock', () {
      final c = Countdown()..start();
      expect(c.endsAt!.isAfter(DateTime.now()), isTrue);
    });

    test('isValid accepts 1s through max only', () {
      expect(Countdown.isValid(Duration.zero), isFalse);
      expect(Countdown.isValid(const Duration(milliseconds: 999)), isFalse);
      expect(Countdown.isValid(const Duration(seconds: 1)), isTrue);
      expect(Countdown.isValid(Countdown.max), isTrue);
      expect(
        Countdown.isValid(Countdown.max + const Duration(seconds: 1)),
        isFalse,
      );
      expect(Countdown.isValid(const Duration(seconds: -1)), isFalse);
    });

    test('setDuration rejects invalid values and keeps the old one', () {
      final c = make();
      expect(c.setDuration(Duration.zero), isFalse);
      expect(
        c.setDuration(Countdown.max + const Duration(seconds: 1)),
        isFalse,
      );
      expect(c.duration, Countdown.defaultDuration);
      expect(c.setDuration(Countdown.max), isTrue);
      expect(c.duration, Countdown.max);
    });

    test('setDuration is refused while running or paused', () {
      final c = make()..start();
      expect(c.setDuration(const Duration(seconds: 3)), isFalse);
      c.pause();
      expect(c.setDuration(const Duration(seconds: 3)), isFalse);
      expect(c.duration, Countdown.defaultDuration);
    });

    test('setDuration from finished returns to idle', () {
      final c = make()
        ..setDuration(const Duration(seconds: 1))
        ..start();
      advance(const Duration(seconds: 1));
      expect(c.checkFinished(), isTrue);
      expect(c.setDuration(const Duration(seconds: 7)), isTrue);
      expect(c.status, CountdownStatus.idle);
      expect(c.remaining(), const Duration(seconds: 7));
    });
  });

  group('transitions', () {
    test('start runs and remaining follows the wall clock', () {
      final c = make()..setDuration(const Duration(seconds: 10));
      c.start();
      expect(c.status, CountdownStatus.running);
      expect(c.endsAt, clock.add(const Duration(seconds: 10)));
      advance(const Duration(milliseconds: 3500));
      expect(c.remaining(), const Duration(milliseconds: 6500));
      advance(const Duration(hours: 1)); // app backgrounded, clock jumped
      expect(c.remaining(), Duration.zero);
    });

    test('pause freezes remaining and resume continues from it', () {
      final c = make()
        ..setDuration(const Duration(seconds: 10))
        ..start();
      advance(const Duration(seconds: 4));
      c.pause();
      expect(c.status, CountdownStatus.paused);
      expect(c.endsAt, isNull);
      advance(const Duration(minutes: 5));
      expect(c.remaining(), const Duration(seconds: 6));
      c.resume();
      expect(c.status, CountdownStatus.running);
      expect(c.endsAt, clock.add(const Duration(seconds: 6)));
    });

    test('pause after the end has passed is ignored', () {
      final c = make()
        ..setDuration(const Duration(seconds: 1))
        ..start();
      advance(const Duration(seconds: 2));
      c.pause();
      expect(c.status, CountdownStatus.running);
      expect(c.checkFinished(), isTrue);
    });

    test('illegal transitions are no-ops', () {
      final c = make();
      c
        ..pause()
        ..resume();
      expect(c.status, CountdownStatus.idle);

      c.start();
      final endsAt = c.endsAt;
      advance(const Duration(seconds: 1));
      c
        ..start()
        ..resume();
      expect(c.status, CountdownStatus.running);
      expect(c.endsAt, endsAt);

      c
        ..pause()
        ..start()
        ..pause();
      expect(c.status, CountdownStatus.paused);
      expect(c.checkFinished(), isFalse);

      c
        ..reset()
        ..setDuration(const Duration(seconds: 1))
        ..start();
      advance(const Duration(seconds: 1));
      c.checkFinished();
      c
        ..start()
        ..pause()
        ..resume();
      expect(c.status, CountdownStatus.finished);
      expect(c.remaining(), Duration.zero);
    });

    test('reset returns to idle keeping the duration', () {
      final c = make()
        ..setDuration(const Duration(seconds: 30))
        ..start();
      advance(const Duration(seconds: 10));
      c.reset();
      expect(c.status, CountdownStatus.idle);
      expect(c.endsAt, isNull);
      expect(c.remaining(), const Duration(seconds: 30));
    });

    test('checkFinished fires exactly once, at the end', () {
      final c = make()
        ..setDuration(const Duration(seconds: 2))
        ..start();
      expect(c.checkFinished(), isFalse);
      advance(const Duration(milliseconds: 1999));
      expect(c.checkFinished(), isFalse);
      advance(const Duration(milliseconds: 1));
      expect(c.checkFinished(), isTrue);
      expect(c.status, CountdownStatus.finished);
      expect(c.endsAt, isNull);
      expect(c.checkFinished(), isFalse);
    });

    test('checkFinished is false while idle', () {
      expect(make().checkFinished(), isFalse);
    });
  });

  group('persistence', () {
    Countdown restore(Map<String, Object?> json) =>
        Countdown.fromJson(json, now: now);

    void expectDefault(Countdown c) {
      expect(c.status, CountdownStatus.idle);
      expect(c.duration, Countdown.defaultDuration);
      expect(c.endsAt, isNull);
    }

    test('round-trips idle, running, paused and finished', () {
      final idle = make()..setDuration(const Duration(seconds: 90));
      expect(restore(idle.toJson()).remaining(), const Duration(seconds: 90));

      final running = make()
        ..setDuration(const Duration(seconds: 90))
        ..start();
      final r = restore(running.toJson());
      expect(r.status, CountdownStatus.running);
      expect(r.endsAt, running.endsAt);
      advance(const Duration(seconds: 30));
      expect(r.remaining(), const Duration(seconds: 60));

      running.pause();
      final p = restore(running.toJson());
      expect(p.status, CountdownStatus.paused);
      expect(p.remaining(), const Duration(seconds: 60));
      expect(p.duration, const Duration(seconds: 90));

      advance(const Duration(minutes: 2));
      expect(r.checkFinished(), isTrue);
      final f = restore(r.toJson());
      expect(f.status, CountdownStatus.finished);
      expect(f.remaining(), Duration.zero);
    });

    test('a running snapshot that ended while away reports finished once', () {
      final c = make()
        ..setDuration(const Duration(seconds: 5))
        ..start();
      final snapshot = c.toJson();
      advance(const Duration(hours: 3));
      final restored = restore(snapshot);
      expect(restored.status, CountdownStatus.running);
      expect(restored.checkFinished(), isTrue);
      expect(restored.checkFinished(), isFalse);
    });

    test('an end further away than the duration is rebased', () {
      final c = make()
        ..setDuration(const Duration(seconds: 30))
        ..start();
      clock = clock.subtract(const Duration(hours: 1));
      expect(c.remaining(), const Duration(seconds: 30));
      expect(c.endsAt, clock.add(const Duration(seconds: 30)));

      final far = restore({
        'durationMs': 5000,
        'status': 'running',
        'endsAtMs': clock.add(const Duration(days: 9)).millisecondsSinceEpoch,
      });
      expect(far.endsAt, clock.add(const Duration(seconds: 5)));
      advance(const Duration(seconds: 5));
      expect(far.checkFinished(), isTrue);
    });

    test('corrupt input falls back to the idle default', () {
      final cases = <Map<String, Object?>>[
        {},
        {'durationMs': 'x', 'status': 'idle'},
        {'durationMs': 1000, 'status': 'bogus'},
        {'durationMs': 1000, 'status': 3},
        {'durationMs': 0, 'status': 'idle'},
        {'durationMs': 360000000, 'status': 'idle'},
        {'durationMs': 1000, 'status': 'running'},
        {'durationMs': 1000, 'status': 'running', 'endsAtMs': '1'},
        {'durationMs': 1000, 'status': 'running', 'endsAtMs': 9000000000000000},
        {'durationMs': 1000, 'status': 'paused'},
        {'durationMs': 1000, 'status': 'paused', 'remainingMs': 0},
        {'durationMs': 1000, 'status': 'paused', 'remainingMs': 1001},
        {'durationMs': 1000, 'status': 'paused', 'remainingMs': 1.5},
      ];
      for (final json in cases) {
        expectDefault(restore(json));
      }
    });
  });
}
