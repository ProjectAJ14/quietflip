# Quietflip: `packages/timekeeping`

Pure-Dart timekeeping: the countdown state machine and the text formatting for
clock, timer and stopwatch. It owns time maths only: no widgets, no Flutter
imports, no persistence, no platform code, no copy. Layer 0 (see
`packages/CLAUDE.md`): depends on nothing in the workspace.

Read the root `CLAUDE.md` and `packages/CLAUDE.md` first.

## Public API (`package:timekeeping/timekeeping.dart`)

| Symbol | Kind | Use |
|---|---|---|
| `CountdownStatus` | enum | `idle`, `running`, `paused`, `finished` |
| `Countdown({now, elapsed})` | class | State machine; `now` is the injected wall clock (default `DateTime.now`), `elapsed` a monotonic reading (default a `Stopwatch` started by the constructor; only differences matter) |
| `Countdown.max` | const | `99:59:59` |
| `Countdown.defaultDuration` | const | `5:00`; fresh and corrupt-restored countdowns use it |
| `Countdown.isValid(d)` | static | `1s <= d <= max` |
| `duration`, `status`, `endsAt` | getters | `endsAt` is set only while running |
| `setDuration(d)` | method | Only from idle/finished (result idle); false when invalid or running/paused |
| `remaining()` | method | While running, the lesser of `endsAt - now()` and the time left at the last read minus the monotonic time since: a wall clock moved forward (or device sleep) shortens it, one set back never lengthens it, and `endsAt` is rebased to `now + remaining` once it lags by more than 1 s. Frozen while paused; zero when finished; `duration` when idle |
| `start`, `pause`, `resume`, `reset` | methods | idle->running, running->paused, paused->running, any->idle (same duration) |
| `checkFinished()` | method | True only on the running->finished transition |
| `toJson()` / `Countdown.fromJson(json, {now, elapsed})` | persistence | Corrupt input -> idle default, never throws. A running snapshot whose `endsAt` has passed restores as running so `checkFinished()` reports it. A running one counts from `max(now, savedAtMs)` and never restores with more than `duration` left (either rebases `endsAt`) |
| `PomodoroPhase` | enum | `focus` (25 min), `rest` (5 min, shown as "Break"); `.duration` |
| `Pomodoro({phase, round})` | value | Defaults focus, round 1. `duration`; `next()` is focus -> break (same round) -> focus (round + 1); `toJson()` `{phase, round}`; `Pomodoro.fromJson(json)` returns null for anything invalid, never throws |
| `formatClock(t, {use24h, showSeconds, meridiem})` | function | `09:41`, `09:41:07`, `9:41 AM`, `12:05 AM` (midnight), `12:30 PM` (noon); the marker comes from `meridiem` |
| `Meridiem`, `meridiemFor(t, meridiem)` | typedef, function | `({String am, String pm})`, the 12-hour markers in the display language; `meridiemFor` picks one for `t` |
| `formatHms(d)` | function | `HH:MM:SS`; callers pass `ceilToSecond(remaining)` |
| `ceilToSecond(d)` | function | Rounds up to a whole second (`400ms -> 1s`, `0 -> 0`) |
| `formatStopwatch(d)` | function | `H:MM:SS.t`, tenths truncated, hours unbounded |

## Layout

| Path | Responsibility |
|---|---|
| `lib/timekeeping.dart` | Barrel |
| `lib/src/countdown.dart` | `CountdownStatus`, `Countdown` |
| `lib/src/format.dart` | `Meridiem`, `meridiemFor`, `formatClock`, `formatHms`, `ceilToSecond`, `formatStopwatch` |
| `lib/src/pomodoro.dart` | `PomodoroPhase`, `Pomodoro` (phase durations and sequence; the timing itself is a `Countdown`) |
| `test/` | Tests for every public behavior |

## Rules

- Never import `package:flutter`. Tests use `flutter_test` only because the
  coverage gate runs `flutter test`.
- Time comes only from the injected `now`; never call `DateTime.now()` directly
  outside the default argument. Remaining time is always derived from the
  clocks (`endsAt` and the injected monotonic `elapsed`), never by counting
  ticks (tabs and backgrounded apps throttle timers).
- Invalid transitions are no-ops (a paused countdown ignores `start`), not
  exceptions: the UI can call them from any button state.
- The stopwatch uses `dart:core` `Stopwatch` (monotonic) directly in the
  feature; do not add a wrapper here.

## Common changes

- **Change a display format:** edit `lib/src/format.dart` and the matching
  expectation table in the format test (include midnight, noon, 99h+).
- **Persist a new countdown field:** add it to `toJson`/`fromJson` with a
  fallback for old snapshots, and add a corrupt/missing-field test.

## Tests

`dart run melos exec --scope=timekeeping -- flutter test`. Cover every
transition (valid and ignored), `remaining()` with a fake wall clock that
jumps apart from the fake monotonic one (set back, slept),
`checkFinished` firing once, and corrupt JSON. `dart run melos run coverage`
must stay 100%.

## Gotchas

- `pause()` is ignored once `endsAt` has passed, so a late pause cannot
  swallow the completion; the next `checkFinished()` still reports it.
- JSON keys: `durationMs`, `status`, `endsAtMs` and `savedAtMs` (running,
  epoch ms UTC; `savedAtMs` is when the snapshot was taken), `remainingMs`
  (paused). Any invalid required field restores the whole idle default; a
  missing, non-int or after-the-end `savedAtMs` is ignored (older snapshots).
- Forward and backward wall jumps are told apart only while the process
  lives. A relaunch knows only `savedAtMs`: a clock set back while closed
  by less than the time since that save still adds that much time, and one
  set back further resumes with the time left at the save (time spent
  closed is not deducted). Moving the clock forward always shortens a
  timer: it cannot be told from device sleep, where the monotonic clock
  stops.
- `formatClock` has no English default: callers pass the markers
  (`flip_clock`'s `meridiemOf(context)`, from `intl`). The marker always
  follows the time, even where the language puts it first (`午前 9:41`).
