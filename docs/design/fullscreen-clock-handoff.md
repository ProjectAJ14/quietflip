# Full-screen clock, seamless island, press-down taps (feedback round 4): handoff

Base: `main` at 019857f (settings sync shipped).
Previous briefs, still valid where this one is silent:
`docs/design/settings-sync-handoff.md`, `docs/design/sound-picker-handoff.md`,
`docs/design/island-feedback-3-handoff.md`, `docs/design/island-control-hub-handoff.md`,
`docs/design/multi-skin-handoff.md`.

Design source: the layouts in this file and the user's four screenshots (iPhone
portrait stacked clock, iPhone landscape row clock, iPhone landscape Settings >
Appearance).

This is the brief for the coding agent. Follow the repository `CLAUDE.md` and the
nested `CLAUDE.md` files on the path (`features/flip_clock`, `packages/design_system`,
`packages/device_services`, `packages/localization`, and `features/auth` for the
button swap): dependency direction, 100% line coverage, strings through i69n, colours
and shapes from the design system, generated files read-only. Load the
`design-system` and `flutter-best-practices` skills before any UI work.

## The feedback, verbatim intent

1. The clock must sit in the centre of the screen.
2. Even Large digits look small on iPhone: the gap the island leaves is wasted. The
   clock fills the whole screen; the island floats over (stacked above) the digits.
3. Switching mode (Stopwatch to Clock) makes the island shrink to a name and 3 dots,
   then reopen. It must change straight into the next mode's island, no shrinking.
4. Swiping shows that strange name and 3 dots. It must not appear.
5. The Orientation setting moves to Appearance.
6. Settings in landscape shows a gap on the left and right. Remove it.
7. Tapping tick sounds quickly lags and sometimes fails to pick the next sound.
8. No ink ripple anywhere. Every tap in the app is a press-down: the thing shrinks
   while the finger is down and springs back when it lifts.
9. That press-down is one core component in the design system, and every tappable
   thing uses it. Nothing repeats it; everything is a core component.
10. Shortcuts follow the platform: keyboard keys on desktop and web, touch gestures on
    iPhone and iPad, each with a small animated gesture icon (like macOS trackpad
    settings).
11. In the skin gallery, some Classic skins show seconds.
12. The selected skin is always shown first, so it is easy to customise.
13. In Appearance: Theme first, then Skins.

## Delivery order

One pull request, one commit (or more) per stage, in this order. Bugs first, then
the press component (every later UI stage is born on it), then layout and settings.
Run `dart run melos run lint` and `dart run melos run coverage` after each stage.

1. **Tick sound lag** (item 7). `device_services` and the Sound picker.
2. **Island changes mode in place** (items 3, 4). `flip_clock` screen and `Island`.
3. **Settings landscape edges** (item 6). `SettingsShell` and `SettingsScreen`.
4. **Press-down core component** (items 8, 9). `design_system`, then every caller.
5. **Clock fills the screen** (items 1, 2). `_ModeView`.
6. **Appearance order and Orientation** (items 5, 13, and the strip half of 12).
7. **Skin gallery** (items 11, 12).
8. **Platform shortcuts with gesture icons** (item 10).

## Stage 1: tick sound lag

### Root cause

- **Verified in code:** `AudioSoundPlayer.playTick`
  (`packages/device_services/lib/src/sound/audio_sound_player.dart:34`) calls
  `_flip.play(AssetSource(file))` on one shared `AudioPlayer`. In audioplayers 6.8.1
  `play` always runs `setSource` then `resume` (`audioplayer.dart:195-224`), and
  `setSourceAsset` resolves the cache path and waits for the native `prepared` event
  (`_completePrepared`, `audioplayer.dart:358`). So every tick, even the same file
  every second on the clock, reloads the file into the native player before it
  sounds. Rapid taps start several overlapping `setSource` calls on one player; each
  waits on the same `_onPrepared` stream, so an earlier source's `prepared` can
  release a later call and the wrong sound (or nothing) plays.
- **Hypothesis:** the "fails to select" half is frame jank, not a lost tap. Each tap
  emits new settings, which rebuilds the whole Settings category (both sound groups,
  ten `SoundWave`s) and starts a save plus a sync write. Confirm in profile mode on an
  iPhone: DevTools timeline while tapping five tiles 150 ms apart; record frame times
  and whether every tap's `onTap` ran. If every `onTap` ran, the selection was never
  lost, only drawn late.

### Fix

- `AudioSoundPlayer` keeps one `AudioPool` per `TickSound` (audioplayers' own pool
  for short repeated sounds, already a dependency): created lazily on the first
  `playTick` of that sound, `maxPlayers: 2`, from the package `AudioCache`. `playTick`
  = `pool.start()`. Keep the stop function of the last tick and call it before
  starting a different sound, so a quick change never layers two sounds.
- Pre-warm the selected tick's pool when the tick sound is on (call from
  `flip_clock.init` through a new `SoundPlayer.warmTick(TickSound)`; contract change,
  update both fakes). The first tick of the session then has no load delay either.
- `dispose` disposes every pool. Pool creation failures go through `guarded` and the
  injected `Logger`, as today.
- `_pickTick` (`features/flip_clock/lib/ui/screens/settings_screen.dart:140`) builds
  from `widget.settings.state`, not the `s` captured at build, so two taps inside one
  frame never write a stale copy over a newer change.
- If the profile confirms jank: give each sound group its own `BlocBuilder` with
  `buildWhen` on its fields (`tickSound`, `flipSound` / `alarmSound`, `alertSound`) so a
  pick rebuilds one group, not the category.

### Tests

- Fake pool factory injected into `AudioSoundPlayer`: ten rapid `playTick` calls across
  three sounds create three pools, each sound plays once per call, and a switch stops
  the previous sound first. Failure is logged, not thrown. Dispose releases all pools.
- Settings: two taps in one frame both land; the second wins and keeps a field changed
  between them.
- Acceptance on a device: tap the five tick tiles as fast as possible, 3 rounds; every
  tap shows its ring and plays its own sound within one frame of the tap.

## Stage 2: island changes mode in place

### Root cause (verified)

- A swipe ends in `GestureLayer._onEnd`
  (`features/flip_clock/lib/ui/components/gesture_layer.dart:128-133`), which calls
  `onPage(target)` **even when the swipe snaps back to the same page**. The screen's
  `onPage` (`flip_clock_screen.dart:601`) and the arrow keys (`_stepMode`, line 225)
  call `_modeHud`, which shows `IslandTitleHud` (mode name plus 3 page dots). A HUD
  wins over the expanded state in `Island._height` (`island.dart:156`), so the open
  island shrinks to the small HUD pill, shows "Clock • • •", and after `hudHold`
  grows back. That is both the "minimise then reopen" and the "strange name and three
  dots" the user saw.
- The rotation button does the same (`_cycleRotation`, line 280): its HUD collapses
  the open island too.
- Tapping a tab never shows the HUD, so tabs already behave; only swipe, arrow keys
  and rotation break.

### Fix

- Delete `_modeHud` and the rotation HUD. A mode change, from any source, only sets
  the mode. If the island is expanded it stays expanded and morphs in place: the
  selected tab moves, the tray swaps, the height follows. If it is a dot or hidden it
  stays so; the panel slide is the feedback.
- `GestureLayer` calls `onPage` only when the target page differs from the start page.
- Rotation feedback is the corner button's icon (it already shows the mode) plus a
  `Semantics(liveRegion: true)` label on the button naming the new mode for screen
  readers.
- `IslandTitleHud` then has no caller: remove it, its painter code (`_title`,
  `hudDot`) and its tests (no speculative API). `IslandBrightnessHud` stays.
- **Sliding tab indicator** so the change reads as one motion:
  - All tabs share one width: the widest label, measured with a `TextPainter` in
    `labelLarge` at the current text scale, plus `islandItemPadding` on both sides.
  - One selected pill sits behind the row and slides to the new index with
    `AnimatedPositioned` on `DesignMotion.islandMorph` / `islandCurve` (460 ms
    spring). Label colours cross-fade over `DesignMotion.fade` (180 ms).
  - The tray content swap keeps its `AnimatedSwitcher`; the height morph keeps its
    `AnimatedSize`. Both run in the same frame as the slide.
  - Reduced motion: the pill jumps, colours swap, no size animation (as today).

### Tests

- Swipe Stopwatch to Clock with the island expanded: no frame shows a HUD; the island
  height never drops below the smaller of the two modes' expanded heights (pump in
  16 ms steps across `islandMorph`).
- A swipe that snaps back calls no `onPage`.
- Arrow key and rotation button: no HUD; rotation icon and semantics label update.
- The pill's left edge at the end of the slide equals index x (tab width + gap); tabs
  are equal width at text scale 1.0 and 2.0.

## Stage 3: Settings landscape edges

### Root cause (verified)

- `SettingsScreen` wraps the whole shell in `SafeArea`
  (`features/flip_clock/lib/ui/screens/settings_screen.dart:191`). In iPhone landscape
  the left and right safe insets (about 59 pt each) become bare `bg` strips: on the
  left a black bar beside the grey sidebar, on the right the inset plus the detail
  pane's own `s8` (32) padding (`settings_shell.dart:355`, `_Detail(padding: s8)`).
  The screenshot measures about 54 pt and 83 pt.

### Fix, in `SettingsShell` (every Settings caller routes through it)

- `SettingsScreen` uses `SafeArea(left: false, right: false)`; the shell owns the
  horizontal insets.
- Split view: the sidebar fill runs to the left screen edge; its list padding is
  `inset.left + s3`. The detail pane runs to the right edge; its horizontal padding is
  `max(s8, inset.right)` (the inset replaces the padding, it does not add to it).
- Phone view: list padding `max(s4, inset.left)` / `max(s4, inset.right)`, same rule.
- Read the insets from `MediaQuery.paddingOf(context)` inside the shell.

### Tests

- 852 x 393 with 59 pt side insets: sidebar colour at x = 0; the first group card's
  right edge at 852 - 59; nothing paints `bg` left of the sidebar.
- No insets: unchanged layout (existing tests stay green).

## Stage 4: press-down core component

### The rule

Every tappable thing in the app is a `Pressable` from `design_system`, or a
design-system component built on it. No ink ripple, no highlight wash, anywhere.

### `Pressable` (`packages/design_system/lib/components/pressable.dart`)

| Behaviour | Value |
| --- | --- |
| Scale while pressed | `DesignMotion.pressScale` = 0.96 (0.92 for children 48 px or smaller, `pressScaleSmall`) |
| Press in | `DesignMotion.pressIn` = 90 ms, `Curves.easeOut`, starts on pointer down (no tap delay) |
| Release | `DesignMotion.pressOut` = 180 ms, `Curves.easeOutCubic`, no overshoot |
| Fires | on pointer up inside the tap slop, like a tap; dragging off cancels and releases without firing |
| Scroll safety | inside a scrollable, a press that becomes a scroll releases without firing (standard `TapGestureRecognizer` arena) |
| Keyboard | focusable; Enter and Space fire it with a 90 ms press-and-release; focus ring = 2 px `DesignColors.accent` outline at the child's corner (`DesignShape`) |
| Hover (pointer devices) | click cursor only; no wash |
| Disabled (`onTap == null`) | no scale, not focusable, `Semantics(enabled: false)` |
| Semantics | `button: true` (overridable for radios, tabs), label passthrough, `onTap` action |
| Reduced motion | no scale; a 90 ms opacity dip to 0.7 instead, so the press is still felt |
| Haptics | none (not asked for) |

API: `Pressable({required Widget child, VoidCallback? onTap, VoidCallback? onLongPress,
String? semanticsLabel, bool selected, SemanticsRole? role, BorderRadius? focusRadius})`.
Nothing else; add parameters only when a caller needs one.

### Buttons on top of it

`AppButton` in `design_system` replaces Material buttons: `AppButton.text`,
`AppButton.filled`, `AppButton.outlined`, `AppButton.icon`, each with optional
leading icon. Colours, text style, padding, min size 44, and shape come from the
theme roles and `DesignShape` exactly as the current `buildTheme` button themes
define them (move those values, do not invent new ones). Each is a `Pressable`
around a decorated box.

Replace every use (counted on base): `TextButton` 16, `FilledButton` 5,
`OutlinedButton` 2, `IconButton` 2; `InkWell` in `island.dart` (3),
`settings_shell.dart` (3), `skin_picker.dart` (2), `skin_customizer.dart` (2),
`account_page.dart` (2), `settings_screen.dart` (1), `file_info_dialog.dart` (1); the
`GestureDetector` tap in `features/auth/lib/ui/components/footer_builder.dart:59`.
`SwitchListTile` (customizer, 2): the row becomes a `Pressable` row with the
design-system switch row used in Settings.

### Theme

`buildTheme` sets `splashFactory: NoSplash.splashFactory`, `highlightColor`,
`splashColor` and `hoverColor` transparent, and `overlayColor` transparent on switch,
slider, segmented button and any remaining Material component, so third-party
screens (FirebaseUI sign-in, `showLicensePage`) lose the ripple too.

### Gate

`packages/design_system/test/press_rule_test.dart` (same scanner as
`features/flip_clock/test/corner_rule_test.dart`): fails with file and line on
`InkWell(`, `InkResponse(`, `TextButton`, `FilledButton`, `OutlinedButton`,
`ElevatedButton`, `IconButton(`, `ListTile(` with `onTap`, `SwitchListTile`, or
`GestureDetector(` with `onTap` in the `lib/` of `design_system`, `flip_clock` and
`auth`, outside `pressable.dart` and `app_button.dart`. Allowed exceptions, listed in
`packages/design_system/CLAUDE.md` with the reason: `gesture_layer.dart` (drags, not
taps), `features/dashboard` (generator demo, not shipped UI),
`packages/developer` (debug tools).

### Tests

- `Pressable`: scale is 0.96 while held and 1.0 after release; 0.92 for a 44 px child;
  fires on up, not on down; drag-off cancels; scroll does not fire; Enter and Space
  fire; disabled ignores all; reduced motion dips opacity, no scale; semantics.
- `AppButton`: each variant's colours and shape match the old theme at corner 0 and 24.
- No `InkSparkle` / `InkRipple` in the tree after a tap on a tray action, a nav row, a
  skin tile, a sound tile and a sheet button.

## Stage 5: clock fills the screen

### Root cause (verified)

`_ModeView` (`flip_clock_screen.dart:850-867`) pads the digits by the expanded
island: `top = islandPlace.top + Island.trayHeight + inset`, about 196 pt on a phone
(cap: a third of the height), and `bottom` about 76 pt for the Rotation button. On an
iPhone 15 Pro (759 pt safe height) the cards get about 490 pt and the block sits
lower than centre (196 top against 76 bottom). Measured on the screenshots: stacked
cards about 138 pt now, about 240 pt with two groups.

### Fix

- The chrome is a layer over the clock. `_ModeView` pads symmetrically: `s4` (16) on
  every side under 400 pt shortest side, `s8` (32) above, inside the safe area. No
  term for the island, the corner buttons or the Rotation button.
- The display (and the date / laps column) centres in that box both ways.
- The expanded island, corner buttons and Rotation button draw over the top and
  bottom cards. The island's surface and elevation (round 3) keep it readable; it
  collapses after `controlsIdle` as today.
- The full-screen note keeps its place under the island (unchanged).
- Remove `_islandPlace`'s use in `_ModeView` and the quarter / third caps; keep
  `_islandPlace` for the island itself.

Expected sizes (Large, 24 pt gaps):

| Device, layout | Cards today | After |
| --- | --- | --- |
| iPhone 15 Pro portrait, H:M:S stacked | ~138 pt | ~226 pt |
| iPhone 15 Pro portrait, H:M stacked | ~240 pt | ~351 pt (width-bound) |
| iPhone 15 Pro landscape, H:M row | ~260 pt | ~339 pt |

### Tests

- 393 x 852 with phone insets: the display's centre equals the safe area's centre
  (±1 px) in clock, timer and stopwatch modes, island expanded and hidden.
- Card height at the sizes in the table (±2 px).
- Layout does not change when the chrome expands, collapses or hides (no reflow).
- 320 x 568 and text scale 2.0 still fit, date included.

## Stage 6: Appearance order and Orientation

New Settings > Appearance, top to bottom:

| Group | Rows |
| --- | --- |
| (no header) | Theme; Orientation (only where `orientationSupported`) |
| Skins | skin strip; View all |
| (no header) | Card size; Digit brightness |
| Corners | sample; slider |

- Move the Orientation row from `_clock` (`settings_screen.dart:357`) unchanged.
- The skin strip always starts with the selected skin, then the others in gallery
  order without it, five in total (`_strip`, `settings_screen.dart:427`, today only
  when the selected skin is outside the first five).
- Tests: group and row order; Orientation absent when unsupported and absent from
  Clock; strip starts with the selected skin for a skin inside and outside the first
  five.

## Stage 7: skin gallery

### Classic skins with seconds (item 11)

| Skin | Seconds |
| --- | --- |
| Mono | off (unchanged: it is the default) |
| Paper | badge |
| Violet | cards |
| Amber | cards |
| Cyan | badge |
| others | off (unchanged) |

Selecting one turns Show seconds on through the existing `selectSkin` rule.

### Selected skin first (item 12)

```
 IN USE
 ┌───────────────┐
 │ ✓ 12 : 34  56 │  Violet   [✎ Customize]
 └───────────────┘
 YOURS   [ + New ] ...
 CLASSIC [Mono] [Paper] [Violet ✓] [Rose] ...
```

- A new first section, "In use", holds one tile: the selected skin, with its ring,
  check and Customize button (the round 3 tile, same width as the grid's tiles).
- The sections below keep their order and keep the selected tile ringed in place, so
  tiles never reflow under the finger on a tap.
- Selecting another tile swaps the "In use" tile with a `DesignMotion.fade`
  cross-fade (instant with reduced motion).
- Tests: "In use" shows the selected skin first for built-in and custom skins; tapping
  a tile updates it; tile positions below do not move after a tap.

## Stage 8: platform shortcuts with gesture icons

### Which shortcuts show

| Platform (`defaultTargetPlatform`, so phone web counts as touch) | Groups |
| --- | --- |
| iOS, Android, shortest side < 600 | Touch |
| iOS, Android, shortest side >= 600 (iPad, tablets) | Touch, then Keyboard |
| macOS, Windows, Linux | Keyboard (today's list) |

- Category icon: `Icons.touch_app_outlined` when Touch is the first group, else
  `Icons.keyboard_outlined`. Label stays "Shortcuts".
- Pass the platform in as a value (`touchShortcuts`, `keyboardShortcuts`) from the
  router, like `orientationSupported`; no platform checks inside the widget.

### Touch rows

| Icon animation | Label | Shown |
| --- | --- | --- |
| tap | Show or hide controls | always; trailing "Off" when Tap to show controls is off |
| swipe sideways | Change mode (`key_change_mode`) | always; "Off" when Swipe sideways is off |
| swipe up / down | Brightness (`key_brightness`) | always; "Off" when the brightness swipe is off |

Double tap is not listed: it is desktop and web only.

### `GestureGlyph` (`design_system`)

A `SettingsShell.iconTileSize` tile (same as the category icons) with a 10 px
fingertip dot in `ink` on `surfaceRaised`, painted with a `CustomPainter`:

| Kind | Loop (1600 ms) |
| --- | --- |
| `tap` | dot presses (scale 1 to 0.7, 0-150 ms), a ring grows 10 to 28 px and fades (150-600 ms), rest |
| `swipeHorizontal` | dot fades in at left (0-150 ms), travels 18 px right with `easeInOutCubic` and a fading trail (150-750 ms), fades out (750-900 ms), rest; next loop goes right to left |
| `swipeVertical` | same, upward, then downward on the next loop |

- Runs only while visible (`TickerMode`); one controller per glyph, disposed.
- Reduced motion: a still frame with a small arrow in the swipe direction (tap: the
  ring at mid size).
- Semantics: excluded; the row's label says what the gesture does.

### Tests

- Each platform shows its groups (iOS phone, iPad size, macOS, web on iOS).
- "Off" follows each gesture setting.
- Glyph paints each kind at 0, 400, 800 ms; stops ticking offstage; reduced motion
  draws the still frame.

## Strings (`clock.*`)

Add: `skins_in_use` ("In use"), `shortcuts_touch` ("Touch"), `shortcuts_keyboard`
("Keyboard"), `touch_controls` ("Show or hide controls"), `shortcut_off` ("Off").
Reuse: `key_change_mode`, `key_brightness`, `orientation*`, `skins_customize`,
`skins_customize_named`. Remove any key left unused after the HUD removal and
regenerate.

## Data and migrations

None. No settings field is added or removed. Built-in Classic skins change their
seconds preset; a user who already has one selected keeps their saved Show seconds
until they pick a skin again.

## Tests the gate expects

- Sound: pooled ticks, no layering, failure logged, dispose; stale-state pick fixed.
- Island: no HUD on swipe, arrows or rotation; snap-back fires no page change; sliding
  pill; equal tab widths; `IslandTitleHud` gone.
- Settings shell: landscape insets fill to the edges; no-inset layout unchanged.
- Press: `Pressable` behaviour table, `AppButton` variants, no ink in the tree, the
  source-scan gate.
- Clock: centred, card sizes, no reflow on chrome change, tiny window and text scale.
- Appearance: group order, Orientation moved, strip starts with the selection.
- Gallery: Classic seconds presets, "In use" section, no reflow on tap.
- Shortcuts: per-platform groups, "Off" states, glyph frames and reduced motion.

## Acceptance

- iPhone portrait and landscape: the clock is in the true centre and visibly larger
  (H:M stacked cards about 1.5x today's); the island floats over the top card.
- Swipe between all three modes with the island open: it never shrinks, never shows
  a name with dots; the selected pill slides to the new tab.
- Swipe a little and let it snap back: nothing happens in the island.
- Settings in iPhone landscape: the sidebar colour reaches the left edge; no black
  strip; the right margin is the safe area only.
- Tap the five tick sounds as fast as possible: each one rings and sounds at once.
- Tap anything (tabs, tray buttons, corner buttons, settings rows, tiles, sheet
  buttons, sign-in): it presses down and springs back; no ripple anywhere.
- Appearance shows Theme (and Orientation on phones) first, then Skins.
- Gallery opens with the selected skin first; Paper, Violet, Amber and Cyan show
  seconds.
- iPhone Settings > Shortcuts shows animated touch gestures; iPad shows touch then
  keys; Mac shows keys.

## Docs to update in the same PR

`packages/design_system/CLAUDE.md` and `README.md` (`Pressable`, `AppButton`,
`GestureGlyph`, press tokens, the press rule and its exceptions, `IslandTitleHud`
removed, sliding tab pill, shell inset rule), `features/flip_clock/CLAUDE.md` and
`README.md` (chrome overlays the clock, mode change without HUD, Appearance order,
gallery "In use", platform shortcuts), `packages/device_services/CLAUDE.md` and
`README.md` (pooled ticks, `warmTick`), root `CLAUDE.md` only if a command changes.

## Decisions taken for the user (change here if wrong)

- **The island covers the top card while open.** That is what "stacked above the
  digits" buys: about 1.5x larger digits. Cost: for the few seconds the island is open,
  the top of the hours card is hidden. Rejected: shrinking the digits while the island
  is open (the clock jumps every tap).
- **No mode HUD at all**, even when the chrome is hidden: the sliding panel is the
  feedback. Cost: a swipe with the chrome hidden shows no mode name. Rejected: wake the
  island on every swipe (it opens over the clock the user just wanted clean).
- **Rotation HUD removed too**: same collapse defect; the button's icon carries the
  state.
- **Press scale 0.96 (0.92 for 48 px and smaller)**, 90 ms in, 180 ms out, no bounce.
  Tune after using it on a device.
- **One `AppButton` family replaces Material buttons**, so the press rule is one
  component and the gate can enforce it. Cost: about 30 call sites change in one stage.
  Rejected: keeping Material buttons with the ripple turned off (no press-down
  possible on them).
- **Classic seconds** on Paper, Violet, Amber and Cyan (two cards, two badge); Mono,
  the default, stays without.
- **Selected skin shown twice** ("In use" plus its ringed place in its section), so a
  tap never reorders the grid under the finger.
- **iPad shows both** touch and keyboard shortcuts (many iPads have a keyboard).
- **Gestures turned off still list, marked "Off"**, so people learn they exist.
- **Tick jank fix is conditional**: the per-group rebuild ships only if the profile
  shows frame drops; the audio pool ships regardless.
