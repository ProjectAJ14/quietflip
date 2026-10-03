import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every face ships in the app with its licence; nothing downloads.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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

  test('every Noto Sans Arabic weight is bundled with its licence', () {
    for (final weight in DesignFonts.arabicWeights) {
      final name = 'NotoSansArabic-${DisplayFace.weightName(weight)}.ttf';
      expect(File('$dir/$name').existsSync(), isTrue, reason: name);
    }
    expect(
      File('$dir/OFL-NotoSansArabic.txt').readAsStringSync(),
      contains('SIL Open Font License, Version 1.1'),
    );
  });

  test('withArabic appends Noto Sans Arabic at a bundled weight', () {
    String arabicOf(FontWeight? weight) => DesignFonts.withArabic(
      TextStyle(fontWeight: weight, fontFamilyFallback: const ['Geist']),
    ).fontFamilyFallback!.last;
    final styled = DesignFonts.withArabic(
      const TextStyle(fontFamily: 'Geist_700', fontFamilyFallback: ['Geist']),
    );
    expect(styled.fontFamily, 'Geist_700');
    expect(styled.fontFamilyFallback, hasLength(2));
    expect(styled.fontFamilyFallback!.first, 'Geist');
    expect(arabicOf(null), startsWith('NotoSansArabic'));
    // Nearest bundled weight: below 400 and above 700 clamp, 650 is 600.
    expect(arabicOf(FontWeight.w100), arabicOf(FontWeight.w400));
    expect(arabicOf(FontWeight.w900), arabicOf(FontWeight.w700));
    expect(arabicOf(const FontWeight(650)), arabicOf(FontWeight.w600));
    expect(arabicOf(FontWeight.w500), isNot(arabicOf(FontWeight.w400)));
    expect(
      DesignFonts.withArabic(const TextStyle()).fontFamilyFallback,
      hasLength(1),
    );
  });

  test('every interface role falls back to Arabic, with or without a face', () {
    for (final face in [null, DisplayFace.bigShoulders]) {
      final theme = DesignSystem.monoTextTheme(
        Typography.material2021().black,
        face: face,
      );
      for (final style in [
        theme.displayLarge, theme.displayMedium, theme.displaySmall, //
        theme.headlineLarge, theme.headlineMedium, theme.headlineSmall,
        theme.titleLarge, theme.titleMedium, theme.titleSmall,
        theme.bodyLarge, theme.bodyMedium, theme.bodySmall,
        theme.labelLarge, theme.labelMedium, theme.labelSmall,
      ]) {
        expect(
          style!.fontFamilyFallback!.last,
          startsWith('NotoSansArabic'),
          reason: '$face ${style.fontFamily}',
        );
      }
    }
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

  test('every display face knows where its digits centre', () {
    for (final face in DisplayFace.values) {
      expect(face.digitCentre, inInclusiveRange(0.25, 0.5), reason: face.name);
    }
    expect(DisplayFace.barlowCondensed.digitCentre, 0.351);
    expect(DisplayFace.dmSerifDisplay.digitCentre, 0.315);
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
