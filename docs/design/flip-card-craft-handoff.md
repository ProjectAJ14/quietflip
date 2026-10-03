# Flip card craft (hinges in notches, bevel, split line, a real flip): handoff

Base: `main` at 28137a0 (hinge pins shipped in ProjectAJ14/quietflip#34, quiet launch in #36).
Previous briefs, still valid where this one is silent:
`docs/design/sound-picker-handoff.md`, `docs/design/multi-skin-handoff.md`
(its "Flip cards" rules are replaced by this brief), `docs/design/fullscreen-clock-handoff.md`.

Design source: **the app icon**, `apps/quietflip/assets/icon/quietflip-master.png`
(1254 px square). Every proportion below was measured from it in icon units
(the icon drawn at 1024) and divided by the icon's card height, **h = 608**. Open it at
400% around the hinge between the two cards (icon 440..580 x 420..570) before writing a
line of paint code; that crop is the target.

This is the brief for the coding agent. Follow the repository `CLAUDE.md` and the
nested `CLAUDE.md` files on the path (`features/flip_clock`, `packages/design_system`):
100% line coverage, colours and shapes from the design system or the skin, radii only
through `DesignShape` (`corner_rule_test.dart`), generated files read-only. Load the
`design-system` and `flutter-best-practices` skills before any UI work.

## The feedback, verbatim intent

1. The hinge PR (#34) came out badly. The cards must look like the app icon.
2. Look closely at the icon's hinges: how they sit in the card and how the card turns
   about them.
3. Look closely at the corners.
4. The flip must work like the real mechanism.
5. Custom painting is expected; widgets stacked on widgets are not good enough.

## What is wrong today (verified)

Rendered `FlipDisplay` at a 300 px card and a 60 px tile, still and mid-flip, and
compared with the icon. Each row is read from `features/flip_clock/lib/ui/components/flip_display.dart`.

| # | Icon | Today | Where |
| --- | --- | --- | --- |
| 1 | Pin sits **inside a notch cut into the card**, its outer face flush with the card's side edge. Nothing sticks out | Pin is a separate widget **centred on the edge, half outside the card**, floating in the gap like a tab | `_FlipCardState.build` `pin()` (`left: -pinWidth / 2`), lines 369-379 |
| 2 | Pin is a **metal cylinder** lying along the split line: one bright band near its top, dark below, thin bright rims at both ends | Pin is a flat blob: top-to-bottom grey gradient and a ground line drawn through its middle | `_HingePainter.paint`, lines 535-566 |
| 3 | The split line **stops at the notch**; it is a dark crack with a bright lip under it (the bottom flap's edge catching light) | A 2 px line runs the full card width **through the pins**; the light half is 12% off ground, invisible | `_Seam`, lines 475-496 |
| 4 | Card is **lit from above**: top half fades 60 -> 36 luminance, bottom half 42 -> 33; a 1-2 px bright rim on the top edge, fading down the sides | Card is one flat colour; no rim, no bevel. Corners are the right radius but read as cut-outs, not a physical edge | `_Half` `BoxDecoration(color: skin.cardColor)`, line 613 |
| 5 | The split line passes through the **middle of the digit** | Digits sit **3.7% of h low** (22 px on a 600 px card). The line box is centred, not the glyph: with `height: 1` the theme's leading crops the font's ascent and descent unevenly, so the ink centre drifts per face | `_Half` `OverflowBox` + `Center`, lines 631-652 |
| 6 | One axle: both halves turn about the **centre of the crack** | Top flap turns about the seam's top edge, bottom flap about its bottom edge, so the axle jumps by the seam height mid-flip | `_Fold` `alignment`, line 465 |
| 7 | (motion, not in the icon) A real flap falls under gravity and slaps down | One `easeInOut` turn: the flap slows down as it reaches edge-on, which no falling object does | `FlipDisplay.flipCurve`, line 72 |
| 8 | On a small tile the icon would show no detail it cannot draw | At 60 px the pins are 3 px specks that read as dirt on the card edge | `hingeWidth`, no minimum size |

Rows 1, 2, 3 and 8 also force the width maths in `_FlipDisplayState.build`
(`across()`, the half-pin padding, `hingeMaxWidth`) that exists only because pins stick
out. It is deleted, not adjusted.

## The target, measured from the icon

All values are fractions of the card height **h**. `r` is the card corner from
`DesignShape` (unchanged, see Decisions). Light comes from straight above.

### Geometry

| Part | Rule (icon units / 608) |
| --- | --- |
| Split axis | `axisY = h / 2` exactly. Both flaps turn about this line |
| Crack (gap between halves) | height `max(1, 0.008h)`, centred on `axisY`; spans from notch to notch, never through a pin |
| Lip (bottom half's top edge) | height `max(0.5, 0.005h)`, directly under the crack |
| Notch (cut into each side of the card) | width `0.045h`, height `0.125h`, centred on `axisY`, open to the side edge. Inner (concave) corners radius `0.015h`; the two corners where the notch meets the side edge rounded `0.006h` |
| Pin (in each notch) | width `0.035h`, height `0.104h`, centred on `axisY`; **outer face flush with the card edge** (x = 0 on the left, x = width on the right). Clearance to the notch: `0.010h` on the inner side, `0.0105h` top and bottom. Corner radius `0.3 x pin width` |
| Halves | each half is the card's rounded rectangle cut at `axisY`, minus its half of both notches (the axle splits each notch, so the top half carries the top half of both notches and the bottom half the bottom half) |
| Detail threshold | below **h = 80 px** draw no notch and no pins; crack and lip only (at 80 px the pin is 2.8 px wide, the smallest that still reads as an object) |

Implement this as one pure value class, `FlipCardGeometry(Size size, double radius)`,
in `features/flip_clock/lib/ui/components/flip_card_geometry.dart`, exposing
`axisY`, `crack`, `lip`, `notchLeft`/`notchRight` (`RRect`s), `pinLeft`/`pinRight`
(`RRect`s), `hasHinges`, and `halfPath({required bool top})`. Every number above lives
in it as a named `static const` with a one-line comment saying it comes from the icon.
It is the only place these numbers exist. Radii go through `DesignShape.radius`.

### Paint (derived from the skin, works for dark and light skins)

No new colour tokens; every shade is derived from the skin's three colours with
`HSLColor` so a light skin (Paper) gets a dark crack, not a light one. Define in the
painter file: `shadeOf(c, k)` = lightness x (1 - k); `lightOf(c, k)` = lightness +
(1 - lightness) x k.

| Part | Paint |
| --- | --- |
| Top half fill | vertical gradient, top `lightOf(card, 0.10)` -> at the crack `shadeOf(card, 0.12)` |
| Bottom half fill | at the crack `card` -> bottom `shadeOf(card, 0.18)` |
| Top rim | 1 logical px stroke along the top edge and round the two top corners, `lightOf(card, 0.55)`, fading to transparent by `0.25h` down each side (a gradient shader on the stroke) |
| Crack | `shadeOf(card, 0.85)`; the last `0.002h` of the top half above it darkened by `shadeOf(card, 0.4)` (the flap's underside) |
| Lip | `lightOf(card, 0.45)` |
| Notch | filled `shadeOf(card, 0.85)` (the dark cavity the pin sits in) |
| Pin body | vertical gradient on the pin `RRect`, stops from the icon: 0.00 `shadeOf(card,0.6)`, 0.10 `lightOf(card,0.35)`, **0.22 `lightOf(card,0.75)`** (the specular band), 0.40 `lightOf(card,0.15)`, 0.75 `shadeOf(card,0.35)`, 1.00 `shadeOf(card,0.55)` |
| Pin end rims | 1 px vertical lines at both ends of the pin, `lightOf(card, 0.6)` at 60% alpha (the cylinder's end caps) |
| Pin outline | 0.5 px stroke `shadeOf(card, 0.85)` (separates it from the notch wall) |

## How the flip works (item 4)

A real split-flap: the upper flap is released, falls toward the viewer about the axle,
and slaps onto the lower half with a small bounce. The pins never move; the flaps turn
**between** them, so the flap's shape carries the notch and the pins are always painted
on top.

| Rule | Value |
| --- | --- |
| Total | `DesignMotion.flip` (360 ms), unchanged |
| Fall, 0 -> pi | first 300 ms, `Curves.easeIn` (gravity: speeds up all the way down). Top flap shows the old value until pi/2, the bottom flap the new value after |
| Bounce | last 60 ms: bottom flap lifts to pi - 0.06 rad (3.4 degrees) and settles, `angle = pi - 0.06 x sin(pi x u)`, u 0..1 |
| Axle | both flaps rotate about `axisY` (a `Transform` with `origin` at the axle, not `alignment` at the half's edge) |
| Perspective | unchanged: `0.4 / h` |
| Falling flap shade | multiply toward `shadeOf(card, 0.5)` by `sin(turn)` (it turns its face away from the light) |
| Landing flap light | while turn is pi/2 .. pi, lighten toward `lightOf(card, 0.12)` by `sin(turn)` (its face points up into the light), then plain on landing |
| Cast shadow | on the bottom half while the top flap falls: gradient from the crack, `shadeOf(card, 0.5)` at alpha `0.45 x sin(turn)` -> 0 at 60% of the half, as today but with the new colour |
| Interrupts | unchanged from today (a change while falling keeps falling; while landing or still, falls again from the shown value) |
| Reduced motion | instant swap, no shade, no bounce; geometry and pins unchanged |

## Delivery order

One pull request, one commit (or more) per stage, in this order. Run
`dart run melos run lint` and `dart run melos run coverage` after each stage.

1. **Digit centring** (row 5). A bug; fix and test it first.
2. **Geometry** (rows 1, 3, 6, 8). `FlipCardGeometry`, halves cut by its path, pins
   inside the card, the width maths deleted.
3. **Paint** (rows 2, 3, 4). The card painter and the pin painter.
4. **Motion** (rows 6, 7). Axle, gravity curve, bounce, shading.

## Stage 1: digit centring

- **Root cause (verified):** the half centres the `Text`'s line box on the axle. With
  `height: 1` the line box crops ascent and descent by the theme's leading rule, so the
  glyphs sit below centre: measured 0.07 x font size low for Barlow Condensed in the
  app (22 px on a 600 px card). Faces differ, so a single offset cannot fix it.
- **Fix at the face, where every caller routes through:** add `digitCentre` to
  `DisplayFace` (`packages/design_system/lib/constants/design_fonts.dart`): the height
  of the digits' vertical centre above the baseline, in em. Measured from each bundled
  `.ttf` (glyph bounds of `0`-`9`, `fontTools` `BoundsPen`):

| Face | `digitCentre` |
| --- | --- |
| barlowCondensed | 0.351 |
| bebasNeue | 0.350 |
| anton | 0.429 |
| oswald | 0.404 |
| bigShoulders | 0.400 |
| archivoBlack | 0.344 |
| jetBrainsMono | 0.365 |
| spaceGrotesk | 0.350 |
| dmSerifDisplay | 0.315 |
| orbitron | 0.360 |

- In `_Half`, place the digits by baseline, not by box: the full-card-height box holds
  a `Baseline(baseline: axisY + digitCentre x fontSize, baselineType: alphabetic)` around
  the `Text`, so the digit centre lands on the axle for any leading. Keep the
  `FittedBox(scaleDown)` outside a box of the full card height so a shrink scales about
  the axle and the digit stays centred.
- Tests: a failing test first, `flip_display_test.dart`: for every `DisplayFace`, the
  `Text`'s alphabetic baseline (`RenderParagraph.getDistanceToBaseline`) minus
  `digitCentre x fontSize` equals the card's `axisY` within 0.5 px, in both halves and on
  a shrunk (wide-face) card. `design_system/test/fonts_test.dart`: every face has a
  `digitCentre` in 0.25..0.5.

## Stage 2: geometry

- Add `FlipCardGeometry` (rules above). Pure Dart over `dart:ui`; no widgets.
- `_Half` clips to `geometry.halfPath(top:)` with a `ClipPath` + a private
  `CustomClipper<Path>` (`shouldReclip` on size, radius). Delete the `BoxDecoration`
  corners; the path owns the shape, so the flap (the same `_Half`) carries the notch too.
- Pins move inside the card: drop the `Positioned(left: -pinWidth / 2)` widgets. Delete
  `hingeWidthScale`, `hingeHeightScale`, `hingeMaxWidth`, `hingeWidth()`, the `across()`
  helper and the horizontal half-pin `Padding` in `_FlipDisplayState.build`. Card width
  is `height x ratio` again, gap `space-6`.
- Delete `_Seam` (the crack and lip are painted in stage 3; the layout no longer
  reserves `seamHeight`: both halves are `h / 2` and the crack is painted over the
  join). Delete `seamHeight`.
- Keep `FlipDisplay.hingeKey`, now on the one `CustomPaint` that draws pins and crack,
  so tests can still find it (one per card, not two).
- Tests (`test/flip_card_geometry_test.dart`, new): at h = 608 every rect matches the
  table within 0.5 units; pins are inside the card's bounds and flush with its sides;
  pins sit inside their notch with the stated clearance; the crack ends at the notches;
  `hasHinges` false at 79 px, true at 80; `halfPath(top: true)` contains a point just
  above the axle in the card middle and not one inside the notch; zero and tiny sizes
  return empty paths without throwing.
  In `flip_display_test.dart`: no pin pixel outside the display's box; display width
  equals `n x height x ratio + (n - 1) x space-6` exactly.

## Stage 3: paint

- One private `_CardPainter extends CustomPainter` per card, on a `CustomPaint`
  **foreground** over the halves and flap: crack, lip, notch cavities, pins (in that
  order, pins last). One private `_FacePainter` as each `_Half`'s background: the
  half's gradient fill and, on the top half, the rim. Both take the geometry and the
  three skin colours; `shouldRepaint` compares those only (they never repaint per
  animation frame; only the flap's `Transform` changes).
- Shading helpers `shadeOf` / `lightOf` are top-level private functions in the painter
  file. No `Color(0x...)`; `corner_rule_test.dart` must still pass.
- The card stays one `RepaintBoundary`.
- Tests: use `flutter_test`'s `paints` matcher on the card's `CustomPaint`
  (`paints..rrect()..rrect()...`): two pin rrects at the geometry's rects when h >= 80,
  none below; the crack rect painted with the `shadeOf(card, 0.85)` colour; for the
  Paper skin the crack is darker than the card (light-skin check) and for Mono darker
  too. `_FacePainter`: top half gradient's first stop is lighter than its last; the
  bottom half's first stop is the card colour. `shouldRepaint` false for equal inputs,
  true when any colour or the size changes.

## Stage 4: motion

- Replace `flipCurve` with the fall + bounce rules above. Keep one `AnimationController`
  of `flipDuration`; map its value to an angle with one pure function,
  `static double turnAt(double t)` on `FlipDisplay` (testable without widgets).
- `_Fold` rotates about the axle: `Transform(origin: Offset(0, axisY - halfTop), ...)`
  with the half's local coordinates, not `alignment`.
- Shade the falling flap and light the landing flap per the table (`_FacePainter`
  takes `shade` and `light` amounts instead of `_Half`'s `foregroundDecoration`).
- Tests: `turnAt(0) == 0`; `turnAt` is increasing on 0..300/360 and its slope grows
  (gravity); `turnAt(300/360) == pi`; on the bounce, the minimum is `pi - 0.06` at
  330/360 and `turnAt(1) == pi`. In widget tests: both flaps' `Transform` origin is
  on the axle; mid-fall the flap is darker than the card, mid-landing lighter;
  reduced motion swaps in one frame with no flap. Existing interrupt tests keep
  passing unchanged.

## Strings, data and migrations

None. No new setting, no JSON change, no user-facing text.

## Tests the gate expects

- Face: every `DisplayFace` has a `digitCentre`; digits centred on the axle per face.
- Geometry: every rect and path from the table, thresholds, degenerate sizes.
- Paint: pins, crack, notch and fills painted from the skin, light and dark skins,
  `shouldRepaint`.
- Motion: `turnAt` shape, axle origin, shade and light, reduced motion, interrupts.
- Layout: display width exact, nothing painted outside the display.

## Acceptance

Compare each with `quietflip-master.png` open beside the running app (Mono skin, Large).

- The pins sit in notches inside the card edge; nothing sticks into the gap between
  cards. At 400% they read as metal rods with one bright band near the top.
- The split line is a dark crack with a thin bright lip under it, and it stops at each
  notch.
- The top edge of every card has a thin highlight that fades down the sides; the top
  half is a touch lighter than the bottom half.
- The split line goes through the middle of every digit, in all ten faces (Settings >
  Skins > customize, cycle the faces).
- A flip: the top flap accelerates down, lands, and bounces once, barely. The pins never
  move and the flaps pass between them.
- On Paper (light skin) the crack and notches are dark, not light.
- Skin tiles in the picker show the crack and lip but no pins (cards under 80 px).
- Reduced motion: instant change, cards still look the same.
- Works on web (`flutter run -d chrome`), macOS and a phone.

## Docs to update in the same PR

`features/flip_clock/CLAUDE.md` (the `FlipDisplay` rule paragraph: replace the hinge,
seam and flip sentences with the geometry, paint and motion above, and add
`flip_card_geometry.dart` to Layout) and `features/flip_clock/README.md`;
`packages/design_system/CLAUDE.md` (`DisplayFace.digitCentre`) and its `README.md`;
`docs/design/multi-skin-handoff.md` line 120 ("The seam is a 2px...") points to this brief.

## Decisions taken for the user (change here if wrong)

- **Two digits per card stays.** The icon shows one digit per tall card (0.69 x h
  wide); the app puts a pair on a square card. Switching would change layout, stacking,
  tiles and every screen test. Cost: the cards are not the icon's shape, only its
  material. Ticket it if wanted (about a day).
- **The card corner stays the user's Corners setting** (`DesignShape` md/lg). At the
  default 14 on a large card that is 22 px on 300 px = 0.073 h, the icon's 0.074 h, so
  it already matches. Cost: a user who picks Square gets square cards with round pins;
  that is their choice.
- **Hybrid: painters for the card, `Text` widgets for the digits.** Rejected: one
  `CustomPainter` drawing digits with `TextPainter` (more control, but breaks every
  `find.text` in the screen tests and the semantics checks for no visual gain).
- **No hinges below 80 px.** Rejected: scaled-down pins on tiles (3 px specks, today's
  "dirt" look). Cost: tiles are not pixel-identical to the clock.
- **Gravity fall with a 3.4 degree bounce** instead of `easeInOut`. Rejected: no bounce
  (reads as a slide, not a slap); a bigger bounce (busy at one flip per second).
- **No paper-grain texture.** The icon has a faint grain on the cards. It costs a
  shader or image per card and is invisible at a metre. Skip.
- **Digit size not normalised across faces.** The icon's digit is 0.72 h tall; ours is
  0.78 h font size, and ink height varies per face (Anton 0.87 em, DM Serif 0.67 em).
  Only centring is fixed here; same-height digits for every face is a separate ticket.
