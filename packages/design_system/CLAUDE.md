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
| `DesignSystemWrapper({builder, mode, face, corner})` | widget | `corner` builds the `DesignShape` every component shape follows; Wraps `MaterialApp`; `mode: AppearanceMode.system` (default) picks light/dark from platform brightness, other modes force a theme; installs `GlobalLoaderOverlay` and `ToastificationWrapper` |
| `AppearanceMode` | enum | `system` (platform brightness picks Mono Dark or Mono Light), `light` (Mono Light), `black` (Mono Dark, the QuietFlip default) |
| `DesignSystem` | theme builder | `light()` / `black()` `ThemeData`, `forMode(mode, platformBrightness)`, static `blackScheme()` / `monoLightScheme()` (tokens on Material roles), static `monoTextTheme()`; `bodyFont` / `displayFont` (default Geist); `face` sets every role in that `DisplayFace` at its one bundled weight, keeping the sizes |
| `DesignColors` | `ThemeExtension` | Every Mono colour token by name (`bg`, `surface`, `surfaceRaised`, `ink`, `inkMuted`, `hairline`, `island*`, `accent`, `danger`, shadows, `islandElevation` ...); `DesignColors.of(context)`; `.dark` / `.light` |
| `DesignElevation` | value | `shadows` plus a 1px top `highlight` that fades out by mid-height; `DesignColors.islandElevation` |
| `DesignShape` | `ThemeExtension` | Every corner from one `corner` (default 14, `minCorner` 0 .. `maxCorner` 24): `xs` / `sm` / `md` / `lg` = corner x 6/14, 10/14, 1, 22/14; `forHeight(h, {role})` caps a role (default `md`) at h/2; `DesignShape.of(context)` (default corner when absent); static `circular` / `radius` / `rounded`, the only place a radius becomes a shape |
| `DesignSkinColors`, `DesignSpace`, `DesignSize`, `DesignMotion` | constants | `skin-*`, `space-*`, `size-*`, `dur-*` and the island spring, exactly as in `tokens.json` |
| `SpringCurve`, `DesignMotion.islandCurve` | curve | A `SpringDescription` played over a `Duration` as a `Curve` (overshoots, ends at exactly 1); `islandCurve` is the island spring over `islandMorph` |
| `DesignFonts`, `DisplayFace` | constants / enum | Geist (`ui`) weights; the ten bundled digit faces (family, weight, `style()`, `assetName`) |
| `MaterialTheme` | generated | Color schemes (light, dark, contrast variants) |
| `NavigationIcons` | constants | Every navigation icon; one edit re-skins the shell |
| `Toast` | static API | `notification`, `error`, `success`, `warning` |
| `Loader` / `DefaultLoader` | overlay / widget | Blocking overlay; inline adaptive spinner |
| `DefaultErrorView`, `ErrorScreen` | widgets | Inline error with retry; full-screen error with retry/home |
| `NetworkUrlImage`, `AppAssetImage`, `Header` | widgets | Cached network image, raster/SVG asset with fallback, header banner |
| `DateFilterChips` | widget | Week/month filter |
| `ChromeState`, `Island`, `IslandAction`, `IslandHud` (`IslandBrightnessHud`, `IslandTitleHud`), `CornerButton` | widgets | Clock chrome: `hidden` / `dot` / `expanded`. `CornerButton({state, icon, tooltip, onPressed, corner})` follows the same state: a 44px button on the island's surface and corner (`forHeight`, never a circle), a `cornerDot` dot toward `corner`, or gone; grows on the spring, shrinks and hides with the island's collapse; its box is always 44 square; tappable only when expanded. `Island` morphs one dark pill between a dot, up to four tabs (tab-bar semantics) over an action tray, and a live-region HUD (a HUD wins over the state). The tray (`actions`, optional live-region `status`; no `trailing` group: corner controls are `CornerButton`s) is one row of `IslandAction`s: an icon button (44px, `label` = tooltip + spoken name), a filled `primary`, or a text chip (no `icon`; `semanticsLabel` speaks an abbreviation in full); null `onPressed` draws it disabled. Island tokens only, >= 4.5:1 in both themes; fits the width it is given (and stays `space-4` off the window edges), scrolls sideways when narrow; spacing from the `DesignSpace.island*` tokens (8 inset, 8 between rows and items, 16 between groups of one kind: status, icon actions, chips; 16 tab/chip padding; every item 44 high), tray centred under the tabs; `Island.trayHeight` = inset + tab row + gap + action row + inset (112); depth from `islandElevation` (drop and contact shadows, top highlight, hairline ring in dark); corners from `DesignShape`: `lg` with a tray, else `forHeight` of the height (the dot stays a dot; square at 0), tweened with the size; tabs, actions and chips `forHeight(44)`. Grows on the spring, shrinks on `collapseCurve` over `islandCollapse` (no overshoot); hiding from more than the dot shrinks first and fades over `collapseFade`; outgoing content scales down inside the shrinking pill; reduced motion drops the size morph and only cross-fades; tray content cross-fades (`DesignMotion.fade`); all text passed in |
| `SettingsShell({title, categories, doneLabel, onDone, desktop, initialCategory, openInitialCategory})` | widget | One settings model laid out three ways: phone stack under 600 (large title root, category detail with a back button; system back returns to the root; `openInitialCategory` starts on `initialCategory`'s page with Done beside its title, a deep link), split 600-1100 (`DesignSize.sidebarWidth` sidebar, accent-pill selection), desktop density at 1100+ or `desktop: true` (230 sidebar, 30px nav rows, 36px rows, 14px labels). All text passed in |
| `SettingsCategory({icon, label, groups})`, `SettingsGroup({header, rows, footer})` | models | A category (sidebar/root row plus its detail page); a grouped inset cell with an uppercase header and a footer |
| `SettingsSwitchRow`, `SettingsValueRow`, `SettingsSegmentedRow<T>`, `SettingsSliderRow`, `SettingsKeyRow`, `SettingsNoteRow` | widgets | Rows for `SettingsGroup.rows`: switch (row tap toggles), value with optional chevron, an optional `trailing` control (such as a delete button) and `semanticsLabel` for an abbreviated label, label over a segmented control, label/value over a slider (optional `minLabel` / `maxLabel` stop labels under its ends; both with `DesignSpace.s2` between label and control and under the control, in both densities), keycap, muted note. Take the shell's density; phone density standalone |
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
| `lib/constants/design_tokens.dart`, `design_shape.dart`, `design_fonts.dart` | Mono tokens, the corner system, bundled faces |
| `lib/utils/extensions/` | Package-private string helpers |

## Rules

- Component styling (buttons, app bar, navigation bar, inputs) is set once in
  `DesignSystem._baseTheme`. Change it there, not with per-widget `style:`.
- **One corner for the whole app.** Every rounded shape comes from
  `DesignShape.of(context)`: buttons, segmented buttons, chips, list tiles,
  snack bars, inputs `sm`; cards, skin tiles, flip cards `md`; sheets,
  dialogs, large flip cards and the two-row island `lg`; keycaps, icon
  tiles, tooltips and the navigation indicator `xs`; anything short
  `forHeight`. No widget picks its own radius, nothing is a circle or a
  stadium. `features/flip_clock/test/corner_rule_test.dart` scans this
  package's and flip_clock's `lib/` and fails on `BorderRadius.circular(`,
  `Radius.circular(`, `StadiumBorder`, `CircleBorder`, `BoxShape.circle`
  or `CircleAvatar` outside `design_shape.dart`. The only exceptions:
  - Material `Switch` (stadium track, round thumb) and `Slider` (round
    thumb, rounded track ends): Material offers no corner for them, and
    replacing either is more than an hour of work.
  - `CircularProgressIndicator` in the loaders: a spinner, not a shape.
  - `Toast.notification` has no `BuildContext` (it is raised from a push
    handler), so it uses the default corner, not the user's.
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
| `shape_test.dart` | `DesignShape` ratios at 0/14/24, `forHeight` cap, value semantics/lerp, `of` fallback, every Material component shape at corner 0/14/24 |
| `components_test.dart` | Mono themes and tokens, Geist text styles, loaders, error view/screen, asset fallbacks, network image, wrapper brightness + loader, string helpers |
| `island_test.dart` | CornerButton (taps only expanded, dot in its corner, hidden, shrink-then-fade, spring back, corner 0/24, reduced motion, theme switch mid-morph), island fits its box, island and tray-action corners at 0/14/24 (dot stays a dot), collapse timeline (opacity holds until the shape is under half height, no overshoot, ends hidden), expand springs, dot stays opaque, dot -> hidden plain fade, reduced-motion cross-fade, spacing tokens and centred tray, depth decoration in both themes, spring overshoot, HUD models, island sizes per state in both Mono themes, HUD over hidden, tab taps/colours/semantics, 320px at text scale 2, tray layout/taps/disabled/status, status-only tray, tray contrast >= 4.5:1, tray scrolls at 320px and text scale 2, reduced motion |
| `settings_shell_test.dart` | Phone/split/desktop layouts at 375/820/1280 and `desktop: true` in both Mono themes, sidebar widths and row heights, phone navigation and system back, sidebar selection and accent pill, shell colours from the theme in both brightnesses, `s2` gap under segmented/slider controls in both densities, slider stop labels, Done, `openInitialCategory` on the phone (Done, back to the root) and split, a value row's trailing control, every row's callback, group header/footer, standalone rows, text scale 2 at 375 and 1280 |
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
- `Positioned(child:)` with no offsets is *not* positioned: it sizes the
  `Stack`. The island lays outgoing content out with `Positioned.fill`, so
  only the incoming content sizes the pill; otherwise the outgoing tray
  held the dot wide and it shrank twice.
- `AnimatedSize` asserts when given `Duration.zero` (it re-dirties itself
  mid-layout), so `Island` leaves it out under reduced motion instead.
- `FileInfoDialog` takes a `dart:io` `File`, so it does not work on web. Its
  labels ("File Information", "File Name", ...) are still raw English
  literals, not `strings.*`.
