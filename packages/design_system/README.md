# Design System

A Melos-managed project for mono-repo, created using NonStop CLI.

[![nonstop_cli](https://img.shields.io/badge/started%20with-nonstop_cli-166C4E.svg?style=flat-square)](https://pub.dev/packages/nonstop_cli)
[![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)

## Installation 💻

**❗ In order to start using Design System you must have the [Flutter SDK][flutter_install_link] installed on your machine.**

Install via `dart pub add`:

```sh
dart pub add design_system
```

[flutter_install_link]: https://docs.flutter.dev/get-started/install
## Appearance override

`DesignSystemWrapper(mode: ...)` takes an `AppearanceMode`: `system` (default, follows OS brightness), `light` (Mono Light) or `black` (Mono Dark: true-black ground, white ink and accent). Both are the QuietFlip Mono themes from the design system's `tokens.json`: `DesignSystem.blackScheme()` / `monoLightScheme()` map the tokens onto Material roles, and `DesignColors.of(context)` gives every token by name (including the island colours, which are the same in both themes).

## Tokens and fonts

- `DesignColors` (theme extension), `DesignSkinColors`, `DesignSpace`, `DesignSize`, `DesignMotion`: the exact `tokens.json` values.
- `DesignShape` (theme extension, `DesignShape.of(context)`): every corner in the app from one value, `DesignSystemWrapper(corner:)` (default 14, 0 is square). Roles `xs` / `sm` / `md` / `lg` keep the token ratios (6 / 10 / 14 / 22 at 14); `forHeight(h, role:)` caps a role at half the height, so nothing is rounder than a pill and the island dot stays a dot. `DesignShape.circular` / `radius` / `rounded` are the only way to build a radius; every Material component shape in the theme follows it. No circles or stadiums anywhere.
- Interface font: Geist 400/500/600/700. Digit faces: `DisplayFace` (Barlow Condensed 700, Bebas Neue, Anton, Oswald 600, Big Shoulders 800, Archivo Black, JetBrains Mono 700, Space Grotesk 700, DM Serif Display, Orbitron 700). Each knows its `digitCentre` (em above the baseline), so the flip cards centre digits on the split line in every face.
- Every font is bundled in `assets/google_fonts/` with its `OFL-<Family>.txt`; nothing downloads at runtime.

## Taps: `Pressable` and `AppButton`

Every tappable thing is a `Pressable` (or a component built on it): the child shrinks while the finger is down (`DesignMotion.pressScale` 0.96, `pressScaleSmall` 0.92 for children 48px or smaller; in over `pressIn` 90 ms ease-out, back over `pressOut` 180 ms ease-out-cubic, no overshoot) and fires on release inside the tap slop. Dragging off, or a scroll taking over, releases without firing. It is focusable (Enter and Space fire it with a short press-and-release; keyboard focus draws a 2px accent ring at `focusRadius`), shows the click cursor on hover with no wash, speaks as a button (or the `role` given) with `semanticsLabel` and `selected`, and under reduced motion dips to `pressOpacity` (0.7) instead of scaling. A null `onTap` disables it. No haptics.

Buttons are `AppButton.text`, `.filled`, `.outlined` (each with an optional leading `icon`) and `.icon` (44px, `tooltip` required): the Material 3 colours, `labelLarge` w600 text, padding and `sm` corner the theme used to give Material buttons, at least 44px high. The theme also turns ink off for every stock and third-party Material widget (`NoSplash`, transparent highlight, hover and overlay colours).

## Chrome: the island

`Island` is the top-centre pill: a dot, a tab bar (`tabs`, `selected`, `onSelect`, `tabsLabel`) over an action tray, or a brightness HUD (`IslandBrightnessHud`), switched by `ChromeState`. Every tab is as wide as the widest label; one selected pill behind the row slides to the new tab on the island spring while the label colours cross-fade, so a mode change is one motion with the tray and height morph. It grows on the island spring (`DesignMotion.islandCurve`) and shrinks on `DesignMotion.collapseCurve` over `islandCollapse`, with no overshoot; hiding from a bigger shape shrinks to the dot first and fades only over the last 40% (`collapseFade`), and outgoing content scales down inside the shrinking pill. Its corner is `DesignShape.lg` with a tray, else `forHeight` of its height, tweened with the size. The tray takes `actions` as `IslandAction(label:, icon:, onPressed:, primary:)`: an icon button, a filled primary, or a text chip when `icon` is null; an optional `status` line is announced. It scrolls sideways rather than overflow. `CornerButton(state:, icon:, tooltip:, onPressed:, corner:)` is a 44px button on the same surface and corner rules that follows the island's `ChromeState`: it shrinks to a 6px dot toward its `corner` and disappears with the island, on the same motion. Both are dark in every theme, and the island is dark in every theme, takes all its text as parameters, and only cross-fades when the platform asks for reduced motion.

| Island token | Value | Use |
|---|---|---|
| `DesignSpace.islandInset` | 8 | Padding inside the island, all sides |
| `DesignSpace.islandRowGap` | 8 | Between the tab row and the tray |
| `DesignSpace.islandItemGap` | 8 | Between items of one group (tabs, actions, chips) |
| `DesignSpace.islandGroupGap` | 16 | Between groups (icon actions vs chips, status vs actions); space only, no line |
| `DesignSpace.islandItemPadding` | 16 | Horizontal padding in tabs and chips |
| `DesignSize.cornerButton` | 44 | Height of every tab, action and chip |
| `DesignSize.islandExpandedHeight` | 60 | Tabs only; `Island.trayHeight` (112) adds the gap and the tray row |
| `DesignMotion.islandCollapse` / `collapseCurve` / `collapseFade` | 380 ms / ease-in-out cubic / `Interval(0.6, 1)` | Every shrink; the fade when hiding from a bigger shape |
| `DesignColors.island` | `#1c1c1e` dark (`surfaceRaised`), `#0a0a0a` light | The island fill |
| `DesignColors.islandElevation` | ambient `0,18,44` at 40% + key `0,6,14` at 30% + contact `0,1,2` at 50% black; 1px rim, 22% white on top and 55% black below, each fading out by mid-height; 6% white sheen over the top half; dark adds the 1px hairline ring. A dot's shadows are 0.4 of these (`DesignElevation.dotLift`) and grow as it opens | Lifts the island over the clock on every ground, black included |

## Settings shell

`SettingsShell` lays out one list of `SettingsCategory` (icon, label, `SettingsGroup`s) three ways: a phone stack under 600px (large-title root; a category opens its detail as a real page, so the back button, the iOS edge swipe and Android back return to the root, and from the root leave Settings), a split view from 600px with a 300px sidebar, and desktop density from 1100px or with `desktop: true` (230px sidebar, 36px rows). Fill groups with `SettingsSwitchRow`, `SettingsValueRow` (an optional `leading` picture before the label), `SettingsSegmentedRow`, `SettingsSliderRow`, `SettingsKeyRow` and `SettingsNoteRow`; every visible string is a parameter. Segmented and slider rows keep 8px (`DesignSpace.s2`) between the label and the control and under the control. The shell handles the left and right safe insets itself (an iPhone in landscape), so wrap it in `SafeArea(left: false, right: false)`: the sidebar colour runs to the left edge, the detail runs to the right edge with its padding at least the inset, and phone pages pad by the larger of 16px and the inset.

## Gesture glyphs

`GestureGlyph(GestureKind.tap / swipeHorizontal / swipeVertical)` is a 28px tile (`SettingsShell.iconTileSize`, `surfaceRaised`, `xs` corner) that acts out a touch gesture with a 10px fingertip dot in `ink`, for a settings row's `leading`. Each loop is `DesignMotion.gestureLoop` (1600 ms): a tap presses the dot to 0.7 over `gestureFade` (150 ms), springs it back, and grows a ring from 10 to 28px while it fades over `gestureRing` (450 ms); a swipe fades the dot in, moves it 18px over `gestureTravel` (600 ms, `gestureTravelCurve` ease-in-out cubic) with a fading trail, fades it out and rests, the other way on the next loop. It ticks only while visible (`TickerMode`), and under reduced motion draws a still frame: the ring at mid size, or a small arrow in the swipe direction. It is not announced; the row's label says what the gesture does.
