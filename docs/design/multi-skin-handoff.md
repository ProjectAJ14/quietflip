# Multi-skin design system: handoff

Design source of truth (tokens, live previews, brand book): https://claude.ai/artifact/DeKZuGwFaBhcDchFfJM2FN
Decisions confirmed 2026-09-30: fourth panel is Stopwatch (order Pomodoro, Clock, Timer, Stopwatch); island sits bottom centre.


This section is the brief for the coding agent. It maps every design in this system to the QuietFlip repository (`packages/design_system`, `packages/device_services`, `features/flip_clock`, `packages/localization`). Follow the repository's `CLAUDE.md` rules: dependency direction, 100% coverage, strings through i69n, no raw colours in widgets, generated files read-only.

## Delivery order

Ship as ONE pull request, built in five stages, one commit (or more) per stage, in this order. Run `dart run melos run lint` and `dart run melos run coverage` after each stage so a break is caught where it starts; the PR opens only when all five are done and both pass:

1. **Mono theme and fonts.** Geist becomes `bodyFont` and `displayFont`. `DesignSystem.blackScheme()` becomes the Mono Dark scheme (`bg` #000000, `surface-raised` #1c1c1e, `ink` #ffffff, `ink-muted` #a1a1a1, `hairline` #2c2c2e, `accent` #ffffff, `on-accent` #000000); add a Mono Light scheme with the `light` values. Default `AppearanceMode.black`. Bundle Geist 400/500/600/700 and every skin face (one weight each) under `assets/google_fonts/` with `OFL.txt`; delete Open Sans. Add a `DesignSize` and `DesignMotion` constants class for the `size-*` and `dur-*` tokens.
2. **Skins.** A `Skin` model and a skin catalogue in `features/flip_clock` (skins are product data, not shared UI). `FlipDisplay` takes a `Skin` instead of reading the theme for its face. Skins picker sheet and Customize sheet.
3. **Chrome.** `ChromeController` (Cubit) with states `expanded`, `dot`, `hidden` plus a transient `hud`; `Island` and `CornerButton` widgets in `design_system` (product-agnostic: they take tabs, icons and callbacks). Replaces the current top bar and `Reveal` / `_WithControls`.
4. **Gestures.** One `GestureLayer` over the clock screen: tap, vertical drag (brightness), horizontal swipe (modes). A `ScreenBrightness` contract in `device_services`. Modes become a `PageView`: Pomodoro, Clock, Timer, Stopwatch.
5. **Settings.** Adaptive `SettingsShell` (phone stack, tablet split, desktop sidebar) and grouped rows in `design_system`; the settings content in `features/flip_clock`.

## Data model

`ClockSettings` gains, each with a default and a per-field `fromJson` fallback like the existing fields:

| Field | Type | Default |
| --- | --- | --- |
| `skinId` | `String` | `'mono'` |
| `customSkins` | `List<Skin>` | `[]` |
| `gestureBrightness` | `bool` | `true` |
| `gestureModes` | `bool` | `true` |
| `tapToggleControls` | `bool` | `true` |
| `controlsIdle` | `Duration` | 4 s (choices 2, 4, 8 s, Never) |

- `ClockMode` gains `pomodoro` (first). Pomodoro moves out of the Timer panel into its own panel; the countdown engine stays shared.
- `ClockTheme` is replaced by the theme choice Dark / Light / Match system. Migrate: `black` -> Dark, `light` -> Light.
- `Skin` fields: `id`, `name`, `face` (enum of bundled faces), `digitColor`, `cardColor`, `groundColor` (ARGB ints in JSON), `seam` bool, `cardRadius` (0..32), `seconds` (off, badge, cards), `meridiem` (hidden, left, right), `showDate` bool. A missing or unknown `skinId` falls back to Mono.
- Skin colours are user data, so they are the one place a `Color(int)` is built from a value; the built-in catalogue reads the `skin-*` values listed in this system.

## Brightness contract

`device_services` gets `abstract interface class ScreenBrightness { bool get supported; Future<double> current(); Future<void> set(double value); Future<void> reset(); }`.

- iOS and Android: implement over the `screen_brightness` plugin (app-scoped brightness). `reset()` on pause, detach and dispose, so the device is never left dim.
- macOS, Windows, web: `supported == false`; the vertical gesture drives `ClockSettings.digitBrightness` (the existing in-app dim) instead.
- Failures surface as the package's typed exception and are logged through the injected `Logger`; the gesture then falls back to in-app dim.

## Gesture rules to implement

- One `RawGestureDetector` at the screen root; axis lock after 12px; the dominant axis wins.
- Vertical: `delta = -dy / screenHeight`; clamp 0..1 (device) or 0.2..1 (in-app).
- Horizontal: next or previous page at 25% width or fling above 600 px/s; `PageView` physics otherwise. No wrap-around.
- Taps on controls are consumed by the control; a tap anywhere else toggles the chrome.
- Off while any sheet or route covers the clock and while the timer input has focus.

## Chrome timing

- Idle timer restarts on every pointer event, key or gesture.
- `expanded` -> `dot` after `controlsIdle` (4 s). `dot` -> `hidden` after 3 s.
- `hud` holds 1.2 s after the gesture ends, then returns to the previous state.
- Morph spring `SpringDescription(mass: 1, stiffness: 320, damping: 26)`; content fade 180 ms, 60 ms delay. `reducedMotion(context)` -> cross-fade only.

## Strings to add (`clock.*`)

`skins_title`, `skins_customize`, `skins_done`, `skins_yours`, `skins_classic`, `skins_bold`, `skins_type`, `skins_new`, `customize_title`, `customize_font`, `customize_digits`, `customize_card`, `customize_ground`, `customize_shape`, `customize_seam`, `customize_seconds`, `customize_seconds_off`, `customize_seconds_badge`, `customize_seconds_cards`, `customize_meridiem`, `customize_save`, `customize_reset`, `customize_delete`, `mode_pomodoro`, `mode_clock`, `mode_timer`, `mode_stopwatch`, `brightness_value` (with a percent arg), `settings_appearance`, `settings_clock`, `settings_gestures`, `settings_timers`, `settings_sound`, `settings_awake`, `settings_shortcuts`, `settings_about`, `gesture_brightness`, `gesture_modes`, `gesture_tap`, `gesture_idle`, `gesture_footer`, `theme_dark`, `theme_light`, `theme_system`, plus one name per built-in skin.

## Tests the gate expects

- `Skin` JSON round trip, unknown face, bad colour, missing fields; migration from `ClockTheme`.
- `ChromeController`: tap toggles, idle collapse to dot then hidden (fake async over more than 7 s), HUD returns to the prior state, reduced motion.
- Gestures: axis lock, threshold and fling, no wrap, off while a sheet is open, brightness clamp, fallback when unsupported, `reset()` on pause.
- Settings shell at 375, 820 and 1280 widths; both themes; text scale 2.0 has no overflow.
- Fonts: a test that every face in the catalogue has an asset declared in `pubspec.yaml`.

## Acceptance

- Launch shows only the digits after 7 s of no input, Mono skin, Geist UI.
- No network request for fonts on any platform (check with the network inspector in a web build).
- Brightness returns to the system value when the app is backgrounded on iOS and Android.
- Every built-in skin passes 4.5:1 digits-on-card contrast (large-text 3:1 is the floor, 4.5 is the target).

# Design rules (copy of the brand book)

QuietFlip is a calm, ad-free flip clock. The screen belongs to the time. Everything else (controls, settings, feedback) lives in one small black island that grows when you need it and shrinks back to a dot, then to nothing.

## Principles

- **The clock is the whole screen.** When nobody is touching the device, only the digits show. No bars, no badges, no banners, no ads, no locks.
- **One place for everything that moves.** Mode tabs, the brightness level and the mode name after a swipe all appear inside the island. Nothing else pops up over the clock.
- **Gestures first, buttons second.** Swipe up or down to change brightness, swipe sideways to change mode, tap to show or hide the controls. Every gesture also has a visible control and a keyboard shortcut.
- **Mono by default.** The default is a black-and-white system: `bg` black, `ink` white, `accent` white. Colour arrives only through the skin the person picks.
- **Skins are the personality, the chrome is not.** A skin changes the digits, cards and ground. The island, corner buttons and settings never take the skin's colour.

## Content

- Sentence case everywhere: "Show seconds", "Change skin". Section headers are the only uppercase (`section` style).
- Short verbs for actions: "Done", "Customize", "Save skin", "Reset".
- Talk to the person as "you" in explanations: "Swipe up or down anywhere to change brightness."
- No exclamation marks, no emoji, no marketing words ("Pro", "VIP", "Unlock").
- Numbers use tabular figures; durations read "25 min", "5 min"; percent without a space: "72%".
- Every string goes through `strings.*` (i69n). The copy in these previews is the proposed English.

## Colour

- The app ships two chrome themes: **Mono Dark** (default, `dark`) and **Mono Light** (`light`). Settings > Appearance > Theme: Dark, Light, Match system. Default is Dark even when the OS is light.
- Clock screen: ground `bg`, cards `card`, digits `ink`, seam `card-seam`. A skin replaces exactly these four roles and nothing else.
- Chrome: island and corner buttons use `island`, labels `island-ink`, inactive tabs `island-ink-muted`, the selected tab `island-active` with `island-on-active` text. The island is dark in both themes, like hardware.
- Settings: page `bg`, cells `surface-raised`, separators `hairline`, labels `ink`, values `ink-muted`, headers `ink-subtle`.
- `accent` is the only interactive colour: switch on, slider fill, selected skin ring, focus ring (2px, 2px offset). It is white in dark and near-black in light, so it holds 3:1 or better on every surface.
- `danger` is for destructive rows only, and always with a word.
- Skin colours (`skin-*`) are digit and card colours only. Never use them for chrome or text.

## Type

- Interface: **Geist** (`ui`) for every label, title and row. It replaces Open Sans as the app font.
- Digits: **Barlow Condensed 700** (`digits`) is the default skin face. Size the digit at 0.78 x card height (`digit-xl`, `digit-l`, `digit-m`, `digit-tile`).
- Skin faces, each one weight, all bundled: Bebas Neue, Anton, Oswald 600, Big Shoulders Display 800, Archivo Black, JetBrains Mono 700, Space Grotesk 700, DM Serif Display, Orbitron 700.
- **Every font ships inside the app.** No runtime download on any platform. Keep `GoogleFonts.config.allowRuntimeFetching = false`; bundle each family's `.ttf` (OFL) in `packages/design_system/assets/google_fonts/`.
- AM/PM is plain text (`meridiem`, `ink-muted`), never a card. Small seconds use `seconds-badge`.

## Layout and shape

- Flip cards: `radius-md` below 160px digits, `radius-lg` above. Gap `space-3` inside a pair, `space-6` between pairs. The seam is a 2px `card-seam` line at exactly half height.
- Island: centred at the bottom, `space-6` above the safe area (bottom-centre keeps it away from the camera notch and thumbs reach it). Corner buttons sit `space-4` (phone) or `space-6` (tablet, desktop) inside the safe area.
- Settings: grouped inset lists with `radius-sm` cells, `space-8` between groups; see SettingsShell for the three layouts.
- Hit targets are at least `corner-button` (44px), even when the visible dot is 6px.

## The chrome: island and corners

The chrome has three states, shared by the island and both corner buttons:

| State | Island | Corners | Enters when |
| --- | --- | --- | --- |
| Expanded | 52px pill with the mode tabs | 44px round buttons (Skins left, Settings right) | A tap anywhere while hidden or dotted; any key; pointer moves on desktop |
| Dot | 10px dot | 6px dots | `dur-controls-idle` (4s) with no input while expanded |
| Hidden | nothing | nothing | `dur-dot-idle` (3s) more with no input; or a tap while expanded |

- Tap toggles: hidden or dot -> expanded; expanded -> hidden. A tap on a control does not count as a toggle.
- Transient HUD: during a gesture the island morphs into a 36px pill showing brightness or the mode name, holds `dur-hud-hold` after release, then returns to the state it came from (a hidden island returns to hidden).
- Motion: every morph is one shape changing size and radius, never a fade-swap. Spring with a small overshoot: Flutter `SpringDescription(mass: 1, stiffness: 320, damping: 26)`; on the web `cubic-bezier(.32,.72,0,1)` over `dur-island-morph`. Content inside fades over `dur-fade`, starting 60ms after the shape.
- Collapse goes expanded -> dot (shape shrinks to the dot at its own centre) -> fade. Corners shrink toward their corner.
- Reduced motion: no springs and no flips; states cross-fade over `dur-fade`.
- Screen readers: when hidden, the whole clock is one "Show controls" button. The island's tabs are a tab bar with the selected mode announced.

## Gestures

| Gesture | Where | Does | Feedback |
| --- | --- | --- | --- |
| Tap | Anywhere on the clock screen | Show / hide controls | Island and corners morph |
| Vertical drag | Anywhere on the clock screen | Brightness: up brighter, down dimmer. Full screen height = 100% change | Island HUD: sun icon, bar, percent |
| Horizontal swipe | Anywhere on the clock screen | Previous / next mode: Pomodoro, Clock, Timer, Stopwatch. No wrap | Panel slides, island HUD shows the mode name and dots |
| Double tap | Clock screen | Full screen on / off (desktop, web) | Existing full-screen note |

- Axis lock: decide the axis after 12px of movement; whichever axis moved more wins for the rest of the drag.
- Mode change fires at 25% of the width or a fling above 600 px/s; below that it springs back.
- Brightness: the device brightness on iOS and Android, restored when the app goes to the background or closes. On macOS, Windows and web the same gesture changes the in-app digit dimming (20%..100%) instead.
- Gestures are off inside sheets (Skins, Customize, Settings) and while typing a timer duration.
- Keyboard: Left / Right switch mode, Up / Down change brightness 10%, Space start/pause, Esc hides the controls.
- Each gesture can be switched off in Settings > Gestures.

## Skins

- A skin is: name, digit face, digit colour, card colour, ground colour, seam on/off, card radius, seconds style (off, small badge, own cards), AM/PM position (hidden, left, right), date line on/off.
- Built-in skins: **Mono** (default: `skin-mono` on `skin-card-ink`, ground `bg`), Paper, Rose, Violet, Amber, Signal, Field, Mint, Cyan, Taxi, plus one per face (Bebas, Anton, Terminal, Serif, Orbit...).
- Every built-in skin is free. No VIP ribbons, no locks, no "Unlock all" bar.
- A custom skin starts as a copy of the current one and is edited in Customize. Custom skins appear first in the picker under "Your skins".

## Iconography

- Material Symbols Rounded, weight 400, 22px in the island and corners, 20px in settings rows. Outline style, never filled, except the selected state of a toggle icon.
- Corner icons: `palette` (Skins, top-left) and `settings` (top-right). Mode tabs are text, not icons.
- Settings category tiles: a 28px `radius-xs` tile in `control-off` (dark) with an `ink` glyph. Mono, never a rainbow.

# Tokens

Exact values: `tokens.json` in the design system artifact (read `project/tokens.json`).
