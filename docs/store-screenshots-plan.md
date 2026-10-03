# Store screenshot pipeline: plan

Status: Stages 0-3 built (`apps/quietflip/store_screenshots/`, run with
`flutter test store_screenshots/` from `apps/quietflip`; see
`apps/quietflip/CLAUDE.md`). Stages 4-6 (CI, upload) not started. Tailors a
generic "Flutter integration tests + PixelDeck + GitHub Actions" plan to
Quietflip.

## As built: deviations from this plan

- **14 languages, not 15**: the app ships en ar de es fr hi id it ja ko pt
  ru tr zh.
- **One test file per language** (`locales/<code>_test.dart` calling
  `render.dart`'s `renderLocale`) instead of one `store_screenshots_test.dart`.
  `flutter test` has no font fallback; the script font is registered under
  google_fonts' fallback family names (`Geist`, `BarlowCondensed` ...), which
  cannot be undone, so each language needs its own process. Bonus: files run
  in parallel (all 617 images in about 40 s on an M-series Mac).
- **The countdown is rewired too**, not only the clock and stopwatch: the
  bootstrap's `CountdownController` reads the real clock and turned the seeded
  running Pomodoro into "finished while away". The seed is saved after
  bootstrap and a `CountdownController(now: frozen)` re-registered. `di`
  re-registration works (`unregister` then `register`), so `flip_clock.init()`
  is unchanged.
- **Arabic also loads a font**: the bundled Noto Sans Arabic, registered as
  the digit faces' fallback (AM/PM is ص / م in the skin's face).
- **App Store names** are `NN_<card>_iphone.png` / `NN_<card>_ipad.png`: both
  devices share one locale folder for `deliver`, so `NN_<card>.png` collided.
- **Nightstand is landscape on tablets only**; a sideways phone left half of
  a portrait card empty.
- **Customize** opens the customizer through the real UI (tap, Skins, the In
  use tile's Customize) on a seeded custom skin in Space Grotesk.
- **Product fix found by the run**: in Hindi the In use skin tile's Customize
  button overflowed its 218px caption on the Mac window. Fixed in
  `features/flip_clock` (button capped at the caption width, label wraps) with
  a test.
- Store sizes and fastlane locale codes were not re-checked against the
  stores' live docs in this stage (no web check was run); the values in this
  plan are used, in `targets.dart`.
- **Raw captures are not written** (Stage 1 said "raw, no card"): each
  capture goes straight into its card; the contact sheet is the review.
- The Stage 0 side-by-side with a simulator screenshot is still for you to
  do.

## The one big change from the generic plan

The generic plan uses three moving parts: simulators/emulators to capture the
app, an external design tool (PixelDeck) to hold the template, and a glue
script that swaps images between them. Quietflip does not need any of the three.

**Flutter draws every pixel of Quietflip itself**, and Flutter can draw a
widget tree straight to a PNG inside `flutter test`, on a plain Linux runner,
with no simulator. So both halves of the pipeline become Dart:

1. **Capture:** boot the real app (real `bootstrap` modules, real router, real
   `FlipClockScreen`) with seeded settings and a frozen clock, at each store
   device's logical size and pixel ratio, and render it to a PNG.
2. **Compose:** a second widget, the store card (background, headline, device
   frame, the captured PNG inside), built from `design_system` tokens and Geist,
   rendered to the store's exact pixel size.

| | Generic plan | Quietflip plan |
|---|---|---|
| Capture | `integration_test` on iOS simulator (macOS runner) + Android emulator | `flutter test` on `ubuntu-latest`, same job type CI already runs |
| Template | PixelDeck project file + CLI | A Flutter widget in the repo, reviewed like code |
| Glue | Script mapping captures to template slots | None: the card takes the capture as a constructor argument |
| Fonts/colours | Re-entered in the design tool, drift over time | `DesignSystem` tokens and bundled Geist: brand changes flow through automatically |
| Localized headlines | Per-locale copy in the design tool | One YAML per locale next to the cards, same 15 languages the app ships |
| CI cost | macOS minutes (~10x Linux) + flaky emulator boots | Linux minutes, minutes per full run |

**What this gives up:** the captures are not taken on a real OS. Nothing
native is on screen in Quietflip's showcase screens (the clock runs full
screen, so there is no status bar to fake), so the output should match a
simulator screenshot. Stage 1 proves that with a side-by-side; if it fails,
fall back to `integration_test` on a simulator for capture only and keep the
Flutter card renderer.

**Why not PixelDeck:** it adds a paid/external tool, a second source of truth
for typography and colour, and an unproven "replace the screenshot via CLI"
step (the generic plan itself flags that as unvalidated). Our renderer is the
app's own rendering engine.

## Targets and sizes

Verify every number against the stores' current docs in Stage 0; these change.

| Store | Slot | Pixels | Notes |
|---|---|---|---|
| App Store | iPhone 6.9" | 1320 x 2868 | Required; Apple scales it down for smaller iPhones |
| App Store | iPad 13" | 2064 x 2752 | Required because the iOS target supports iPad |
| Mac App Store | Mac | 2880 x 1800 | 16:10 |
| Google Play | Phone | 1080 x 1920 | 2-8 images, 9:16 |
| Google Play | 7" and 10" tablet | 1200 x 1920, 1600 x 2560 | Optional but improves tablet listing |
| Google Play | Feature graphic | 1024 x 500 | Required; no app capture, a pure card |
| Microsoft Store | Desktop | 1920 x 1080 | |
| Web | Social preview (`og:image`) | 1200 x 630 | Free bonus: same card renderer, used by `quietflip.web.app` |

Each target also sets `debugDefaultTargetPlatformOverride` (iOS, Android,
macOS, Windows) so platform-adaptive UI, such as the Settings > Shortcuts
groups from `FlipClockRouter.shortcutsFor`, shows what that platform's users
actually see.

## Proposed card set (copy is a draft for you to rewrite)

| # | Capture ID | Screen and state | Draft headline |
|---|---|---|---|
| 1 | `clock` | Clock mode, Mono skin, Mono Dark, 10:09, large cards | A flip clock. No ads. |
| 2 | `pomodoro` | Pomodoro running, focus phase, 18:42 left, controls visible | Focus in calm cycles |
| 3 | `stopwatch` | Stopwatch at 03:27.4 with three laps | Laps, splits, nothing else |
| 4 | `skins` | Skins sheet open over the clock | 20+ skins and faces |
| 5 | `customize` | Skin customizer, custom colours | Make it yours |
| 6 | `nightstand` | Landscape, Nightstand skin, dimmed digits, date on | Made for the nightstand |
| - | none | Feature graphic and `og:image` | Wordmark + one line |

Every claim on a card must be true of the shipped build (for example, only say
"no tracking" if the release build has no analytics module enabled). You
approve the copy and order once; after that it is data in the repo.

## How state is made predictable

Everything below uses seams that already exist; the goal is **no production
code change**.

- **Time:** `ClockController({DateTime Function()? now})` already takes a
  clock. The capture re-registers it in `di` with a fixed `10:09:30` after
  `flip_clock.init()` (the capture runner is a composition edge, where
  `di.get`/`di.register` are allowed).
- **Settings and countdown:** seed the in-memory `SharedPreferencesAsync`
  (already used by `apps/quietflip/test/clock_support.dart`) with
  `ClockSettings` JSON under `flip_clock.settings` and a countdown under
  `flip_clock.countdown`, so the real `SettingsRepository` loads them.
- **Stopwatch:** `flip_clock.init()` registers `StopwatchController(stopwatch:
  Stopwatch())`; the runner replaces it with one over a fake `Stopwatch` at a
  fixed elapsed time, then calls `lap()` three times.
- **Firebase:** off, as in the existing app tests; the app already boots
  without it. No network, per the repo rules.
- **Plugins:** the same mocked channels as `clock_support.dart` (audio, device
  info); notifications, wake lock and full screen stay absent.
- **Animation:** `testWidgets` runs on fake time; pump past every flip and
  chrome transition with `pumpAndSettle`, with explicit `find.byKey` readiness
  checks instead of delays.
- **Locale and text scale:** set per run; text scale fixed at 1.0.

If Stage 1 shows that re-registering in `di` is not supported, the fallback is
an optional `now`/`stopwatch` parameter on `flip_clock.init()`, tested like
any other change.

## Fonts (the main gotcha)

`flutter test` renders with a placeholder font unless fonts are loaded by hand,
and it has **no system font fallback**:

- Geist, the ten digit faces and Noto Sans Arabic are bundled in
  `design_system`; the runner loads them from the font manifest with
  `FontLoader`, plus the Material icons font from the Flutter SDK.
- **Japanese, Korean, Chinese and Hindi** are drawn by the device's system
  fonts in the real app, and the repo bundles none. Without action those
  locales render as empty boxes. Plan: download pinned Noto Sans JP / KR / SC /
  Devanagari files (checksum-verified, cached) in the capture step only. They
  never ship in the app. The screenshots will show Noto where a real phone
  shows its own system font; visually close, worth calling out.

## Repository layout

```
apps/quietflip/store_screenshots/
  store_screenshots_test.dart   entry: loops targets x locales x cards, writes PNGs
  targets.dart                  store slots: pixel size, logical size, platform
  scenarios.dart                one function per capture ID: seed state, navigate, ready-check
  card.dart                     StoreCard widget: background, headline, frame, capture
  device_frame.dart             drawn phone/tablet/laptop bezels (no third-party frame assets)
  contact_sheet.dart            all cards for one locale on one image, for review
  fonts.dart                    FontLoader for bundled + CI-downloaded fonts
  copy/en.yaml ... copy/zh.yaml headlines, one file per app locale
tool/fetch_store_fonts.dart     downloads and verifies the CJK/Devanagari fonts
.github/workflows/store-screenshots.yml
```

- Lives in the app because it composes the whole app; nothing imports it, so
  the dependency direction rule holds.
- Not under `test/`, so `melos run test` and the coverage gate skip it (it is
  slow and writes files). Run it with
  `flutter test store_screenshots/` from `apps/quietflip`.
- `tool/check.dart` only lints `lib/` and `test/`; it must be extended to
  `store_screenshots/` or this code goes unlinted.
- Headlines stay out of `messages.i69n.yaml` so marketing text does not bloat
  the app bundle. A test asserts every `copy/*.yaml` has every key the English
  file has.
- Card list is a Dart `const` list, not a YAML manifest: type-checked, no
  parser to write.
- Output (as built, fastlane-shaped): see `apps/quietflip/CLAUDE.md`, Store
  screenshots. Build output, never committed.

## Validation built into the run

- Every target x locale x card produced a file; the run fails on any missing.
- Every PNG has the exact pixel size its slot requires.
- Each capture's ready-check found its key widget, or the test fails with the
  card ID and locale in the message.
- Fails if a headline overflows its box (the card measures text, and long
  German and Russian copy is the likely case) rather than silently clipping.
- No pixel diff against the last release: changing UI is the point.

## CI workflow (`store-screenshots.yml`)

| Trigger | What runs |
|---|---|
| `workflow_dispatch` | Full set, while building and whenever you want fresh images |
| Push of a `v*` tag | Full set from the exact release commit |
| PR, later and optional | English-only contact sheet, commented on the PR like the hosting preview |

One `ubuntu-latest` job, Flutter pinned to `3.47.5` as in `quality.yml`:
checkout, `flutter pub get`, fetch fonts (cached), run the capture, upload one
ZIP per store plus the contact sheets as artifacts. Expected size: ~6 cards x
~7 slots x 15 locales, about 600 PNGs.

## Store upload (last, and separate)

Every store's images are generated from Stage 4 on. Upload is wired per store
as its listing exists: today only App Store Connect is set up, so Stage 5
uploads iPhone, iPad and Mac only. Google Play and Microsoft Store upload are
follow-ups once those listings exist; until then their ZIPs are uploaded by
hand from the CI artifact.

- Uploading is a separate manual workflow that takes a screenshots run's
  artifact, so a rendering failure can never block or alter an app release.
- Tooling: fastlane `deliver` (App Store and Mac App Store) and `supply`
  (Google Play), which both take a folder per locale; the output layout above
  is chosen to match them.
- Needs secrets you create by hand: an App Store Connect API key (`.p8`, key
  ID, issuer ID) and a Google Play service account JSON. Never committed.
- Locale codes differ per store (our app `zh`, App Store `zh-Hans`, Play
  `zh-CN`); a small map in `targets.dart` translates.

## Stages, each ends with something you can look at

| Stage | Delivers | Acceptance | Rough size |
|---|---|---|---|
| 0. Spike (built) | Card 1 (clock), iPhone 6.9", English, run locally | PNG at 1320x2868; you compare it with a simulator screenshot of the same state and agree they match | 0.5 day |
| 1. Captures (built) | All 6 capture scenarios, all slots, English, raw (no card) | Two runs on the same commit give identical-looking images; a broken ready-check fails the run | 1 day |
| 2. Template (built) | `StoreCard`, frames, feature graphic, contact sheet | You approve layout, copy and order from the contact sheet | 1-2 days + your review |
| 3. Locales (built) | 15 locales, fonts, overflow check, RTL for Arabic | Contact sheet per locale; no empty boxes in ja/ko/zh/hi; Arabic laid out right-to-left | 1 day + translations |
| 4. CI | `store-screenshots.yml`, artifacts | Manual run on GitHub produces the full ZIP | 0.5 day |
| 5. Upload | fastlane `deliver` lane + upload workflow (App Store + Mac App Store) | App Store Connect listing updated from a CI artifact | 1 day once the API key secret exists |
| 6. Upload, later | `supply` (Play) and Microsoft Store submission | Same, per store | 0.5-1 day each, after each listing exists |

The first milestone matches the generic plan's: change something visible in
`FlipClockScreen`, run one command, see it inside the approved card with no
design tool opened.

## How future changes are handled

| Change | What happens |
|---|---|
| UI inside an existing screen | Picked up on the next run, no other work |
| Brand colour, font or corner token | Flows into both the app captures and the cards |
| New skin or feature worth a card | Add a scenario function and a row in the card list |
| Navigation change | Update that scenario's navigation; its ready-check fails loudly until then |
| Headline change | Edit `copy/en.yaml`, then the 14 translations |
| New app locale | Add `copy/<code>.yaml` (the key-parity test enforces it) and, if the script needs it, a font |
