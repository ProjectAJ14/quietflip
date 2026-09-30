import 'package:flutter_test/flutter_test.dart';
import 'package:timekeeping/timekeeping.dart';

void main() {
  test('starts on focus round 1: 25 min focus, 5 min break', () {
    const p = Pomodoro();
    expect(p.phase, PomodoroPhase.focus);
    expect(p.round, 1);
    expect(p.duration, const Duration(minutes: 25));
    expect(PomodoroPhase.rest.duration, const Duration(minutes: 5));
  });

  test('alternates focus and break; a new focus starts the next round', () {
    final seq = [const Pomodoro()];
    for (var i = 0; i < 4; i++) {
      seq.add(seq.last.next());
    }
    expect(seq, const [
      Pomodoro(),
      Pomodoro(phase: PomodoroPhase.rest),
      Pomodoro(round: 2),
      Pomodoro(phase: PomodoroPhase.rest, round: 2),
      Pomodoro(round: 3),
    ]);
  });

  test('round-trips through JSON', () {
    const p = Pomodoro(phase: PomodoroPhase.rest, round: 7);
    expect(Pomodoro.fromJson(p.toJson()), p);
    expect(p.toJson(), {'phase': 'rest', 'round': 7});
  });

  test('corrupt JSON restores nothing', () {
    for (final json in <Object?>[
      null,
      'focus',
      <String, Object?>{},
      {'phase': 'nap', 'round': 1},
      {'phase': 'focus'},
      {'phase': 'focus', 'round': '2'},
      {'phase': 'focus', 'round': 0},
    ]) {
      expect(Pomodoro.fromJson(json), isNull, reason: '$json');
    }
  });

  test('equality and hashCode', () {
    expect(const Pomodoro().hashCode, const Pomodoro(round: 1).hashCode);
    expect(const Pomodoro(), isNot(const Pomodoro(round: 2)));
    expect(const Pomodoro(), isNot(const Pomodoro(phase: PomodoroPhase.rest)));
  });
}
