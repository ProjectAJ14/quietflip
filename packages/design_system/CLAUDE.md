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
| `DesignElevation` | value | `shadows`, a 1px rim lit with `highlight` on top and shaded with `lowlight` below (each clear by mid-height) and a `sheen` over the top half of the fill; `shadowsAt(lift)` scales the blurred shadows' offset and blur (an unblurred ring stays); `dotLift` (0.4) is a dot's lift; `DesignColors.islandElevation` |
| `DesignShape` | `ThemeExtension` | Every corner from one `corner` (default 14, `minCorner` 0 .. `maxCorner` 24): `xs` / `sm` / `md` / `lg` = corner x 6/14, 10/14, 1, 22/14; `forHeight(h, {role})` caps a role (default `md`) at h/2; `DesignShape.of(context)` (default corner when absent); static `circular` / `radius` / `rounded`, the only place a radius becomes a shape |
| `DesignSkinColors`, `DesignSpace`, `DesignSize`, `DesignMotion` | constants | `skin-*`, `space-*`, `size-*`, `dur-*` and the island spring, exactly as in `tokens.json` |
| `DesignMotion.pressScale` / `pressScaleSmall` / `pressOpacity` / `pressIn` (+ `pressInCurve`) / `pressOut` (+ `pressOutCurve`) | constants | The press: 0.96 (0.92 for children 48px or smaller), 0.7 opacity under reduced motion, 90 ms `easeOut` in, 180 ms `easeOutCubic` out (no overshoot) |
| `DesignMotion.gestureLoop` / `gestureFade` / `gestureRing` / `gestureTravel` (+ `gestureTravelCurve`) | constants | The `GestureGlyph` loop: 1600 ms; 150 ms press or fade (and the swipe trail's lag); 450 ms ring; 600 ms travel on `easeInOutCubic` |
| `reducedMotion(context)` | function | True for `disableAnimations` (Android "Remove animations", web `prefers-reduced-motion`) or iOS Reduce Motion; every motion in the package and in features asks it |
| `Pressable({child, onTap, onLongPress, semanticsLabel, selected, role, focusRadius})` | widget | The one tap: shrinks on pointer down (no tap delay), fires on release inside the tap slop, moving past the slop (drag off, a scroll) releases without firing; long press; focusable, Enter/Space fire with a `pressIn` press-and-release; keyboard focus draws a 2px `accent` ring outside the child at `focusRadius` (default `sm`); click cursor on hover, no wash; null `onTap` = disabled (no press, not focusable, `enabled: false`); semantics `button` (or `role`, which also speaks `selected: false`), label, tap/long-press actions, `selected`; reduced motion dips opacity, no scale; nested, only the innermost enabled one under the finger presses (a tile around its Customize button stays still) |
| `AppButton.text` / `.filled` / `.outlined({label, onPressed, icon, semanticsLabel})`, `AppButton.text(danger:)`, `AppButton.icon({icon, tooltip, onPressed})` | widget | Every button: a `Pressable` around a `ShapeDecoration` box with the Material 3 values the old button themes gave (filled: `primary` fill, `onPrimary` text; text and outlined: `primary` text, outlined adds a 1.5px `primary` side in every state; icon: `onSurfaceVariant`, 24px glyph, 8 padding, 44 square, `forHeight(44, role: sm)`; disabled `onSurface` at 38% text and 12% fill), `labelLarge` w600, Material's text-scaled padding and icon gap (18px icon), `sm` corner, min 64 x 44 (`DesignSize.cornerButton`). `danger` colours a text button `DesignColors.danger`; `semanticsLabel` replaces the spoken label; the icon variant's `tooltip` is its tooltip and spoken name |
| `SpringCurve`, `DesignMotion.islandCurve` | curve | A `SpringDescription` played over a `Duration` as a `Curve` (overshoots, ends at exactly 1); `islandCurve` is the island spring over `islandMorph` |
| `DesignFonts`, `DisplayFace` | constants / enum | Geist (`ui`) weights; `arabic` (Noto Sans Arabic) and `arabicWeights`, and `withArabic(style)`, which appends it at the nearest bundled weight (400-700) to a style's `fontFamilyFallback` (every `monoTextTheme` role gets it, with or without a `face`); the ten bundled digit faces (family, weight, `style()`, `assetName`, `digitCentre`: the digits' vertical centre above the baseline in em, measured from each `.ttf`'s `0`-`9` glyph bounds, so a caller can centre digits on a line by baseline whatever the leading) |
| `MaterialTheme` | generated | Color schemes (light, dark, contrast variants) |
| `NavigationIcons` | constants | Every navigation icon; one edit re-skins the shell |
| `Toast` | static API | `notification`, `error`, `success`, `warning` |
| `Loader` / `DefaultLoader` | overlay / widget | Blocking overlay; inline adaptive spinner |
| `DefaultErrorView`, `ErrorScreen` | widgets | Inline error with retry; full-screen error with retry/home |
| `NetworkUrlImage`, `AppAssetImage`, `Header` | widgets | Cached network image, raster/SVG asset with fallback, header banner |
| `DateFilterChips` | widget | Week/month filter |
| `ChromeState`, `Island`, `IslandAction`, `IslandHud` (`IslandBrightnessHud`), `CornerButton` | widgets | Clock chrome: `hidden` / `dot` / `expanded`. The brightness HUD is locked left to right (icon, bar filling from the left, value) in every language. `CornerButton({state, icon, tooltip, onPressed, corner})` (`corner` an `AlignmentGeometry`: a directional one mirrors in right-to-left) follows the same state: a 44px button on the island's surface and corner (`forHeight`, never a circle), a `cornerDot` dot toward `corner`, or gone; grows on the spring, shrinks and hides with the island's collapse; its box is always 44 square; tappable only when expanded. `Island` morphs one dark pill between a dot, up to four tabs (tab-bar semantics) over an action tray, and a live-region HUD (a HUD wins over the state). The tray (`actions`, optional live-region `status`; no `trailing` group: corner controls are `CornerButton`s) is one row of `IslandAction`s: an icon button (44px, `label` = tooltip + spoken name), a filled `primary`, or a text chip (no `icon`; `semanticsLabel` speaks an abbreviation in full); null `onPressed` draws it disabled. Island tokens only, >= 4.5:1 in both themes; fits the width it is given (and stays `space-4` off the window edges), scrolls sideways when narrow; spacing from the `DesignSpace.island*` tokens (8 inset, 8 between rows and items, 16 between groups of one kind: status, icon actions, chips; 16 tab/chip padding; every item 44 high), tray centred under the tabs; tabs all one width (the widest label, measured with a `TextPainter` in the ambient style merged with `labelLarge` at the current text scale, re-measured when system fonts change, + `islandItemPadding` both sides), one selected pill (`islandActive`) behind the row sliding with `AnimatedPositionedDirectional` on `islandMorph` / `islandCurve`, label colours cross-fading over `DesignMotion.fade`, in the same frame as the tray switch and height morph; reduced motion: the pill jumps and colours swap; `Island.trayHeight` = inset + tab row + gap + action row + inset (112); depth from `islandElevation` (ambient, key and contact shadows, lit top and shaded bottom rim, top sheen under the content, hairline ring in dark), lifted fully when expanded or showing a HUD and at `dotLift` as a dot, the lift tweened with the corner on `collapseCurve` over `islandCollapse` (no overshoot; instant under reduced motion); `CornerButton` lifts the same way; corners from `DesignShape`: `lg` with a tray, else `forHeight` of the height (the dot stays a dot; square at 0), tweened with the size; tabs, actions and chips `forHeight(44)`. Grows on the spring, shrinks on `collapseCurve` over `islandCollapse` (no overshoot); hiding from more than the dot shrinks first and fades over `collapseFade`; outgoing content scales down inside the shrinking pill; reduced motion drops the size morph and only cross-fades; tray content cross-fades (`DesignMotion.fade`); all text passed in |
| `SettingsShell({title, categories, doneLabel, onDone, desktop, initialCategory, openInitialCategory, pinned, pinnedCard})` | widget | One settings model laid out three ways: phone stack under 600 (large title root; a category opens as a page of the shell's own `Navigator`, so its back button, the iOS edge swipe and a system or predictive back return to the root, and from the root leave the screen; the pages follow the shell's state, so a resize keeps the open page; `openInitialCategory` starts on `initialCategory`'s page with Done beside its title, a deep link), split 600-1100 (`DesignSize.sidebarWidth` sidebar, accent-pill selection), desktop density at 1100+ or `desktop: true` (230 sidebar, 30px nav rows, 36px rows, 14px labels). Optional `pinned` category with its `pinnedCard` content (both or neither): on the phone its own card after the list, `space-6` below it; in split/desktop at the bottom of the sidebar, outside its scroll, `space-4` padding; the card is `surfaceRaised` with a hairline (a 2px `accent` ring when selected), `md` corners, `pinnedCardHeight` (72) minimum, focusable, Enter/Space open it; `initialCategory == categories.length` addresses it. Owns the horizontal safe insets (`MediaQuery.paddingOf`; wrap it in `SafeArea(left: false, right: false)`): split/desktop sidebar widened by the start inset with its fill to the start edge, its list and pinned card padded `start + s3` / `start + s4`, detail to the end edge with `max(s8, end inset)` padding (the inset replaces the padding); phone lists, detail page and pinned card `max(s4, inset)` each side, the detail header row padded by the inset. Start and end follow `Directionality`: in right-to-left the sidebar is on the right, the start inset is the right one, and the `chevron_*_rounded` icons (they `matchTextDirection`) mirror, so back points right. All text passed in |
| `SettingsCategory({icon, label, groups})`, `SettingsGroup({header, hint, rows, footer})` | models | A category (sidebar/root row plus its detail page); a grouped inset cell with an uppercase header, an optional muted `hint` at the end of the header line (as given, wraps under it when narrow) and a footer |
| `GestureGlyph(kind)`, `GestureKind` (`tap` / `swipeHorizontal` / `swipeVertical`), `GestureFrame`, `GestureGlyphPainter` | widget | A `SettingsShell.iconTileSize` tile (`surfaceRaised`, `xs` corner) acting out a touch gesture with a 10px `ink` fingertip, one `AnimationController` over two `gestureLoop`s (a swipe reverses each loop), disposed; tap: the dot presses to 0.7 and back over `gestureFade` each, a ring 10 to 28px fades over `gestureRing` after the press; swipes: fade in over `gestureFade`, travel 18px over `gestureTravel` on `gestureTravelCurve` with a trail lagging `gestureFade`, fade out, rest. Ticks only while its `TickerMode` is on; reduced motion: `GestureGlyph.still` (tap: the ring at 19px, half opacity; swipe: the dot behind centre and a small arrow its first way, right or up). `GestureGlyph.frameAt(kind, elapsed)` is the pure timeline the painter draws (`painter.frame`); excluded from semantics |
| `SettingsSwitchRow`, `SettingsValueRow`, `SettingsSegmentedRow<T>`, `SettingsSliderRow`, `SettingsKeyRow`, `SettingsNoteRow` | widgets | Rows for `SettingsGroup.rows`: switch (row tap toggles), value with optional chevron, an optional `leading` picture (a `GestureGlyph`) and `trailing` control (such as a delete button) and `semanticsLabel` for an abbreviated label, label over a segmented control, label/value over a slider (optional `minLabel` / `maxLabel` stop labels under its ends; both with `DesignSpace.s2` between label and control and under the control, in both densities), keycap, muted note. The end of a row (value, chevron, switch, trailing) is as wide as it is, up to half the row; the label takes the rest. Take the shell's density; phone density standalone |
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

- **Every tappable thing is a `Pressable`**, or a component built on it;
  **buttons are `AppButton`**. No `InkWell`, `InkResponse`, Material buttons
  (`TextButton`, `FilledButton`, `OutlinedButton`, `ElevatedButton`,
  `IconButton`), `ListTile(onTap:)`, `SwitchListTile` or
  `GestureDetector(onTap:)`: they ripple or skip the press-down. Island
  tabs, tray actions, corner buttons, settings rows and cards, file-info
  rows are all `Pressable`s; a row that is not tappable (`_Cell` without
  `onTap`) is not wrapped, so it gains no button semantics. `_baseTheme`
  sets `NoSplash` and transparent highlight, splash, hover and overlay
  colours (switch, checkbox, radio, slider, segmented button, navigation
  bar, the button themes) so stock and third-party screens draw no ink
  either. The Material button themes stay on purpose: FirebaseUI's sign-in
  screens (`features/auth`), `showLicensePage` and stock dialogs still
  render Material buttons, and the themes keep them in the app's shape and
  type.
- **The press gate** is `features/flip_clock/test/press_rule_test.dart`. It
  scans the `lib/` of `design_system`, `flip_clock` and `auth` (comments
  blanked, whitespace-tolerant, `file:line` in the failure) for the widgets
  above. `*ThemeData` and `.styleFrom` are theme config, not taps, and do
  not match. Exceptions, with the reason: `pressable.dart` and
  `app_button.dart` (they own the tap), `features/flip_clock`'s
  `gesture_layer.dart` (drags and swipes on the clock face, not taps).
  `features/dashboard` (generator demo, not shipped UI) and
  `packages/developer` (debug tools) are not scanned.
- Other component styling (app bar, navigation bar, inputs, segmented
  buttons) is set once in `DesignSystem._baseTheme`. Change it there, not
  with per-widget `style:`.
- **One corner for the whole app.** Every rounded shape comes from
  `DesignShape.of(context)`: buttons, segmented buttons, chips, list tiles,
  snack bars, inputs `sm`; cards, skin tiles, flip cards `md`; sheets,
  dialogs, large flip cards and the two-row island `lg`; keycaps, icon
  tiles, tooltips and the navigation indicator `xs`; anything short
  `forHeight`. No widget picks its own radius, nothing is a circle or a
  stadium. `features/flip_clock/test/corner_rule_test.dart` scans this
  package's and flip_clock's `lib/` and fails on `BorderRadius.circular(`,
  `Radius.circular(` / `elliptical(`, `StadiumBorder`, `CircleBorder`,
  `BoxShape.circle`, `CircleAvatar`, `ClipOval`, `OvalBorder`, `StarBorder`,
  `BeveledRectangleBorder`, `ContinuousRectangleBorder`, `InkResponse(`
  (circular splash) or a default `OutlineInputBorder()` outside
  `design_shape.dart`. The only exceptions:
  - Material `Switch` (stadium track, round thumb) and `Slider` (round
    thumb, rounded track ends, and its value-indicator bubble, which no
    slider in the app shows): Material offers no corner for them, and
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
| `fonts_test.dart` | Every Geist and Noto Sans Arabic weight and `DisplayFace` has its `.ttf` and OFL licence in `assets/google_fonts/`, declared in `pubspec.yaml`; every face has a `digitCentre` in 0.25..0.5; `withArabic` weights (clamped to 400-700, 650 -> 600) and every text-theme role falling back to Arabic with and without a face |
| `shape_test.dart` | `DesignShape` ratios at 0/14/24, `forHeight` cap, value semantics/lerp, `of` fallback, every Material component shape at corner 0/14/24 |
| `components_test.dart` | Mono themes and tokens, Geist text styles, loaders, error view/screen, asset fallbacks, network image, wrapper brightness + loader, string helpers |
| `pressable_test.dart` | Scale 0.96 held / 1.0 released, 0.92 for a 44px child, press shows inside the tap delay, fires on up not down, drag-off and scroll release without firing, long press, a second finger, Enter and Space, dispose mid keyboard press, focus ring (2px accent at `focusRadius`, `sm` default), click cursor with no wash, disabled ignores press/keys/focus, disabling mid-press, reduced-motion opacity dip, semantics (button, label, actions, selected; a `role` replaces the button flag) |
| `app_button_test.dart` | Each variant (with and without icon, enabled and disabled) matches the old theme's resolved `ButtonStyle` (fill, foreground, shape and side, text style, padding, icon size) in both Mono themes at corner 0 and 24; the old `IconButton` defaults the icon variant copies; one tap fires once and no ink paints; min 64 x 44; danger colour; semantics and tooltip; text scale 2; the theme's no-ink settings and a stock `InkWell` / `TextButton` painting no ripple in both themes |
| `island_test.dart` | CornerButton (taps only expanded, dot in its corner, hidden, shrink-then-fade, spring back, corner 0/24, reduced motion, theme switch mid-morph), island fits its box, island and tray-action corners at 0/14/24 (dot stays a dot), collapse timeline (opacity holds until the shape is under half height, no overshoot, ends hidden), expand springs, dot stays opaque, dot -> hidden plain fade, reduced-motion cross-fade, spacing tokens and centred tray, depth decoration in both themes (sheen, rim), a directional corner mirrors in right-to-left, the brightness HUD stays left to right under RTL, depth follows the morph (dot low, mid-way between, HUD high, reduced motion jumps, corner button), spring overshoot, HUD model, island sizes per state in both Mono themes, HUD over hidden, tab taps/colours/semantics, 320px at text scale 2, tray layout/taps/disabled/status, status-only tray, tray contrast >= 4.5:1, tray scrolls at 320px and text scale 2, reduced motion; sliding tab pill: equal tab widths at text scale 1 and 2, re-measured after fonts load, pill at index x (tab width + gap) after the slide with the colour fade and height morph in the same frames, reduced-motion jump |
| `settings_shell_test.dart` | Phone/split/desktop layouts at 375/820/1280 and `desktop: true` in both Mono themes, sidebar widths and row heights, phone navigation and system back, back gestures on a pushed shell (iOS edge swipe from a category to the root then off the screen, also from a page opened directly; Android system back the same two steps), a resize to split and back keeping the open page, sidebar selection and accent pill, shell colours from the theme in both brightnesses, `s2` gap under segmented/slider controls in both densities, slider stop labels, Done, `openInitialCategory` on the phone (Done, back to the root) and split, a value row's trailing control and leading widget (text scale 2), every row's callback, group header/hint/footer, standalone rows, text scale 2 at 375 and 1280; right to left: split sidebar on the right, the start inset on the right edge, mirrored chevrons with the back button on the right on the phone, Arabic labels at 375 (text scale 1 and 2) and 820 with no overflow; pinned category: phone card after the list opens its page, split card at the sidebar bottom with the accent ring, Enter/Space, `initialCategory` past the list, text scale 2 in Mono Light |
| `gesture_glyph_test.dart` | The tokens; tap and swipe frames at 0/75/150/400/800/1000 ms and the reversed second loop (pure `frameAt`); each kind's painter frame at 0, 400 and 800 ms in a running glyph; reduced motion paints `still` and schedules no ticks, toggling it stops and restarts the loop; offstage (`TickerMode` off) no ticks, resumes when on; tile size, `surfaceRaised` fill and `ink` dot in both Mono themes at text scale 2; trail and arrow painted; `ExcludeSemantics`; `shouldRepaint` |
| `integration_test.dart` | Image adapters, `AuthHeadersBuilder` (missing provider, failures, rebuilds), dialogs, toast variants |

Run `dart run melos exec --scope=design_system -- flutter test`. Keep
`dart run melos run coverage` at 100%.

## Gotchas

- Geist 400/500/600/700, Noto Sans Arabic 400/500/600/700 (the Arabic
  fallback; static instances from the notofonts repository) and one weight
  of each `DisplayFace` (OFL,
  `OFL-<Family>.txt` alongside) are bundled in `assets/google_fonts/` and the
  app sets `GoogleFonts.config.allowRuntimeFetching = false`, so nothing is
  fetched at launch. Changing `bodyFont` / `displayFont`, adding a face, or
  using another weight means bundling that family's `<Family>-<Weight>.ttf`
  (google_fonts' file name) there too; `fonts_test.dart` fails otherwise.
  A new face also needs its `digitCentre`: the middle of the glyph bounds
  of `0`-`9` over units-per-em (`fontTools` `BoundsPen` over the `.ttf`).
- google_fonts renders the nearest bundled weight: the `title` token's 650
  draws Geist SemiBold.
- With a `face`, all text is one weight (the face's only bundled file):
  titles and body differ by size only. Never ask a face for another weight;
  google_fonts would find no bundled file.
- The island spring overshoots past 1: animate only sizes and positions on
  it (the tab pill may slide a few pixels past the row's ends, so its
  `Stack` does not clip; label colours fade on `fade`, never the spring). A shadow
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
- On the phone, a category page lives in `SettingsShell`'s nested
  `Navigator`. `Navigator.of(context)` from inside a category page finds
  that navigator, not the app's: `showModalBottomSheet` (which defaults to
  the nearest navigator) opened from a row would cover only the shell.
  Dialogs default to the root navigator and are unaffected.
- `FileInfoDialog` takes a `dart:io` `File`, so it does not work on web. Its
  labels come from `strings.files`; the size units (`B`, `KB`, `MB`) stay
  as they are.
