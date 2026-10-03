# Optional sign-in and settings sync: handoff

Base: `main` at c2599ea (sound picker shipped, app id renamed to
`live.iajaykumar.quietflip`).
Previous briefs, still valid where this one is silent:
`docs/design/sound-picker-handoff.md`, `docs/design/island-feedback-3-handoff.md`,
`docs/design/island-control-hub-handoff.md`, `docs/design/multi-skin-handoff.md`.

Design source: the layouts in this file (no separate mockup).

This is the brief for the coding agent. Follow the repository `CLAUDE.md` and the
nested `CLAUDE.md` files on the path (`apps/quietflip`, `features/auth`,
`features/flip_clock`, `packages/` and every package touched, `packages/design_system`,
`packages/localization`): dependency direction, 100% line coverage, strings through
i69n, colours and shapes from the design system, generated files read-only, secrets
never in git. Load `design-system` and `flutter-best-practices` before any UI work,
`new-feature`-style package rules and `melos-workspace` before adding the new package,
and `troubleshooting` if Firebase setup fails.

## The feedback, verbatim intent

1. Sign-in lives in Settings, **at the bottom, always** (not at the top like iOS).
2. The headline message wherever sign-in appears: you only need to sign in if you
   want your settings on your other devices. Make it clear and friendly; it is the
   product's stance going forward.
3. Once signed in, one simple **Sync settings** switch, **on by default**.
4. Every settings change is saved on the device first (it already is; confirm it,
   and use something like Hive if that is faster).
5. Then it syncs to Firebase when there is a connection: offline first.
6. If a sync fails (error, no network), say so **inside Settings only**: no toast,
   no system notification.
7. The account page shows when the last sync happened.
8. Firebase Authentication and Firestore need enabling; use the Firebase CLI where
   possible and tell the user what they must do by hand.

## What exists today (verified)

| Fact | Where |
| --- | --- |
| Every change is already saved on the device at once: `SettingsController.update` emits, then `SettingsRepositoryImp.save` writes one JSON string through `KeyValueStore` | `features/flip_clock/lib/state/settings_controller.dart:46`, `features/flip_clock/lib/data/repositories/settings_repository_imp.dart:28` |
| The store is `shared_preferences` (`SharedPreferencesAsync`), failures logged, never thrown | `packages/device_services/lib/src/storage/preferences_key_value_store.dart` |
| Settings load once at launch (`flip_clock.init`, before the first frame) | `features/flip_clock/lib/flip_clock.dart:29` |
| Sign-in already exists: `features/auth` (FirebaseUI email, Google, Apple on iOS), routes `/auth/sign-in`, `/auth/sign-up`; nothing in the UI links to it | `features/auth/lib/router/router.dart`, `apps/quietflip/lib/router/router.dart:49` |
| After sign-in the app goes to the demo dashboard | `apps/quietflip/lib/router/router.dart:105` (`_onAuthenticated`) |
| Firebase is **not configured**: `firebase_options.dart` is the throwing placeholder, so bootstrap skips every Firebase module | `apps/quietflip/lib/firebase_options.dart`, `apps/quietflip/lib/bootstrap.dart:51` |
| `cloud_firestore` and `firebase_auth` are already dependencies (emulator wiring) | `packages/core/pubspec.yaml:24`, `packages/core/lib/developer/emulators.dart` |
| Firebase project `quietflip` (number 894286222021) exists; **no apps registered, Firestore API not enabled**, no `firebase.json`, `.firebaserc` or rules in the repo | `firebase apps:list`, `firebase firestore:databases:list` (403) |
| `firebase` CLI 15.28.1 is installed and logged in; `flutterfire` CLI is not installed | `which firebase flutterfire` |
| Settings has 8 categories; phone shows them as one list, 600 px and up as a sidebar | `features/flip_clock/lib/ui/screens/settings_screen.dart:177`, `packages/design_system/lib/components/settings_shell.dart:126` |
| Settings opens on a category only through `openTimers: bool` | `settings_screen.dart:63`, `flip_clock_router.dart:51` |

**Hive is not needed.** Settings are one small JSON value (a few KB, custom skins
included) read once at launch; `shared_preferences` writes it in single-digit
milliseconds. Hive would add a dependency and a migration for no visible gain.

## Delivery order

One pull request, one commit (or more) per stage, in this order. After each code
stage run `dart run melos run lint` and `dart run melos run coverage`.

0. **Firebase setup** (item 8). Config files and CLI steps; the user does the
   console-only steps in parallel.
1. **`packages/cloud_sync`**: the sync contract and its Firestore implementation
   (items 3, 5, 6, 7).
2. **Sync in `flip_clock`**: local-first coordinator, which fields sync, conflict
   rule (items 4, 5).
3. **Settings shell: pinned bottom entry** in `design_system` (item 1).
4. **Account page and sync card** in `flip_clock`, auth wiring in the app
   (items 1, 2, 3, 6, 7).

## Stage 0: Firebase setup

### The implementer runs (CLI, logged in on this machine)

| Step | Command / file |
| --- | --- |
| Project alias | `.firebaserc`: `{"projects": {"default": "quietflip"}}` |
| Emulator + rules config | `firebase.json` at the repo root: `firestore.rules` path, emulators `auth` 9099, `firestore` 8080, `functions` 5001, `ui` enabled (ports must match `packages/core/lib/developer/emulators.dart`) |
| Rules | `firestore.rules` (below) |
| Enable Firestore + create the database | `firebase firestore:databases:create "(default)" --project quietflip --location <LOCATION>`; if the API is off, enable it with `gcloud services enable firestore.googleapis.com --project quietflip` or the console link the CLI prints. **The location is permanent; use the one the user confirmed** |
| Deploy rules | `firebase deploy --only firestore:rules --project quietflip` |
| Register apps and write config | `dart pub global activate flutterfire_cli`, then in `apps/quietflip`: `flutterfire configure --project=quietflip --platforms=android,ios,macos,web,windows --android-package-name=live.iajaykumar.quietflip --ios-bundle-id=live.iajaykumar.quietflip --macos-bundle-id=live.iajaykumar.quietflip`. Commits `firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist` (public client config only, allowed by rule 9) |
| iOS / macOS Google sign-in | add the `REVERSED_CLIENT_ID` URL scheme to `ios/Runner/Info.plist` and `macos/Runner/Info.plist`; macOS needs `com.apple.security.network.client` and keychain sharing entitlements |

Rules (owner only, shape checked):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid}/sync/{doc} {
      allow read, delete: if request.auth != null && request.auth.uid == uid;
      allow create, update: if request.auth != null && request.auth.uid == uid
        && request.resource.data.keys().hasOnly(['data', 'updatedAt'])
        && request.resource.data.data is map
        && request.resource.data.updatedAt is int;
    }
  }
}
```

### The user does by hand (console only, no CLI exists)

| Step | Where |
| --- | --- |
| Authentication > Get started, enable **Email/Password** and **Google** | Firebase console > quietflip > Authentication > Sign-in method |
| Android Google sign-in: add debug and release **SHA-1** fingerprints to the Android app | Project settings > Your apps > Android (`cd apps/quietflip/android && ./gradlew signingReport`) |
| Apple sign-in (iOS): enable the provider, create a Services ID and key in Apple Developer, add the Sign in with Apple capability | Firebase console + developer.apple.com |
| Web: add the production domain to Authorized domains (localhost is there by default) | Authentication > Settings |

The app must keep booting with Firebase off (tests, forks): every new module is
skipped when `firebaseReady` is false, exactly like `auth` today.

## Stage 1: `packages/cloud_sync`

A new layer-3 package (depends on `core`, `di`, `device_services`; the
`device_services` dependency is for `KeyValueStore`). It knows nothing about clocks:
it syncs named JSON documents for the signed-in user. Add it to the layer table in
`packages/CLAUDE.md` and ship its own `CLAUDE.md` and `README.md`.

Why a package: `flip_clock` needs sync and the sign-in state, and a feature may not
import `auth`. The contract crosses a package boundary and needs a test fake, so the
interface is allowed (rule 3).

```dart
abstract interface class CloudSync {
  /// Signed-in account (uid, email, provider label), null when signed out.
  ValueListenable<SyncAccount?> get account;

  /// What the account page and the sync card show.
  ValueListenable<SyncStatus> get status;

  /// The Sync settings switch. True by default; saved per device.
  bool get enabled;
  Future<void> setEnabled(bool on);

  /// Uploads [data] as document [name]. Never throws: the outcome lands in [status].
  Future<void> push(String name, Map<String, Object?> data, {required int updatedAt});

  /// Server-confirmed copies of document [name] for the current account,
  /// re-subscribed on sign-in and sign-out. Own pending writes are skipped.
  Stream<SyncedDocument> watch(String name);

  /// Re-sends the last push that did not land (the Try again button).
  Future<void> retry();

  /// Deletes every synced document of the current account (before account deletion).
  Future<void> deleteAll();
}
```

`SyncStatus` (sealed): `SyncOff` (signed out or switch off), `SyncPending`
(a push is in flight), `SyncWaiting` (in flight for more than 5 s: no connection),
`SyncDone(DateTime at)`, `SyncFailed(DateTime at, SyncFailure reason)` with
`SyncFailure { offline, denied, unknown }`.

`FirestoreCloudSync` (`lib/src/firestore_cloud_sync.dart`) takes `FirebaseAuth`,
`FirebaseFirestore`, `KeyValueStore`, `Logger` and `now` through its constructor.

- Path: `users/{uid}/sync/{name}`, fields `data` (map) and `updatedAt` (int, ms since
  epoch, set by the device that changed the setting).
- Offline first is Firestore's own cache: `FirebaseFirestore.settings =
  Settings(persistenceEnabled: true)` on every platform (web needs it set
  explicitly). A write made offline is queued by the SDK and sent when the
  connection returns. **No hand-written queue.**
- `push`: status `SyncPending`; a 5 s timer moves it to `SyncWaiting`; the `set()`
  future completing moves it to `SyncDone(now)` and saves `cloud_sync.last_synced`
  (ms) in `KeyValueStore`; a `FirebaseException` moves it to `SyncFailed` (`unavailable`
  → offline, `permission-denied` / `unauthenticated` → denied, else unknown), logged
  through `Logger`. Every failure is logged and reflected, never swallowed, never
  turned into `SyncDone`.
- `account` follows `authStateChanges()`. Signing out: status `SyncOff`, watchers
  close, `last_synced` cleared. Local settings are **never** wiped.
- `enabled` reads `cloud_sync.enabled` (default true); off: status `SyncOff`, no
  pushes, watchers paused; back on: status follows the next push.
- On launch, status starts from the saved `last_synced` (`SyncDone(at)`) so the
  account page shows the real last sync, not "never".
- `init({required FirebaseAuth auth, required FirebaseFirestore firestore})`
  registers `CloudSync` with a `dispose:` that cancels the auth subscription,
  timers and watchers.
- Tests (`mocktail` fakes of `FirebaseAuth`, `User`, `FirebaseFirestore`,
  `DocumentReference`, `DocumentSnapshot`, a `Completer` per `set()`): pending →
  done; pending past 5 s → waiting → done when the completer finishes; each
  exception code → its failure; signed out push is a no-op; switch off is a no-op
  and persists; launch restores last sync; snapshots with `hasPendingWrites` are
  skipped; sign-out closes watchers and clears last sync; `deleteAll` deletes the
  account's documents; dispose cancels everything (`di.reset`).

## Stage 2: sync in `flip_clock`

`flip_clock.init({CloudSync? sync})` gets the sync from the app (null when Firebase
is off: no sync, no card). A small `SettingsSync` class
(`features/flip_clock/lib/state/settings_sync.dart`) connects `SettingsController` to
`CloudSync`. The local save path is unchanged: **the device copy is always written
first and never waits for the network.**

- Document name `clock_settings`. Payload: `ClockSettings.toJson()` minus the
  device-only keys below.
- Push on change: listen to `settings.stream.distinct()` and push the syncable part
  1 s after the last change (trailing debounce, so dragging the Corners slider sends
  one write, not forty). Stamp `updatedAt = now` and save it under
  `flip_clock.settings_updated_at` in `KeyValueStore`.
- Pull: on `watch('clock_settings')`, if `remote.updatedAt > local updatedAt`, apply
  the remote syncable fields onto the current settings (device-only fields kept),
  save locally with the remote `updatedAt`, and **do not push it back** (remember the
  applied value and skip the stream event equal to it). Older or equal remote: push
  the local copy instead.
- First sign-in on a device: the same rule. A device that never stamped
  `updatedAt` (every install today) counts as 0, so an existing cloud copy wins; a
  first device with nothing in the cloud uploads its settings.
- `SettingsController` gains `applyRemote(ClockSettings next)` (emit + save, no
  other side effects) so the coordinator never reaches into the repository.
- Device-only, never synced:

| Key | Why |
| --- | --- |
| `systemAlerts` | OS permission is per device |
| `lastMode` | which screen this device was on |
| `orientation` | a phone and a tablet want different rotation |
| `digitBrightness` | screens differ in brightness |
| countdown snapshot (`flip_clock.countdown`) | a running timer belongs to the device it runs on |

Everything else syncs, custom skins included.

- Tests: change → one push after 1 s with the stamp, two quick changes → one push;
  remote newer → applied, device-only fields kept, no echo push; remote older →
  local pushed; never-stamped device adopts the cloud copy; device-only keys absent
  from the payload; null sync → nothing happens; local save still happens when the
  push fails; close cancels the debounce and subscriptions.

## Stage 3: settings shell, pinned bottom entry

`SettingsShell` (`packages/design_system/lib/components/settings_shell.dart`) gains
one optional slot: `pinned: SettingsCategory?` plus `pinnedCard: Widget?`. Generic,
no product copy.

| Layout | Where the pinned entry sits |
| --- | --- |
| Phone (< 600) | after the category list, `DesignSpace.s6` gap, as its own card (not a row in the group); tap opens its detail page like a category |
| Split / desktop (≥ 600) | pinned to the **bottom of the sidebar**, outside its scroll, `s4` padding; selected state uses the same accent ring as a selected nav row; its detail shows on the right |

- The card surface: `surfaceRaised`, hairline border, `DesignShape.of(context).md`
  corners, min height 72, 48 dp tap target, focusable, Enter / Space opens it.
- `initialCategory` can address it: index `categories.length` means the pinned one.
- Tests: phone renders it after the list and opens its detail; split renders it at
  the sidebar bottom and selects it; keyboard opens it; absent slot changes nothing
  (existing tests unchanged).

## Stage 4: account page, sync card, auth wiring

### The bottom card (`features/flip_clock/lib/ui/components/sync_card.dart`)

Shown only when `CloudSync` exists. Two looks:

```
 Signed out                                   Signed in
 ┌──────────────────────────────────────┐     ┌──────────────────────────────────────┐
 │ ☁  Your settings stay on this device │     │ ☁✓ Sync is on                     >  │
 │    Sign in only if you want them on  │     │    Synced 2 min ago                  │
 │    your other devices.            >  │     └──────────────────────────────────────┘
 └──────────────────────────────────────┘
```

- Icon `Icons.cloud_outlined` (signed out), and by status when signed in:
  `cloud_done_outlined` (done), `cloud_sync_outlined` (pending / waiting),
  `cloud_off_outlined` (off), `error_outline` in the `danger` role (failed).
- Title `bodyLarge` weight 600 `ink`; subtitle `bodyMedium` `inkSubtle`; the failed
  subtitle uses `danger`.

### The account page (the pinned category, label "Account", icon `cloud_outlined`)

Signed out:

```
        ☁
  Your settings stay on this device
  Quietflip never needs an account. Sign in only if you
  want your clock, skins and sounds on your other devices.

          [ Sign in to sync ]          (FilledButton, full width up to 320)

 WHAT SYNCS
 Theme, skins, sounds, clock and timer settings.
 Stays on this device: brightness, rotation, notifications and a running timer.
```

Signed in:

```
 ACCOUNT
 ajay@example.com                                Google
 SYNC
 Sync settings                                    [on]
 Your settings follow you to every device you sign in on.
 Last synced                                 2 min ago
   (failed)  Couldn't sync: no connection. It will try again
             when you're back online.         [Try again]
 ┌────────────────────────────────────────────────────┐
 │ Sign out                                           │
 │ Delete account                        (danger ink) │
 └────────────────────────────────────────────────────┘
 Signing out keeps your settings on this device.
```

- Last synced text: under 60 s "Just now"; under 60 min "N min ago"; today
  "Today at 14:05" (24 h or 12 h following `use24h`); else the date. It refreshes
  every 30 s while the page is open (one `Timer.periodic`, cancelled on dispose).
- Status line by `SyncStatus`: pending "Syncing…"; waiting "Waiting for a
  connection"; failed offline "Couldn't sync: no connection. It will try again when
  you're back online."; failed denied "Couldn't sync: sign in again." (taps to sign
  in); failed unknown "Couldn't sync. Try again." with the Try again button
  (`CloudSync.retry`). Switch off: "Sync is off. Changes stay on this device."
- **No toast, no snackbar, no system notification for any sync outcome.**
- Sign out: confirm dialog (reuse `auth.sign_out_confirmation`), then the app's
  `AppRouter.signOut`; the page returns to the signed-out look.
- Delete account: confirm dialog ("Delete your account? Your synced settings are
  removed from the cloud. Settings on this device stay."), then `CloudSync.deleteAll()`
  and `AuthService.deleteAccount()`. Firebase may answer `requires-recent-login`:
  show "Sign in again to delete your account" and send the user to sign-in. Use
  `AlertDialog` with theme roles, like `skin_customizer.dart:517`.
- `SettingsScreen` and `FlipClockRouter` take `CloudSync? sync`, `onSignIn`,
  `onSignOut`, `onDeleteAccount` (callbacks: `flip_clock` never imports `auth`).
- Replace `openTimers: bool` with `category: String?` (`'timers'`, `'account'`),
  read from the `category` query parameter; add
  `FlipClockRouter.accountSettings = '$settings?category=account'`.

### Auth wiring (app and `features/auth`)

- `AuthService` gains `deleteAccount()`: `currentUser.delete()`, logs and rethrows
  `FirebaseAuthException` (as `signOut` does); new case in `auth_service_test.dart`.
- `apps/quietflip/lib/router/router.dart`: `_onAuthenticated` goes to
  `FlipClockRouter.accountSettings` (not the dashboard), so the user lands back on
  the account page showing "Syncing…" then "Synced just now".
- Sign-in header: add a line under the logo with the same message,
  `strings.sync.sign_in_reason`, in `features/auth/lib/ui/components/header_builder.dart`.
- `bootstrap.dart`: after `auth.init`, `if (firebaseReady) await
  cloud_sync.init(...)`; then `flip_clock.init(sync: di.has<CloudSync>() ?
  di.get<CloudSync>() : null)`. Update the order line in `apps/quietflip/CLAUDE.md`.

### Tests

Card: signed-out and each status look; tap opens the account page. Page: sign-in
button calls `onSignIn`; switch toggles `setEnabled`; every status line; Try again
calls `retry`; last-synced formats at 30 s, 5 min, today, yesterday; the periodic
timer is cancelled on dispose; sign-out and delete confirm and call back; delete
with `requires-recent-login` shows the message and routes to sign-in; no card when
`sync` is null; `category=account` opens the page; text scale 2.0; semantics (card
announces title and status). App: `_onAuthenticated` routes to the account page.

## Strings

New group `sync` in `packages/localization/lib/messages.i69n.yaml`:

| Key | Text |
| --- | --- |
| `account` | Account |
| `card_title_signed_out` | Your settings stay on this device |
| `card_body_signed_out` | Sign in only if you want them on your other devices. |
| `card_title_on` | Sync is on |
| `card_title_off` | Sync is off |
| `headline` | Your settings stay on this device |
| `body` | Quietflip never needs an account. Sign in only if you want your clock, skins and sounds on your other devices. |
| `sign_in` | Sign in to sync |
| `sign_in_reason` | Only needed to sync your settings across devices. |
| `what_syncs` / `what_syncs_body` / `stays_body` | What syncs / Theme, skins, sounds, clock and timer settings. / Stays on this device: brightness, rotation, notifications and a running timer. |
| `sync_settings` / `sync_settings_note` | Sync settings / Your settings follow you to every device you sign in on. |
| `last_synced`, `just_now`, `minutes_ago(int n)`, `today_at(String time)`, `never` | Last synced, Just now, N min ago, Today at …, Not yet |
| `syncing`, `waiting`, `off_note` | Syncing…, Waiting for a connection, Sync is off. Changes stay on this device. |
| `failed_offline`, `failed_denied`, `failed_unknown`, `try_again` | as in Stage 4 |
| `sign_out_note`, `delete_account`, `delete_title`, `delete_body`, `delete_recent_login` | as in Stage 4 |
| `signed_in_with(String provider)` | Google / Email / Apple label |

Reuse `auth.sign_out`, `auth.sign_out_confirmation`, `generic.cancel` if present.
Update `clock.about_privacy_value` to "No ads. An account is optional." (Since
superseded: the app now has usage analytics, and the line also says anonymous
usage statistics help improve the app.)
Regenerate with `dart run melos run generate:i69n`.

## Data and migrations

- Local: new keys `flip_clock.settings_updated_at`, `cloud_sync.enabled`,
  `cloud_sync.last_synced`. Absent on old installs: defaults (0, true, none). No
  migration code. `ClockSettings` JSON keys unchanged.
- Cloud: `users/{uid}/sync/clock_settings` `{data, updatedAt}`. Nothing else is
  stored about the user (Firebase Auth holds the email).

## Tests the gate expects

- `cloud_sync`: every status transition, failure mapping, enabled switch, last-sync
  restore, pending-write echo skipped, sign-out cleanup, delete, dispose.
- `flip_clock` sync: debounce, stamp, last-write-wins both ways, no echo, first sign-in,
  device-only keys, null sync, local save survives a failed push, close.
- `design_system`: pinned slot on phone and split, keyboard, absent slot.
- Account page and card: every look and status, callbacks, timer cleanup, text scale,
  semantics, deep link.
- `auth`: `deleteAccount` success and failure.
- App: post-sign-in route, bootstrap with Firebase off still boots without a card.

## Acceptance

Run with `--dart-define=USE_EMULATORS=true` and `firebase emulators:start` first, then
once against the real project.

- Settings shows the "Your settings stay on this device" card **below** every
  category on a phone, and at the **bottom of the sidebar** on a tablet and desktop.
- Tap it → Sign in to sync → sign in with email → back on the account page: Sync
  settings is **on**, "Syncing…" then "Last synced Just now".
- Change the theme; the Firestore emulator UI shows `users/{uid}/sync/clock_settings`
  updated within about 2 s, without `systemAlerts`, `lastMode`, `orientation`,
  `digitBrightness`.
- Second device (or a second browser profile) signs in with the same account: it
  takes the theme and skins from the first; brightness and rotation stay its own.
- Stop the emulators (or go offline): change a setting; it applies at once, the page
  says "Waiting for a connection"; no toast appears; restart them and it reaches
  "Last synced Just now" without any tap.
- Sync settings off: changes stay local, the cloud copy does not change.
- Sign out: settings on the device unchanged, the card shows the signed-out look.
- Delete account: the cloud document and the user are gone; local settings stay.
- With `firebase_options.dart` reverted to the placeholder the app boots, no card.
- Works on web (`flutter run -d chrome`), macOS and a phone.

## Docs to update in the same PR

New `packages/cloud_sync/CLAUDE.md` and `README.md`; `packages/CLAUDE.md` layer table;
`features/flip_clock/CLAUDE.md` and `README.md` (sync, device-only keys, account page,
`category` parameter); `features/auth/CLAUDE.md` (`deleteAccount`, header line);
`packages/design_system/CLAUDE.md` (pinned slot); `apps/quietflip/CLAUDE.md` (bootstrap
order, post-sign-in route); root `CLAUDE.md` first-time setup (`firebase.json`,
emulators, the console steps above) and the repository map (`firestore.rules`).

## Decisions taken for the user (change here if wrong)

- **Bottom, always, on every layout.** iOS puts the account at the top because an
  Apple ID is central; here it is optional, and the bottom says so. Cost: less
  discoverable; the card's own look (not a plain row) offsets it.
- **Keep `shared_preferences`, no Hive.** Already saves every change at once; one
  small value. Rejected Hive: new dependency and migration, no measurable gain.
- **Firestore's offline cache is the queue.** Rejected a hand-written outbox: the
  SDK already queues writes offline and sends them on reconnect.
- **Last write wins, per whole settings document**, by the device's change time.
  Cost: two devices changing different settings within the same second offline can
  lose one change. Per-field merge is a ticket if it ever matters.
- **No connectivity package.** "No connection" is inferred from a write still
  pending after 5 s or an `unavailable` error. Cost: a very slow network reads as
  offline for a moment.
- **Device-only fields:** notifications permission, last mode, rotation, brightness,
  running timer. Everything else syncs.
- **Feedback contradiction resolved:** the message says both "notify the user if the
  sync failed" and "we will not notify the user". Last statement wins: status inside
  Settings only, no toast or notification.
- **Delete account is included.** Not asked, but the App Store rejects apps that let
  users create an account without deleting it in the app (guideline 5.1.1(v)). Cost:
  about half a day.
- **After sign-in the user lands on the account page**, not the demo dashboard.
- **Firestore rules are checked by hand on the emulator**, not by an automated rules
  test (that needs Node tooling outside the Dart gate). Ticket an emulator rules test
  if the rules grow.
- **Firestore location is the user's call** (permanent). Suggested: `nam5`
  (multi-region US, highest availability, same free quota).
- **Providers:** Email and Google everywhere, Apple on iOS (as `auth.init` does
  today). Google on Windows is a **hypothesis**: confirm `firebase_ui_oauth_google`
  works there; if not, Windows shows email only.
