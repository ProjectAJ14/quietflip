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
| `Countdown({now})` | class | State machine; `now` is the injected wall clock (default `DateTime.now`) |
| `Countdown.max` | const | `99:59:59` |
| `Countdown.defaultDuration` | const | `5:00`; fresh and corrupt-restored countdowns use it |
| `Countdown.isValid(d)` | static | `1s <= d <= max` |
| `duration`, `status`, `endsAt` | getters | `endsAt` is set only while running |
| `setDuration(d)` | method | Only from idle/finished (result idle); false when invalid or running/paused |
| `remaining()` | method | Derived from `endsAt - now()` while running (never above `duration`: a clock set back, or a snapshot ending further away, rebases `endsAt` to `now + duration`); frozen while paused; zero when finished; `duration` when idle |
| `start`, `pause`, `resume`, `reset` | methods | idle->running, running->paused, paused->running, any->idle (same duration) |
| `checkFinished()` | method | True only on the running->finished transition |
| `toJson()` / `Countdown.fromJson(json, {now})` | persistence | Corrupt input -> idle default, never throws. A running snapshot whose `endsAt` has passed restores as running so `checkFinished()` reports it |
| `formatClock(t, {use24h, showSeconds})` | function | `09:41`, `09:41:07`, `9:41 AM`, `12:05 AM` (midnight), `12:30 PM` (noon) |
| `formatHms(d)` | function | `HH:MM:SS`; callers pass `ceilToSecond(remaining)` |
| `ceilToSecond(d)` | function | Rounds up to a whole second (`400ms -> 1s`, `0 -> 0`) |
| `formatStopwatch(d)` | function | `H:MM:SS.t`, tenths truncated, hours unbounded |

## Layout

| Path | Responsibility |
|---|---|
| `lib/timekeeping.dart` | Barrel |
| `lib/src/countdown.dart` | `CountdownStatus`, `Countdown` |
| `lib/src/format.dart` | `formatClock`, `formatHms`, `ceilToSecond`, `formatStopwatch` |
| `test/` | Tests for every public behavior |

## Rules

- Never import `package:flutter`. Tests use `flutter_test` only because the
  coverage gate runs `flutter test`.
- Time comes only from the injected `now`; never call `DateTime.now()` directly
  outside the default argument. Remaining time is always derived from `endsAt`,
  never by counting ticks (tabs and backgrounded apps throttle timers).
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
transition (valid and ignored), `remaining()` with a fake clock that jumps,
`checkFinished` firing once, and corrupt JSON. `dart run melos run coverage`
must stay 100%.

## Gotchas

- `pause()` is ignored once `endsAt` has passed, so a late pause cannot
  swallow the completion; the next `checkFinished()` still reports it.
- JSON keys: `durationMs`, `status`, `endsAtMs` (running, epoch ms UTC),
  `remainingMs` (paused). Any invalid field restores the whole idle default.
- `formatClock` emits literal `AM`/`PM`; localise in the caller if a locale
  ever needs different markers.
