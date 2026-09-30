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
| `ClockSettings`, `ClockTheme`, `ClockMode` (pomodoro, clock, timer, stopwatch: panel order), `ClockOrientation` | model | Defaults: theme dark (`ClockTheme` dark / light / system; a saved `black` reads as dark), Mono skin (`skinId` `'mono'`, no `customSkins`), 24h, no seconds, flip sound off, alert sound on, system alerts off, keep awake off, last mode clock, digit brightness 1.0 (0.2..1.0; `fromJson` clamps numbers into range), subtle movement off, date off, orientation auto, tap toggles controls on, controls idle 4 s (`controlsIdleChoices` 2/4/8 s or `Duration.zero` = Never; `controlsIdleMs`, other values -> 4 s), brightness gesture on (`gestureBrightness`), mode swipe on (`gestureModes`). `fromJson` falls back per field. `ClockSettings.nextDim` is the quick-dim cycle |

## Layout

```
lib/
  flip_clock.dart                          barrel: init, appearance, exports (model + router only)
  router/flip_clock_router.dart            paths + routes; resolves controllers from di
  data/models/clock_settings.dart          ClockSettings, ClockTheme, ClockMode, ClockOrientation
  data/models/skin.dart                    Skin (face, digit/card/ground colour, seam, radius,
                                           seconds off/badge/cards, AM/PM hidden/left/right,
                                           date); JSON with ARGB ints, per-field fallback,
                                           no id -> dropped; WCAG `contrast`
  data/skins.dart                          Skins: built-in catalogue (Classic, Type) from
                                           `DesignSkinColors`, `resolve` (unknown -> Mono),
                                           custom ids `custom-<n>`
  data/repositories/settings_repository*.dart  contract + imp over KeyValueStore
                                           (keys flip_clock.settings, flip_clock.countdown;
                                           corrupt/failed read -> defaults, failed write logged)
  state/settings_controller.dart           Cubit<ClockSettings>; saves every change; `appearance`
                                           notifier; setSystemAlerts asks permission; `skin`,
                                           selectSkin, saveSkin (built-in -> new copy first),
                                           deleteSkin (selected -> Mono)
  state/countdown_controller.dart          Cubit<CountdownState>; owns Countdown, 250 ms ticker
                                           plus a one-shot timer at endsAt (hidden web tabs
                                           throttle repeating timers), persists each transition
                                           (and each rebase after the clock is set back),
                                           LocalAlerts + SoundPlayer; syncAlert() on setting change;
                                           Pomodoro cycle (startPomodoro/startNextPhase)
  state/stopwatch_controller.dart          Cubit<StopwatchState>; injected Stopwatch, 100 ms ticker
  state/clock_controller.dart              Cubit<DateTime>; ticks on each second boundary
  state/chrome_controller.dart             Cubit<Chrome> (design_system `ChromeState` + optional
                                           `IslandHud`); starts expanded, -> dot after idle, -> hidden
                                           after dotIdle; activity/wake/tap/hide, showHud/releaseHud
                                           (hudHold), setIdle (zero = never)
  state/brightness_control.dart            BrightnessControl (plain class): drag/Up-Down keys drive
                                           ScreenBrightness 0..1 where supported, else
                                           digitBrightness 0.2..1 (saved); first
                                           ScreenBrightnessException -> in-app for good (logged);
                                           reset() restores system level, never throws
  ui/screens/flip_clock_screen.dart        modes, chrome (Island tabs bottom centre, Skins /
                                           Settings CornerButtons, owned ChromeController), tap
                                           toggle, date line, full-screen note, _WithControls
                                           (run controls at most half height), keys, wake lock
  ui/screens/skins_sheet.dart              showSkins: picker sheet over the clock, customizer on top
  ui/screens/settings_screen.dart          SettingsShell content: Appearance (Skin -> Skins sheet,
                                           theme Dark/Light/Match system, digit brightness) /
                                           Clock (24h, seconds, date, orientation) / Gestures
                                           (swipes, tap, hide-after) / Timers (pomodoro lengths) /
                                           Sound & alerts / Keep awake (+ full-screen note) /
                                           Shortcuts (keycaps) / About (licences, privacy); Done
  ui/components/                           GestureLayer (one RawGestureDetector: tap, double tap,
                                           axis-locked brightness drag and page swipe),
                                           FlipDisplay (cards + badge + AM/PM, styled by a Skin),
                                           display_value (clock/duration/stopwatch -> cards),
                                           SkinPicker + SkinTile + SheetHeader + SectionHeader +
                                           showSheet, SkinCustomizer (parseHex/hexOf), TimerInput (+ `secondary` beside Start),
                                           CompletionBanner (+ optional `action`),
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
  switched, so a running countdown gains or loses its alert; permission is
  requested only when the user turns on system notifications. Denied -> explain that the in-app alert still works.
- Orientation: `init()` applies the saved `orientation` through
  `OrientationLock` at start (unawaited, so launch never waits) and on every
  distinct change. Settings > Clock shows the Orientation control only when
  `OrientationLock.supported` (Android/iOS), passed in by the router.
- Wake lock only when `keepAwake` and the app is resumed and this screen is
  visible; released otherwise.
- Every string from `strings.clock.*`; chrome colours from
  `Theme.of(context)` / `DesignColors.of(context)`. The clock's digits, cards,
  seam and ground come only from the selected `Skin` (the one place a
  `Color(int)` is built from a value, because custom skins are user data);
  built-ins use `DesignSkinColors` only. A skin never colours controls.
- `FlipDisplay` is one card per entry (a pair of digits): card height fills
  the box, digits are 0.78 x height and not text-scaled, width 1.0 x height
  (1.3 x for a monospaced face), `space-6` between cards, the 2px seam at
  half height in the ground colour, `radius-md` becoming `radius-lg` once
  digits reach 160px. A flip is `DesignMotion.flip` (360 ms): top half
  ease-in, then bottom half ease-out. It and `Reveal` honour
  `reducedMotion(context)` (`disableAnimations` or iOS `reduceMotion`) and
  never clip; AM/PM and small seconds are plain text at 70% of the digit
  colour, never cards.
- Seconds show when `showSeconds` is on, in the skin's style (`off` hides
  them for that skin). The date line shows when Show date is on or the skin
  asks for it. AM/PM placement is the skin's.
- Sheets (`showSheet`) use `surface`, `radius-lg` top corners and a
  hairline, full width (Material's 640px cap is lifted). Skin tiles are at
  least 196px wide.
- Subtle movement (burn-in) wraps the display only while full screen and the
  setting are both on. It is driven by the screen's `ClockController` (no
  timer of its own), steps through a fixed offset table indexed by minute of
  day (max 8 px per axis), and shifts via padding that always sums to 16 px,
  so it never clips or overflows. Never describe it as preventing burn-in.
- Space reaches the timer/stopwatch only when no control has focus, so a
  focused button keeps its own Space activation. An invalid timer entry
  (`TimerInput.onChanged(null)`) keeps Space from starting.
- Chrome: the screen owns a `ChromeController` (idle from
  `ClockSettings.controlsIdle`, updated on change). Launch is expanded; 4 s
  idle -> dots, 3 s more -> hidden. Pointer down restarts the idle timer, a
  mouse move or any key expands, Esc leaves full screen first, otherwise
  hides. A tap on the clock toggles (when `tapToggleControls`); a tap on a
  control is the control's (it wins the gesture arena). Run controls show
  only while expanded (`Reveal`). The mode island sits `space-6` above the
  safe area; corners `space-4` inside it (`space-6` from 600px shortest
  side). The mode view reserves room for both (at most a quarter of the
  height each), so the chrome never covers the digits. A hidden chrome makes
  the whole clock one "show controls" button for screen readers.
- Seconds: the S key (Clock mode only) and the Settings switch toggle
  `showSeconds`.
- Digit brightness dims only the digits (`Opacity` around each `FlipDisplay`,
  and around the date line with the Clock digits);
  the background stays the skin's ground and the chrome, run controls,
  timer input and completion banner stay at full brightness. The D key calls
  `ClockSettings.nextDim` (100% -> 50% -> 20% -> 100%; a slider value in
  between steps down to the next preset) and save.
- Entering full screen expands the chrome and shows
  `strings.clock.full_screen_note` for `noteFor` (3 s, a live region, so
  screen readers hear it); leaving clears it. Settings shows the same note
  under Keep screen awake. Full screen is not a lock screen or screensaver:
  never word it as one.
- No dependency on another feature; no account section in Settings.
- Show date puts `MaterialLocalizations.formatFullDate` under the Clock
  digits (headlineSmall, onSurfaceVariant, scaled down, never wraps). It is
  driven by the `ClockController` tick, so it rolls over at midnight, and is
  read as part of the display label (`current_time_and_date`). It dims with
  the digits (one `Opacity` around the digits and the date).
- Panels: a `PageView` (NeverScrollableScrollPhysics) in `ClockMode` order
  (Pomodoro, Clock, Timer, Stopwatch) under one `GestureLayer`: tap toggles
  the chrome, vertical drag -> `BrightnessControl.change(-dy / height)`
  (device 0..1 where `ScreenBrightness.supported`, else digitBrightness
  0.2..1; a `ScreenBrightnessException` falls back to in-app for good),
  horizontal swipe pages at 25% width or 600 px/s, no wrap. Axis lock at
  12 px. Off while the clock route is not current (sheets, Settings) or a
  text field has focus. `gestureBrightness` / `gestureModes` switch each
  axis off. Double tap toggles full screen on desktop/web only (it delays
  taps). Island HUD: brightness while dragging / Up / Down, the mode name
  after a swipe or Left / Right; both release after `hudHold`. The device
  brightness is reset on pause, detach and dispose. A mode change from tabs
  or keys slides the panel (jumps with reduced motion).
- Mode switching is `SettingsController.update(lastMode:)`, so the last mode
  is restored on launch and when returning from Settings (a child route of
  `/clock`, so the clock screen and its state stay underneath).
- Completion: the in-app banner and chime always; the system notification is
  scheduled at `endsAt` on native, and shown at completion on web
  (`notifyOnFinish = kIsWeb`, because web cannot schedule). A timer that
  ended while the app was closed shows the banner silently on relaunch.
  Finishing (or relaunching finished) switches to the Timer panel (the
  Pomodoro panel for a pomodoro phase) so the banner is always seen.
- Pomodoro (its own panel; the countdown engine is shared with the Timer:
  idle, the Pomodoro panel offers 25:00 + Start and the Timer panel the
  input; running, both show the countdown): 25 min focus / 5 min break from
  `timekeeping`'s `Pomodoro`, run as one `Countdown` per phase. While the
  app is open a phase end chimes for `chimeFor` (5 s, only with Alert
  sound), shows the web notification like the timer, and starts the next
  phase at once (round + 1 on each new focus); the "Focus · Round n" /
  "Break · Round n" label is a live region. The system alert is scheduled
  per phase and cancelled on pause/reset like the timer. Reset ends the
  cycle and restores the timer's own duration. The snapshot adds
  `pomodoro: {phase, round}` and `timerMs`; corrupt fields load as a plain
  timer (or the default duration), an idle snapshot drops them. A phase
  that ended while the app was closed loads finished with Start break /
  Start focus (autofocused) beside Dismiss; Space starts it. `setDuration`
  is ignored during a cycle.

## Common changes

- **Add a setting:** field + default + JSON key in `ClockSettings` (and its
  test), a `Settings*Row` in the right category of `SettingsScreen` (and
  `test/settings_screen_test.dart`), the key in `strings.clock`.
- **Add a keyboard shortcut:** the handler in `FlipClockScreen`, a
  `key_*` label and `keycap_*` row in Settings > Shortcuts, a widget test
  sending the key.

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

- Customizer controls apply each edit to the current draft (a function of
  the draft), so two taps before a rebuild both stick.
- The flip sound follows card flips: with seconds as a badge, the minute
  card is the first to flip.

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
