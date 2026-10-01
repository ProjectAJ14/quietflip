# Island, corners and layout (app feedback round 3): handoff

Base: `main` at 4f92a13 (island control hub, feedback round 2 shipped).
Previous briefs, still valid where this one is silent:
`docs/design/island-control-hub-handoff.md`, `docs/design/multi-skin-handoff.md`.

This is the brief for the coding agent. Follow the repository `CLAUDE.md` and the
nested `CLAUDE.md` files on the path (`features/flip_clock`, `packages/design_system`,
`packages/device_services`, `packages/localization`): dependency direction, 100% line
coverage, strings through i69n, colours and shapes from the design system, generated
files read-only. Load the `design-system` and `flutter-best-practices` skills before
any UI work.

## The feedback, verbatim intent

1. The island feels cramped: everything is too close. It needs spacing rules so it
   breathes.
2. The island has no depth. It should feel like it floats *above* the clock, not like
   it is painted on it.
3. Collapsing the island is not smooth: it "just goes away". The user should see it
   shrink back, the same way they see it grow. Expanding is fine.
4. Skins and Settings leave the island and go back to the top-left and top-right
   corners of the screen, showing and hiding in sync with the island, like before
   round 2. The island keeps only the current mode's controls, centred.
5. Stopwatch laps use the horizontal space: a grid, as many columns as fit, scrolling
   after three rows.
6. One corner style for the whole app. No circles, no pills that ignore the system:
   island, buttons, chips, tiles, sheets, flip cards, all from one radius. A global
   setting in Settings > Appearance changes it; 0 gives a boxy app everywhere.
7. A rotation button at the bottom-right, behaving like the corner buttons (shown and
   hidden with the island). It picks the screen rotation regardless of how the device
   is held: follow the device, portrait, or landscape.
8. When the space is tall (phone held upright), the clock stacks vertically: hours
   over minutes (over seconds) instead of one row. Strict rules decide which layout.
9. The date moves above the time, with good spacing. The bottom stays free (later:
   weather, word of the day; nothing to build for that now).
10. Skin gallery tiles render the real settings: seconds show in the preview when they
    show on the clock.
11. Picking a skin is not intuitive: it is unclear what is selected and that it can be
    customised. Make select and customise obvious.

## Delivery order

One pull request, one commit (or more) per stage, in this order. Run
`dart run melos run lint` and `dart run melos run coverage` after each stage.

1. **Island motion, spacing, depth** (items 1, 2, 3). `design_system` `Island` only.
2. **Global corners** (item 6). Cross-cutting; lands before new chrome so new
   widgets are born with the right shape.
3. **Corner chrome** (items 4, 7). Skins / Settings / Rotation buttons around the island.
4. **Clock layout** (items 8, 9). Stacked layout and date above.
5. **Lap grid** (item 5).
6. **Skin gallery** (items 10, 11).

## Stage 1: island motion, spacing, depth

### Collapse is not smooth (item 3), root cause

Verified in code, confirm with a test first:

- A tap on an expanded island goes straight to `hidden`
  (`ChromeController.tap`, `features/flip_clock/lib/state/chrome_controller.dart:92`).
- In `Island.build` (`packages/design_system/lib/components/island.dart`) the whole
  pill fades with `AnimatedOpacity(duration: DesignMotion.fade)` (180 ms) while its size
  morphs with `AnimatedSize(DesignMotion.islandMorph)` (460 ms). So on hide the island
  is fully transparent while it is still almost full size: it vanishes instead of
  shrinking. The expanded content also swaps out through the 180 ms `AnimatedSwitcher`.
- Expand looks right because the size grows while opacity is already 1.

Fix, in `Island` (every caller routes through it):

- Hiding from `expanded` plays as **shrink to the dot, then fade the dot**: the size
  morph runs first; opacity stays 1 for the morph and fades over the last part
  (`Interval(0.6, 1)` of a collapse duration), never before the shape is small.
- Collapse uses its own token, `DesignMotion.islandCollapse` (about 380 ms) with a
  curve that does not overshoot (`Curves.easeInOutCubic` or a critically damped
  `SpringCurve`); expand keeps the current spring. Overshoot on the way in feels alive;
  overshoot on the way out reads as a bounce.
- Content fades out *with* the shrink (it scales down inside the shrinking pill via
  the existing `FittedBox`), not before it.
- Same rule for `expanded -> dot` (idle) and `dot -> hidden`.
- Reduced motion: cross-fade only, as today.
- Measure: record a widget-test timeline (pump in 16 ms steps across the full
  collapse) and assert that opacity stays above 0.9 until the island's height is below
  half of its expanded height, and that the final frame is hidden. Observe it in the
  running app too (`flutter run -d chrome`), tapping to toggle 10+ times.

### Spacing rules (item 1)

Codify these as tokens in `design_tokens.dart` (`DesignSize` / `DesignSpace`) and use
them in `Island`; no literals:

| Rule | Value |
| --- | --- |
| Island inner padding, all sides | `s2` (8) |
| Gap between tab row and tray row | `s2` (8) |
| Gap between items in a group (tabs, actions, chips) | `s2` (8) |
| Gap between groups (primary actions vs preset chips) | `s4` (16), no line: "invisible but identifiable" |
| Tab and chip horizontal padding | `s4` (16) |
| Hit target of every tab, action and chip | `cornerButton` (44) |
| Tray content | centred under the tabs, never left-aligned |

- `Island.trayHeight` becomes padding + tab row + gap + tray row + padding (about 112).
  `_ModeView` already reserves `Island.trayHeight`, so the digits move down with it;
  check 320 x 568 still fits (`top` is capped at a quarter of the height).
- The trailing group and its hairline go away in stage 3 (Skins and Settings leave
  the island), so the tray is one centred row of the mode's controls.

### Depth (item 2)

The island must read as a raised object over the clock on every skin ground, black
included (where shadows vanish).

- Add `islandElevation` to `DesignColors` (both themes), replacing `islandShadow`:
  - a soft drop shadow, large and offset down (about `0, 12, 32` at 45% black) plus a
    tight contact shadow (about `0, 2, 6` at 35%). Visible on light grounds (Paper).
  - a 1 px top highlight: a gradient border from 14% white at the top edge to 0 at
    mid-height. This is what gives depth on pure black.
  - keep the 1 px hairline ring only in dark, under the highlight.
- Island fill in dark goes up one step (`surfaceRaised`, `#1c1c1e`) so it separates
  from black cards. Keep tray contrast >= 4.5:1 (the existing contrast test covers it).
- Update the design-system README token table. Tests: the decoration carries the
  shadows and the highlight in both themes.

## Stage 2: global corners

### The rule

One user-chosen base radius drives every rounded shape in the app. No widget picks
its own radius, and nothing is a circle or a stadium by default: at the default value
the app looks like today's cards; at 0 every shape is square, island included.

### Design-system API

- Replace the static `DesignRadius` constants with a `DesignShape` `ThemeExtension`
  (read with `DesignShape.of(context)`), built from one `corner` value:
  - `xs = corner * 6/14`, `sm = corner * 10/14`, `md = corner`, `lg = corner * 22/14`
    (today's ratios, so the default `corner = 14` reproduces today's look).
  - `forHeight(double h)` = the role's radius capped at `h / 2`, so a short element
    never becomes more round than a pill and the island dot stays a dot at high values.
  - `pill` is removed. Every former `DesignRadius.pill`, `StadiumBorder`,
    `CircleBorder`, `BoxShape.circle`, `CircleAvatar` becomes a `RoundedRectangle`
    from `DesignShape` (most use `forHeight`).
- `buildTheme` (`packages/design_system/lib/design_system.dart`) takes the corner value
  and sets every Material component shape from it: filled / text / outlined / icon
  buttons, segmented button, chips, cards, dialogs, bottom sheets, tooltips, snack bars,
  input decorations, slider value indicator, list tiles' ink.
- Known exceptions must be listed in `packages/design_system/CLAUDE.md` with the reason.
  Material `Switch` and `Slider` thumbs cannot take a custom shape; replace them with
  design-system controls only if it is under an hour each, otherwise list them as the
  only allowed exceptions.

### Setting

- `ClockSettings.corner: double`, default 14, range 0..24 in steps of 2, per-field
  `fromJson` fallback, clamped on read.
- Settings > Appearance, group "Corners": a slider with a live sample (a small row of
  a button, a chip and a mini flip card that redraw as you drag) and stop labels
  `Square` at 0 and `Round` at 24. The whole app updates live.
- The app's `MaterialApp` theme is built from it (app composition root wires
  `SettingsController` state into `buildTheme`; keep `di.get` at that edge).

### Flip cards and skins

- Flip-card radius comes from the global value too (`flip_display.dart:124` already
  scales by card size: keep that scaling, swap the source).
- Remove `Skin.cardRadius`, its customizer slider (`skin_customizer.dart:278`) and the
  per-skin values in `skins.dart`. `Skin.fromJson` ignores an old `cardRadius` key
  (test it). Remove the `customize_radius` string.

### Gate

- Add a unit test that scans `lib/` of `design_system` and `flip_clock` for
  `BorderRadius.circular(`, `Radius.circular(`, `StadiumBorder`, `CircleBorder`,
  `BoxShape.circle`, `CircleAvatar` outside `DesignShape` and fails with the file and
  line. This is how "no different corners" stays true after this PR.
- Widget tests at corner 0 and 24: island, a tray action, a skin tile, a sheet and a
  flip card report the expected radius.

## Stage 3: corner chrome

### Skins and Settings back in the corners (item 4)

- Restore the corner buttons: the deleted `CornerButton` is in git
  (`git show 7c03959^:packages/design_system/lib/components/corner_button.dart`), with
  its tests and README section. Bring it back with the stage 2 shapes (no circle).
- Top-left: Skins (`Icons.palette_outlined`). Top-right: Settings. Both follow the
  island's `ChromeState`: expanded = 44 px button, dot = `cornerDot`, hidden = gone,
  morphing on the same spring and collapsing with the stage 1 collapse motion, in the
  same frame as the island.
- Remove `trailing` from `Island` and the hairline (no other caller; no speculative
  API). The island tray is only the current mode's controls, centred.
- Same tap rules as island actions: a tap on a corner button is consumed and never
  toggles the chrome.

### Rotation button (item 7)

- Bottom-right, same `CornerButton`, same chrome states.
- Shown only when `OrientationLock.supported` (Android, iOS). Web and desktop never
  show it. Pass `supported` into the screen from `flip_clock.dart` init; do not
  `di.get` in the widget.
- Tap cycles the existing `ClockSettings.orientation`: auto -> portrait -> landscape
  -> auto. Nothing new in the model; `flip_clock.dart` already applies changes through
  `OrientationLock`.
- Icon shows the current mode: auto `Icons.screen_rotation_outlined`, portrait
  `Icons.stay_current_portrait_outlined`, landscape
  `Icons.stay_current_landscape_outlined`.
- Feedback on tap: the island shows `IslandTitleHud` with the new mode name
  (`orientation_auto` / `_portrait` / `_landscape`, already in strings) and 3 dots.
- The Orientation row in Settings stays and stays in sync.
- Keyboard: `R` cycles rotation (only where supported); add to Settings > Shortcuts.

## Stage 4: clock layout

### Date above the time (item 9)

- In `_ModeView` clock mode (`flip_clock_screen.dart`, the `Column` after
  `formatFullDate`), the date line goes first, then `s6` (24), then the display, and
  the pair is centred as one block in the free space. Today it is display then a
  literal 16 px then date: replace the literal with the token.
- Nothing is reserved at the bottom (no placeholder, no empty slot).

### Stacked layout (item 8)

Applies to the clock, Pomodoro and stopwatch displays (`FlipDisplay`). Gallery tiles
and the customizer preview stay in one row.

- Groups: the display already receives `cards` as groups (HH, MM, SS). Row layout
  places groups side by side; stacked places them top to bottom, centred.
- **The rule:** compute the largest card height that fits the available box for the
  row layout and for the stacked layout (same gaps, same `CardSize.factor`). Use
  stacked when its card height is at least 1.15x the row's. Switch back to the row
  only when the row's card height is at least 1.15x the stacked one. The 15% band
  stops flicker near square windows and during resize.
- Meridiem: `left` stays inside the first card; `right` sits beside the last card of
  the last row. Seconds badge stays in the last card's corner.
- The flip animation is per card and unchanged. Switching layout cross-fades
  (`DesignMotion.fade`), reduced motion swaps instantly.
- Date (clock mode) stays above the whole stack; laps (stopwatch) stay below it.
- Tests: 390 x 844 portrait stacks, 844 x 390 landscape is a row, 600 x 640 stays as it
  was (inside the band), with seconds on and off, both meridiem sides, text scale 2.0.

## Stage 5: lap grid

- `_Laps` (`flip_clock_screen.dart`) becomes a grid: columns = as many as fit at a
  minimum cell width that fits `Lap 99  00:00:00.0` in the skin face at the current
  text scale (measure with a `TextPainter`, do not guess), at least 1.
- Order: newest first, row-major (left to right, then down).
- Height: up to 3 rows visible (and still at most a third of the panel), then the grid
  scrolls vertically.
- Cell spacing from tokens (`s2` rows, `s4` columns). Skin face, digit colour, dims with
  the digits as today.
- Tests: 1 column at 320 px, several at 1280 px; 9 laps on a wide screen show 3 rows
  with no scroll; 10+ scrolls; text scale 2.0 reduces columns, never clips.

## Stage 6: skin gallery

### Real settings in the preview (item 10)

- `SkinTile` hard-codes `showSeconds: false`
  (`features/flip_clock/lib/ui/components/skin_picker.dart`, `clockValue(...)` in
  `SkinTile.build`). Pass the user's `showSeconds` (and `use24h`, already passed) from
  `SkinPicker` and the Appearance strip, so each tile draws exactly what the clock would
  with that skin: seconds cards for `SkinSeconds.off`/`cards`, the badge for `badge`.
- Show the date line on the tile when the clock would show it (`showDate` setting or
  `skin.showDate`), small, above the cards (matches stage 4).
- Tiles stay one row (no stacking). Check three groups fit at the 196 px minimum tile
  width.

### Select vs customise (item 11)

Today: tapping a tile applies it; a single "Customize" in the sheet header edits
whichever skin is current. The link between the two is invisible.

Chosen design (see "Decisions" to change it): **select on tap, customise on the
selected tile.**

```
 ┌───────────────┐  ┌───────────────┐  ┌───────────────┐
 │   12 : 34     │  │ ✓ 12 : 34     │  │   12 : 34     │
 │               │  │               │  │               │
 └───────────────┘  └───────────────┘  └───────────────┘
  Mono      Barlow    Rose  [✎ Customize]  Amber   Barlow
```

- Tap any tile: applies the skin (as today). The selected tile gets the accent ring
  and check (as today) **and** its caption row swaps the face name for a
  `Customize` button (pencil icon + label), which opens the customizer on that skin.
- Remove the header "Customize" button; the header keeps Done and the title.
- Custom skins get the same button (it opens their editor with Delete available).
- The Appearance strip uses the same `SkinTile`, so it gets the button too.
- Accessibility: the tile announces "Rose, selected"; the Customize button is its own
  focusable button "Customize Rose". Keyboard: Enter on a focused tile applies, then
  Tab reaches Customize.
- Tests: tap applies and shows Customize only on that tile; Customize opens the
  customizer for that skin (built-in and custom); the header has no Customize.

## Strings (`clock.*`)

Add: `settings_corners`, `corners_square`, `corners_round`, `corners_value` (arg),
`action_rotation`, `key_rotation`, `keycap_r`, `skins_customize_named` (arg: skin name,
spoken). Reuse `orientation_auto/_portrait/_landscape`, `skins_customize`,
`action_skins`, `action_settings`. Remove keys left unused (`customize_radius`) and
regenerate.

## Tests the gate expects

- Island: collapse timeline (opacity holds until the shape is small), collapse has no
  overshoot, expand unchanged, reduced motion cross-fades, spacing tokens, depth
  decoration in both themes, tray centred.
- Corners: `DesignShape` ratios and `forHeight` cap; theme component shapes follow the
  value; source scan finds no stray radius; corner 0 and 24 widget checks;
  `ClockSettings.corner` round trip, clamp, fallback; old `cardRadius` JSON ignored.
- Corner chrome: Skins / Settings / Rotation follow chrome state in sync with the
  island; taps do not toggle; rotation hidden when unsupported; cycle order; HUD; `R`.
- Layout: date above with `s6`; stacking rule with hysteresis at the sizes listed.
- Laps: column count, order, 3-row scroll, text scale.
- Gallery: tiles show seconds and date per settings; select and Customize flow.

## Acceptance

- Tap to hide: the island visibly shrinks to a dot and then fades; never pops away.
- The island reads as floating above the clock on Mono (black) and Paper (light).
- Island controls have clear air between them; groups are distinguishable without lines.
- Skins top-left, Settings top-right, Rotation bottom-right (phones only), all
  appearing and disappearing with the island.
- Settings > Appearance > Corners at 0: every shape in the app is square. At 24: all
  rounded the same way. Nothing ignores it (except any exception listed in
  `design_system/CLAUDE.md`).
- Phone upright: the clock stacks hours over minutes; turned sideways: one row.
- The date sits above the time.
- 12 laps on a laptop: a grid of several columns, 3 rows visible, scrolls.
- With Show seconds on, every gallery tile shows seconds.
- In the gallery it is obvious which skin is selected and how to customise it.

## Docs to update in the same PR

`features/flip_clock/CLAUDE.md` and `README.md` (corner chrome, rotation, stacked
layout, date, laps grid, gallery flow), `packages/design_system/CLAUDE.md` and
`README.md` (`DesignShape`, corner rule and exceptions, island spacing / depth / collapse
tokens, `CornerButton` back, `Island.trailing` removed), `packages/localization` notes
if keys are listed there.

## Decisions taken for the user (change here if wrong)

- **Global corner wins over skins.** Built-in skins lose their own card radius
  (Arcade round, Minimal square). This is what "no different corners in the system"
  means; the cost is less variety between skins.
- **Rotation modes** are the three that already exist in settings: follow device,
  portrait, landscape. The button cycles them; it is hidden on web and desktop, where
  the screen cannot be locked.
- **Gallery: select on tap, Customize on the selected tile.** Alternatives considered:
  two buttons (Apply, Customize) on every tile (clear but doubles the controls on a
  20-tile grid); tap opens a full preview with Apply / Customize (one extra tap for the
  most common action); long-press to customise (invisible, same problem as today).
- **Stacked threshold** is 1.15x with the same 15% band back. Tune after using it.
- **Lap order** newest first, row-major, matching the list it replaces.
- **Gallery seconds follow the skin, not Show seconds** (changed after
  review, 2026-10-01). A tile shows seconds only when that skin is
  configured to (`cards` or `badge`), because selecting it applies that
  preset; Show seconds does not turn them on in every preview. This
  replaces item 10's "seconds show in the preview when they show on the
  clock".
