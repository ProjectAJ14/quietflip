import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Where a literal is shown to the user: the first argument of `Text(` and
/// the named arguments widgets render or read aloud. Whitespace-tolerant, so
/// a call the formatter splits across lines is still caught.
final _shown = RegExp(
  r'''(?:\bText\s*\(\s*|\b(?:label|title|subtitle|message|tooltip|semanticsLabel|semanticLabel|hintText|labelText|helperText|errorText|counterText|description|body|text)\s*:\s*)(?:'((?:[^'\\\n]|\\.)*)'|"((?:[^"\\\n]|\\.)*)")''',
);

/// Interpolations (`$name`, `${expr}`) carry already-localized text.
final _interpolation = RegExp(r'\$\{[^}]*\}|\$\w+');

/// Two letters in a row: words, not separators like `·` or `%`.
final _word = RegExp(r'\p{L}{2,}', unicode: true);

/// Literals that look shown but never reach the screen, with why.
const _allowed = {
  // An `ErrorResponse` built for logs and callers; no screen renders it.
  'packages/network/lib/src/client/dio_network_client.dart':
      'Network Client failed to parse response!',
};

/// [source] with every comment blanked out (line count kept), so docs may
/// quote copy.
String _code(String source) =>
    source.replaceAllMapped(RegExp(r'//[^\n]*'), (m) => ' ' * m[0]!.length);

/// User-facing literals in [code].
Iterable<RegExpMatch> _hits(String code) => _shown.allMatches(code).where((m) {
  final text = (m[1] ?? m[2]!).replaceAll(_interpolation, '');
  return _word.hasMatch(text);
});

void main() {
  test('no user-facing string literal in any lib/ outside localization', () {
    const root = '../..';
    final hits = <String>[];
    for (final area in ['apps', 'features', 'packages', 'plugins']) {
      final dir = Directory('$root/$area');
      if (!dir.existsSync()) continue;
      for (final member in dir.listSync().whereType<Directory>()) {
        final lib = Directory('${member.path}/lib');
        if (!lib.existsSync() || member.path.endsWith('/localization')) {
          continue;
        }
        final files = lib
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))
            .where((f) => !f.path.contains('/generated/'))
            .where((f) => !RegExp(r'\.(g|freezed|i69n)\.dart$').hasMatch(f.path))
            .where((f) => !f.path.endsWith('firebase_options.dart'));
        for (final file in files) {
          final path = file.path.substring(root.length + 1);
          final code = _code(file.readAsStringSync());
          for (final m in _hits(code)) {
            if (_allowed[path] == (m[1] ?? m[2])) continue;
            final line = '\n'.allMatches(code.substring(0, m.start)).length + 1;
            hits.add('$path:$line: ${m[0]!.replaceAll(RegExp(r'\s+'), ' ')}');
          }
        }
      }
    }
    expect(hits, isEmpty, reason: hits.join('\n'));
  });

  test('the scan sees shown literals, and not composed or hidden ones', () {
    for (final shown in [
      "Text('Hello')",
      'Text("Hello")',
      "Text(\n  'Hello',\n)",
      "label: 'File Name'",
      "tooltip:\n    'Close'",
      "semanticsLabel: 'Close menu'",
      r"message: '$label copied'",
      "title: 'Ünïcode wörds'",
      "hintText: 'こんにちは'",
    ]) {
      expect(_hits(_code(shown)), isNotEmpty, reason: shown);
    }
    for (final fine in [
      'Text(strings.generic.ok)',
      r"semanticsLabel: '$name, $mood'",
      r"label: '${strings.a} · ${strings.b}'",
      "Text('·')",
      "Text('%')",
      "Text('A')",
      "fontFamily: 'monospace'",
      "key: 'label'",
      "// Text('Hello')",
      "/// label: 'File Name'",
      "Text(r'raw')",
    ]) {
      expect(_hits(_code(fine)), isEmpty, reason: fine);
    }
  });
}
