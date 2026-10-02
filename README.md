# QuietFlip

An ad-free flip clock, countdown timer, and stopwatch for Android, iOS, web,
macOS and Windows. It launches straight onto the clock: no account needed, no
dashboard, no ads, no analytics. You only need to sign in (Settings > Account,
at the bottom) if you want your settings on your other devices. The Black theme
is the default even when the OS is in light mode.

[![nonstop_cli](https://img.shields.io/badge/started%20with-nonstop_cli-166C4E.svg?style=flat-square)](https://pub.dev/packages/nonstop_cli)
[![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)

## Layout

```
apps/quietflip      the application shell: bootstrap, router, splash
features/                      vertical slices (ui + state + data)
packages/                      shared capabilities
plugins/                       native integrations
```

Dependencies point inward: apps depend on features, features depend on
packages, packages depend on nothing above them.

### What is already wired

| Module | Role |
| --- | --- |
| `packages/core` | logger, DI bootstrap, route observers, error types, BLoC observer |
| `packages/di` | service locator (GetIt) behind a small interface |
| `packages/design_system` | Material 3 theme, shared components, toasts, loaders |
| `packages/localization` | type-safe strings generated from YAML (i69n) |
| `packages/utils` | dependency-light helpers |
| `packages/timekeeping` | pure-Dart countdown state machine and clock/timer/stopwatch formatting |
| `packages/device_services` | full screen, screen wake, local notifications, sounds, key-value storage |
| `packages/cloud_sync` | offline-first sync of the signed-in user's documents (Firestore), sync status |
| `packages/network` | Dio client, auth + logging interceptors, typed errors |
| `packages/analytics` | event tracking behind a swappable client |
| `packages/crashlytics` | crash and non-fatal reporting |
| `packages/notifications` | FCM, permissions, device-token registration |
| `packages/feature_flags` | Remote Config flags with a widget wrapper |
| `packages/developer` | in-app dev tools, reachable by a hidden 5-tap gesture |
| `features/auth` | Firebase Auth (email, Google, Apple) + route guards |
| `features/dashboard` | bottom-navigation shell with starter tabs |
| `features/flip_clock` | flip clock, countdown timer, stopwatch and settings (the launch screen) |


## Getting started

Use Flutter 3.47.5 or newer. The root `pubspec.yaml` declares the native Dart
workspace and Melos scripts; member packages share a single dependency lockfile.

```sh
dart pub get
dart run melos bootstrap
```

### Firebase

Firebase project `quietflip` is configured. QuietFlip uses Authentication and
Firestore only for optional settings sync; the clock never waits for them.
Every settings change is saved on the device first, then synced when there is
a connection. Run locally against the emulators:

```sh
cd apps/quietflip
firebase emulators:start                                   # terminal 1
flutter run -d chrome --dart-define=USE_EMULATORS=true     # terminal 2
```

The template's other Firebase modules (analytics, crashlytics, feature flags,
FCM notifications, dashboard) stay in the workspace for future scope. One-time
console steps (enabling sign-in providers and so on) are listed in
`CLAUDE.md` under First-time setup.

### Run and build

```sh
cd apps/quietflip
flutter run -d chrome          # or -d macos, -d windows, an Android/iOS device
flutter build web --no-web-resources-cdn   # bundle the renderer; also: appbundle, ipa, macos, windows
```

Windows builds only run on a Windows machine; iOS and macOS need Xcode.
See [apps/quietflip/README.md](apps/quietflip/README.md) for the per-platform
table.

### Keyboard shortcuts

`Space` start/pause the Pomodoro timer or stopwatch, `←` / `→` change mode
(Pomodoro, Clock, Stopwatch), `↑` / `↓` brightness, `S` show seconds (Clock),
`L` lap (Stopwatch), `D` dim the digits, `F` full screen, `Esc` leave full
screen or hide the controls.

### Known limitations

- Web: a closed tab cannot alert; alerts work only while the tab is open.
- iPhone Safari has no full-screen API: full screen hides the app's controls
  and fills the viewport instead.
- A force-closed mobile app may lose its scheduled notification (OS policy);
  reopening it still shows the right remaining time or "Time's up".
- Settings sync is last-write-wins per device change: two devices changing
  different settings offline within the same second can lose one change.

Every environment value is a `--dart-define` read in
`packages/core/lib/constants/environment.dart`. Add new ones there rather than
scattering `String.fromEnvironment` around the codebase.

To run against the Firebase emulator suite, add
`--dart-define=USE_EMULATORS=true`.

## Day-to-day

```sh
dart run melos run lint       # format-check and analyze
dart run melos run test       # run every package's tests
dart run melos run coverage   # tests + strict 100% line-coverage gate
dart run melos run generate   # rebuild serializers
dart run melos run generate:i69n  # rebuild localization
```

## Adding to the monorepo

```sh
nonstop create my_feature --template package -o features
nonstop create my_package --template package -o packages
nonstop create my_second_app --template app -o apps
nonstop create my_plugin --template plugin -o plugins
```

## Where to start

1. The product is `features/flip_clock`; platform services are in
   `packages/device_services`; time maths is in `packages/timekeeping`.
2. Product strings are in `packages/localization/lib/messages.i69n.yaml`
   (`clock` group).
3. The dashboard and auth routes are still registered in
   `apps/quietflip/lib/router/router.dart` but nothing in the UI links to them.

## Architecture and testing

The starter separates the app view, routing, startup and foreground lifecycle.
Clients accept injected SDKs, loggers and transports; feature code consumes small
interfaces rather than subclassing platform SDKs. See [architecture](docs/architecture.md)
for the SOLID boundaries and an example of adding a tested feature.

Every generated package has tests. Unit and widget tests run without a Firebase
account or network service; Firebase integration tests use offline platform doubles.
The strict gate imports otherwise-unloaded libraries, runs all suites, merges their
LCOV records and requires **100% executable-line coverage of workspace `lib/` code**.
It includes entrypoints, startup, theme and error paths. Only compiler-generated
`.g.dart`, `.freezed.dart` and `.i69n.dart` files, and web-only `*_web.dart`
files (they import `dart:js_interop`, which the VM test runner cannot compile),
are excluded. Keep `*_web.dart` files to thin browser calls behind a VM-tested
contract.

```sh
dart run tool/coverage.dart
# Inspect existing reports without rerunning tests (not a validation run):
dart run tool/coverage.dart --report-only
```

The gate fails for failed tests, missing tests/reports, or uncovered lines.
The merged report is `coverage/lcov.info`. Do not run two coverage jobs in the
same checkout: each owns a temporary `test/coverage_imports_test.dart` fixture,
removed on normal completion. After an interrupted run, inspect and remove only
that generated fixture before retrying.

Coverage is not a proof of correctness, branch completeness, security, or native
plugin compatibility. Keep assertions about behavior, and add device integration
tests for your Firebase project, native permissions, provider sign-in and backend.
The GitHub Actions workflow (`CI`) runs three parallel jobs: Lint, Tests (100% coverage) and Web build. It runs on pull requests and pushes to `main`; a newer push cancels the older run, and changes that only touch `.md` files skip it.

### Authentication and demo mode

`GoAuthRoute` denies access when authentication is missing or signed out.
The starter dashboard explicitly allows **unconfigured demo mode** so
you can explore it before `flutterfire configure`. It contains no protected data.
Do not use `allowUnconfigured: true` for real protected routes.
Client-side guards are navigation helpers; enforce authorization in
backend endpoints and Firebase security rules.

### Notifications

The SDK client owns subscriptions, not navigation or toast widgets. The app
supplies callbacks, queues cold-start routes until the router is ready, and owns
foreground lifecycle handling. Device IDs are random per installation and
persisted locally; they are not hardware fingerprints.

Implement the `POST /device-tokens/me` and `DELETE /device-tokens/me/:deviceId`
backend endpoints before enabling token registration in production. Configure
native capabilities, Firebase messaging and your app's permission explanation.

