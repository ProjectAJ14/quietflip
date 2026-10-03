# Quietflip: `features/flip_clock`

The whole first-release product: the flip clock, countdown timer, stopwatch
and their Settings screen. The app launches straight into
`FlipClockRouter.home`. It owns screens, state and local settings. Time maths
comes from `timekeeping`; platform work (full screen, wake lock, local
notifications, sounds, storage) comes from `device_services` contracts;
optional settings sync and the signed-in account from `cloud_sync`'s
`CloudSync`. It never imports `auth`: the app passes sign-in, sign-out and
delete-account callbacks in. No analytics, network or FCM.

Read the root `CLAUDE.md` and `features/CLAUDE.md` first. Load the
`design-system` and `flutter-best-practices` skills before UI work.

## Public API (`package:flip_clock/flip_clock.dart`)

| Symbol | Kind | Notes |
|---|---|---|
| `init({sync})` | function | Registers `SettingsRepository` and the controllers with `di`; with a `CloudSync` (`cloud_sync`; null when Firebase is off) also starts and registers `SettingsSync`. After `core.init()` and `device_services.init()` |
| `FlipClockRouter({sync, onSignIn, onSignOut, onDeleteAccount})` | `CoreRouter` | `home = '/clock'`, `settings = '/clock/settings'`, `timerSettings` (`?category=timers`: Settings opened on Timers; the island's tune icon), `accountSettings` (`?category=account`: the Account page; where sign-in returns), `routes`, `shortcutsFor(platform, shortestSide)` (Settings > Shortcuts groups: iOS/Android touch, plus keys from `tabletSide` 600; macOS/Windows/Linux keys only; the settings route passes `defaultTargetPlatform`, so a phone browser counts as touch, and `MediaQuery.sizeOf` through a `Builder`, so a resize re-picks). Callbacks take the route's `BuildContext`; `onDeleteAccount` returns an `AccountDeletion`. No `sync`: no Account card |
| `AccountDeletion` | enum | `deleted`, `needsSignIn` (Firebase wants a recent sign-in; the app has signed out), `failed` |
| `appearance()` | `ValueListenable<AppearanceMode>` | The chosen theme for `DesignSystemWrapper(mode:)`; Black by default, even when the OS is light |
| `appCorner()` | `ValueListenable<double>` | `ClockSettings.corner` for `DesignSystemWrapper(corner:)`: the one corner every shape in the app follows |
| `appFace()` | `ValueListenable<DisplayFace?>` | The face the whole app is set in for `DesignSystemWrapper(face:)`: the selected skin's face, or null (Geist) for the default Barlow Condensed face, so Mono and the Classic skins keep Geist |
| `ClockSettings`, `ClockTheme`, `ClockMode` (pomodoro, clock, stopwatch: panel order; a saved `timer` reads as pomodoro), `TimerPreset` (sealed: `PomodoroCycle`, `Minutes(duration)`), `ClockOrientation` | model | Defaults: theme dark (`ClockTheme` dark / light / system; a saved `black` reads as dark), Mono skin (`skinId` `'mono'`, no `customSkins`), `use24h` null (unpicked: `uses24h(context, settings)` follows the device's 24-hour switch, else its language, so English reads 12-hour and German 24-hour; JSON absent or non-bool -> null; the Settings switch shows the resolved value and saves an explicit choice), no seconds, flip sound off, alert sound on, tick sound Classic and alarm sound Chime (`tickSound` / `alarmSound`: `device_services`' `TickSound` / `AlarmSound`, JSON by name, unknown -> default; `flipSound` / `alertSound` stay the on/off switches), system alerts off, keep awake off, last mode clock, digit brightness 1.0 (0.2..1.0; `fromJson` clamps numbers into range), subtle movement off, date off, orientation auto, tap toggles controls on, controls idle 4 s (`controlsIdleChoices` 2/4/8 s or `Duration.zero` = Never; `controlsIdleMs`, other values -> 4 s), brightness gesture on (`gestureBrightness`), mode swipe on (`gestureModes`), card size large (`CardSize` small / medium / large, `factor` 0.6 / 0.8 / 1.0; JSON `cardSize` by name), timer presets 5 / 10 / 15 min (`timerPresets`, JSON `timerPresetsMs`; `normalizePresets`: valid per `Countdown.isValid`, no duplicates, ascending, at most `maxTimerPresets` = 6, bad entries dropped), corner 14 (`corner`, `DesignShape.minCorner`..`maxCorner` = 0..24, steps of `cornerStep` 2 in Settings, clamped and snapped to a step on read), default timer the cycle (`defaultTimer`, JSON `defaultTimerMs`, absent = cycle; `copyWith`/`fromJson` turn a default that is not among the presets back into the cycle). `fromJson` falls back per field. `ClockSettings.nextDim` is the quick-dim cycle |

## Layout

```
lib/
  flip_clock.dart                          barrel: init, appearance, exports (model + router only)
  router/flip_clock_router.dart            paths + routes; resolves controllers from di
  data/models/clock_settings.dart          ClockSettings, ClockTheme, ClockMode, TimerPreset,
                                           ClockOrientation, CardSize
  data/models/skin.dart                    Skin (face, digit/card/ground colour (no radius or seam:
                                           corners are global, every card has the crack and hinges;
                                           old `cardRadius` and `seam` keys are ignored),
                                           seconds off (default)/badge/cards, AM/PM
                                           hidden/left/right, date, `themed`); JSON with ARGB
                                           ints, per-field fallback, no id -> dropped; WCAG
                                           `contrast`; `forTheme(colors)`: a themed skin (Mono)
                                           is `ink` on `card` over `bg` in Mono Light
  data/skins.dart                          Skins: built-in catalogue (Classic, Bold, Type) from
                                           `DesignSkinColors` (Classic seconds: Paper and Cyan
                                           badge, Violet and Amber cards, Mono and the rest
                                           off), `resolve` (unknown -> Mono),
                                           custom ids `custom-<n>`
  data/repositories/settings_repository*.dart  contract + imp over KeyValueStore
                                           (keys flip_clock.settings, flip_clock.countdown;
                                           corrupt/failed read -> defaults, failed write logged)
  state/settings_controller.dart           Cubit<ClockSettings>; saves every change; `appearance`
                                           notifier; setSystemAlerts asks permission; `skin`,
                                           selectSkin (also sets showSeconds from the skin's
                                           preset), saveSkin (built-in -> new copy first;
                                           never themed; sets showSeconds), deleteSkin
                                           (selected -> Mono)
  state/settings_sync.dart                 SettingsSync: mirrors the synced part of ClockSettings to
                                           `CloudSync` document `clock_settings` (see Settings sync)
  state/countdown_controller.dart          Cubit<CountdownState>; owns Countdown, 250 ms ticker
                                           plus a one-shot timer at endsAt (hidden web tabs
                                           throttle repeating timers), persists each transition
                                           (and each rebase after the clock is set back),
                                           LocalAlerts + SoundPlayer; syncAlert() on setting change;
                                           Pomodoro cycle (startPomodoro/startNextPhase),
                                           startPreset (cycle or plain start); toggle
                                           on idle starts settings' defaultTimer
  state/stopwatch_controller.dart          Cubit<StopwatchState>; injected Stopwatch, 100 ms ticker;
                                           lap() while running (splits newest first, in
                                           memory only), reset clears laps
  state/clock_controller.dart              Cubit<DateTime>; ticks on each second boundary
  state/chrome_controller.dart             Cubit<Chrome> (design_system `ChromeState` + optional
                                           `IslandHud`); starts hidden, expanded -> dot after idle, -> hidden
                                           after dotIdle; activity/wake/tap/hide, showHud/releaseHud
                                           (hudHold; a showHud after releaseHud re-arms the hold, activity()
                                           starts a new gesture), setIdle (zero = never)
  state/brightness_control.dart            BrightnessControl (plain class): drag/Up-Down keys drive
                                           ScreenBrightness 0..1 where supported, else
                                           digitBrightness 0.2..1 (saved); first
                                           ScreenBrightnessException -> in-app for good (logged);
                                           reset() restores system level, never throws
  ui/screens/flip_clock_screen.dart        modes, chrome (the Island top centre: tabs over the
                                           current mode's action tray; CornerButtons Skins
                                           top-left, Settings top-right, Rotation bottom-right
                                           where supported; owned ChromeController), tap
                                           toggle, date line,
                                           full-screen note, keys, wake lock
  ui/screens/skins_sheet.dart              showSkins: picker sheet over the clock, customizer on
                                           top; customizeSkin: the customizer on the selected
                                           skin (Settings' strip, via the router)
  ui/components/account_page.dart          accountCategory (the pinned Account page), LastSyncedRow,
                                           AccountDeletion
  ui/components/sync_card.dart             SyncCard (the pinned card), syncedWhen, failureText
  ui/screens/settings_screen.dart          SettingsShell content: Appearance, top to bottom
                                           (no header: theme Dark/Light/Match system,
                                           Orientation where supported; Skins: a strip of 5
                                           SkinTiles, the selected one first, then the others
                                           in picker order (yours first), tap applies, the
                                           selected tile's Customize -> `onCustomize`, View
                                           all -> Skins sheet; no header: card size, digit
                                           brightness; Corners: a live sample of a button,
                                           a chip and a mini flip card over a 0..24 slider,
                                           Square .. Round) /
                                           Clock (24h, seconds, date) / Gestures
                                           (swipes, tap, hide-after) / Timers (Default timer: segmented
                                           Pomodoro + presets; Presets: a row each with delete,
                                           Add timer -> TimerPicker, off at 6 with a footer;
                                           Pomodoro lengths read-only; `category: 'timers'`
                                           starts here) /
                                           Sound & alerts (Tick and Alarm groups:
                                           switch, then five sound tiles with a live
                                           SoundWave each; see Sound picker) /
                                           Keep awake (+ full-screen note) /
                                           Shortcuts (`touchShortcuts` / `keyboardShortcuts`
                                           from the router: Touch rows with a GestureGlyph
                                           each (tap = Show or hide controls, swipe sideways =
                                           Change mode, swipe up/down = Brightness; always
                                           listed, "Off" while the setting is off; no double
                                           tap), then keycaps; Touch / Keyboard headers only
                                           when both show; touch_app icon when Touch leads,
                                           else keyboard) / About (licences, privacy); Done
  ui/components/                           GestureLayer (one RawGestureDetector: tap, double tap,
                                           axis-locked brightness drag and page swipe),
                                           FlipDisplay (cards + badge + AM/PM, styled by a Skin),
                                           flip_card_geometry (FlipCardGeometry: axle, crack,
                                           lip, notches, pins and half paths from the icon),
                                           display_value (clock/duration/stopwatch -> cards,
                                           `uses24h`, `meridiemOf`: AM/PM from `intl`'s
                                           CLDR data, e.g. 午前 / 午後, a. m. / p. m.),
                                           TimerPicker (showTimerPicker: minutes + seconds
                                           fields, 0:01..99:59, refuses a preset that already exists
                                           with a live-region message), presetLabel (`5m` / `1:30`),
                                           presetSpoken (`5 minute timer`: chips, rows and
                                           Delete tooltips are spoken in full),
                                           SkinPicker + SkinTile + SheetHeader + SectionHeader +
                                           showSheet, SkinCustomizer (parseHex/hexOf),
                                           SubtleMovement, SoundWave (sound_wave.dart)
```

## Rules

- Every tap presses down: buttons are `AppButton` (the sheet headers' Done
  and Cancel, dialog actions, the customizer footer, Sign in to sync, the
  preset delete icon), every other tappable is a `Pressable` (skin, New,
  face, swatch and sound tiles, account rows). No Material button,
  `InkWell`, `ListTile(onTap:)`, `SwitchListTile` or
  `GestureDetector(onTap:)` in `lib/`; `test/press_rule_test.dart` scans
  this feature, `design_system` and `auth` and fails with `file:line`.
  `gesture_layer.dart` is exempt (drags and swipes on the clock face). The
  customizer's Show date switch is a local `_SwitchRow` (a
  `Pressable` row, flush with the sheet's other controls;
  `SettingsSwitchRow`'s `space-4` cell padding would indent it). The
  Rotation corner button sits in a `MergeSemantics` so its live-region
  value and the button are one node.
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
- Tick warm-up: while the tick sound (`flipSound`) is on, `init()` calls
  `SoundPlayer.warmTick` for the selected `tickSound` at start and on every
  distinct change of the pair (sound changed or switch turned on;
  unawaited), so the first tick plays without a load delay.
- Orientation: `init()` applies the saved `orientation` through
  `OrientationLock` at start (unawaited, so launch never waits) and on every
  distinct change. Settings > Appearance shows the Orientation control
  (under Theme), the
  clock screen its Rotation corner button and the R key, only when
  `OrientationLock.supported` (Android/iPhone; not iPad), passed in by the router (the
  widgets never `di.get`). Rotation and R cycle `orientation` auto ->
  portrait -> landscape -> auto (the button's icon shows the current one:
  `screen_rotation`, `stay_current_portrait`, `stay_current_landscape`);
  the button carries a live-region `Semantics` value naming the current one
  (`orientation_*`), so screen readers hear the change. No HUD (it would
  collapse an open island); nothing new in the model, and the Settings row
  stays in sync.
- Wake lock only when `keepAwake` and the app is resumed and this screen is
  visible; released otherwise.
- Every string from `strings.clock.*`; chrome colours from
  `Theme.of(context)` / `DesignColors.of(context)`. The clock's digits, cards
  (crack and pins shaded from the card colour) and ground come only from the
  selected `Skin` (the one place a
  `Color(int)` is built from a value, because custom skins are user data);
  built-ins use `DesignSkinColors` only. A skin never colours controls.
- `FlipDisplay` is one card per entry (a pair of digits): card height fills
  the box, digits are 0.78 x height and not text-scaled, width 1.0 x height
  (1.3 x for a monospaced face), `space-6` between cards, so the display is
  exactly n x height x ratio + gaps wide; the app's corner (`DesignShape`
  `md`, capped at half the card) becoming `lg` once digits reach 160px.
  Digits are placed by baseline (`DisplayFace.digitCentre`) so their centre
  sits on the axle in every face, shrunk or not.
  The card is shaped as on the app icon by `FlipCardGeometry`
  (`flip_card_geometry.dart`, the only place its proportions exist, as
  fractions of card height h): the axle at h/2; a crack (0.008h, at least
  1px) and a lip under it (0.005h) from notch to notch; a notch cut into
  each side edge (0.045h x 0.125h, inner corners 0.015h, rounded 0.006h into
  the edge) with a pin inside it (0.035h x 0.104h, corner 0.3 x its width)
  whose outer face is flush with the card side, so nothing sticks out. No
  notch and no pins below an 80px card (skin tiles). Each half is a
  `ClipPath` of its half of the rounded card minus the notches, so the flap
  carries the notch. Paint is derived from the skin's card colour in HSL
  (`shadeOf` lightness x (1 - k), `lightOf` towards white by k), so a light
  skin gets a dark crack: a face painter behind each half lights it from
  above (top `lightOf` 0.10 -> `shadeOf` 0.12, bottom card -> `shadeOf`
  0.18) with a 1px top rim (`lightOf` 0.55) fading out by 0.25h; one card
  painter per card (`hingeKey`) over the halves and flap draws the crack
  (`shadeOf` 0.85, the flap's underside 0.002h above it at 0.4), the lip
  (`lightOf` 0.45), the notch cavities, then the metal pins (a specular band
  at 22%, bright end caps, a dark outline). A flip is `DesignMotion.flip`
  (360 ms), mapped by `FlipDisplay.turnAt`: a `fallDuration` (300 ms) fall
  under gravity (an exact u squared; `Curves.easeIn` is solved only to 0.001
  and its speed wobbles), the old value on the top flap until pi/2 and the
  new one on the bottom flap after, then a 60 ms `bounce` that lifts the
  landed flap 0.06 rad and settles. Both flaps turn about the axle (a
  `Transform` origin on it, centred across) with perspective 0.4 / card
  height, passing between the pins. The falling flap moves toward
  `shadeOf(card, 0.5)` by sin(turn), digits included, and casts a shadow of
  that colour (`castShadow` 0.45 x sin(turn), clear by 60% of the half) on
  the bottom half; the landing flap's face lifts toward `lightOf(card, 0.12)`.
  A new value while the top flap falls keeps it falling and lands on the
  newest value; while landing (or still) the card falls again from the value
  it showed. Each
  card is a `RepaintBoundary`. It honours
  `reducedMotion(context)` (`disableAnimations` or iOS `reduceMotion`:
  instant swap, no shade, no bounce; pins and crack stay) and
  never clip; AM/PM and small seconds are plain text in the skin's face at
  70% of the digit colour, never cards, sized 0.12 x card height (AM/PM)
  and 0.1 x (badge) with 0.05 x corner padding, so they stay in the card's
  bottom margin at every size (18px / 13px, the tokens, from 150 / 130px
  cards; small skin tiles never have them over the digits). `size` (`CardSize.factor`, clamped 0.1..1) scales the
  fitted card height; everything inside follows. It draws
  `skin.forTheme(DesignColors.of(context))`, as do SkinTile and the
  customizer preview.
- Stacked layout: the clock, Pomodoro and stopwatch displays are
  `stackable` (skin tiles and the customizer preview are not). A display
  works out the largest card for one row and for a stack (same gaps, same
  `CardSize.factor`) and stacks the groups (HH over MM over SS, centred)
  when the stack's card is at least `FlipDisplay.stackGain` (1.15) times
  the row's; it goes back to the row only when the row's is 1.15 times the
  stack's, so near-square windows and resizes never flicker. Left AM/PM
  stays in the first card, right AM/PM beside the last card of the last
  row, the badge in the last card. A switch cross-fades
  (`DesignMotion.fade`; instant with reduced motion); flips are per card
  as before. A display is as big as its cards (so the date can sit above
  it as one centred block).
- The hour card is always two digits, in 12-hour time too (`09 41 AM`), so
  it never sits half empty; the text label keeps `9:41 AM`.
- Seconds show when `showSeconds` is on, in the skin's style (a skin with
  `off` shows them as cards, so the switch always shows something).
  Selecting a skin applies its preset: Show seconds on unless the skin's
  seconds are `off` (Mono), and the user can toggle it after. The date line shows when Show date is on or the skin
  asks for it. AM/PM placement is the skin's.
- Sheets (`showSheet`) use `surface`, `DesignShape.lg` top corners and a
  hairline, full width (Material's 640px cap is lifted). Skin tiles are at
  least 196px wide (three groups and the date fit) and draw the skin as it
  is configured: the user's `use24h`, seconds only when the skin shows them
  (`cards` -> a card, `badge` -> the badge, `off` -> none, whatever Show
  seconds says; selecting a skin applies that preset), the date line small
  above the cards only when `skin.showDate` (Show date never adds it);
  always one row. Select vs
  customise: a tap applies the skin; the selected tile gets the accent
  ring, the check and, in place of the face name, a Customize button (pencil
  + label, its own focusable button spoken "Customize <name>"; the tile is
  "<name>, selected"), which opens the customizer on that skin (custom
  skins with Delete). The sheet header keeps only Done and the title. The
  Appearance strip uses the same tile. The sheet opens on an "In use"
  section (`skins_in_use`): one tile, the selected skin (built-in or custom,
  via `Skins.resolve`) at the grid's tile width, the only tile in the sheet
  with Customize. The sections below (Your skins, Classic, Bold, Type) keep
  their order and ring the selected tile in place without Customize, so a
  tap never reflows a tile under the finger; the In use tile cross-fades to
  the new skin over `DesignMotion.fade` (an `AnimatedSwitcher` keyed by the
  skin id; instant under `reducedMotion`).
- Subtle movement (burn-in) always wraps the panels and moves only while
  full screen and the setting are both on (`enabled`; off it sits centred
  with the same padding). It is driven by the screen's `ClockController` (no
  timer of its own), steps through a fixed offset table indexed by minute of
  day (max 8 px per axis), and shifts via padding that always sums to 16 px,
  so it never clips or overflows. Never describe it as preventing burn-in.
- Keep the widget tree above the panels' `PageView` the same shape in every
  state (chrome hidden or not, full screen, subtle movement): pass flags to
  wrappers, never add or drop one conditionally. A wrapper coming or going
  rebuilds the `PageView`, whose new position starts on the launch mode, so
  the panels jumped back to Clock while the island still said Timer.
- Space reaches the countdown/stopwatch only when no control has focus, so
  a focused button keeps its own Space activation. On an idle Pomodoro panel
  it starts `defaultTimer`.
- Chrome: the screen owns a `ChromeController` (idle from
  `ClockSettings.controlsIdle`, updated on change). Launch is hidden: the
  clock shows alone (no island, dot or corner buttons) until a tap, mouse
  move or key; screen readers get the "show controls" button. Once shown, 4 s
  idle -> dots, 3 s more -> hidden. Pointer down restarts the idle timer, a
  mouse move or any key expands, Esc leaves full screen first, otherwise
  hides. A tap or mouse click on the clock toggles (when
  `tapToggleControls`); hovering still shows a hidden chrome, and the first
  press within `ChromeController.hoverGrace` (300 ms) of that hover does not
  hide it again (moving to the clock and clicking is one motion). A tap on a
  tray action or a corner button is that control's (both sit above the
  gesture layer), never a chrome toggle.
- Chrome is the island plus corner buttons, all driven by the one
  `ChromeState` in the same frame (button / dot / gone, same spring in,
  same collapse out): Skins (`palette_outlined`) top-left, Settings
  top-right, Rotation bottom-right on phones only. Each sits `inset` from
  the safe area. All of it floats above the clock. From 600px wide the
  island is centred between the top two (`inset + cornerButton + space-2`
  from each side); below 600px it floats just under their row
  (`inset + cornerButton + space-2` from the top, `inset` from the sides),
  so it is never scaled down to squeeze between them (a 390px phone draws
  44px tabs; only text scale 2 or a 320px window still scales it).
- The island sits top centre, `space-4` inside the safe area (`space-6`
  from 600px shortest side). Expanded, it shows the mode tabs over the
  tray (`IslandAction`s, drawn in island tokens on its dark pill, never on
  the skin's ground, so they are legible on every skin in both themes),
  only the current mode's controls, centred:

  | Mode / state | Tray |
  |---|---|
  | Clock | (none: tabs only) |
  | Pomodoro idle | Start (`defaultTimer`), chips Pomodoro + each preset (`5m`, `1:30`), tune -> `onOpenTimerSettings` |
  | Pomodoro running / paused | Pause or Resume, Reset |
  | Pomodoro finished | "Time's up" (live region); Restart (same duration, `restart()`) or Start break / Start focus; Done |
  | Stopwatch idle / running / paused | Start / Pause + Lap / Resume + Reset |

  The island rebuilds on countdown/stopwatch state changes, not on ticks.
  A countdown that finishes while the chrome is hidden wakes it on the
  finished tray; the idle collapse still applies. The full-screen note
  sits under the island. The chrome is an overlay: the mode view pads the
  safe area by the same `space-4` on every side below 400px shortest side
  (`space-8` from 400px), plus `SubtleMovement`'s constant 16px, with no
  term for the island, the corner buttons or the Rotation button, and the
  display (with its date or laps) centres in that box both ways. The
  expanded island and the corner buttons draw over the top and bottom
  cards (the island's surface keeps it legible) and nothing reflows when
  the chrome expands, collapses or hides (iPhone 15 Pro, Large: 221px
  stacked H:M:S, 343.5px stacked H:M, 324px landscape row). A hidden chrome makes
  the whole clock one "show controls" button for screen readers.
- Rotation: the R key (phones only) and the Rotation corner button cycle
  the screen rotation (see Orientation).
- Seconds: the S key (Clock mode only) and the Settings switch toggle
  `showSeconds`.
- Laps: the tray's Lap and the L key (Stopwatch mode only) record a split.
  They sit under the digits in a grid: as many columns as fit the widest
  label (`Lap 99  99:59:59.9`, measured with a `TextPainter` in the skin's
  face at the current text scale; at least one), `space-4` between columns
  and `space-2` between rows; fewer laps than fit take only their columns,
  centred. Newest first, left to right then down (`Lap 3  0:00:12.4`), in
  the skin's face and digit colour at the titleMedium size, dimmed with the
  digits; three rows show (at most a third of the panel), the rest scroll.
- Digit brightness dims only the digits (`Opacity` around each `FlipDisplay`,
  and around the date line with the Clock digits);
  the background stays the skin's ground and the island stays at full
  brightness. The D key calls
  `ClockSettings.nextDim` (100% -> 50% -> 20% -> 100%; a slider value in
  between steps down to the next preset) and save.
- Entering full screen expands the chrome and shows
  `strings.clock.full_screen_note` for `noteFor` (3 s, a live region, so
  screen readers hear it); leaving clears it. Settings shows the same note
  under Keep screen awake. Full screen is not a lock screen or screensaver:
  never word it as one.
- No dependency on another feature. The Account page is the only place
  sign-in is offered, and only when the router has a `sync` (Firebase
  configured), so the button is never dead.
- Account (`ui/components/account_page.dart`, `sync_card.dart`): the pinned
  category of `SettingsShell` (`pinned` / `pinnedCard`), so it sits at the
  bottom, always: after the list on phones, at the bottom of the sidebar
  from 600px. `SettingsScreen` rebuilds the shell on `sync.account` /
  `sync.status` changes. The card: signed out `cloud_outlined`, "Your
  settings stay on this device" + why; signed in "Sync is on" / "Sync is
  off" with an icon per status (`cloud_done_outlined`, `cloud_sync_outlined`
  pending/waiting, `cloud_off_outlined`, `error_outline` in `danger`) and
  the status or "Last synced …" (title `bodyLarge` 600 `ink`, subtitle
  `bodyMedium` `inkSubtle`, `danger` when failed); one merged semantics node.
  The page signed out: headline, body, Sign in to sync (`AppButton.filled`, full
  width up to 320), What syncs / Stays on this device. Signed in: email and
  provider, Sync settings switch, `LastSyncedRow` ("Just now" < 60 s, "N min
  ago" < 60 min, "Today at 14:05" by `use24h`, else the medium date; one
  `Timer.periodic` of 30 s, cancelled on dispose), a status line (live
  region; pending, waiting, failed offline / denied (taps to sign in) /
  unknown (Try again -> `CloudSync.retry`), switch off), Sign out and
  Delete account (each behind an `AlertDialog` with `AppButton.text` actions; Delete in `danger`), "Signing out keeps your
  settings on this device". `needsSignIn` shows "Sign in again to delete
  your account", then `onSignIn`; `failed` says so. **No toast, snackbar or
  system notification for any sync outcome.**
- Show date puts `MaterialLocalizations.formatFullDate` above the Clock
  digits, `space-6` apart (at most an eighth of the height, and the date
  at most a quarter of it, scaled down, so a cramped window never
  overflows), the pair centred as one block in the free space; nothing is reserved at the bottom (the date stays above a stack,
  laps stay below the stopwatch's) (the skin's face at the headlineSmall size, 70% of the digit
  colour, scaled down, never wraps; the pomodoro round label is the skin's
  face at the titleLarge size). Every `FlipDisplay` on the clock screen gets
  `size: settings.cardSize.factor`, and the screen draws
  `skin.forTheme(DesignColors.of(context))`, so Mono's ground follows Light
  or Black. It is
  driven by the `ClockController` tick, so it rolls over at midnight, and is
  read as part of the display label (`current_time_and_date`). It dims with
  the digits (one `Opacity` around the digits and the date).
- Panels: a `PageView` (NeverScrollableScrollPhysics) in `ClockMode` order
  (Pomodoro, Clock, Stopwatch) under one `GestureLayer`: tap toggles
  the chrome, vertical drag -> `BrightnessControl.change(-dy / height)`
  (device 0..1 where `ScreenBrightness.supported`, else digitBrightness
  0.2..1; a `ScreenBrightnessException` falls back to in-app for good),
  horizontal swipe pages at 25% width or 600 px/s, no wrap. Axis lock at
  12 px. Off while the clock route is not current (sheets, Settings). `gestureBrightness` / `gestureModes` switch each
  axis off. Double tap toggles full screen on desktop/web only (it delays
  taps). Island HUD: brightness while dragging / Up / Down only, released
  after `hudHold`. A mode change from any source (tab, swipe, Left / Right)
  only sets `lastMode`: an expanded island stays expanded and morphs in
  place (the tab pill slides, the tray swaps, the height follows); a dot or
  hidden chrome stays so, and the panel slide is the feedback. A swipe that
  springs back to its start page calls no `onPage`. The device
  brightness is reset on pause, detach and dispose. A mode change from tabs
  or keys slides the panel (jumps with reduced motion).
- Mode switching is `SettingsController.update(lastMode:)`, so the last mode
  is restored on launch and when returning from Settings (a child route of
  `/clock`, so the clock screen and its state stay underneath).
- Completion: the finished tray and chime always; the system notification is
  scheduled at `endsAt` on native, and shown at completion on web
  (`notifyOnFinish = kIsWeb`, because web cannot schedule). A timer that
  ended while the app was closed shows the finished tray silently on
  relaunch. Finishing (or relaunching finished) switches to the Pomodoro
  panel so the finished tray is always seen.
- Pomodoro (one panel for the cycle and the timer presets; idle, it shows
  the default timer's duration + Start; running, the countdown): 25 min focus / 5 min break from
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
  Start focus beside Done; Space starts it.

## Settings sync

- The device copy is always saved first (`SettingsController.update` emits,
  then saves) and never waits for the network. `shared_preferences` stays
  the store: one small JSON value read once at launch; Hive would add a
  dependency and a migration for no visible gain.
- `SettingsSync` (only when `init` gets a `CloudSync`) pushes
  `ClockSettings.toJson()` minus `SettingsSync.deviceOnly` (`systemAlerts`,
  `lastMode`, `orientation`, `digitBrightness`) as document `clock_settings`,
  1 s after the last change (trailing debounce). The countdown snapshot has
  its own key and never syncs. A change that touches only device-only keys
  pushes nothing.
- Each synced change is stamped at once (`flip_clock.settings_updated_at`,
  ms; absent = 0). Cloud copy newer than the stamp: its synced fields are
  applied over the current settings (device-only kept, maps normalised by a
  JSON round trip), saved locally with the cloud's stamp, and not pushed
  back. Older, or no cloud copy: the local copy is pushed (a never-stamped
  device stamps now first). Equal: nothing (pushing would echo forever). So
  a fresh install adopts an existing cloud copy, and the first device
  uploads.
- `close()` (via `di.reset`) cancels the pending push and both
  subscriptions at once (a Cubit stream's cancel never completes in fake
  time, so they are not awaited one after the other).
- Last write wins per whole document: two devices changing different
  settings offline within the same second can lose one change.

## Common changes

- **Add a setting:** field + default + JSON key in `ClockSettings` (and its
  test), a `Settings*Row` in the right category of `SettingsScreen` (and
  `test/settings_screen_test.dart`), the key in `strings.clock`. It syncs
  unless its key goes in `SettingsSync.deviceOnly` (then also name it in
  `strings.sync.stays_body`).
- **Add a keyboard shortcut:** the handler in `FlipClockScreen`, a
  `key_*` label and `keycap_*` row in the Keyboard group of Settings >
  Shortcuts, a widget test sending the key.
- **Add a touch gesture row:** the gesture in `GestureLayer`, a row in the
  Touch group of Settings > Shortcuts with its `GestureGlyph` kind (a new
  kind goes in `design_system`) and "Off" bound to its setting, a test in
  `settings_screen_test.dart`.

## Tests

`account_page_test.dart` covers the card and page in every look and status (no card without a sync, card below the list / at the sidebar bottom, providers, switch, every status line and icon, denied and Try again, last-synced wording, the 30 s refresh and its timer's cleanup, sign-out and delete confirmations and outcomes, `category=account`, text scale 2, the card's merged semantics); `screens_test.dart` the router's account wiring, `shortcutsFor` per platform and size, and the settings route passing the groups (iPhone, then resized to an iPad, then macOS). `settings_screen_test.dart` covers Shortcuts per platform (iPhone and web on one: touch only, no headers; iPad: Touch then Keyboard headers; macOS: keys, keyboard icon), "Off" following each gesture setting, and the touch rows in both themes at text scale 2; it pumps a fixed time on that page because the glyphs loop. Every row saves through `_update`, an edit applied to `settings.state` at the moment of the change (not the copy the frame drew), so two changes in one frame never revert each other; `settings_screen_test.dart` taps two rows of each kind (switch, segmented, slider, value) in one frame with an outside change between, and the tick and alarm tiles the same way. `settings_sync_test.dart` covers the debounce, the stamp, last-write-wins both ways, no echo, first sign-in, device-only keys, loosely typed cloud maps, a failed push keeping the local save, close, and `init` with and without a `CloudSync`.

`press_rule_test.dart` is the press gate (above) plus a check that it catches every pattern, formatter-split calls included, and ignores comments and theme config. No ink after a tap on a tray action (`screens_test.dart`), a sidebar row and a sound tile (`settings_screen_test.dart`), a skin tile and the sheet's Done (`skin_sheets_test.dart`), read from every `Material`'s ink features by `test/ink.dart` (which a stock `InkWell` in the default theme is shown to trip).

`flip_card_geometry_test.dart` checks every part against the icon at h = 608, pins flush and inside their notches with the stated clearance, the crack ending at the notches, the 80px threshold, half paths (axle, notches, corners, fillets) and empty sizes. `flip_display_test.dart` covers the digits centred on the axle in every face (real fonts, shrunk too), pins inside the card and the exact display width, the painters (crack, underside, lip, cavities, pins in order; none under 80px; dark crack on Mono and Paper; lit halves and the top rim; `shouldRepaint`) and the motion (`turnAt` fall and bounce, flaps about the axle, shade, light and cast shadow, interrupts, reduced motion). `flip_card_probe.dart` reads a card's corner off its clip and finds halves by card colour.

`dart run melos exec --scope=flip_clock -- flutter test`. Fakes for every
`device_services` contract and a controllable clock; cover each Cubit
transition, repository corrupt data, each screen state, shortcuts and route
navigation. `setUp(core.init)`, `tearDown(di.reset)`. Coverage stays 100%.

## Edge cases

`test/language_layout_test.dart`: every Settings page, and the clock
(12-hour, seconds, date) with its Pomodoro tray, lay out without overflow in
German and Japanese on a phone (390x844) and a tablet (1024x1366). The
`Harness.screen(locale:)` adds Flutter's localizations; tests that need a
24-hour device call `deviceOn24h(tester)` (`fakes.dart`).

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
- **Stacking:** 390x844 stacks, 844x390 is a row, 600x640 stays the row
  it starts as, with seconds on and off; portrait 12h with AM/PM left and
  right at text scale 2 fits every mode. The band holds either layout
  (`flip_display_test.dart`).
- **Window size:** every mode and Settings lay out without overflow at
  320x1024, 320x568, 507x1024, 1024x320, 200x100, 1366x1024 and 390x844,
  text scale 1 and 2, and while resized mid-run (timer, full screen,
  stopwatch). The chrome floats over the clock: with seconds, the date,
  laps and every corner button on, the digits and laps stay inside the
  window and do not move when the chrome hides. At 393x852 with phone
  insets the display's centre is the safe area's centre in every mode,
  chrome open or hidden; 320x568 at text scale 1 and 2 fits the date and
  digits inside the `space-4` box.
- **Hours on a charger:** 24 h of clock ticks keep exactly one timer, one
  emission per second, all aligned; a 12 h countdown keeps exactly two
  timers (ticker + end) and none after finishing; 3 h of the screen ticking
  keeps the element count flat and the wake lock on (released on dispose).

- Sound picker (Settings > Sound & alerts): `SettingsScreen` takes the
  `SoundPlayer` (the router passes `di.get<SoundPlayer>()`). Two
  `SettingsGroup`s with a header hint: Tick (the `flipSound` switch, the
  five ticks) and Alarm (the `alertSound` switch, the five alarms, System
  notifications and its notes, the footer). Tiles: 5 across when each gets
  80 px, else 3 (3 + 2 on a phone), `space-3` gaps and padding; a square
  wave on `surfaceRaised`, `sm` corners, the skin tiles' ring and check
  (`selectionRing` / `SelectionCheck` in `skin_picker.dart`); name
  (bodyMedium 500) and mood word (labelSmall, `inkSubtle`, `ink` while
  playing), two lines at most. A radio group per kind: each tile is
  "<name>, <mood>" with a checked state; Enter / Space activate it. A tap
  saves the pick, turns its kind's switch on and previews it: ticks at 0,
  1 and 2 s; an alarm with `previewAlarm` until `SoundWave.alarmPreview`
  (two loops), then `stopPreview`. One preview at a time: a new tap
  cancels its timers and stops its preview; leaving Settings does the
  same, and calls `stopPreview` only for a preview that may still loop.
  Settings never calls `playAlarm` / `stopAlarm`, so it cannot silence a
  real alarm. A
  switch off dims its tiles to 45%; they stay tappable.
- Sound waves: `SoundWave.tick(TickSound)` / `.alarm(AlarmSound)`, one
  `CustomPainter` per sound, the motion ported from the `shapes` object in
  `docs/design/sounds/index.html` (that page is the spec; change both
  together). A designed motif timed to the sound, not an audio meter
  (`audioplayers` has no amplitude stream). At rest (`playing` null) it
  paints a still pose (0.12 s, energy 0.25) with no ticker running; a new
  `playing` value starts one from 0: ticks pulse
  `0.25 + 0.75 e^(-p / decay)` on ticks at 0, 1, 2 s, alarms hold 1 for two
  loops, then 0.4 s at rest energy and the ticker stops. Reduced motion
  (`reducedMotion`) keeps the still pose. Line 1.6 px, round joins, the
  colour passed in; sized by its parent.

## Gotchas

- An alarm preview plays on its own player, never the alarm's: picking an
  alarm while a finished timer rings plays no preview (the alarm keeps
  ringing), and a timer that finishes during a preview cuts the preview
  short. Only the wave animates in the first case.
- In the background the system notification plays the OS default sound,
  not the picked alarm.

- Customizer controls apply each edit to the current draft (a function of
  the draft), so two taps before a rebuild both stick.
- The flip sound follows card flips: with seconds as a badge, the minute
  card is the first to flip. It plays only while the clock is on screen:
  never under Settings, a sheet or another route, nor while the app is not
  resumed.

- In `testWidgets`, do not `await cubit.close()` (or `di.reset()`) after a
  widget or listener subscribed to the cubit: the broadcast stream's close
  never completes in fake time and the test hangs. Dispose the tree, call
  `close()` unawaited, then `pump()` (see `Harness.dispose` in
  `test/screens_test.dart`).
- A clock set back by less than the time a running timer has already used
  is not detected: the end is only rebased once it lies more than a full
  duration away, so such a timer runs long by the set-back amount (a paused
  timer is unaffected).
- Flip sound is wired for Clock and the countdown only (the stopwatch's tenths would
  click ten times a second).
