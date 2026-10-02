abstract interface class AuthService {
  String get uid;

  bool get isSignedIn;

  Future<void> signOut();

  /// Deletes the signed-in account (no-op when signed out). Failures, such
  /// as `requires-recent-login`, are logged and rethrown.
  Future<void> deleteAccount();
}
