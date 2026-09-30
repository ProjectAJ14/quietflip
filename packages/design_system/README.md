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

- `DesignColors` (theme extension), `DesignSkinColors`, `DesignSpace`, `DesignRadius`, `DesignSize`, `DesignMotion`: the exact `tokens.json` values.
- Interface font: Geist 400/500/600/700. Digit faces: `DisplayFace` (Barlow Condensed 700, Bebas Neue, Anton, Oswald 600, Big Shoulders 800, Archivo Black, JetBrains Mono 700, Space Grotesk 700, DM Serif Display, Orbitron 700).
- Every font is bundled in `assets/google_fonts/` with its `OFL-<Family>.txt`; nothing downloads at runtime.
