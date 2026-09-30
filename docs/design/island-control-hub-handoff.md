# Island control hub (app feedback round 2): handoff

Base: `main` at c435d3b (multi-skin shipped, first feedback round fixed).
Design source of truth for tokens and the island look: https://claude.ai/artifact/DeKZuGwFaBhcDchFfJM2FN
Previous brief (still valid where this one is silent): `docs/design/multi-skin-handoff.md`.

This is the brief for the coding agent. Follow the repository `CLAUDE.md` and the
nested `CLAUDE.md` files on the path (`features/flip_clock`, `packages/design_system`,
`packages/timekeeping`, `packages/localization`): dependency direction, 100% line
coverage, strings through i69n, colours from the design system, generated files
read-only. Load the `design-system` and `flutter-best-practices` skills before any UI work.

## The feedback, verbatim intent

1. Dragging to change brightness leaves the island stuck on the brightness readout.
2. In the dark theme the Reset button is not visible.
3. The island is the only control surface. No other buttons on the clock screen. It
   expands to show the actions of the current mode (start, pause, resume, reset,
   restart, lap, ...) and collapses again, like the iPhone Dynamic Island.
4. Pomodoro and Timer are one thing: merge them. Keep one panel (named Pomodoro),
   remove the Timer panel. Idle, the island offers quick-start presets (5, 10, 15 min,
   plus the user's own, e.g. 23 min). Settings gets a Timers section to add presets and
   pick the default one that Start runs. The island has a way to jump to those settings.
5. Stopwatch gets the same island treatment, plus Lap.
6. A tap anywhere on the clock toggles the controls: hidden -> shown, shown -> hidden.
   This applies to mouse clicks too.
7. Settings > Appearance: skins shown as a horizontal strip of the first few skins with
   a "View all" that opens the full picker, so skins are visible without digging.

## Delivery order

One pull request, one commit (or more) per stage, in this order. Run
`dart run melos run lint` and `dart run melos run coverage` after each stage.

1. **Bug fixes** (items 1, 2, 6). Small, independent, land first.
2. **Timer model** (item 4, data only): presets in `ClockSettings`, `ClockMode.timer`
   removed with migration, countdown controller starts from a preset.
3. **Island action tray** (items 3, 4, 5 UI): the island grows a second row of actions;
   `RunControls`, `CompletionBanner`, `TimerInput` and both `CornerButton`s go away.
4. **Stopwatch laps** (item 5).
5. **Settings** (items 4 settings side, 7): Timers section with presets, Appearance skins strip.

## Stage 1: bug fixes

### Brightness HUD stuck (item 1)

- Likely cause (confirm with a failing test first): `_brighten` in
  `features/flip_clock/lib/ui/screens/flip_clock_screen.dart` awaits
  `BrightnessControl.change` before calling `ChromeController.showHud`. On drag end,
  `GestureLayer` calls `onBrightnessEnd` -> `releaseHud()` synchronously, while the last
  `change` is still in flight. When it resolves, `showHud` cancels `_hudTimer`
  (`features/flip_clock/lib/state/chrome_controller.dart`), so the release is lost and
  the HUD never clears.
- Fix in `ChromeController`, where every caller routes: remember that the HUD was
  released; a `showHud` after release re-arms the hold timer instead of cancelling it.
  A new gesture start (`showHud` after `activity` from a new pan) clears the flag.
- Test: `fakeAsync`, call `showHud`, `releaseHud`, then `showHud` again (the late one),
  elapse more than `hudHold` -> HUD is null. Also a widget test that drags vertically
  with a `BrightnessControl` whose `change` completes after the drag ends.

### Reset invisible in dark theme (item 2)

- Not yet verified. Hypothesis: `RunControls` (`ui/components/controls.dart`) uses app
  theme colours (`TextButton` -> `colorScheme.primary`, white in dark) but sits on the
  skin's ground, which can be light for non-Mono skins; disabled Reset (idle) is also
  38% ink. Reproduce on Mono and on a light-ground skin in dark theme before fixing.
- Stage 3 deletes `RunControls`. The lasting fix is the rule for the tray: island
  actions draw with island tokens on the island's own dark pill, never on the skin
  ground, so they are legible on every skin in both themes. Add a golden-free contrast
  test: every tray action's foreground vs island background >= 4.5:1 in both themes.

### Tap toggles for mouse too (item 6)

- `_onTap` currently does `_mouse ? _chrome.wake() : _chrome.tap()`. Make it always
  `_chrome.tap()`.
- Keep hover waking a hidden chrome (desktop discoverability). Gotcha: the first
  feedback round complained that moving the mouse showed the controls and the click
  then hid them. The user now explicitly wants click to toggle; accept that trade-off
  and update `a mouse click shows the chrome and never hides it` in `features/flip_clock/test/screens_test.dart`.
- Taps on island actions are consumed by the action and do not toggle.

## Stage 2: timer model

- `ClockMode` becomes `{ pomodoro, clock, stopwatch }`. `ClockSettings.fromJson`:
  a saved `lastMode: timer` maps to `pomodoro`. Update `Island` tab count, page order,
  swipe bounds, the mode HUD (`IslandTitleHud(..., 3)`), arrow keys.
- New `ClockSettings` fields, each with a default and a per-field `fromJson` fallback:

| Field | Type | Default |
| --- | --- | --- |
| `timerPresets` | `List<Duration>` | `[5 min, 10 min, 15 min]` |
| `defaultTimer` | `TimerPreset` (sealed: `PomodoroCycle` or `Minutes(Duration)`) | `PomodoroCycle` |

- Rules: at most 6 presets (what fits the tray), no duplicates, each valid per
  `Countdown.isValid`, sorted ascending. Invalid entries in JSON are dropped, not
  crashed on. Removing the preset that is `defaultTimer` resets the default to
  `PomodoroCycle`.
- The Pomodoro cycle (25 focus / 5 break, rounds) stays as it is in
  `packages/timekeeping/lib/src/pomodoro.dart` and `CountdownController.startPomodoro`.
  A plain preset uses `CountdownController.start(duration)`. The countdown engine is unchanged.
- Delete the free-form entry path (`setDuration`, `_entryValid`, `TimerInput`) once
  nothing calls it. Space on an idle Pomodoro panel starts `defaultTimer`.

## Stage 3: island action tray

The island keeps its three states (hidden, dot, expanded) and the HUD. Expanded now has
two rows: the mode tabs (as today) and an action tray for the current mode. The tray
morphs with the same island spring; content cross-fades (`DesignMotion.fade`), and
`reducedMotion` gives a cross-fade only.

`Island` in `design_system` stays product-agnostic: it takes a list of
`IslandAction { IconData icon; String label; VoidCallback? onPressed; bool primary }`
(or chips for presets) and renders them. Labels are for semantics and tooltips; the
flip_clock feature decides which actions exist.

Tray contents:

| Mode / state | Tray |
| --- | --- |
| Clock | Skins, Settings |
| Pomodoro idle | Start (runs `defaultTimer`), chips: Pomodoro, each preset (`5m`, `10m`, ...), a tune icon -> Settings > Timers |
| Pomodoro running | Pause, Reset; label shows `Focus · round 2` / `Break` for a cycle |
| Pomodoro paused | Resume, Reset |
| Pomodoro finished | Restart (same duration), Done; for a cycle: Start break / Start focus, Done |
| Stopwatch idle | Start |
| Stopwatch running | Pause, Lap |
| Stopwatch paused | Resume, Reset |

- Skins and Settings are tray actions on every mode (trailing, after a hairline), so the
  two `CornerButton`s are removed. Delete `CornerButton` from `design_system` if nothing
  else uses it (no speculative code).
- When a countdown finishes while the chrome is hidden, the island expands to its
  finished tray (this replaces `CompletionBanner`) and the idle collapse still applies.
- The island must fit at 320 px width with text scale 2.0: the tray scrolls
  horizontally rather than overflowing; preset chips come after the primary action.
- Remove `_WithControls`, `Reveal`, `RunControls`, `CompletionBanner`, `TimerInput` and
  their tests once unused.

## Stage 4: stopwatch laps

- `StopwatchState` gains `laps: List<Duration>` (split times, newest first). `lap()`
  while running appends `elapsed - sum(previous laps)`; ignored when not running.
  `reset()` clears laps.
- Laps show under the digits in the Stopwatch panel: the latest 3 visible (`Lap 3  00:12.4`),
  scroll for more; skin font and digit colour, sized from design tokens.
- Keyboard: `L` = lap. Add to Settings > Shortcuts.
- In memory only, like the stopwatch itself today.

## Stage 5: settings

### Timers section (item 4)

Replace the read-only `_timers()` in `ui/screens/settings_screen.dart`:

- Group "Default timer": a choice row over Pomodoro + every preset.
- Group "Presets": one row per preset with a delete action, plus "Add timer" that opens
  a minutes (and seconds) picker; disabled at 6 presets with a footer saying why.
- Group "Pomodoro": focus and break lengths, read-only as today.
- The island's tune icon opens Settings directly on this category and returns to the
  clock on close.

### Appearance skins strip (item 7)

- At the top of Appearance, a group "Skins": a horizontal row of the first 5 skin
  thumbnails (reuse `SkinTile` from `ui/components/skin_picker.dart`, do not
  re-draw), the selected one outlined, tap applies it. A trailing "View all" opens the
  existing skin picker sheet. Remove the old `settings_skin` value row.
- Works in the phone stack, tablet split and desktop sidebar layouts of `SettingsShell`.

## Strings (`clock.*`)

Add: `action_start`, `action_pause`, `action_resume`, `action_reset`, `action_restart`,
`action_done`, `action_lap`, `action_skins`, `action_settings`, `action_timer_settings`,
`preset_minutes` (arg), `preset_pomodoro`, `lap_label` (args: number, time),
`timers_default`, `timers_presets`, `timers_add`, `timers_limit_footer`, `timers_delete`,
`skins_view_all`, `key_lap`, `keycap_l`. Remove keys that end up unused (`mode_timer`,
timer-input keys) and regenerate.

## Tests the gate expects

- `ChromeController`: late `showHud` after `releaseHud` still clears after `hudHold`.
- Tap toggles for touch and mouse; taps on tray actions do not toggle.
- `ClockSettings`: `timerPresets` / `defaultTimer` round trip, limit 6, duplicates and
  invalid values dropped, deleting the default preset, `lastMode: timer` migration.
- Island: tray per mode and state, horizontal scroll at 320 px and text scale 2.0,
  contrast of tray actions in both themes, reduced motion.
- Pomodoro panel: chip starts that preset; Start runs `defaultTimer`; finished tray.
- Stopwatch: lap while running, ignored while paused, reset clears laps, `L` key.
- Settings: add/delete preset, limit footer, default choice; skins strip applies a
  skin and "View all" opens the sheet, at 375, 820 and 1280 widths.

## Acceptance

- The clock screen has no control outside the island.
- Brightness drag: the readout disappears about 1.2 s after the finger lifts, every time.
- In the dark theme on every built-in skin, every island action is clearly visible.
- Idle Pomodoro panel: one tap on `10m` starts a 10 minute countdown.
- Stopwatch: Start, Lap, Lap, Pause, Reset works from the island alone.
- A click or tap on an empty area of the clock toggles the controls both ways.
- Settings > Appearance shows skins without opening another screen.

## Docs to update in the same PR

`features/flip_clock/CLAUDE.md` and `README.md` (modes, island tray, presets, laps),
`packages/design_system/CLAUDE.md` and `README.md` (`Island` actions, `CornerButton`
removal), `packages/localization` notes if keys are listed there.

## Decisions taken for the user (change here if wrong)

- Merged panel is named Pomodoro, per the feedback. Its tab label may read oddly for a
  plain 5 minute timer; revisit after using it.
- Presets are the user's list (max 6), not "last 6 used". Recent-use tracking was not
  asked for firmly and adds state for little gain.
- Skins and Settings move into the island, because the feedback says no other buttons.
