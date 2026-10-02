# cloud_sync

Offline-first sync of named JSON documents for the signed-in user, behind the
`CloudSync` contract, with a Firestore implementation. It stores each document
at `users/{uid}/sync/{name}` as `{data, updatedAt}` and reports what happened
through a `status` the UI can show.

## Initialise

Firebase must be initialised, and `Logger` and `KeyValueStore` registered
(`core.init()`, `device_services.init()`).

```dart
import 'package:cloud_sync/cloud_sync.dart' as cloud_sync;

await cloud_sync.init(
  auth: FirebaseAuth.instance,
  firestore: FirebaseFirestore.instance,
);
final sync = di.get<cloud_sync.CloudSync>();
```

## Use

```dart
// Upload; never throws. The outcome lands in sync.status.
await sync.push('clock_settings', settings.toJson(), updatedAt: stamp);

// Server-confirmed copies (null = nothing in the cloud yet).
sync.watch('clock_settings').listen((remote) { ... });
```

| Status | Meaning |
| --- | --- |
| `SyncOff` | signed out, or the Sync settings switch is off |
| `SyncPending` | a push (or the first check after sign-in) is in flight |
| `SyncWaiting` | still in flight after 5 s: no connection; the SDK sends it on reconnect |
| `SyncDone(at)` | this device matches the cloud as of `at` |
| `SyncFailed(at, reason)` | `offline`, `denied` or `unknown`; `retry()` re-sends it |

Offline writes are queued by Firestore's own cache (turned on by `init`,
including on web). The switch (`cloud_sync.enabled`) and the last sync
(`cloud_sync.last_synced`) are saved per device; signing out clears the last
sync and never touches local data. `deleteAll()` removes the account's
documents before the account itself is deleted.

## Test

```sh
dart run melos exec --scope=cloud_sync -- flutter test
```
