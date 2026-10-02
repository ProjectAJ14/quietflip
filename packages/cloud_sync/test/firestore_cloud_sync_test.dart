// FlutterFire marks its reference and snapshot types @sealed; mocking them
// is the only way to test against Firestore without a real project.
// ignore_for_file: subtype_of_sealed_class
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_sync/cloud_sync.dart' as cloud_sync;
import 'package:cloud_sync/cloud_sync.dart';
import 'package:core/core.dart';
import 'package:device_services/device_services.dart';
import 'package:di/di.dart';
import 'package:fake_async/fake_async.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

typedef _Json = Map<String, dynamic>;

class _Auth extends Mock implements FirebaseAuth {}

class _User extends Mock implements User {}

class _Info extends Mock implements UserInfo {}

class _Firestore extends Mock implements FirebaseFirestore {}

class _Collection extends Mock implements CollectionReference<_Json> {}

class _Doc extends Mock implements DocumentReference<_Json> {}

class _Snapshot extends Mock implements DocumentSnapshot<_Json> {}

class _Meta extends Mock implements SnapshotMetadata {}

class _Query extends Mock implements QuerySnapshot<_Json> {}

class _QueryDoc extends Mock implements QueryDocumentSnapshot<_Json> {}

class _Store implements KeyValueStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

class _Logger implements Logger {
  final List<String> errors = [];
  final List<String> warnings = [];

  @override
  Object get logger => this;

  @override
  void d(String message) {}

  @override
  void i(String message) {}

  @override
  void w(String message) => warnings.add(message);

  @override
  void e(String message, [Object? error, StackTrace? stackTrace]) =>
      errors.add(message);
}

/// A signed-in (or not) Firebase double with one document per name under
/// `users/u1/sync`. Each `set()` waits on the next completer in [writes].
class _Harness {
  _Harness({bool signedIn = true}) {
    when(() => user.uid).thenReturn('u1');
    when(() => user.email).thenReturn('ada@example.com');
    when(() => info.providerId).thenReturn('google.com');
    when(() => user.providerData).thenReturn([info]);
    when(() => auth.currentUser).thenReturn(signedIn ? user : null);
    when(auth.authStateChanges).thenAnswer((_) => users.stream);
    when(() => firestore.collection('users')).thenReturn(usersCollection);
    when(() => usersCollection.doc(any())).thenReturn(userDoc);
    when(() => userDoc.collection('sync')).thenReturn(sync);
    when(() => sync.doc(any())).thenReturn(doc);
    when(() => doc.set(any())).thenAnswer((invocation) {
      written.add(invocation.positionalArguments.first as _Json);
      final write = Completer<void>();
      writes.add(write);
      return write.future;
    });
    when(
      () => doc.snapshots(includeMetadataChanges: true),
    ).thenAnswer((_) => snapshots.stream);
  }

  final auth = _Auth();
  final user = _User();
  final info = _Info();
  final firestore = _Firestore();
  final usersCollection = _Collection();
  final userDoc = _Doc();
  final sync = _Collection();
  final doc = _Doc();
  final store = _Store();
  final logger = _Logger();
  final users = StreamController<User?>.broadcast();
  StreamController<DocumentSnapshot<_Json>> snapshots =
      StreamController<DocumentSnapshot<_Json>>.broadcast();
  final List<Completer<void>> writes = [];
  final List<_Json> written = [];
  DateTime clock = DateTime(2026, 10, 2, 9);

  late final FirestoreCloudSync cloud = FirestoreCloudSync(
    auth: auth,
    firestore: firestore,
    store: store,
    logger: logger,
    now: () => clock,
  );

  _Snapshot snapshot(
    _Json? data, {
    bool pending = false,
    bool fromCache = false,
  }) {
    final meta = _Meta();
    when(() => meta.hasPendingWrites).thenReturn(pending);
    when(() => meta.isFromCache).thenReturn(fromCache);
    final snapshot = _Snapshot();
    when(() => snapshot.metadata).thenReturn(meta);
    when(snapshot.data).thenReturn(data);
    return snapshot;
  }
}

void main() {
  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  test('accounts and statuses compare by value', () {
    final at = DateTime(2026);
    const account = SyncAccount(
      uid: 'u',
      email: 'e',
      provider: SyncProvider.email,
    );
    // Built at run time so equality, not const identity, is under test.
    final copy = SyncAccount(
      uid: account.uid,
      email: 'e',
      provider: SyncProvider.email,
    );
    expect({account, copy}, hasLength(1));
    expect({SyncDone(at), SyncDone(at)}.toList(), hasLength(1));
    final failed = [
      SyncFailed(at, SyncFailure.offline),
      SyncFailed(at, SyncFailure.offline),
    ];
    expect(failed.toSet(), hasLength(1));
    expect(SyncFailed(at, SyncFailure.offline), isNot(SyncDone(at)));
  });

  test('push goes pending, then done, and saves the last sync', () async {
    final h = _Harness();
    await h.cloud.start();
    final push = h.cloud.push('clock', {'theme': 'dark'}, updatedAt: 42);
    expect(h.cloud.status.value, const SyncPending());
    expect(h.written.single, {
      'data': {'theme': 'dark'},
      'updatedAt': 42,
    });
    h.writes.single.complete();
    await push;
    expect(h.cloud.status.value, SyncDone(h.clock));
    expect(h.cloud.lastSynced, h.clock);
    expect(
      h.store.values[FirestoreCloudSync.lastSyncedKey],
      '${h.clock.millisecondsSinceEpoch}',
    );
    verify(() => h.usersCollection.doc('u1')).called(greaterThan(0));
    verify(() => h.sync.doc('clock')).called(1);
  });

  test('a push in flight past 5 s reads as waiting, then lands as done', () {
    fakeAsync((time) {
      final h = _Harness();
      unawaited(h.cloud.start());
      time.flushMicrotasks();
      unawaited(h.cloud.push('clock', {}, updatedAt: 1));
      time.elapse(const Duration(seconds: 4));
      expect(h.cloud.status.value, const SyncPending());
      time.elapse(const Duration(seconds: 1));
      expect(h.cloud.status.value, const SyncWaiting());
      h.clock = DateTime(2026, 10, 2, 10);
      h.writes.single.complete();
      time.flushMicrotasks();
      expect(h.cloud.status.value, SyncDone(h.clock));
    });
  });

  test('each failure code maps to its reason, logged and never done', () async {
    for (final (code, reason) in [
      ('unavailable', SyncFailure.offline),
      ('permission-denied', SyncFailure.denied),
      ('unauthenticated', SyncFailure.denied),
      ('internal', SyncFailure.unknown),
    ]) {
      final h = _Harness();
      await h.cloud.start();
      final push = h.cloud.push('clock', {}, updatedAt: 1);
      h.writes.single.completeError(
        FirebaseException(plugin: 'cloud_firestore', code: code),
      );
      await push;
      expect(h.cloud.status.value, SyncFailed(h.clock, reason), reason: code);
      expect(h.logger.errors.single, contains(code));
      expect(h.cloud.lastSynced, isNull);
    }
  });

  test('a non-Firebase exception fails as unknown', () async {
    final h = _Harness();
    await h.cloud.start();
    final push = h.cloud.push('clock', {}, updatedAt: 1);
    h.writes.single.completeError(Exception('boom'));
    await push;
    expect(h.cloud.status.value, SyncFailed(h.clock, SyncFailure.unknown));
    expect(h.logger.errors, hasLength(1));
  });

  test('retry re-sends the push that did not land', () async {
    final h = _Harness();
    await h.cloud.start();
    await h.cloud.retry();
    expect(h.written, isEmpty);
    final first = h.cloud.push('clock', {'a': 1}, updatedAt: 7);
    h.writes.single.completeError(
      FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
    );
    await first;
    final again = h.cloud.retry();
    expect(h.written.last, {
      'data': {'a': 1},
      'updatedAt': 7,
    });
    h.writes.last.complete();
    await again;
    expect(h.cloud.status.value, SyncDone(h.clock));
    await h.cloud.retry();
    expect(h.written, hasLength(2));
  });

  test('an older push finishing late never overwrites a newer one', () async {
    final h = _Harness();
    await h.cloud.start();
    final older = h.cloud.push('clock', {}, updatedAt: 1);
    final newer = h.cloud.push('clock', {}, updatedAt: 2);
    h.writes.first.completeError(
      FirebaseException(plugin: 'cloud_firestore', code: 'internal'),
    );
    await older;
    expect(h.cloud.status.value, const SyncPending());
    h.writes.last.complete();
    await newer;
    expect(h.cloud.status.value, SyncDone(h.clock));
    final third = h.cloud.push('clock', {}, updatedAt: 3);
    final fourth = h.cloud.push('clock', {}, updatedAt: 4);
    h.writes[2].complete();
    await third;
    expect(h.cloud.status.value, const SyncPending());
    h.writes[3].complete();
    await fourth;
  });

  test('signed out: off, and push is a no-op', () async {
    final h = _Harness(signedIn: false);
    await h.cloud.start();
    expect(h.cloud.account.value, isNull);
    expect(h.cloud.status.value, const SyncOff());
    await h.cloud.push('clock', {}, updatedAt: 1);
    expect(h.written, isEmpty);
    await h.cloud.deleteAll();
    verifyNever(() => h.sync.get());
  });

  test('account follows sign-in with the provider label', () async {
    final h = _Harness(signedIn: false);
    await h.cloud.start();
    h.users.add(h.user);
    await pumpEventQueue();
    expect(
      h.cloud.account.value,
      const SyncAccount(
        uid: 'u1',
        email: 'ada@example.com',
        provider: SyncProvider.google,
      ),
    );
    // Never synced on this device: checking until the watch answers.
    expect(h.cloud.status.value, const SyncPending());
    // The same user again (auth replays it) changes nothing.
    h.users.add(h.user);
    await pumpEventQueue();
    expect(h.cloud.status.value, const SyncPending());
    for (final (id, provider) in [
      ('apple.com', SyncProvider.apple),
      ('password', SyncProvider.email),
    ]) {
      h.users.add(null);
      await pumpEventQueue();
      when(() => h.info.providerId).thenReturn(id);
      when(() => h.user.email).thenReturn(null);
      h.users.add(h.user);
      await pumpEventQueue();
      expect(h.cloud.account.value!.provider, provider);
      expect(h.cloud.account.value!.email, isEmpty);
    }
  });

  test('switch off is a no-op that persists; on again resumes', () async {
    final h = _Harness();
    await h.cloud.start();
    expect(h.cloud.enabled, isTrue);
    await h.cloud.setEnabled(true);
    expect(h.store.values, isNot(contains(FirestoreCloudSync.enabledKey)));
    await h.cloud.setEnabled(false);
    expect(h.cloud.enabled, isFalse);
    expect(h.cloud.status.value, const SyncOff());
    expect(h.store.values[FirestoreCloudSync.enabledKey], 'false');
    await h.cloud.push('clock', {}, updatedAt: 1);
    expect(h.written, isEmpty);

    final relaunched = FirestoreCloudSync(
      auth: h.auth,
      firestore: h.firestore,
      store: h.store,
      logger: h.logger,
    );
    await relaunched.start();
    expect(relaunched.enabled, isFalse);
    expect(relaunched.status.value, const SyncOff());
    await relaunched.dispose();

    await h.cloud.setEnabled(true);
    expect(h.store.values[FirestoreCloudSync.enabledKey], 'true');
    expect(h.cloud.status.value, const SyncPending());
  });

  test('switching on while signed out stays off', () async {
    final h = _Harness(signedIn: false);
    await h.cloud.start();
    await h.cloud.setEnabled(false);
    await h.cloud.setEnabled(true);
    expect(h.cloud.status.value, const SyncOff());
  });

  test('launch restores the last sync instead of "never"', () async {
    final h = _Harness();
    final at = DateTime(2026, 10, 1, 8, 30);
    h.store.values[FirestoreCloudSync.lastSyncedKey] =
        '${at.millisecondsSinceEpoch}';
    await h.cloud.start();
    expect(h.cloud.lastSynced, at);
    expect(h.cloud.status.value, SyncDone(at));
  });

  test('watch delivers server copies and skips own pending writes', () async {
    final h = _Harness();
    await h.cloud.start();
    final seen = <SyncedDocument?>[];
    final subscription = h.cloud.watch('clock').listen(seen.add);
    await pumpEventQueue();
    // Our own write, echoed before the server has it: skipped.
    h.snapshots.add(
      h.snapshot({
        'data': {'theme': 'light'},
        'updatedAt': 5,
      }, pending: true),
    );
    // A cached copy: delivered, but not proof of a sync.
    h.snapshots.add(
      h.snapshot({
        'data': {'theme': 'dark'},
        'updatedAt': 4,
      }, fromCache: true),
    );
    await pumpEventQueue();
    expect(seen.single!.updatedAt, 4);
    expect(seen.single!.data, {'theme': 'dark'});
    expect(h.cloud.status.value, const SyncPending());
    // The server's answer: in step with the cloud.
    h.snapshots.add(
      h.snapshot({
        'data': {'theme': 'dark'},
        'updatedAt': 4,
      }),
    );
    await pumpEventQueue();
    expect(seen, hasLength(2));
    expect(h.cloud.status.value, SyncDone(h.clock));
    // No cloud copy yet: null.
    h.snapshots.add(h.snapshot(null));
    // Malformed: logged and skipped.
    h.snapshots.add(h.snapshot({'data': 'x', 'updatedAt': 1}));
    h.snapshots.add(
      h.snapshot({'data': <String, dynamic>{}, 'updatedAt': 'x'}),
    );
    await pumpEventQueue();
    expect(seen, hasLength(3));
    expect(seen.last, isNull);
    expect(h.logger.warnings, hasLength(2));
    // Watch errors are logged, never thrown.
    h.snapshots.addError(Exception('denied'));
    await pumpEventQueue();
    expect(h.logger.errors, hasLength(1));
    await subscription.cancel();
    expect(h.snapshots.hasListener, isFalse);
  });

  test('a whole-number updatedAt decoded as a double still counts', () async {
    // Web can hand integers back as doubles.
    final h = _Harness();
    await h.cloud.start();
    final seen = <SyncedDocument?>[];
    final sub = h.cloud.watch('clock').listen(seen.add);
    await pumpEventQueue();
    h.snapshots.add(
      h.snapshot({'data': <String, dynamic>{}, 'updatedAt': 4.0}),
    );
    await pumpEventQueue();
    expect(seen.single!.updatedAt, 4);
    await sub.cancel();
  });

  test('a server copy never hides a failed or in-flight push', () async {
    final h = _Harness();
    await h.cloud.start();
    final sub = h.cloud.watch('clock').listen((_) {});
    await pumpEventQueue();
    final push = h.cloud.push('clock', {}, updatedAt: 1);
    h.snapshots.add(h.snapshot(null));
    await pumpEventQueue();
    expect(h.cloud.status.value, const SyncPending());
    h.writes.single.completeError(
      FirebaseException(plugin: 'cloud_firestore', code: 'internal'),
    );
    await push;
    h.snapshots.add(h.snapshot(null));
    await pumpEventQueue();
    expect(h.cloud.status.value, isA<SyncFailed>());
    await sub.cancel();
  });

  test('switch off pauses watchers; on resubscribes', () async {
    final h = _Harness();
    await h.cloud.start();
    final sub = h.cloud.watch('clock').listen((_) {});
    await pumpEventQueue();
    expect(h.snapshots.hasListener, isTrue);
    await h.cloud.setEnabled(false);
    await pumpEventQueue();
    expect(h.snapshots.hasListener, isFalse);
    await h.cloud.setEnabled(true);
    await pumpEventQueue();
    expect(h.snapshots.hasListener, isTrue);
    await sub.cancel();
  });

  test('sign-out goes off, closes watchers, clears the last sync and keeps '
      'the switch', () async {
    final h = _Harness();
    h.store.values[FirestoreCloudSync.lastSyncedKey] = '1';
    await h.cloud.start();
    final sub = h.cloud.watch('clock').listen((_) {});
    await pumpEventQueue();
    h.users.add(null);
    await pumpEventQueue();
    expect(h.cloud.account.value, isNull);
    expect(h.cloud.status.value, const SyncOff());
    expect(h.cloud.lastSynced, isNull);
    expect(h.store.values, isNot(contains(FirestoreCloudSync.lastSyncedKey)));
    expect(h.snapshots.hasListener, isFalse);
    expect(h.cloud.enabled, isTrue);
    h.users.add(h.user);
    await pumpEventQueue();
    expect(h.snapshots.hasListener, isTrue);
    await sub.cancel();
  });

  test('deleteAll deletes the account documents and stops syncing', () async {
    final h = _Harness();
    await h.cloud.start();
    final sub = h.cloud.watch('clock').listen((_) {});
    await pumpEventQueue();
    final query = _Query();
    final first = _QueryDoc();
    final second = _QueryDoc();
    final firstRef = _Doc();
    final secondRef = _Doc();
    when(() => first.reference).thenReturn(firstRef);
    when(() => second.reference).thenReturn(secondRef);
    when(firstRef.delete).thenAnswer((_) async {});
    when(secondRef.delete).thenAnswer((_) async {});
    when(() => query.docs).thenReturn([first, second]);
    when(() => h.sync.get()).thenAnswer((_) async => query);
    await h.cloud.deleteAll();
    verify(firstRef.delete).called(1);
    verify(secondRef.delete).called(1);
    expect(h.snapshots.hasListener, isFalse);
    await h.cloud.push('clock', {}, updatedAt: 1);
    expect(h.written, isEmpty);
    // A new account resumes.
    h.users.add(null);
    h.users.add(h.user);
    await pumpEventQueue();
    expect(h.snapshots.hasListener, isTrue);
    await sub.cancel();
  });

  test('deleteAll failing logs, rethrows and resumes syncing', () async {
    final h = _Harness();
    await h.cloud.start();
    final sub = h.cloud.watch('clock').listen((_) {});
    await pumpEventQueue();
    final error = FirebaseException(
      plugin: 'cloud_firestore',
      code: 'unavailable',
    );
    when(() => h.sync.get()).thenThrow(error);
    await expectLater(h.cloud.deleteAll(), throwsA(same(error)));
    expect(h.logger.errors, hasLength(1));
    expect(h.snapshots.hasListener, isTrue);
    expect(h.cloud.status.value, const SyncPending());
    await sub.cancel();
  });

  test('init turns on the offline cache, registers, and di.reset disposes '
      'everything', () async {
    final h = _Harness();
    final logger = _Logger();
    di.register<Logger>(logger);
    di.register<KeyValueStore>(h.store);
    await cloud_sync.init(auth: h.auth, firestore: h.firestore);
    verify(
      () => h.firestore.settings = const Settings(persistenceEnabled: true),
    ).called(1);
    final sync = di.get<CloudSync>();
    expect(sync, isA<FirestoreCloudSync>());
    final done = Completer<void>();
    sync.watch('clock').listen((_) {}, onDone: done.complete);
    await pumpEventQueue();
    expect(h.users.hasListener, isTrue);
    expect(h.snapshots.hasListener, isTrue);
    await di.reset();
    await done.future;
    expect(h.users.hasListener, isFalse);
    expect(h.snapshots.hasListener, isFalse);
  });

  test('dispose cancels the wait timer', () {
    fakeAsync((time) {
      final h = _Harness();
      unawaited(h.cloud.start());
      time.flushMicrotasks();
      unawaited(h.cloud.push('clock', {}, updatedAt: 1));
      unawaited(h.cloud.dispose());
      time.flushMicrotasks();
      expect(time.pendingTimers, isEmpty);
    });
  });
}
