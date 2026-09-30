# flip_clock

QuietFlip's whole first release: a split-flap clock, a countdown timer (1 s to
99:59:59) and a stopwatch, plus Settings. No account, network or analytics.

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

`init()` needs `Logger`, `KeyValueStore`, `LocalAlerts` and `SoundPlayer` in
`di`; the clock route also resolves `FullScreenController` and `ScreenWake`.

## Subtle movement

Off by default (Settings > Display). When on, full screen shifts the display
up to 8 px per axis once a minute, easing over 1 s (a jump with reduced
motion). It lowers, but does not prevent, burn-in risk.

## Keyboard

F full screen, Esc leave full screen, Space start/pause, 1 / 2 / 3 Clock /
Timer / Stopwatch, S show or hide seconds (Clock mode; also a top-bar
button, with a one-time hint until it is used or dismissed), D dim the digits
(100%, 50%, 20%).

## Night dimming

Settings > Display > Digit brightness (20% to 100%) dims only the digits; the
background stays black and the controls stay readable. In full screen the
top bar also has a quick-dim button that cycles 100%, 50%, 20%.

See `CLAUDE.md` for rules and tests.
