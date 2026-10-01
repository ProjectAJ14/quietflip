import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flip_clock/data/skins.dart';
import 'package:flip_clock/ui/components/flip_display.dart';
import 'package:flip_clock/ui/components/skin_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Shape code that would let a widget pick its own corner. Only
/// `DesignShape` turns a radius into a shape. Whitespace-tolerant, so a
/// call the formatter splits across lines is still caught.
final _stray = RegExp(
  r'Radius\s*\.\s*(circular|elliptical)\s*\(|StadiumBorder|CircleBorder|'
  r'BoxShape\s*\.\s*circle\b|CircleAvatar|ClipOval|OvalBorder|StarBorder|'
  r'BeveledRectangleBorder|ContinuousRectangleBorder|InkResponse\s*\(|'
  r'OutlineInputBorder\s*\(\s*\)',
);

/// [source] with every comment blanked out (line count kept), so docs may
/// name the forbidden shapes.
String _code(String source) =>
    source.replaceAllMapped(RegExp(r'//[^\n]*'), (m) => ' ' * m[0]!.length);

double _radiusOf(Decoration? d) =>
    ((d! as BoxDecoration).borderRadius! as BorderRadius).topLeft.x;

void main() {
  test('no shape outside DesignShape in design_system or flip_clock', () {
    final hits = <String>[];
    for (final root in ['lib', '../../packages/design_system/lib']) {
      final files = Directory(root)
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => !f.path.contains('/generated/'))
          .where((f) => !f.path.endsWith('design_shape.dart'));
      for (final file in files) {
        final code = _code(file.readAsStringSync());
        for (final m in _stray.allMatches(code)) {
          final line = '\n'.allMatches(code.substring(0, m.start)).length + 1;
          hits.add('${file.path}:$line: ${m[0]}');
        }
      }
    }
    expect(hits, isEmpty, reason: hits.join('\n'));
  });

  test('the scan sees every way to pick a corner, and not DesignShape', () {
    for (final stray in [
      'shape: const StadiumBorder(),',
      'BorderRadius.circular(8)',
      'Radius.elliptical(4, 2)',
      'ClipOval(child: x)',
      'InkResponse(onTap: f)',
      'border: OutlineInputBorder(),',
      'shape: BeveledRectangleBorder(',
      // Split by the formatter.
      'BorderRadius\n    .circular(8)',
      'shape: BoxShape\n.circle,',
    ]) {
      expect(_stray.hasMatch(_code(stray)), isTrue, reason: stray);
    }
    // A comment may name them.
    expect(_stray.hasMatch(_code('// never a StadiumBorder')), isFalse);
    expect(_stray.hasMatch('DesignShape.circular(shape.md)'), isFalse);
    expect(_stray.hasMatch('DesignShape.radius(shape.lg)'), isFalse);
  });

  for (final corner in [0.0, 24.0]) {
    testWidgets('at corner $corner: skin tile, sheet and flip card agree', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final shape = DesignShape(corner);
      final mono = Skins.resolve(Skins.monoId, const []);
      await tester.pumpWidget(
        DesignSystemWrapper(
          mode: AppearanceMode.black,
          corner: corner,
          builder: (_, theme) => MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Builder(
                builder: (context) => Column(
                  children: [
                    SizedBox(
                      width: SkinPicker.minTileWidth,
                      child: SkinTile(
                        skin: mono,
                        selected: true,
                        now: DateTime(2026, 10, 1, 9, 41),
                        use24h: true,
                        onTap: () {},
                      ),
                    ),
                    SizedBox(
                      width: 400,
                      height: 200,
                      child: FlipDisplay(
                        cards: const ['12'],
                        skin: mono,
                        semanticsLabel: '12',
                      ),
                    ),
                    TextButton(
                      onPressed: () => showSheet<void>(
                        context,
                        const SizedBox(key: Key('sheet')),
                      ),
                      child: const Text('open'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      final tile = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(SkinTile),
              matching: find.byWidgetPredicate(
                (w) => w is Container && w.constraints?.maxHeight == 118,
              ),
            )
            .first,
      );
      expect(_radiusOf(tile.decoration), shape.md);
      // The big card (200 high) is under digit-l: the md role.
      final card = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(FlipDisplay).last,
              matching: find.byType(Container),
            ),
          )
          .firstWhere((c) => c.decoration is BoxDecoration);
      expect(_radiusOf(card.decoration), shape.forHeight(200));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final sheet = tester.widget<Material>(
        find
            .ancestor(
              of: find.byKey(const Key('sheet')),
              matching: find.byType(Material),
            )
            .first,
      );
      final border = sheet.shape! as RoundedRectangleBorder;
      expect((border.borderRadius as BorderRadius).topLeft.x, shape.lg);
    });
  }
}
