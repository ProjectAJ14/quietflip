/// Small persistent string store (preferences, timer snapshot).
abstract interface class KeyValueStore {
  /// The stored value, or null when absent.
  Future<String?> read(String key);

  /// Stores [value] under [key], replacing any previous value.
  Future<void> write(String key, String value);

  /// Removes [key]; no-op when absent.
  Future<void> delete(String key);
}
