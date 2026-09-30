import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

// Values from the QuietFlip design system `tokens.json` (Mono Dark / Mono
// Light). Change a value there first, then here; never invent one in a
// widget.

/// The chrome colour roles of the Mono themes, read with
/// `DesignColors.of(context)`. The island roles are the same in both themes
/// ("dark like hardware").
@immutable
class DesignColors extends ThemeExtension<DesignColors> {
  const DesignColors({
    required this.bg,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSidebar,
    required this.card,
    required this.cardSeam,
    required this.ink,
    required this.inkMuted,
    required this.inkSubtle,
    required this.hairline,
    required this.island,
    required this.accent,
    required this.onAccent,
    required this.controlOff,
    required this.danger,
    required this.sheetShadow,
    required this.islandShadow,
  });

  /// Mono Dark, the default.
  static const DesignColors dark = DesignColors(
    bg: Color(0xff000000),
    surface: Color(0xff0e0e0f),
    surfaceRaised: Color(0xff1c1c1e),
    surfaceSidebar: Color(0xff111112),
    card: Color(0xff161616),
    cardSeam: Color(0xff000000),
    ink: Color(0xffffffff),
    inkMuted: Color(0xffa1a1a1),
    inkSubtle: Color(0xff7c7c7c),
    hairline: Color(0xff2c2c2e),
    island: Color(0xff161617),
    accent: Color(0xffffffff),
    onAccent: Color(0xff000000),
    controlOff: Color(0xff39393d),
    danger: Color(0xffff6b5e),
    // Shadows vanish on black, so dark uses a 1px hairline ring instead.
    sheetShadow: [BoxShadow(color: Color(0xff2c2c2e), spreadRadius: 1)],
    islandShadow: [BoxShadow(color: Color(0xff2c2c2e), spreadRadius: 1)],
  );

  /// Mono Light.
  static const DesignColors light = DesignColors(
    bg: Color(0xfff2f2f4),
    surface: Color(0xffffffff),
    surfaceRaised: Color(0xffffffff),
    surfaceSidebar: Color(0xffe9e9ec),
    card: Color(0xffffffff),
    cardSeam: Color(0xffd4d4d8),
    ink: Color(0xff0a0a0a),
    inkMuted: Color(0xff525252),
    inkSubtle: Color(0xff6b6b6b),
    hairline: Color(0xffd1d1d6),
    island: Color(0xff0a0a0a),
    accent: Color(0xff0a0a0a),
    onAccent: Color(0xffffffff),
    controlOff: Color(0xffd1d1d6),
    danger: Color(0xffc4271a),
    sheetShadow: [
      BoxShadow(
        color: Color(0x29000000),
        offset: Offset(0, 18),
        blurRadius: 48,
      ),
    ],
    islandShadow: [
      BoxShadow(color: Color(0x38000000), offset: Offset(0, 6), blurRadius: 20),
    ],
  );

  /// Clock screen and settings page ground.
  final Color bg;

  /// Sheets and the settings detail pane.
  final Color surface;

  /// Grouped settings cells, skin tiles, customizer groups.
  final Color surfaceRaised;

  /// Settings sidebar on tablet and desktop.
  final Color surfaceSidebar;

  /// Default flip-card face; skins override it.
  final Color card;

  /// The 2px split line across a flip card.
  final Color cardSeam;

  /// Titles and body text.
  final Color ink;

  /// Row values, footnotes, AM/PM, the date line.
  final Color inkMuted;

  /// Section headers and hints on [bg] only.
  final Color inkSubtle;

  /// Row separators, sheet borders, the island outline on black.
  final Color hairline;

  /// Island and corner buttons (dark in both themes).
  final Color island;

  /// The only interactive colour: switch on, slider fill, selection, focus.
  final Color accent;

  /// Knobs and text on [accent].
  final Color onAccent;

  /// Switch track off, slider track, settings icon tiles.
  final Color controlOff;

  /// Destructive rows only, always with a word.
  final Color danger;

  /// Skins and Customize sheets.
  final List<BoxShadow> sheetShadow;

  /// Island and corner buttons.
  final List<BoxShadow> islandShadow;

  /// Labels and icons on [island].
  Color get islandInk => const Color(0xffffffff);

  /// Inactive tabs and HUD numbers on [island].
  Color get islandInkMuted => const Color(0xff9a9a9a);

  /// The selected tab pill inside the island.
  Color get islandActive => const Color(0xffffffff);

  /// Label on [islandActive].
  Color get islandOnActive => const Color(0xff000000);

  /// The roles of the current theme; Mono Dark when the theme has none.
  static DesignColors of(BuildContext context) =>
      Theme.of(context).extension<DesignColors>() ?? dark;

  /// The tokens are fixed per theme, so there is nothing to override.
  @override
  DesignColors copyWith() => this;

  /// Themes swap at the midpoint: the two Mono themes are never blended.
  @override
  DesignColors lerp(DesignColors? other, double t) =>
      other == null || t < 0.5 ? this : other;
}

/// Digit, card and ground colours of the built-in skins (`skin-*`). Digit
/// and card colours only: never chrome or text.
abstract final class DesignSkinColors {
  static const Color mono = Color(0xfff5f5f5);
  static const Color rose = Color(0xffff2d6f);
  static const Color violet = Color(0xffd27bff);
  static const Color amber = Color(0xffff7a00);
  static const Color red = Color(0xffff3b30);
  static const Color green = Color(0xff4caf50);
  static const Color mint = Color(0xff1de9b6);
  static const Color cyan = Color(0xff22d3ee);
  static const Color yellow = Color(0xfff5e14a);

  /// Card face for every dark skin.
  static const Color cardInk = Color(0xff151515);
  static const Color cardPaper = Color(0xfffbfbfb);
  static const Color inkPaper = Color(0xff1c1c1c);
  static const Color bgPaper = Color(0xffe6e7eb);

  /// Ground of the dark skins: Mono Dark `bg`.
  static const Color bgInk = Color(0xff000000);
}

/// Spacing (`space-*`), in logical pixels.
abstract final class DesignSpace {
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s12 = 48;
}

/// Corner radii (`radius-*`).
abstract final class DesignRadius {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 22;
  static const double pill = 999;
}

/// Fixed chrome sizes (`size-*`).
abstract final class DesignSize {
  /// Island collapsed to a single dot.
  static const double islandDot = 10;

  /// Island HUD height (brightness, mode name).
  static const double islandPillHeight = 36;

  /// Island expanded with the tabs.
  static const double islandExpandedHeight = 52;

  /// Corner buttons, and the minimum hit target everywhere.
  static const double cornerButton = 44;

  /// Corner buttons collapsed to dots.
  static const double cornerDot = 6;

  /// Settings sidebar on tablet and desktop.
  static const double sidebarWidth = 300;
}

/// Chrome and gesture timing (`dur-*`) and the island spring.
abstract final class DesignMotion {
  /// One card flip: top fold then bottom fold, 50/50.
  static const Duration flip = Duration(milliseconds: 360);

  /// Island size/shape morph on the web curve; Flutter uses [islandSpring].
  static const Duration islandMorph = Duration(milliseconds: 460);

  /// Content cross-fade inside the island.
  static const Duration fade = Duration(milliseconds: 180);

  /// The fade starts this long after the morph.
  static const Duration fadeDelay = Duration(milliseconds: 60);

  /// Expanded controls collapse to dots after this long without input.
  static const Duration controlsIdle = Duration(milliseconds: 4000);

  /// Dots fade out after this further idle time.
  static const Duration dotIdle = Duration(milliseconds: 3000);

  /// The HUD stays this long after the finger lifts.
  static const Duration hudHold = Duration(milliseconds: 1200);

  /// Every island and corner morph: a spring with a small overshoot.
  static const SpringDescription islandSpring = SpringDescription(
    mass: 1,
    stiffness: 320,
    damping: 26,
  );

  /// [islandSpring] over [islandMorph] as a [Curve], for implicit animations
  /// (`AnimatedSize`, `AnimatedContainer`). Overshoots slightly.
  static const Curve islandCurve = SpringCurve(islandSpring, islandMorph);
}

/// A [Curve] that plays [spring] from 0 to 1 at rest over [duration]:
/// `transform(t)` is the spring's position `t * duration` after release. It
/// overshoots 1 when the spring is underdamped, and `transform(1)` is exactly
/// 1 (the spring has all but settled by then).
class SpringCurve extends Curve {
  const SpringCurve(this.spring, this.duration);

  /// The spring to play.
  final SpringDescription spring;

  /// How long the curve runs; `t` of 1 is this much time after release.
  final Duration duration;

  @override
  double transformInternal(double t) => SpringSimulation(
    spring,
    0,
    1,
    0,
  ).x(t * duration.inMicroseconds / Duration.microsecondsPerSecond);
}
