/// A pomodoro phase: focus, then a short break.
enum PomodoroPhase {
  focus(Duration(minutes: 25)),
  rest(Duration(minutes: 5));

  const PomodoroPhase(this.duration);

  /// How long this phase runs.
  final Duration duration;
}

/// Where a focus/break cycle is: the phase and the 1-based round. A round is
/// one focus plus its break; the round grows when a new focus starts.
class Pomodoro {
  const Pomodoro({this.phase = PomodoroPhase.focus, this.round = 1});

  final PomodoroPhase phase;
  final int round;

  /// Length of the current phase.
  Duration get duration => phase.duration;

  /// The phase after this one: focus -> break (same round) -> focus (next).
  Pomodoro next() => phase == PomodoroPhase.focus
      ? Pomodoro(phase: PomodoroPhase.rest, round: round)
      : Pomodoro(round: round + 1);

  Map<String, Object?> toJson() => {'phase': phase.name, 'round': round};

  /// Restores [toJson] output; null for anything else, never throws.
  static Pomodoro? fromJson(Object? json) {
    if (json is! Map) return null;
    final phase = PomodoroPhase.values.asNameMap()[json['phase']];
    final round = json['round'];
    if (phase == null || round is! int || round < 1) return null;
    return Pomodoro(phase: phase, round: round);
  }

  @override
  bool operator ==(Object other) =>
      other is Pomodoro && other.phase == phase && other.round == round;

  @override
  int get hashCode => Object.hash(phase, round);
}
