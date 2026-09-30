# Quietflip: `packages/design_system`

The visual language of the app: theme, shared components, dialogs, screens,
toasts and loaders. It is product-agnostic: no feature names, no business
logic, no navigation decisions. Layer 3 (see `packages/CLAUDE.md`).

Read the root `CLAUDE.md` and `packages/CLAUDE.md` first. **Load the
`design-system` skill** before adding or changing anything here; it holds the
rules for tokens, components and review.

## Public API

Everything, including `Toast`, is exported from
`package:design_system/design_system.dart`.

| Symbol | Kind | Use |
|---|---|---|
| `DesignSystemWrapper({builder, mode, face})` | widget | Wraps `MaterialApp`; `mode: AppearanceMode.system` (default) picks light/dark from platform brightness, other modes force a theme; installs `GlobalLoaderOverlay` and `ToastificationWrapper` |
| `AppearanceMode` | enum | `system` (platform brightness picks Mono Dark or Mono Light), `light` (Mono Light), `black` (Mono Dark, the QuietFlip default) |
| `DesignSystem` | theme builder | `light()` / `black()` `ThemeData`, `forMode(mode, platformBrightness)`, static `blackScheme()` / `monoLightScheme()` (tokens on Material roles), static `monoTextTheme()`; `bodyFont` / `displayFont` (default Geist); `face` sets every role in that `DisplayFace` at its one bundled weight, keeping the sizes |
| `DesignColors` | `ThemeExtension` | Every Mono colour token by name (`bg`, `surface`, `surfaceRaised`, `ink`, `inkMuted`, `hairline`, `island*`, `accent`, `danger`, shadows ...); `DesignColors.of(context)`; `.dark` / `.light` |
| `DesignSkinColors`, `DesignSpace`, `DesignRadius`, `DesignSize`, `DesignMotion` | constants | `skin-*`, `space-*`, `radius-*`, `size-*`, `dur-*` and the island spring, exactly as in `tokens.json` |
| `SpringCurve`, `DesignMotion.islandCurve` | curve | A `SpringDescription` played over a `Duration` as a `Curve` (overshoots, ends at exactly 1); `islandCurve` is the island spring over `islandMorph` |
| `DesignFonts`, `DisplayFace` | constants / enum | Geist (`ui`) weights; the ten bundled digit faces (family, weight, `style()`, `assetName`) |
| `MaterialTheme` | generated | Color schemes (light, dark, contrast variants) |
| `NavigationIcons` | constants | Every navigation icon; one edit re-skins the shell |
| `Toast` | static API | `notification`, `error`, `success`, `warning` |
| `Loader` / `DefaultLoader` | overlay / widget | Blocking overlay; inline adaptive spinner |
| `DefaultErrorView`, `ErrorScreen` | widgets | Inline error with retry; full-screen error with retry/home |
| `NetworkUrlImage`, `AppAssetImage`, `Header` | widgets | Cached network image, raster/SVG asset with fallback, header banner |
| `DateFilterChips` | widget | Week/month filter |
| `ChromeState`, `Island`, `IslandAction`, `IslandHud` (`IslandBrightnessHud`, `IslandTitleHud`) | widgets | Clock chrome: `hidden` / `dot` / `expanded`. `Island` morphs one dark pill between a dot, up to four tabs (tab-bar semantics) over an action tray, and a live-region HUD (a HUD wins over the state). The tray (`actions`, then `trailing` after a hairline, optional live-region `status`) is one row of `IslandAction`s: an icon button (44px, `label` = tooltip + spoken name), a filled `primary`, or a text chip (no `icon`); null `onPressed` draws it disabled. Island tokens only, >= 4.5:1 in both themes; scrolls sideways when narrow; `Island.trayHeight` = tab row + one action row; with a tray the pill takes `radius-lg` corners (a stadium's round ends would clip the outer tabs and actions). Spring morph (dropped under reduced motion), tray content cross-fades (`DesignMotion.fade`); all text passed in |
| `SettingsShell({title, categories, doneLabel, onDone, desktop, initialCategory, openInitialCategory})` | widget | One settings model laid out three ways: phone stack under 600 (large title root, category detail with a back button; system back returns to the root; `openInitialCategory` starts on `initialCategory`'s page with Done beside its title, a deep link), split 600-1100 (`DesignSize.sidebarWidth` sidebar, accent-pill selection), desktop density at 1100+ or `desktop: true` (230 sidebar, 30px nav rows, 36px rows, 14px labels). All text passed in |
| `SettingsCategory({icon, label, groups})`, `SettingsGroup({header, rows, footer})` | models | A category (sidebar/root row plus its detail page); a grouped inset cell with an uppercase header and a footer |
| `SettingsSwitchRow`, `SettingsValueRow`, `SettingsSegmentedRow<T>`, `SettingsSliderRow`, `SettingsKeyRow`, `SettingsNoteRow` | widgets | Rows for `SettingsGroup.rows`: switch (row tap toggles), value with optional chevron and an optional `trailing` control (such as a delete button), label over a segmented control, label/value over a slider (both with `DesignSpace.s2` between label and control and under the control, in both densities), keycap, muted note. Take the shell's density; phone density standalone |
| `AuthHeadersBuilder` | widget | Builds a child with current auth headers |
| `FileInfoDialog` | dialog | `FileInfoDialog.show(context, file)`; tap-to-copy confirms with `Toast.success` |

## Layout

| Path | Responsibility |
|---|---|
| `lib/design_system.dart` | `DesignSystem`: component theme overrides on top of `MaterialTheme` |
| `lib/generated/` | Material Theme Builder export (`theme.dart`; its `util.dart` text-theme helper was replaced by `DesignSystem.monoTextTheme`). Never hand-edit |
| `lib/components/` | Reusable widgets (`app_asset_image.dart`, ...), hand-maintained `index.dart` barrel |
| `lib/screens/`, `lib/dialogs/` | Full screens and dialogs |
| `lib/toast/`, `lib/loader/` | Toast and overlay APIs |
| `lib/wrapper/wrappers.dart` | `DesignSystemWrapper` |
| `lib/constants/navigation_icons.dart` | Navigation icon set |
| `lib/constants/design_tokens.dart`, `design_fonts.dart` | Mono tokens and bundled faces |
| `lib/utils/extensions/` | Package-private string helpers |

## Rules

- Component styling (buttons, app bar, navigation bar, inputs) is set once in
  `DesignSystem._baseTheme`. Change it there, not with per-widget `style:`.
- Colors come from `Theme.of(context).colorScheme` roles; text from
  `textTheme`. Components never use raw `Color(...)`; even input borders use
  `outlineVariant`.
- Every user-visible string comes from `strings.*` (`localization`).
- Components take everything they render as constructor parameters. They
  never call `di.get`, except `AuthHeadersBuilder`, which falls back to the
  registered `AuthTokenProvider` / `Logger` when none is passed.
- `network` (`AuthTokenProvider`) and `core` (`Logger`) are imported only by
  `AuthHeadersBuilder`. Do not add other imports from them.
- The wrapper owns brightness. The app passes only `theme:` to
  `MaterialApp.router`; do not add a separate `darkTheme` there.

## Common changes

- **Rebrand the palette:** export from Material Theme Builder, replace
  `lib/generated/theme.dart` wholesale, then check both brightnesses.
- **Change a Mono colour:** edit `DesignColors.dark` / `.light` in `lib/constants/design_tokens.dart` to the new `tokens.json` value; `blackScheme()` / `monoLightScheme()` map them onto Material roles. Never edit `lib/generated/`. The test `wrapper mode forces a theme regardless of platform` asserts the surfaces.
- **Change fonts:** pass `bodyFont` / `displayFont` to `DesignSystem` in
  `DesignSystemWrapper` (any Google Fonts family name) and bundle its files
  (see Gotchas).
- **Add a component:** follow the `design-system` skill. Add a file to
  `lib/components/`, export it from `components/index.dart`, and test it in
  `test/components_test.dart`.
- **Add a toast variant:** add a static method to `Toast` that mirrors the
  others, and add it to the toast test in `test/integration_test.dart`.

## Tests

| File | Covers |
|---|---|
| `design_system_test.dart` | Wrapper hands the builder a themed context |
| `fonts_test.dart` | Every Geist weight and `DisplayFace` has its `.ttf` and OFL licence in `assets/google_fonts/`, declared in `pubspec.yaml` |
| `components_test.dart` | Mono themes and tokens, Geist text styles, loaders, error view/screen, asset fallbacks, network image, wrapper brightness + loader, string helpers |
| `island_test.dart` | Spring overshoot, HUD models, island sizes per state in both Mono themes, HUD over hidden, tab taps/colours/semantics, 320px at text scale 2, tray layout/taps/disabled/status, trailing rule, tray contrast >= 4.5:1, tray scrolls at 320px and text scale 2, reduced motion |
| `settings_shell_test.dart` | Phone/split/desktop layouts at 375/820/1280 and `desktop: true` in both Mono themes, sidebar widths and row heights, phone navigation and system back, sidebar selection and accent pill, shell colours from the theme in both brightnesses, `s2` gap under segmented/slider controls in both densities, Done, `openInitialCategory` on the phone (Done, back to the root) and split, a value row's trailing control, every row's callback, group header/footer, standalone rows, text scale 2 at 375 and 1280 |
| `integration_test.dart` | Image adapters, `AuthHeadersBuilder` (missing provider, failures, rebuilds), dialogs, toast variants |

Run `dart run melos exec --scope=design_system -- flutter test`. Keep
`dart run melos run coverage` at 100%.

## Gotchas

- Geist 400/500/600/700 and one weight of each `DisplayFace` (OFL,
  `OFL-<Family>.txt` alongside) are bundled in `assets/google_fonts/` and the
  app sets `GoogleFonts.config.allowRuntimeFetching = false`, so nothing is
  fetched at launch. Changing `bodyFont` / `displayFont`, adding a face, or
  using another weight means bundling that family's `<Family>-<Weight>.ttf`
  (google_fonts' file name) there too; `fonts_test.dart` fails otherwise.
- google_fonts renders the nearest bundled weight: the `title` token's 650
  draws Geist SemiBold.
- With a `face`, all text is one weight (the face's only bundled file):
  titles and body differ by size only. Never ask a face for another weight;
  google_fonts would find no bundled file.
- The island spring overshoots past 1: animate only sizes on it. A shadow
  or decoration lerped past 1 (Mono Light's blur to Mono Dark's ring on a
  theme switch mid-morph) gets a negative blur and asserts; `Island`
  springs its size and draws the decoration un-animated.
- "Big Shoulders Display" is now the "Big Shoulders" family on Google Fonts
  (same design); the face bundles `BigShoulders-ExtraBold.ttf`.
- `AnimatedSize` asserts when given `Duration.zero` (it re-dirties itself
  mid-layout), so `Island` leaves it out under reduced motion instead.
- `FileInfoDialog` takes a `dart:io` `File`, so it does not work on web. Its
  labels ("File Information", "File Name", ...) are still raw English
  literals, not `strings.*`.
