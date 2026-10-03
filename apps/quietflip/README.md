# QuietFlip

An ad-free flip clock, countdown timer and stopwatch for Android, iOS, web,
macOS and Windows. It opens straight onto the clock: no ads, no tracking, and
no account needed. Signing in (Settings > Account) only syncs your settings
across devices.

This folder is the composition root. The clock itself lives in
`features/flip_clock`; platform services (full screen, wake lock, local
notifications, sounds, storage) live in `packages/device_services`.

## Run

From the repository root, once: `dart pub get && dart run melos bootstrap`.
Then from this folder:

| Platform | Run | Build |
|---|---|---|
| Android | `flutter run -d android` | `flutter build appbundle` |
| iOS | `flutter run -d ios` | `flutter build ipa` (macOS + Xcode) |
| Web | `flutter run -d chrome` | `flutter build web --no-web-resources-cdn` (bundles the renderer; nothing loads from a CDN) |
| macOS | `flutter run -d macos` | `flutter build macos` |
| Windows | `flutter run -d windows` | `flutter build windows` (only on a Windows machine) |

**Publish the web app** (Firebase Hosting, `https://quietflip.web.app`):
`flutter build web --release --no-web-resources-cdn`, then
`firebase deploy --only hosting --project quietflip`. Every file is served
`no-cache` (the browser revalidates and gets a cheap 304 when nothing changed),
so a returning visitor gets a new release on the next load. CI does this for
you: once its checks pass, a push to `main` goes live and a pull request gets a
preview link (see the root `CLAUDE.md`).

App Store uploads (iOS and macOS) skip the encryption-documentation question:
both `Info.plist` files declare `ITSAppUsesNonExemptEncryption` = `false`,
because the only encryption is Firebase's TLS and sign-in, which is exempt.

## Launch screen

The logo shows on black from the moment the app opens (iOS, Android,
including the Android 12+ splash, and web), and the first Flutter frame
draws the same logo in the same place. Config is in
`flutter_native_splash.yaml`; after changing it or the logo in
`assets/splash/`, run `dart run flutter_native_splash:create` here, then
`git checkout ios/Runner/Info.plist` (see `CLAUDE.md` for what to keep).

## Keyboard shortcuts

| Key | Action |
|---|---|
| `Space` | Start or pause the Pomodoro timer or stopwatch |
| `←` / `→` | Previous / next mode (Pomodoro, Clock, Stopwatch) |
| `↑` / `↓` | Brightness |
| `S` | Show or hide seconds (Clock) |
| `L` | Lap (Stopwatch) |
| `D` | Dim the digits |
| `F` | Enter or leave full screen |
| `Esc` | Leave full screen, or hide the controls |

## Known limitations

- **Web, closed tab:** a browser cannot alert once the tab is closed. While the
  tab is open, the in-app alert and a browser notification (if allowed) fire.
- **iPhone Safari:** the browser has no full-screen API, so full screen hides
  the app's own controls and fills the viewport instead.
- **Force-closed app:** Android and iOS may drop scheduled notifications for an
  app the user force-stopped (and some Android vendors kill background alarms).
  The timer itself is based on wall-clock time, so reopening the app shows the
  correct remaining time or "Time's up".
- **macOS sign-in** relies on the keychain-sharing entitlement, which only builds when the macOS target is signed by a development team (`QAL4T5U87S` today; see the root `CLAUDE.md` setup table). A contributor outside that team must pick their own team in Xcode, or the Mac build fails to sign.
- **Windows** builds need a Windows machine; they cannot be cross-compiled.
- **Launcher icon** (from `assets/icon/quietflip-master.png`): Android 13 themed
  (monochrome) icons and iOS 18 dark/tinted icons are not generated, so those
  modes show the full-color icon. The Windows `.ico` holds one 256px image that
  Windows scales down. The macOS icon is full-bleed square, without the rounded
  plate macOS 11+ icons usually draw.
- **Firebase is used only for optional settings sync** (Authentication and
  Firestore, project `quietflip`). Analytics, crashlytics, feature flags and
  push notifications stay in the workspace for future use. Local emulators:
  `firebase emulators:start` here, then
  `flutter run --dart-define=USE_EMULATORS=true`. If Firebase cannot start
  (for example `firebase_options.dart` reverted to the placeholder), the app
  still boots and Settings shows no Account card.
