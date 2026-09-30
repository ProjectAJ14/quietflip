// This file is a placeholder. Generate the real one with:
//
//   cd apps/quietflip && flutterfire configure
//
// FlutterFire overwrites this file with your project's options and also drops
// google-services.json / GoogleService-Info.plist into the native folders.
// Until then, bootstrap catches the throw and skips Firebase-backed modules
// so the rest of the app still runs.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

abstract final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
    'Firebase has not been configured for Quietflip.\n'
    'Run `flutterfire configure` inside apps/quietflip '
    'to replace lib/firebase_options.dart.',
  );
}
