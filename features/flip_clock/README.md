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

## Keyboard

F full screen, Esc leave full screen, Space start/pause, 1 / 2 / 3 Clock /
Timer / Stopwatch, S show or hide seconds (Clock mode; also a top-bar
button, with a one-time hint until it is used or dismissed). See `CLAUDE.md` for rules and tests.
