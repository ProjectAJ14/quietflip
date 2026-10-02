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
- Interface font: Geist 400/500/600/700. Digit faces: `DisplayFace` (Barlow Condensed 700, Bebas Neue, Anton, Oswald 600, Big Shoulders 800, Archivo Black, JetBrains Mono 700, Space Grotesk 700, DM Serif Display, Orbitron 700).
- Every font is bundled in `assets/google_fonts/` with its `OFL-<Family>.txt`; nothing downloads at runtime.

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
| `DesignColors.islandElevation` | drop `0,12,32` at 45% + contact `0,2,6` at 35% black; 1px top highlight 14% white fading out by mid-height; dark adds the 1px hairline ring | Lifts the island over the clock on every ground, black included |

## Settings shell

`SettingsShell` lays out one list of `SettingsCategory` (icon, label, `SettingsGroup`s) three ways: a phone stack under 600px (large-title root; a category opens its detail, and back returns to the root), a split view from 600px with a 300px sidebar, and desktop density from 1100px or with `desktop: true` (230px sidebar, 36px rows). Fill groups with `SettingsSwitchRow`, `SettingsValueRow`, `SettingsSegmentedRow`, `SettingsSliderRow`, `SettingsKeyRow` and `SettingsNoteRow`; every visible string is a parameter. Segmented and slider rows keep 8px (`DesignSpace.s2`) between the label and the control and under the control.
