import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Taps that ripple or skip the press-down. Whitespace-tolerant, so a call
/// the formatter splits across lines is still caught. `*ThemeData` and
/// `styleFrom` are theme config for third-party screens, not taps.
final _stray = RegExp(
  r'\bInkWell\s*\(|\bInkResponse\s*\(|\bSwitchListTile\b|'
  r'\b(Text|Filled|Outlined|Elevated|Icon)Button\b(?!\s*\.\s*styleFrom)',
);

/// Widgets that are fine until they take a tap.
final _tapOwner = RegExp(r'\b(ListTile|GestureDetector)\s*\(');
final _onTap = RegExp(r'\bonTap\s*:');

/// Files that own the tap itself, or only drag.
const _allowed = [
  // The two widgets every other tap is built on.
  'pressable.dart',
  'app_button.dart',
  // Swipes and drags on the clock face, not taps on a control.
  'gesture_layer.dart',
];

/// [source] with every comment blanked out (line count kept), so docs may
/// name the forbidden widgets.
String _code(String source) =>
    source.replaceAllMapped(RegExp(r'//[^\n]*'), (m) => ' ' * m[0]!.length);

/// The argument list of the call whose `(` ends at [open], up to its
/// matching `)`.
String _args(String code, int open) {
  var depth = 0;
  for (var i = open; i < code.length; i++) {
    if (code[i] == '(') depth++;
    if (code[i] == ')' && --depth == 0) return code.substring(open, i);
  }
  return code.substring(open);
}

/// Offsets of every stray tap in [code].
Iterable<int> _hits(String code) => [
  for (final m in _stray.allMatches(code)) m.start,
  for (final m in _tapOwner.allMatches(code))
    if (_onTap.hasMatch(_args(code, m.end - 1))) m.start,
];

void main() {
  test('every tap in design_system, flip_clock and auth is a Pressable', () {
    final hits = <String>[];
    for (final root in [
      'lib',
      '../../packages/design_system/lib',
      '../auth/lib',
    ]) {
      final files = Directory(root)
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => !f.path.contains('/generated/'))
          .where((f) => !_allowed.any(f.path.endsWith));
      for (final file in files) {
        final code = _code(file.readAsStringSync());
        for (final at in _hits(code)) {
          final line = '\n'.allMatches(code.substring(0, at)).length + 1;
          final end = code.indexOf('\n', at);
          hits.add(
            '${file.path}:$line: '
            '${code.substring(at, end < 0 ? null : end).trim()}',
          );
        }
      }
    }
    expect(hits, isEmpty, reason: hits.join('\n'));
  });

  test('the scan sees every stray tap, and not theme config', () {
    for (final stray in [
      'InkWell(onTap: f)',
      'InkResponse(onTap: f)',
      'TextButton(onPressed: f, child: x)',
      'TextButton.icon(onPressed: f)',
      'FilledButton(onPressed: f)',
      'OutlinedButton(onPressed: f)',
      'ElevatedButton(onPressed: f)',
      'IconButton(onPressed: f, icon: x)',
      'SwitchListTile(value: v, onChanged: f)',
      'ListTile(title: x, onTap: f)',
      'GestureDetector(onTap: f, child: x)',
      // Split by the formatter.
      'InkWell\n  (onTap: f)',
      'TextButton\n    .icon(onPressed: f)',
      'ListTile(\n  title: Text(a(b)),\n  onTap: f,\n)',
      'GestureDetector(\n  behavior: b,\n  onTap\n    : f,\n)',
    ]) {
      expect(_hits(_code(stray)), isNotEmpty, reason: stray);
    }
    for (final fine in [
      // A comment may name them.
      '// never an InkWell( or a TextButton',
      '/// a ListTile(onTap: f) ripples',
      // Theme config and our own widgets.
      'textButtonTheme: TextButtonThemeData(',
      'style: TextButton.styleFrom(shape: s)',
      'FilledButton\n  .styleFrom(shape: s)',
      'AppButton.text(label: l, onPressed: f)',
      'Pressable(onTap: f, child: x)',
      'RawGestureDetector(gestures: g)',
      'ListTile(title: x)',
      'GestureDetector(onVerticalDragUpdate: f)',
      // An unclosed call stops at the end of the file.
      'ListTile(title: x',
    ]) {
      expect(_hits(_code(fine)), isEmpty, reason: fine);
    }
  });
}
