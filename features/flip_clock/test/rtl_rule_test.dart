import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Layout pinned to a physical side, which does not mirror in right-to-left
/// languages. Use `EdgeInsetsDirectional`, `AlignmentDirectional`,
/// `PositionedDirectional` and `TextAlign.start` / `end` instead.
/// Whitespace-tolerant, so a call the formatter splits is still caught.
final _pinned = RegExp(
  r'\bEdgeInsets\s*\.\s*fromLTRB\s*\(|'
  r'\bAlignment\s*\.\s*(top|center|bottom)(Left|Right)\b|'
  r'\bTextAlign\s*\.\s*(left|right)\b',
);

/// Calls that are fine until they name a side.
final _sided = RegExp(r'\b(EdgeInsets\s*\.\s*only|(Animated)?Positioned)\s*\(');
final _side = RegExp(r'\b(left|right)\s*:');

/// Deliberately physical code: the file, the start of the match, and why.
const _allowed = [
  (
    file: 'subtle_movement.dart',
    match: 'EdgeInsets.fromLTRB',
    reason: 'a burn-in pixel shift, not layout; it has no reading direction',
  ),
];

/// [source] with every comment blanked out (line count kept), so docs may
/// name the forbidden forms.
String _code(String source) =>
    source.replaceAllMapped(RegExp(r'//[^\n]*'), (m) => ' ' * m[0]!.length);

/// The argument list of the call whose `(` ends at [open], up to its
/// matching `)`; only its own arguments, not those of nested calls.
String _args(String code, int open) {
  final own = StringBuffer();
  var depth = 0;
  for (var i = open; i < code.length; i++) {
    if (code[i] == '(') depth++;
    if (depth == 1) own.write(code[i]);
    if (code[i] == ')' && --depth == 0) break;
  }
  return own.toString();
}

/// Offsets of every physical-side form in [code].
Iterable<int> _hits(String code) => [
  for (final m in _pinned.allMatches(code)) m.start,
  for (final m in _sided.allMatches(code))
    if (_side.hasMatch(_args(code, m.end - 1))) m.start,
];

/// Every hand-written `.dart` file under a `lib/` of an app, feature,
/// package or plugin.
Iterable<File> _sources() sync* {
  for (final area in ['apps', 'features', 'packages', 'plugins']) {
    final root = Directory('../../$area');
    if (!root.existsSync()) continue;
    for (final member in root.listSync().whereType<Directory>()) {
      final lib = Directory('${member.path}/lib');
      if (!lib.existsSync()) continue;
      yield* lib
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => !f.path.contains('/generated/'))
          .where((f) => !RegExp(r'\.(g|freezed|i69n)\.dart$').hasMatch(f.path));
    }
  }
}

void main() {
  test('no layout in any lib/ is pinned to the left or right', () {
    final hits = <String>[];
    var scanned = 0;
    for (final file in _sources()) {
      scanned++;
      final code = _code(file.readAsStringSync());
      for (final at in _hits(code)) {
        final end = code.indexOf('\n', at);
        final text = code.substring(at, end < 0 ? null : end).trim();
        if (_allowed.any(
          (a) => file.path.endsWith(a.file) && text.startsWith(a.match),
        )) {
          continue;
        }
        final line = '\n'.allMatches(code.substring(0, at)).length + 1;
        hits.add('${file.path}:$line: $text');
      }
    }
    // The flip clock, the design system and the app at least.
    expect(scanned, greaterThan(50));
    expect(hits, isEmpty, reason: hits.join('\n'));
  });

  test('every allowed exception still exists', () {
    for (final allowed in _allowed) {
      final file = _sources().singleWhere((f) => f.path.endsWith(allowed.file));
      expect(
        _hits(_code(file.readAsStringSync())),
        isNotEmpty,
        reason: '${allowed.file}: ${allowed.reason}',
      );
    }
  });

  test('the scan sees every physical side, and not directional forms', () {
    for (final pinned in [
      'EdgeInsets.fromLTRB(1, 2, 3, 4)',
      'const EdgeInsets.fromLTRB(a, b, c, d)',
      'EdgeInsets.only(left: 8)',
      'EdgeInsets.only(top: 4, right: 8)',
      'Alignment.topLeft',
      'Alignment.centerRight',
      'Alignment.bottomLeft',
      'TextAlign.left',
      'TextAlign.right',
      'Positioned(left: 0, child: x)',
      'Positioned(top: 0, right: 0, child: x)',
      'AnimatedPositioned(left: 0, duration: d, child: x)',
      // Split by the formatter.
      'EdgeInsets\n  .fromLTRB(1, 2, 3, 4)',
      'Positioned(\n  top: 0,\n  left\n    : 0,\n  child: f(x),\n)',
      'EdgeInsets.only(\n  left: f(a),\n)',
    ]) {
      expect(_hits(_code(pinned)), isNotEmpty, reason: pinned);
    }
    for (final fine in [
      // A comment may name them.
      '// never EdgeInsets.only(left: 8) or Alignment.topLeft',
      '/// a Positioned(left: 0) does not mirror',
      'EdgeInsetsDirectional.fromSTEB(1, 2, 3, 4)',
      'EdgeInsetsDirectional.only(start: 8)',
      'EdgeInsets.only(top: 4, bottom: 8)',
      'EdgeInsets.symmetric(horizontal: 8)',
      'AlignmentDirectional.topStart',
      'Alignment.topCenter',
      'Alignment.center',
      'TextAlign.start',
      'TextAlign.center',
      'PositionedDirectional(start: 0, child: x)',
      'Positioned.fill(child: x)',
      'Positioned(top: 0, bottom: 0, child: x)',
      // Geometry and other calls that take a side.
      'Rect.fromLTRB(0, 0, w, h)',
      'SafeArea(left: false, right: false, child: x)',
      'geometry.cavity(left: true)',
      // A nested call's side is not the outer one's.
      'Positioned(top: 0, child: SafeArea(left: false, child: x))',
      // An unclosed call stops at the end of the file.
      'Positioned(top: 0',
    ]) {
      expect(_hits(_code(fine)), isEmpty, reason: fine);
    }
  });
}
