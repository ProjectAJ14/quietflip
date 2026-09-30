# flip_clock

QuietFlip's whole first release: a split-flap clock, a Pomodoro panel that
runs the Pomodoro cycle (25 min focus, 5 min break, repeating, with a round
count) or one of your timer presets (5, 10, 15 min by default, up to six),
and a stopwatch, plus Settings. The clock can show today's date
under the digits (Settings > Clock > Show date). No account, network or analytics.

## Routes

| Path | Screen |
|---|---|
| `/clock` (`FlipClockRouter.home`) | Pomodoro / Clock / Stopwatch panels; the app launches here |
| `/clock/settings` (`FlipClockRouter.settings`) | Settings, stacked on the clock |

## Wiring

```dart
await core.init();
await device_services.init();
await flip_clock.init();          // restores settings and any running timer

DesignSystemWrapper(mode: ..., builder: ...)  // feed flip_clock.appearance()
GoRouter(routes: [...const FlipClockRouter().routes])
```

`init()` needs `Logger`, `KeyValueStore`, `LocalAlerts`, `SoundPlayer` and
`OrientationLock` in `di`; the clock route also resolves
`FullScreenController`, `ScreenWake` and `ScreenBrightness`.

## Settings

Settings opens from the top-right corner button. It adapts: a list you tap
into on phones, a sidebar and detail pane on tablets, and a denser sidebar
window on desktop and the web (a narrow browser window gets the phone list).
Everything is saved at once and restored on launch.

- **Appearance:** Skin (opens the Skins sheet), Theme (Dark, the default
  even when the OS is light; Light; Match system), Digit brightness (20% to
  100%; dims only the digits and the date line, never the controls; the D
  key cycles 100%, 50%, 20%).
- **Clock:** 24-hour time, Show seconds (also the S key), Show date,
  Orientation (Auto / Landscape / Portrait; phones and tablets only).
- **Gestures:** swipe up or down for brightness, swipe sideways to change
  mode, tap to show controls, hide controls after 2 s / 4 s / 8 s / Never.
- **Timers:** the Pomodoro lengths (25 min focus, 5 min break).
- **Sound & alerts:** flip sound, alert sound, system notifications.
- **Keep awake:** keep the screen awake; subtle movement (full screen
  shifts the display up to 8 px per axis once a minute, easing over 1 s, a
  jump with reduced motion; it lowers, but does not prevent, burn-in risk).
- **Shortcuts** and **About** (licences, privacy).

## Controls

Only the digits show when nobody touches the screen. A tap shows the
controls: the mode island at the top centre (on its own row under the corner buttons on phones; Pomodoro, Clock, Stopwatch)
between the Skins (top left) and Settings (top right) buttons. After 4 seconds without
input they shrink to dots, and 3 seconds later they are gone. Any key or a
mouse move shows them; Esc hides them. Settings sets the idle time and
whether a tap toggles them.

## Gestures

- **Swipe up or down** anywhere: brightness (full screen height = 100%).
  On iOS and Android it changes the screen brightness for QuietFlip only
  and returns it to the system level when the app goes to the background
  or closes; on macOS, Windows and the web it dims the digits (20% to
  100%). The island shows the level.
- **Swipe sideways**: previous or next mode (Pomodoro, Clock, Stopwatch),
  no wrap-around. A quarter of the width or a quick fling
  changes it; the island names the mode.
- **Tap or click**: show or hide the controls. **Double tap** (desktop, web): full
  screen.
- Gestures are off while a sheet or Settings covers the clock. Swipes and brightness can each be turned off.

## Skins

The Skins corner button opens the Skins sheet: live tiles of every skin, applied
on tap. Classic is Mono (the default, white on near-black; black on white in
the Light theme) plus nine colour variations; Bold has presets that show off
the options (Nightstand, Studio, Arcade, Railway, Desk, Neon, Minimal); Type
has one skin per bundled face (Bebas, Anton, Oswald,
Shoulders, Poster, Terminal, Grotesk, Serif, Orbit). Every built-in skin is
free and passes 4.5:1 digits-on-card contrast.

A skin with its own face (Bebas, Orbit, Terminal and the rest) sets the whole
app in that face: settings, the island, sheets, the date and AM/PM. Mono and
the Classic colour skins keep Geist for everything but the digits.

Customize (or New skin) opens the customizer on the current skin: face,
digit / card / background colour (token swatches or a hex colour), corner
radius, split line, seconds style (off, small, cards), AM/PM (hidden, inside
the first card, beside the last) and the date line. Saving a built-in skin
creates a copy under Your skins; custom skins can be edited or deleted. A
skin controls only the digits, cards and ground, never the controls.

Picking a skin applies its preset: Show seconds turns on for skins that show
seconds and off for those that do not (Mono), and Settings or the S key can
still change it. With a skin that has no seconds style of its own, seconds
get their own cards. The skin can add the date line on its own. AM/PM and
the small seconds grow with the cards, in the skin's font.

## Full screen

Entering full screen shows the controls for three seconds with a plain note:
full screen only hides the controls while the app stays open; it is not a
lock screen or screensaver. Settings repeats the note under Keep screen awake.

## Keyboard

F full screen, Esc leave full screen (or hide the controls), Space start/pause (or start the next
pomodoro phase after one ended while the app was closed), Left / Right
change mode, Up / Down brightness (10% steps), S show or hide seconds (Clock mode), D dim the digits
(100%, 50%, 20%).

## Edge cases covered

Daylight-saving jumps, time-zone changes while open, the wall clock jumping
forward or back during a countdown (the end, saved snapshot and system alert
move together), iPad split view / resized windows down to 200x100 at text
scale 2, and hours of ticking on a charger (one aligned timer, wake lock
held). Details in `CLAUDE.md`; tests in `test/edge_cases_test.dart`.

See `CLAUDE.md` for rules and tests.
