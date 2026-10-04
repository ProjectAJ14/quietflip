import 'dart:convert';
import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Where `tool/fetch_store_fonts.dart` caches the script fonts, from
/// `apps/quietflip`.
const String _cache = '../../.dart_tool/store_fonts';

/// Script fonts for the languages the app leaves to the device's system
/// fonts (the repo bundles none): file in [_cache] per language.
const Map<String, String> _scriptFonts = {
  'ja': 'NotoSansJP.ttf',
  'ko': 'NotoSansKR.ttf',
  'zh': 'NotoSansSC.ttf',
  'hi': 'NotoSansDevanagari.ttf',
};

/// `flutter test` draws with a placeholder font and has no system font
/// fallback. Loads every font the app bundles (FontManifest: Material and
/// Cupertino icons, the `Roboto` copy of Geist, SocialIcons) and turns off
/// google_fonts' network fetching (Geist and the digit faces then load from
/// design_system's assets on first use), plus the script font [language]
/// needs (Arabic: the bundled Noto Sans Arabic for the digit faces). Call
/// once per test file, inside `tester.runAsync` or `setUpAll`.
Future<void> loadFonts(String language) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  final manifest =
      jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final family in manifest.cast<Map<String, Object?>>()) {
    final loader = FontLoader(family['family']! as String);
    for (final font
        in (family['fonts']! as List).cast<Map<String, Object?>>()) {
      loader.addFont(rootBundle.load(font['asset']! as String));
    }
    await loader.load();
  }
  final ByteData bytes;
  if (language == 'ar') {
    // Bundled for the theme's Arabic fallback, but the digit faces (AM/PM
    // as ص / م) have no fallback of their own: a phone's system font
    // draws those.
    bytes = await rootBundle.load(
      'packages/design_system/assets/google_fonts/NotoSansArabic-Regular.ttf',
    );
  } else {
    final file = _scriptFonts[language];
    if (file == null) return;
    final path = File('$_cache/$file');
    if (!path.existsSync()) {
      throw StateError(
        'Missing ${path.path} for "$language" screenshots. From the '
        'repository root run: dart run tool/fetch_store_fonts.dart',
      );
    }
    bytes = ByteData.sublistView(path.readAsBytesSync());
  }
  // google_fonts gives every style `fontFamilyFallback: [<family>]` (the
  // plain name without spaces, e.g. 'Geist', 'SpaceGrotesk'), and only
  // registers '<family>_<variant>'.
  // Registering the script font under the plain names makes it the
  // fallback for the glyphs Geist and the digit faces lack, the job the
  // system font does on a phone. Each test file is its own process, so this
  // never leaks into another language.
  for (final family in [
    DesignFonts.ui,
    for (final f in DisplayFace.values) f.family.replaceAll(' ', ''),
  ]) {
    // A copy each: loading hands the buffer to the engine, so a second
    // family given the same one silently gets nothing.
    final copy = ByteData.sublistView(
      Uint8List.fromList(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      ),
    );
    await (FontLoader(family)..addFont(Future.value(copy))).load();
  }
}
