import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_sync/src/cloud_sync.dart';
import 'package:core/core.dart';
import 'package:device_services/device_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// [CloudSync] over Firestore at `users/{uid}/sync/{name}`, fields `data`
/// (map) and `updatedAt` (int).
///
/// Offline first is Firestore's own cache: a write made offline is queued by
/// the SDK and sent when the connection returns. There is no hand-written
/// queue. Call [start] once before use and [dispose] when done.
class FirestoreCloudSync implements CloudSync {
  FirestoreCloudSync({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required KeyValueStore store,
    required Logger logger,
    DateTime Function() now = DateTime.now,
  }) : _auth = auth,
       _firestore = firestore,
       _store = store,
       _logger = logger,
       _now = now;

  static const String enabledKey = 'cloud_sync.enabled';
  static const String lastSyncedKey = 'cloud_sync.last_synced';

  /// A push still in flight after this reads as "no connection".
  static const Duration waitAfter = Duration(seconds: 5);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final KeyValueStore _store;
  final Logger _logger;
  final DateTime Function() _now;

  final ValueNotifier<SyncAccount?> _account = ValueNotifier(null);
  final ValueNotifier<SyncStatus> _status = ValueNotifier(const SyncOff());
  final Set<_Watcher> _watchers = {};
  StreamSubscription<User?>? _authChanges;
  Timer? _wait;
  bool _enabled = true;
  bool _stopped = false;
  DateTime? _lastSynced;
  ({String name, Map<String, Object?> data, int updatedAt})? _unsent;

  /// Bumped by every push, account change and switch change, so the late
  /// outcome of an older attempt never overwrites a newer status.
  int _epoch = 0;

  @override
  ValueListenable<SyncAccount?> get account => _account;

  @override
  ValueListenable<SyncStatus> get status => _status;

  @override
  DateTime? get lastSynced => _lastSynced;

  @override
  bool get enabled => _enabled;

  /// Restores the switch and the last sync, then follows the signed-in user.
  Future<void> start() async {
    _enabled = await _store.read(enabledKey) != 'false';
    final ms = int.tryParse(await _store.read(lastSyncedKey) ?? '');
    _lastSynced = ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
    _onUser(_auth.currentUser);
    _authChanges = _auth.authStateChanges().listen(_onUser);
  }

  void _onUser(User? user) {
    if (user?.uid == _account.value?.uid) return;
    _epoch++;
    _wait?.cancel();
    _unsent = null;
    _stopped = false;
    if (user == null) {
      _account.value = null;
      _lastSynced = null;
      unawaited(_store.delete(lastSyncedKey));
    } else {
      _account.value = SyncAccount(
        uid: user.uid,
        email: user.email ?? '',
        provider: _providerOf(user),
      );
    }
    _settle();
    _resubscribe();
  }

  /// The status with nothing in flight: off, the last sync, or checking.
  void _settle() {
    final last = _lastSynced;
    if (_account.value == null || !_enabled) {
      _status.value = const SyncOff();
    } else if (last != null) {
      _status.value = SyncDone(last);
    } else {
      _begin(_epoch);
    }
  }

  static SyncProvider _providerOf(User user) {
    final ids = user.providerData.map((info) => info.providerId).toSet();
    if (ids.contains('google.com')) return SyncProvider.google;
    if (ids.contains('apple.com')) return SyncProvider.apple;
    return SyncProvider.email;
  }

  @override
  Future<void> setEnabled(bool on) async {
    if (on == _enabled) return;
    _enabled = on;
    _epoch++;
    _wait?.cancel();
    if (on || _account.value == null) {
      _settle();
    } else {
      _status.value = const SyncOff();
    }
    _resubscribe();
    await _store.write(enabledKey, '$on');
  }

  @override
  Future<void> push(
    String name,
    Map<String, Object?> data, {
    required int updatedAt,
  }) async {
    final account = _account.value;
    if (account == null || !_enabled || _stopped) return;
    final epoch = ++_epoch;
    _unsent = (name: name, data: data, updatedAt: updatedAt);
    _begin(epoch);
    try {
      await _document(
        account.uid,
        name,
      ).set({'data': data, 'updatedAt': updatedAt});
    } on FirebaseException catch (error, stack) {
      _logger.e('Could not sync $name (${error.code})', error, stack);
      _fail(epoch, switch (error.code) {
        'unavailable' => SyncFailure.offline,
        'permission-denied' || 'unauthenticated' => SyncFailure.denied,
        _ => SyncFailure.unknown,
      });
      return;
    } on Exception catch (error, stack) {
      _logger.e('Could not sync $name', error, stack);
      _fail(epoch, SyncFailure.unknown);
      return;
    }
    if (epoch != _epoch) return;
    _unsent = null;
    await _done();
  }

  void _begin(int epoch) {
    _status.value = const SyncPending();
    _wait?.cancel();
    _wait = Timer(waitAfter, () {
      if (epoch == _epoch) _status.value = const SyncWaiting();
    });
  }

  void _fail(int epoch, SyncFailure reason) {
    if (epoch != _epoch) return;
    _wait?.cancel();
    _status.value = SyncFailed(_now(), reason);
  }

  Future<void> _done() async {
    _wait?.cancel();
    final at = _now();
    _lastSynced = at;
    _status.value = SyncDone(at);
    await _store.write(lastSyncedKey, '${at.millisecondsSinceEpoch}');
  }

  @override
  Future<void> retry() async {
    final unsent = _unsent;
    if (unsent == null) return;
    await push(unsent.name, unsent.data, updatedAt: unsent.updatedAt);
  }

  @override
  Stream<SyncedDocument?> watch(String name) {
    late final _Watcher watcher;
    final controller = StreamController<SyncedDocument?>(
      onListen: () {
        _watchers.add(watcher);
        _subscribe(watcher);
      },
      onCancel: () {
        _watchers.remove(watcher);
        return watcher.subscription?.cancel();
      },
    );
    watcher = _Watcher(name, controller);
    return controller.stream;
  }

  void _resubscribe() {
    for (final watcher in _watchers) {
      _subscribe(watcher);
    }
  }

  void _subscribe(_Watcher watcher) {
    unawaited(watcher.subscription?.cancel());
    watcher.subscription = null;
    final account = _account.value;
    if (account == null || !_enabled || _stopped) return;
    watcher.subscription = _document(account.uid, watcher.name)
        .snapshots(includeMetadataChanges: true)
        .listen(
          (snapshot) => _onSnapshot(watcher, snapshot),
          onError: (Object error, StackTrace stack) =>
              _logger.e('Could not watch ${watcher.name}', error, stack),
        );
  }

  void _onSnapshot(
    _Watcher watcher,
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final metadata = snapshot.metadata;
    if (metadata.hasPendingWrites) return;
    final raw = snapshot.data();
    SyncedDocument? document;
    if (raw != null) {
      final data = raw['data'];
      final updatedAt = raw['updatedAt'];
      // Web can decode a whole number as a double.
      if (data is! Map<String, Object?> || updatedAt is! num) {
        _logger.w('Ignoring malformed synced document ${watcher.name}');
        return;
      }
      document = SyncedDocument(data: data, updatedAt: updatedAt.toInt());
    }
    watcher.controller.add(document);
    // A server answer with nothing of ours in flight: this device is in
    // step with the cloud. A failed push keeps its message.
    final status = _status.value;
    if (!metadata.isFromCache &&
        _unsent == null &&
        (status is SyncPending ||
            status is SyncWaiting ||
            status is SyncDone)) {
      unawaited(_done());
    }
  }

  @override
  Future<void> deleteAll() async {
    final account = _account.value;
    if (account == null) return;
    // Stop first, so the deletion is not answered by a fresh upload.
    _stopped = true;
    _epoch++;
    _wait?.cancel();
    _resubscribe();
    try {
      final documents = await _firestore
          .collection('users')
          .doc(account.uid)
          .collection('sync')
          .get();
      for (final document in documents.docs) {
        await document.reference.delete();
      }
    } on Exception catch (error, stack) {
      _logger.e('Could not delete synced documents', error, stack);
      _stopped = false;
      _settle();
      _resubscribe();
      rethrow;
    }
  }

  DocumentReference<Map<String, dynamic>> _document(String uid, String name) =>
      _firestore.collection('users').doc(uid).collection('sync').doc(name);

  /// Cancels the auth subscription, the wait timer and every watcher.
  Future<void> dispose() async {
    _epoch++;
    _wait?.cancel();
    await _authChanges?.cancel();
    for (final watcher in _watchers.toList()) {
      await watcher.subscription?.cancel();
      await watcher.controller.close();
    }
    _watchers.clear();
    _account.dispose();
    _status.dispose();
  }
}

class _Watcher {
  _Watcher(this.name, this.controller);

  final String name;
  final StreamController<SyncedDocument?> controller;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? subscription;
}
