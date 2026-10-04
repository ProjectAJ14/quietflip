import 'dart:io';

import 'package:crypto/crypto.dart';

/// google/fonts at a fixed commit, so the files (and their checksums) never
/// change under us.
const String _commit = '9710da1eacb3be272583c3224dcb70f9da6eadbb';

/// Cache file -> (path in google/fonts, sha256). Only the store screenshots
/// use these (Japanese, Korean, Chinese and Hindi, which the app leaves to
/// the device's system fonts); they never ship in the app. The cache name
/// must match `apps/quietflip/store_screenshots/fonts.dart`.
const Map<String, (String, String)> _fonts = {
  'NotoSansJP.ttf': (
    'ofl/notosansjp/NotoSansJP%5Bwght%5D.ttf',
    'c2f3b4d463500a2ddcd3849cded1fceeb9fd6d1c32e6cbecd568453ba50fc68f',
  ),
  'NotoSansKR.ttf': (
    'ofl/notosanskr/NotoSansKR%5Bwght%5D.ttf',
    '194018e6b2b293a7964f037b25c0249ce1418bc9ab3c971060a03aa57861e252',
  ),
  'NotoSansSC.ttf': (
    'ofl/notosanssc/NotoSansSC%5Bwght%5D.ttf',
    'a3041811a78c361b1de50f953c805e0244951c21c5bd412f7232ef0d899af0da',
  ),
  'NotoSansDevanagari.ttf': (
    'ofl/notosansdevanagari/NotoSansDevanagari%5Bwdth,wght%5D.ttf',
    '14ec4af41f27482216d1c2229f417ff9b1425e1babb014e57d1d40d03229853e',
  ),
};

/// Gitignored, and outside `build/` so `flutter clean` keeps it.
const String _cache = '.dart_tool/store_fonts';

/// Downloads the store screenshots' script fonts into [_cache] and checks
/// each against its pinned sha256. Files already there with the right
/// checksum are kept. Run from the repository root:
/// `dart run tool/fetch_store_fonts.dart`.
Future<void> main() async {
  Directory(_cache).createSync(recursive: true);
  final client = HttpClient();
  try {
    for (final MapEntry(key: name, value: (path, sha)) in _fonts.entries) {
      final file = File('$_cache/$name');
      if (file.existsSync() &&
          sha256.convert(file.readAsBytesSync()).toString() == sha) {
        stdout.writeln('ok      $name (cached)');
        continue;
      }
      final url = Uri.parse(
        'https://raw.githubusercontent.com/google/fonts/$_commit/$path',
      );
      final response = await (await client.getUrl(url)).close();
      if (response.statusCode != HttpStatus.ok) {
        stderr.writeln('failed  $name: HTTP ${response.statusCode} for $url');
        exitCode = 1;
        continue;
      }
      final bytes = [for (final chunk in await response.toList()) ...chunk];
      final actual = sha256.convert(bytes).toString();
      if (actual != sha) {
        stderr.writeln('failed  $name: sha256 $actual, expected $sha');
        exitCode = 1;
        continue;
      }
      file.writeAsBytesSync(bytes);
      stdout.writeln('fetched $name (${bytes.length} bytes)');
    }
  } finally {
    client.close();
  }
}
