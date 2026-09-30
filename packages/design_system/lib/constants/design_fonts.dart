import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

/// The interface family (`ui`) and the weights bundled for it.
abstract final class DesignFonts {
  static const String ui = 'Geist';
  static const List<FontWeight> uiWeights = [
    FontWeight.w400,
    FontWeight.w500,
    FontWeight.w600,
    FontWeight.w700,
  ];
}

/// The bundled digit faces, one weight each. Every file ships in
/// `assets/google_fonts/` as `<Family>-<Weight>.ttf` (see [assetName]), so
/// nothing is fetched at runtime.
enum DisplayFace {
  barlowCondensed('Barlow Condensed', FontWeight.w700),
  bebasNeue('Bebas Neue', FontWeight.w400),
  anton('Anton', FontWeight.w400),
  oswald('Oswald', FontWeight.w600),
  bigShoulders('Big Shoulders', FontWeight.w800),
  archivoBlack('Archivo Black', FontWeight.w400),
  jetBrainsMono('JetBrains Mono', FontWeight.w700),
  spaceGrotesk('Space Grotesk', FontWeight.w700),
  dmSerifDisplay('DM Serif Display', FontWeight.w400),
  orbitron('Orbitron', FontWeight.w700);

  const DisplayFace(this.family, this.weight);

  /// Google Fonts family name.
  final String family;

  /// The one bundled weight.
  final FontWeight weight;

  /// Monospaced faces need wider cards.
  bool get monospaced => this == jetBrainsMono;

  /// This face at its bundled weight, [color] and [fontSize].
  TextStyle style({required Color color, required double fontSize}) =>
      GoogleFonts.getFont(
        family,
        fontWeight: weight,
        color: color,
        fontSize: fontSize,
        height: 1,
      );

  /// The bundled file name, as google_fonts looks it up.
  String get assetName =>
      '${family.replaceAll(' ', '')}-'
      '${weightName(weight)}.ttf';

  /// Google Fonts' file-name part for [weight].
  static String weightName(FontWeight weight) => const {
    400: 'Regular',
    500: 'Medium',
    600: 'SemiBold',
    700: 'Bold',
    800: 'ExtraBold',
  }[weight.value]!;
}
