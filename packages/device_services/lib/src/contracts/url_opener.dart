/// Opens a web address outside the app (the browser, or a new tab on web).
abstract interface class UrlOpener {
  /// Returns whether the address was opened. Never throws.
  Future<bool> open(Uri url);
}
