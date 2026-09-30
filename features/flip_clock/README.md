# flip_clock

QuietFlip's whole first release: a split-flap clock, a countdown timer (1 s to
99:59:59) with a Pomodoro preset (25 min focus, 5 min break, repeating, with
a round count) and a stopwatch, plus Settings. The clock can show today's date
under the digits (Settings > Display > Show date). No account, network or analytics.

## Routes

| Path | Screen |
|---|---|
| `/clock` (`FlipClockRouter.home`) | Clock / Timer / Stopwatch; the app launches here |
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
`FullScreenController` and `ScreenWake`.

## Display settings

Settings > Display, all saved and restored on launch:

- **Show seconds**, also a top-bar button in Clock mode (S key), with a
  one-time hint until it is used or dismissed.
- **Digit brightness** (20% to 100%) dims only the digits (and the date line);
  the background (the skin's ground) stays as it is and the controls stay readable. In full screen
  the top bar also has a quick-dim button that cycles 100%, 50%, 20% (D key).
- **Subtle movement**, off by default: full screen shifts the display up to
  8 px per axis once a minute, easing over 1 s (a jump with reduced motion).
  It lowers, but does not prevent, burn-in risk.
- **Show date**, off by default: today's full date under the clock digits.
- **Orientation** (Auto / Landscape / Portrait) locks the screen on phones
  and tablets. The control is hidden on web and desktop.

## Skins

The palette button opens the Skins sheet: live tiles of every skin, applied
on tap. Classic is Mono (the default, white on near-black) plus nine colour
variations; Type has one skin per bundled face (Bebas, Anton, Oswald,
Shoulders, Poster, Terminal, Grotesk, Serif, Orbit). Every built-in skin is
free and passes 4.5:1 digits-on-card contrast.

Customize (or New skin) opens the customizer on the current skin: face,
digit / card / background colour (token swatches or a hex colour), corner
radius, split line, seconds style (off, small, cards), AM/PM (hidden, inside
the first card, beside the last) and the date line. Saving a built-in skin
creates a copy under Your skins; custom skins can be edited or deleted. A
skin controls only the digits, cards and ground, never the controls.

Seconds and the date still follow Settings (and the S key); the skin picks
how seconds look and can add the date line on its own.

## Full screen

Entering full screen shows the controls for three seconds with a plain note:
full screen only hides the controls while the app stays open; it is not a
lock screen or screensaver. Settings repeats the note under Keep screen awake.

## Keyboard

F full screen, Esc leave full screen, Space start/pause (or start the next
pomodoro phase after one ended while the app was closed), 1 / 2 / 3 Clock /
Timer / Stopwatch, S show or hide seconds (Clock mode; also a top-bar
button, with a one-time hint until it is used or dismissed), D dim the digits
(100%, 50%, 20%).

## Edge cases covered

Daylight-saving jumps, time-zone changes while open, the wall clock jumping
forward or back during a countdown (the end, saved snapshot and system alert
move together), iPad split view / resized windows down to 200x100 at text
scale 2, and hours of ticking on a charger (one aligned timer, wake lock
held). Details in `CLAUDE.md`; tests in `test/edge_cases_test.dart`.

See `CLAUDE.md` for rules and tests.
