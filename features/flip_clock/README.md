# flip_clock

QuietFlip's whole first release: a split-flap clock, a Pomodoro panel that
runs the Pomodoro cycle (25 min focus, 5 min break, repeating, with a round
count) or one of your timer presets (5, 10, 15 min by default, up to six),
and a stopwatch, plus Settings. The clock can show today's date
above the digits (Settings > Clock > Show date). On a tall screen (a phone
held upright) the cards stack, hours over minutes (over seconds); turned
sideways they sit in one row. No analytics. An account is optional: signed
in, your settings follow you to your other devices.

## Routes

| Path | Screen |
|---|---|
| `/clock` (`FlipClockRouter.home`) | Pomodoro / Clock / Stopwatch panels; the app launches here |
| `/clock/settings` (`FlipClockRouter.settings`) | Settings, stacked on the clock |
| `/clock/settings?category=timers` (`timerSettings`) / `?category=account` (`accountSettings`) | Settings opened on Timers / the Account page |

## Wiring

```dart
await core.init();
await device_services.init();
await cloud_sync.init();          // optional: only when Firebase is up
await flip_clock.init(sync: cloudSyncOrNull); // restores settings and any running timer

DesignSystemWrapper(mode: ..., builder: ...)  // feed flip_clock.appearance()
GoRouter(routes: [
  ...FlipClockRouter(
    sync: cloudSyncOrNull,                 // null: no Account card
    onSignIn: (context) => ...,            // the app opens sign-in
    onSignOut: (context) => ...,
    onDeleteAccount: (context) => ...,     // returns an AccountDeletion
  ).routes,
])
```

`init()` needs `Logger`, `KeyValueStore`, `LocalAlerts`, `SoundPlayer` and
`OrientationLock` in `di`; the clock route also resolves
`FullScreenController`, `ScreenWake` and `ScreenBrightness`.

## Settings

Settings opens from the Settings button in the top-right corner. It adapts: a list you tap
into on phones, a sidebar and detail pane on tablets, and a denser sidebar
window on desktop and the web (a narrow browser window gets the phone list).
Everything is saved at once and restored on launch.

- **Appearance:** Skins (the first five as live thumbnails, tap to apply;
  View all opens the Skins sheet), Theme (Dark, the default
  even when the OS is light; Light; Match system), Digit brightness (20% to
  100%; dims only the digits and the date line, never the controls; the D
  key cycles 100%, 50%, 20%).
- **Clock:** 24-hour time, Show seconds (also the S key), Show date,
  Orientation (Auto / Landscape / Portrait; phones and tablets only).
- **Gestures:** swipe up or down for brightness, swipe sideways to change
  mode, tap to show controls, hide controls after 2 s / 4 s / 8 s / Never.
- **Timers:** the default timer Start runs (Pomodoro or a preset), your
  presets (delete any, Add timer in minutes and seconds, up to six), and the
  Pomodoro lengths (25 min focus, 5 min break). The island's tune icon opens
  Settings right here; Done returns to the clock.
- **Sound & alerts:** two groups of five tiles, each with its own moving
  wave. Tick (the sound on every card flip): Classic, Split-flap,
  Clockwork, Woodblock, Digital. Alarm (loops until dismissed, at most
  60 s): Chime, Bell, Beeps, Rising, Ring. Tapping a tile picks it, turns
  that sound on if it was off, and previews it: a tick three times a second
  apart, an alarm for two loops, with its wave moving in time. Each group
  has its on/off switch (tiles dim while off); System notifications sits
  under the alarms.
- **Keep awake:** keep the screen awake; subtle movement (full screen
  shifts the display up to 8 px per axis once a minute, easing over 1 s, a
  jump with reduced motion; it lowers, but does not prevent, burn-in risk).
- **Shortcuts** (R for rotation on phones) and **About** (licences, privacy).
- **Account** (a card at the bottom of the list on phones, at the bottom of
  the sidebar on tablets and desktop; only when Firebase is configured):
  signed out, it explains that you only need to sign in to get your
  settings on your other devices. Signed in: a **Sync settings** switch (on
  by default, per device), when the last sync happened, sign out (settings
  stay on the device) and delete account. Sync problems ("Waiting for a
  connection", "Couldn't sync…") show here only: never a toast or a
  notification.

## Settings sync

Every change is saved on the device first, then synced to Firestore one
second after the last change, offline first (Firestore queues writes until a
connection returns). Everything syncs, custom skins included, except what
belongs to one device: brightness, rotation, notifications permission, the
last screen and a running timer. The most recent change wins; a device that
has never synced takes the cloud copy when it first signs in.

## Controls

Only the digits show when nobody touches the screen. A tap or click shows,
floating above the clock, the island at the top centre (on a phone, just
below the corner buttons, so it is never squeezed) (the mode tabs, Pomodoro, Clock, Stopwatch,
over the actions of the current mode, centred), Skins in the top-left
corner, Settings in the top-right and, on phones and tablets, Rotation in
the bottom-right. They appear, shrink and disappear together. Rotation
picks the screen rotation whatever way the device is held: follow the
device, portrait, landscape, round again (the island says which; the R key
does the same). Pomodoro offers Start (your default timer), a Pomodoro chip,
one chip per preset (one tap on `10m` starts ten minutes) and a shortcut to
the timer settings; running it offers Pause/Resume and Reset; finished,
Restart (or the next Pomodoro phase) and Done. The stopwatch offers Start,
Pause, Lap, Resume and Reset; laps fill a grid under its digits, newest first, as many columns as fit, three rows before it scrolls. After 4 seconds without input the island and
the corner buttons shrink to dots, and 3 seconds later they are gone; a timer that finishes brings it
back. Any key or a
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

The Skins button (top-left) opens the Skins sheet: live tiles of every skin,
drawn as each skin is configured (seconds only on skins that show them,
which is what you get when you pick one; the date above the cards only on
skins that show it). Tap a tile to apply it: it gets the accent ring and check,
and its caption turns into a Customize button for that skin. Classic is Mono (the default, white on near-black; black on white in
the Light theme) plus nine colour variations; Bold has presets that show off
the options (Nightstand, Studio, Arcade, Railway, Desk, Neon, Minimal); Type
has one skin per bundled face (Bebas, Anton, Oswald,
Shoulders, Poster, Terminal, Grotesk, Serif, Orbit). Every built-in skin is
free and passes 4.5:1 digits-on-card contrast.

A skin with its own face (Bebas, Orbit, Terminal and the rest) sets the whole
app in that face: settings, the island, sheets, the date and AM/PM. Mono and
the Classic colour skins keep Geist for everything but the digits.

Customize on the selected tile (in the sheet or the Appearance strip), or
New skin, opens the customizer on that skin: face, digit / card /
background colour (token swatches or a hex colour), split line (corners
follow Settings > Appearance > Corners for the whole app), seconds style (off, small, cards), AM/PM (hidden, inside
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
change mode, Up / Down brightness (10% steps), S show or hide seconds (Clock mode), L lap (Stopwatch), D dim the digits
(100%, 50%, 20%).

## Edge cases covered

Daylight-saving jumps, time-zone changes while open, the wall clock jumping
forward or back during a countdown (the end, saved snapshot and system alert
move together), iPad split view / resized windows down to 200x100 at text
scale 2, and hours of ticking on a charger (one aligned timer, wake lock
held). Details in `CLAUDE.md`; tests in `test/edge_cases_test.dart`.

See `CLAUDE.md` for rules and tests.
