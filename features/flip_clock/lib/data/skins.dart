import 'package:design_system/design_system.dart';
import 'package:flip_clock/data/models/skin.dart';
import 'package:flutter/painting.dart';
import 'package:localization/localization.dart';

/// The built-in skins, all free. Colours are the design system's `skin-*`
/// tokens; names are read from `strings` when called.
abstract final class Skins {
  static const String monoId = 'mono';

  /// Colour variations on the default face (the picker's Classic section).
  /// Paper and Cyan show seconds as a badge, Violet and Amber as cards;
  /// Mono (the default) and the rest show none.
  static List<Skin> classic() {
    final c = strings.clock;
    Skin tint(
      String id,
      String name,
      Color digits, [
      SkinSeconds seconds = SkinSeconds.off,
    ]) => Skin(id: id, name: name, digitColor: digits, seconds: seconds);
    return [
      // Follows the app theme: ink on card in Mono Light.
      Skin(id: monoId, name: c.skin_mono, themed: true),
      Skin(
        id: 'paper',
        name: c.skin_paper,
        digitColor: DesignSkinColors.inkPaper,
        cardColor: DesignSkinColors.cardPaper,
        groundColor: DesignSkinColors.bgPaper,
        seconds: SkinSeconds.badge,
      ),
      tint('rose', c.skin_rose, DesignSkinColors.rose),
      tint('violet', c.skin_violet, DesignSkinColors.violet, SkinSeconds.cards),
      tint('amber', c.skin_amber, DesignSkinColors.amber, SkinSeconds.cards),
      tint('signal', c.skin_signal, DesignSkinColors.red),
      tint('field', c.skin_field, DesignSkinColors.green),
      tint('mint', c.skin_mint, DesignSkinColors.mint),
      tint('cyan', c.skin_cyan, DesignSkinColors.cyan, SkinSeconds.badge),
      tint('taxi', c.skin_taxi, DesignSkinColors.yellow),
    ];
  }

  /// Presets that each show off a different mix of options (the Bold
  /// section, between Classic and Type).
  static List<Skin> bold() {
    final c = strings.clock;
    return [
      Skin(
        id: 'nightstand',
        name: c.skin_nightstand,
        digitColor: DesignSkinColors.amber,
        seconds: SkinSeconds.cards,
        showDate: true,
      ),
      Skin(
        id: 'studio',
        name: c.skin_studio,
        digitColor: DesignSkinColors.inkPaper,
        cardColor: DesignSkinColors.cardPaper,
        groundColor: DesignSkinColors.bgPaper,
        seconds: SkinSeconds.cards,
        meridiem: SkinMeridiem.right,
      ),
      Skin(
        id: 'arcade',
        name: c.skin_arcade,
        face: DisplayFace.orbitron,
        digitColor: DesignSkinColors.cyan,
        seconds: SkinSeconds.cards,
      ),
      Skin(
        id: 'railway',
        name: c.skin_railway,
        face: DisplayFace.bebasNeue,
        digitColor: DesignSkinColors.yellow,
        seam: false,
        seconds: SkinSeconds.cards,
      ),
      Skin(
        id: 'desk',
        name: c.skin_desk,
        seconds: SkinSeconds.badge,
        showDate: true,
      ),
      Skin(
        id: 'neon',
        name: c.skin_neon,
        face: DisplayFace.jetBrainsMono,
        digitColor: DesignSkinColors.rose,
        seconds: SkinSeconds.cards,
      ),
      Skin(id: 'minimal', name: c.skin_minimal, seam: false),
    ];
  }

  /// One skin per bundled face besides the default (the Type section).
  static List<Skin> type() {
    final c = strings.clock;
    return [
      Skin(id: 'bebas', name: c.skin_bebas, face: DisplayFace.bebasNeue),
      Skin(
        id: 'anton',
        name: c.skin_anton,
        face: DisplayFace.anton,
        digitColor: DesignSkinColors.yellow,
      ),
      Skin(id: 'oswald', name: c.skin_oswald, face: DisplayFace.oswald),
      Skin(
        id: 'shoulders',
        name: c.skin_shoulders,
        face: DisplayFace.bigShoulders,
      ),
      Skin(
        id: 'poster',
        name: c.skin_poster,
        face: DisplayFace.archivoBlack,
        digitColor: DesignSkinColors.inkPaper,
        cardColor: DesignSkinColors.cardPaper,
        groundColor: DesignSkinColors.bgPaper,
      ),
      Skin(
        id: 'terminal',
        name: c.skin_terminal,
        face: DisplayFace.jetBrainsMono,
        digitColor: DesignSkinColors.mint,
        seam: false,
      ),
      Skin(
        id: 'grotesk',
        name: c.skin_grotesk,
        face: DisplayFace.spaceGrotesk,
        digitColor: DesignSkinColors.violet,
      ),
      Skin(
        id: 'serif',
        name: c.skin_serif,
        face: DisplayFace.dmSerifDisplay,
        seam: false,
      ),
      Skin(
        id: 'orbit',
        name: c.skin_orbit,
        face: DisplayFace.orbitron,
        digitColor: DesignSkinColors.cyan,
      ),
    ];
  }

  /// Every built-in skin.
  static List<Skin> builtIn() => [...classic(), ...bold(), ...type()];

  /// The skin [id] among [custom] and the built-ins; Mono when it is
  /// missing or unknown.
  static Skin resolve(String id, List<Skin> custom) {
    for (final skin in [...custom, ...builtIn()]) {
      if (skin.id == id) return skin;
    }
    return classic().first;
  }

  /// A fresh id for a custom skin, unused by [custom].
  static String nextCustomId(List<Skin> custom) {
    var n = 1;
    while (custom.any((s) => s.id == 'custom-$n')) {
      n++;
    }
    return 'custom-$n';
  }

  /// True for ids of the skins the user made.
  static bool isCustom(Skin skin) => skin.id.startsWith('custom-');
}
