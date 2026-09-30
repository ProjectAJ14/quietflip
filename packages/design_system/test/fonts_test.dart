import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every face ships in the app with its licence; nothing downloads.
void main() {
  const dir = 'assets/google_fonts';

  test('the font folder is declared as an asset', () {
    expect(File('pubspec.yaml').readAsStringSync(), contains('- $dir/'));
  });

  test('every Geist weight is bundled with its licence', () {
    for (final weight in DesignFonts.uiWeights) {
      final name = 'Geist-${DisplayFace.weightName(weight)}.ttf';
      expect(File('$dir/$name').existsSync(), isTrue, reason: name);
    }
    expect(File('$dir/OFL-Geist.txt').existsSync(), isTrue);
  });

  test('every display face is bundled with its OFL licence', () {
    for (final face in DisplayFace.values) {
      expect(
        File('$dir/${face.assetName}').existsSync(),
        isTrue,
        reason: face.assetName,
      );
      final licence = File('$dir/OFL-${face.family.replaceAll(' ', '')}.txt');
      expect(
        licence.readAsStringSync(),
        contains('SIL Open Font License, Version 1.1'),
      );
    }
  });

  test('a face style carries its family, weight and size', () {
    final style = DisplayFace.bigShoulders.style(
      color: const Color(0xff000000),
      fontSize: 88,
    );
    expect(style.fontFamily, startsWith('BigShoulders'));
    expect(style.fontWeight, FontWeight.w800);
    expect(style.fontSize, 88);
    expect(style.height, 1);
    expect(DisplayFace.bigShoulders.assetName, 'BigShoulders-ExtraBold.ttf');
    expect(DisplayFace.jetBrainsMono.monospaced, isTrue);
    expect(DisplayFace.barlowCondensed.monospaced, isFalse);
  });
}
