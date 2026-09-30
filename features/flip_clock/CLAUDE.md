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
| `ClockSettings`, `ClockTheme`, `ClockMode` | model | Defaults: black, 24h, no seconds, flip sound off, alert sound on, system alerts off, keep awake off, last mode clock. `fromJson` falls back per field |

## Layout

```
lib/
  flip_clock.dart                          barrel: init, appearance, exports (model + router only)
  router/flip_clock_router.dart            paths + routes; resolves controllers from di
  data/models/clock_settings.dart          ClockSettings, ClockTheme, ClockMode
  data/repositories/settings_repository*.dart  contract + imp over KeyValueStore
                                           (keys flip_clock.settings, flip_clock.countdown;
                                           corrupt/failed read -> defaults, failed write logged)
  state/settings_controller.dart           Cubit<ClockSettings>; saves every change; `appearance`
                                           notifier; setSystemAlerts asks permission
  state/countdown_controller.dart          Cubit<CountdownState>; owns Countdown, 250 ms ticker
                                           plus a one-shot timer at endsAt (hidden web tabs
                                           throttle repeating timers), persists each transition,
                                           LocalAlerts + SoundPlayer; syncAlert() on setting change
  state/stopwatch_controller.dart          Cubit<StopwatchState>; injected Stopwatch, 100 ms ticker
  state/clock_controller.dart              Cubit<DateTime>; ticks on each second boundary
  ui/screens/flip_clock_screen.dart        modes, top bar, full screen reveal, keys, wake lock
  ui/screens/settings_screen.dart          Display / Sound & alerts / Keep awake / shortcuts
  ui/components/                           FlipDisplay, TimerInput, CompletionBanner,
                                           Reveal + RunControls
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
- Wake lock only when `keepAwake` and the app is resumed and this screen is
  visible; released otherwise.
- Every string from `strings.clock.*`; every colour from `Theme.of(context)`.
  `FlipDisplay` and `Reveal` honour `reducedMotion(context)`
  (`disableAnimations` or iOS `reduceMotion`) and never clip; only digits are
  cards (AM/PM letters are plain text).
- Space reaches the timer/stopwatch only when no control has focus, so a
  focused button keeps its own Space activation. An invalid timer entry
  (`TimerInput.onChanged(null)`) keeps Space from starting.
- Hidden full-screen controls are offered to screen readers as a
  "show controls" button over the display.
- No dependency on another feature; no account section in Settings.
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

## Gotchas

- In `testWidgets`, do not `await cubit.close()` (or `di.reset()`) after a
  widget or listener subscribed to the cubit: the broadcast stream's close
  never completes in fake time and the test hangs. Dispose the tree, call
  `close()` unawaited, then `pump()` (see `Harness.dispose` in
  `test/screens_test.dart`).
- Keyboard shortcuts are ignored while a text field has focus, so typing
  digits into the timer does not switch modes.
- Flip sound is wired for Clock and Timer only (the stopwatch's tenths would
  click ten times a second).
