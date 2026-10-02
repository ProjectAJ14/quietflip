# Quietflip: `packages/cloud_sync`

Offline-first sync of named JSON documents for the signed-in user, over
Firestore. It knows nothing about clocks or settings: callers choose the
document names and payloads and decide which copy wins. It owns the sync
status (for display), the per-device Sync settings switch and the last-sync
time. Layer 3 (see `packages/CLAUDE.md`): depends on `core`, `di`,
`device_services` (for `KeyValueStore`).

It exists because `flip_clock` needs sync and the sign-in state, and a feature
may not import `auth`.

Read the root `CLAUDE.md` and `packages/CLAUDE.md` first.

## Public API (`package:cloud_sync/cloud_sync.dart`)

| Symbol | Kind | Notes |
|---|---|---|
| `init({auth, firestore})` | function | Sets `Settings(persistenceEnabled: true)` (web needs it explicitly), builds `FirestoreCloudSync` from `di`'s `KeyValueStore` and `Logger`, `start()`s it, registers `CloudSync` with `dispose:`. After `device_services.init()`, behind `firebaseReady` |
| `CloudSync` | contract | `account` (`ValueListenable<SyncAccount?>`), `status` (`ValueListenable<SyncStatus>`), `lastSynced`, `enabled` / `setEnabled`, `push(name, data, updatedAt:)` (never throws), `watch(name)` (`Stream<SyncedDocument?>`, null = no cloud copy yet), `retry()`, `deleteAll()` |
| `FirestoreCloudSync({auth, firestore, store, logger, now})` | implementation | `start()`, `dispose()`; `enabledKey`, `lastSyncedKey`, `waitAfter` (5 s) |
| `SyncAccount(uid, email, provider)`, `SyncProvider` (`email`, `google`, `apple`) | models | Provider from `providerData` (`google.com`, `apple.com`, else email); no product copy, the UI labels it |
| `SyncedDocument(data, updatedAt)` | model | A server-confirmed copy |
| `SyncStatus` (sealed): `SyncOff`, `SyncPending`, `SyncWaiting`, `SyncDone(at)`, `SyncFailed(at, reason)`; `SyncFailure` (`offline`, `denied`, `unknown`) | models | `SyncDone` / `SyncFailed` / `SyncAccount` compare by value; the others are const singletons |

## Layout

```
lib/
  cloud_sync.dart                  barrel + init()
  src/cloud_sync.dart              contract and models
  src/firestore_cloud_sync.dart    Firestore implementation
```

## Rules

- Path `users/{uid}/sync/{name}`, fields `data` (map) and `updatedAt` (int, ms
  since epoch, set by the device that changed the value). The rules in
  `apps/quietflip/firestore.rules` allow exactly these two fields, owner only.
- Offline first is Firestore's cache: a write made offline is queued by the
  SDK. **No hand-written queue.** "No connection" is a push still in flight
  after `waitAfter` (`SyncWaiting`) or an `unavailable` error; there is no
  connectivity package.
- `push`: `SyncPending`, then `SyncWaiting` after 5 s, `SyncDone(now)` when
  `set()` completes (saves `cloud_sync.last_synced`), or `SyncFailed` on an
  exception (`unavailable` -> offline, `permission-denied` / `unauthenticated`
  -> denied, else unknown). Every failure is logged through `Logger` and never
  turned into `SyncDone`. An older attempt finishing late never overwrites a
  newer status (`_epoch`).
- `watch` listens with `includeMetadataChanges: true`, skips snapshots with
  `hasPendingWrites`, logs and skips malformed documents, and logs stream
  errors. A server (not cache) snapshot with no push in flight means the
  device is in step: `SyncDone(now)`, unless the status is a failure or off.
- `account` follows `authStateChanges()` (a replay of the same uid is
  ignored). Sign-in with no saved last sync is `SyncPending` until the watch
  answers. Sign-out: `SyncOff`, watchers' Firestore listeners cancelled (the
  stream stays open and resubscribes on the next sign-in), `last_synced`
  cleared. Local data is never touched.
- `enabled` reads `cloud_sync.enabled` (absent = true). Off: `SyncOff`, pushes
  are no-ops, listeners cancelled. On: back to the last sync or pending.
- `deleteAll` stops syncing first (so the deletion is not answered by a fresh
  upload), deletes every document under `users/{uid}/sync`, and stays
  stopped until the account changes. A failure is logged, rethrown, and sync
  resumes.
- `dispose` (via `di.reset`) cancels the auth subscription, the wait timer
  and every listener, and closes the watch streams.

## Common changes

- **Sync another document:** nothing here; the caller picks a new `name`.
  Firestore rules already cover any name under `sync/`.
- **New failure reason:** a `SyncFailure` value, its code in `push`, the
  status line in `flip_clock`'s account page, and a row in the failure test.

## Tests

`test/firestore_cloud_sync_test.dart`, `mocktail` fakes of `FirebaseAuth`,
`User`, `UserInfo`, `FirebaseFirestore`, `CollectionReference`,
`DocumentReference`, `DocumentSnapshot`, `SnapshotMetadata`, `QuerySnapshot`
and a `Completer` per `set()`; `fake_async` for the 5 s timer. Covers every
status transition, failure mapping, retry, stale results, signed-out no-ops,
provider labels, the switch (persisted, pauses and resumes listeners),
last-sync restore, pending-write and malformed snapshots, sign-out cleanup,
`deleteAll` success and failure, `init` + `di.reset` disposal.

`dart run melos exec --scope=cloud_sync -- flutter test`; `dart run melos run coverage` must stay 100%.

## Gotchas

- Last write wins per whole document, by `updatedAt`, decided by the caller.
  Two devices changing different values offline within the same second can
  lose one change.
- A very slow network reads as "Waiting for a connection" for a moment.
- `firestore.settings` must be set before the first Firestore call, so `init`
  runs before anything reads a document. It merges with the emulator host
  set earlier by `core`'s `emulators.init`.
