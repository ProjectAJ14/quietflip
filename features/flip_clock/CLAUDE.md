# Quietflip: `features/flip_clock`

The whole first-release product: the flip clock, countdown timer, stopwatch
and their Settings screen. The app launches straight into
`FlipClockRouter.home`. It owns screens, state and local settings. Time maths
comes from `timekeeping`; platform work (full screen, wake lock, local
notifications, sounds, storage) comes from `device_services` contracts. No
sign-in, analytics, network or FCM.

Read the root `CLAUDE.md` and `features/CLAUDE.md` first. Load the
`design-system` and `flutter-best-practices` skills before UI work.

## Public API (`package:flip_clock/flip_clock.dart`)

| Symbol | Kind | Notes |
|---|---|---|
| `init()` | function | Registers `SettingsRepository` and the controllers with `di`. After `core.init()` and `device_services.init()` |
| `FlipClockRouter` | `CoreRouter` | `home = '/clock'`, `settings = '/clock/settings'`, `routes` |
| `appearance()` | `ValueListenable<AppearanceMode>` | The chosen theme for `DesignSystemWrapper(mode:)`; Black by default, even when the OS is light |
| `ClockSettings`, `ClockTheme`, `ClockMode`, `ClockOrientation` | model | Defaults: black, 24h, no seconds, flip sound off, alert sound on, system alerts off, keep awake off, last mode clock, seconds hint not seen, digit brightness 1.0 (0.2..1.0; `fromJson` clamps numbers into range), subtle movement off, date off, orientation auto. `fromJson` falls back per field. `ClockSettings.nextDim` is the quick-dim cycle |

## Layout

```
lib/
  flip_clock.dart                          barrel: init, appearance, exports (model + router only)
  router/flip_clock_router.dart            paths + routes; resolves controllers from di
  data/models/clock_settings.dart          ClockSettings, ClockTheme, ClockMode, ClockOrientation
  data/repositories/settings_repository*.dart  contract + imp over KeyValueStore
                                           (keys flip_clock.settings, flip_clock.countdown;
                                           corrupt/failed read -> defaults, failed write logged)
  state/settings_controller.dart           Cubit<ClockSettings>; saves every change; `appearance`
                                           notifier; setSystemAlerts asks permission
  state/countdown_controller.dart          Cubit<CountdownState>; owns Countdown, 250 ms ticker
                                           plus a one-shot timer at endsAt (hidden web tabs
                                           throttle repeating timers), persists each transition
                                           (and each rebase after the clock is set back),
                                           LocalAlerts + SoundPlayer; syncAlert() on setting change
  state/stopwatch_controller.dart          Cubit<StopwatchState>; injected Stopwatch, 100 ms ticker
  state/clock_controller.dart              Cubit<DateTime>; ticks on each second boundary
  ui/screens/flip_clock_screen.dart        modes, top bar (seconds button in Clock mode, quick-dim
                                           in full screen), one-time seconds hint, full screen
                                           reveal, keys, wake lock
  ui/screens/settings_screen.dart          Display (incl. digit brightness slider) / Sound & alerts /
                                           Keep awake / shortcuts
  ui/components/                           FlipDisplay, TimerInput, CompletionBanner,
                                           Reveal + RunControls, SubtleMovement
```

## Rules

- State management is `Cubit` (`flutter_bloc`), one per concern, collaborators
  (repository, `Countdown`, `Stopwatch`, `now`, device_services contracts,
  `Logger`) injected through the constructor.
- Countdown remaining time is recomputed from `endsAt` on every tick and on
  app resume; never count frames. The stopwatch uses an injected monotonic
  `Stopwatch`; tick (~100 ms) only while running.
- Persist every countdown transition; relaunch shows "finished while away".
- `LocalAlerts` is scheduled on start/resume and cancelled on pause/reset/
  dismiss; `init()` also calls `syncAlert()` whenever System notifications is
  switched, so a running countdown gains or loses its alert; permission is requested only when the user turns on system
  notifications. Denied -> explain that the in-app alert still works.
- Orientation: `init()` applies the saved `orientation` through
  `OrientationLock` at start (unawaited, so launch never waits) and on every
  distinct change. Settings > Display shows the Orientation control only when
  `OrientationLock.supported` (Android/iOS), passed in by the router.
- Wake lock only when `keepAwake` and the app is resumed and this screen is
  visible; released otherwise.
- Every string from `strings.clock.*`; every colour from `Theme.of(context)`.
  `FlipDisplay` and `Reveal` honour `reducedMotion(context)`
  (`disableAnimations` or iOS `reduceMotion`) and never clip; only digits are
  cards (AM/PM letters are plain text).
- Subtle movement (burn-in) wraps the display only while full screen and the
  setting are both on. It is driven by the screen's `ClockController` (no
  timer of its own), steps through a fixed offset table indexed by minute of
  day (max 8 px per axis), and shifts via padding that always sums to 16 px,
  so it never clips or overflows. Never describe it as preventing burn-in.
- Space reaches the timer/stopwatch only when no control has focus, so a
  focused button keeps its own Space activation. An invalid timer entry
  (`TimerInput.onChanged(null)`) keeps Space from starting.
- Seconds: the top-bar button (Clock mode only) and the S key toggle
  `showSeconds`, as does the Settings switch. The one-time seconds hint shows
  in Clock mode, not in full screen, while `secondsHintSeen` is false; it
  overlays the display's top padding so the digits keep their size.
  Dismissing it or using the button/S sets `secondsHintSeen` and saves.
- Hidden full-screen controls are offered to screen readers as a
  "show controls" button over the display.
- Digit brightness dims only the digits (`Opacity` around each `FlipDisplay`);
  the background stays the theme surface and the top bar, run controls,
  timer input and completion banner stay at full brightness. The quick-dim
  button (top bar, full screen only) and the D key both call
  `ClockSettings.nextDim` (100% -> 50% -> 20% -> 100%; a slider value in
  between steps down to the next preset) and save.
- Entering full screen reveals the controls for `revealFor` together with
  `strings.clock.full_screen_note` (a live region, so screen readers hear
  it); later reveals show the controls only. Settings shows the same note
  under Keep screen awake. Full screen is not a lock screen or screensaver:
  never word it as one.
- No dependency on another feature; no account section in Settings.
- Show date puts `MaterialLocalizations.formatFullDate` under the Clock
  digits (headlineSmall, onSurfaceVariant, scaled down, never wraps). It is
  driven by the `ClockController` tick, so it rolls over at midnight, and is
  read as part of the display label (`current_time_and_date`). It dims with
  the digits (one `Opacity` around the digits and the date).
- Mode switching is `SettingsController.update(lastMode:)`, so the last mode
  is restored on launch and when returning from Settings (a child route of
  `/clock`, so the clock screen and its state stay underneath).
- Completion: the in-app banner and chime always; the system notification is
  scheduled at `endsAt` on native, and shown at completion on web
  (`notifyOnFinish = kIsWeb`, because web cannot schedule). A timer that
  ended while the app was closed shows the banner silently on relaunch.
  Finishing (or relaunching finished) switches to the Timer mode so the
  banner is always seen.

## Common changes

- **Add a setting:** field + default + JSON key in `ClockSettings` (and its
  test), a tile in `SettingsScreen`, the key in `strings.clock`.
- **Add a keyboard shortcut:** the handler in `FlipClockScreen`, a
  `strings.clock.shortcut_*` line in Settings, a widget test sending the key.

## Tests

`dart run melos exec --scope=flip_clock -- flutter test`. Fakes for every
`device_services` contract and a controllable clock; cover each Cubit
transition, repository corrupt data, each screen state, shortcuts and route
navigation. `setUp(core.init)`, `tearDown(di.reset)`. Coverage stays 100%.

## Edge cases

Verified in `test/edge_cases_test.dart` (fake time via `fake_async` and the
widget tester's clock):

- **Daylight saving:** the clock shows 01:59:59 -> 03:00:00 (spring forward)
  and repeats 1:00 AM (fall back) on the next tick, still on the second
  boundary with one pending timer. A countdown runs its exact duration across
  a jump because it compares instants, not wall fields (plus a check against
  the machine's own zone, skipped when it has no DST). 12h/24h text at
  00:xx / 12:xx / 23:59.
- **Time-zone change while open:** the clock shows the new local time on the
  next tick and on `refresh()` (resume); the countdown's end instant and alert
  are unchanged; the stopwatch reading is untouched.
- **Wall clock jumps:** forward past the end (device slept) finishes on the
  next check; backward rebases the end to a full duration from now and
  re-saves the snapshot and re-schedules the system alert at the new end
  (`check()` and `load()`), so no stale alert fires later. Relaunch after a
  jump past the end shows finished-while-away.
- **Window size:** every mode and Settings lay out without overflow at
  320x1024, 507x1024, 1024x320, 200x100, 1366x1024 and 390x844, text scale 1
  and 2, and while resized mid-run (timer, full screen, stopwatch). On very
  short windows the run controls shrink to at most half the height.
- **Hours on a charger:** 24 h of clock ticks keep exactly one timer, one
  emission per second, all aligned; a 12 h countdown keeps exactly two
  timers (ticker + end) and none after finishing; 3 h of the screen ticking
  keeps the element count flat and the wake lock on (released on dispose).

## Gotchas

- In `testWidgets`, do not `await cubit.close()` (or `di.reset()`) after a
  widget or listener subscribed to the cubit: the broadcast stream's close
  never completes in fake time and the test hangs. Dispose the tree, call
  `close()` unawaited, then `pump()` (see `Harness.dispose` in
  `test/screens_test.dart`).
- A clock set back by less than the time a running timer has already used
  is not detected: the end is only rebased once it lies more than a full
  duration away, so such a timer runs long by the set-back amount (a paused
  timer is unaffected).
- Keyboard shortcuts are ignored while a text field has focus, so typing
  digits into the timer does not switch modes.
- Flip sound is wired for Clock and Timer only (the stopwatch's tenths would
  click ten times a second).
