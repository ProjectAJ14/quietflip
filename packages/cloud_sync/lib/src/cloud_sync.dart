import 'package:flutter/foundation.dart';

/// Syncs named JSON documents for the signed-in user, offline first.
///
/// Knows nothing about what it syncs: callers pick the document names and
/// payloads, and decide which copy wins.
abstract interface class CloudSync {
  /// The signed-in account, null when signed out.
  ValueListenable<SyncAccount?> get account;

  /// What the account page and the sync card show.
  ValueListenable<SyncStatus> get status;

  /// When this device last confirmed it matches the cloud, null when never
  /// (or since signing out). Restored at launch.
  DateTime? get lastSynced;

  /// The Sync settings switch. True by default; saved per device.
  bool get enabled;

  /// Turns sync on or off for this device and saves the choice.
  Future<void> setEnabled(bool on);

  /// Uploads [data] as document [name], stamped [updatedAt] (ms since epoch,
  /// set by the device that changed it). Never throws: the outcome lands in
  /// [status]. A no-op when signed out or switched off.
  Future<void> push(
    String name,
    Map<String, Object?> data, {
    required int updatedAt,
  });

  /// Server-confirmed copies of document [name] for the current account;
  /// null when the account has no copy yet. Re-subscribed on sign-in,
  /// sign-out and when the switch changes. Own pending writes are skipped.
  Stream<SyncedDocument?> watch(String name);

  /// Re-sends the last push that did not land (the Try again button).
  Future<void> retry();

  /// Deletes every synced document of the current account and stops syncing
  /// until the account changes (call before deleting the account). Errors
  /// are logged and rethrown.
  Future<void> deleteAll();
}

/// How the account signed in.
enum SyncProvider { email, google, apple }

/// The signed-in account, as the account page shows it.
@immutable
class SyncAccount {
  const SyncAccount({
    required this.uid,
    required this.email,
    required this.provider,
  });

  final String uid;
  final String email;
  final SyncProvider provider;

  @override
  bool operator ==(Object other) =>
      other is SyncAccount &&
      other.uid == uid &&
      other.email == email &&
      other.provider == provider;

  @override
  int get hashCode => Object.hash(uid, email, provider);
}

/// A server-confirmed copy of a synced document.
@immutable
class SyncedDocument {
  const SyncedDocument({required this.data, required this.updatedAt});

  final Map<String, Object?> data;

  /// When the device that wrote it changed it (ms since epoch).
  final int updatedAt;
}

/// Why a push failed.
enum SyncFailure { offline, denied, unknown }

/// Where sync stands, for display.
@immutable
sealed class SyncStatus {
  const SyncStatus();
}

/// Signed out, or the switch is off.
final class SyncOff extends SyncStatus {
  const SyncOff();
}

/// A push (or the first check after signing in) is in flight.
final class SyncPending extends SyncStatus {
  const SyncPending();
}

/// In flight for longer than [FirestoreCloudSync.waitAfter]: no connection.
/// The write is queued and goes out when the connection returns.
final class SyncWaiting extends SyncStatus {
  const SyncWaiting();
}

/// This device matches the cloud as of [at].
final class SyncDone extends SyncStatus {
  const SyncDone(this.at);

  final DateTime at;

  @override
  bool operator ==(Object other) => other is SyncDone && other.at == at;

  @override
  int get hashCode => at.hashCode;
}

/// The last push failed at [at] because of [reason].
final class SyncFailed extends SyncStatus {
  const SyncFailed(this.at, this.reason);

  final DateTime at;
  final SyncFailure reason;

  @override
  bool operator ==(Object other) =>
      other is SyncFailed && other.at == at && other.reason == reason;

  @override
  int get hashCode => Object.hash(at, reason);
}
