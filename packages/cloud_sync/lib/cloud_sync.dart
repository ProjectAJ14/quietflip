/// Offline-first sync of named JSON documents for the signed-in user.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_sync/src/cloud_sync.dart';
import 'package:cloud_sync/src/firestore_cloud_sync.dart';
import 'package:core/core.dart';
import 'package:device_services/device_services.dart';
import 'package:di/di.dart';
import 'package:firebase_auth/firebase_auth.dart';

export 'src/cloud_sync.dart';
export 'src/firestore_cloud_sync.dart';

/// Turns on Firestore's offline cache and registers [CloudSync].
///
/// Needs Firebase initialised and `Logger` and `KeyValueStore` in `di`
/// (after `core.init()` and `device_services.init()`). [auth] and
/// [firestore] default to the SDK instances; tests pass fakes.
Future<void> init({FirebaseAuth? auth, FirebaseFirestore? firestore}) async {
  final store = firestore ?? FirebaseFirestore.instance;
  // Web needs it set explicitly; native platforms default to on.
  store.settings = const Settings(persistenceEnabled: true);
  final sync = FirestoreCloudSync(
    auth: auth ?? FirebaseAuth.instance,
    firestore: store,
    store: di.get<KeyValueStore>(),
    logger: di.get<Logger>(),
  );
  await sync.start();
  di.register<CloudSync>(sync, dispose: (_) => sync.dispose());
  di.get<Logger>().i('Cloud sync module initialized');
}
