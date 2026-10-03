import 'package:design_system/generated/theme.dart';
import 'package:design_system/constants/design_fonts.dart';
import 'package:design_system/constants/design_shape.dart';
import 'package:design_system/constants/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

export 'components/index.dart';
export 'constants/design_fonts.dart';
export 'constants/design_shape.dart';
export 'constants/design_tokens.dart';
export 'constants/navigation_icons.dart';
export 'dialogs/index.dart';
export 'generated/theme.dart';
export 'loader/loader.dart';
export 'screens/index.dart';
export 'toast/toasts.dart';
export 'wrapper/wrappers.dart';

class DesignSystem {
  final MaterialTheme theme;

  /// Every component shape follows this one corner ([DesignShape]).
  final DesignShape shape;

  DesignSystem(
    BuildContext context, {
    String bodyFont = DesignFonts.ui,
    String displayFont = DesignFonts.ui,
    DisplayFace? face,
    double corner = DesignShape.defaultCorner,
  }) : shape = DesignShape(corner),
       theme = buildTheme(
         context,
         bodyFont: bodyFont,
         displayFont: displayFont,
         face: face,
       );

  static MaterialTheme buildTheme(
    BuildContext context, {
    String bodyFont = DesignFonts.ui,
    String displayFont = DesignFonts.ui,
    DisplayFace? face,
  }) => MaterialTheme(
    monoTextTheme(
      Theme.of(context).textTheme,
      bodyFont: bodyFont,
      displayFont: displayFont,
      face: face,
    ),
  );

  /// The interface type styles of the design system on Material roles:
  ///
  /// | Role | Token |
  /// |---|---|
  /// | `displaySmall` | large-title |
  /// | `headlineSmall` | title |
  /// | `titleLarge`, `titleMedium` | headline |
  /// | `titleSmall` | meridiem |
  /// | `bodyLarge` | body |
  /// | `bodyMedium` | body-desktop |
  /// | `bodySmall` | footnote |
  /// | `labelLarge` | callout |
  /// | `labelMedium` | hud, seconds-badge (tabular figures) |
  /// | `labelSmall` | section |
  ///
  /// The other roles keep [base]'s sizes in [bodyFont].
  ///
  /// With a [face] (the app following a skin), every role uses that face at
  /// its one bundled weight instead, keeping the sizes: a skin face ships a
  /// single weight, so asking for another would find no bundled file.
  ///
  /// Every role falls back to the bundled [DesignFonts.arabic] for the
  /// Arabic glyphs the faces lack.
  static TextTheme monoTextTheme(
    TextTheme base, {
    String bodyFont = DesignFonts.ui,
    String displayFont = DesignFonts.ui,
    DisplayFace? face,
  }) {
    final theme = _monoTextTheme(
      base,
      bodyFont: bodyFont,
      displayFont: displayFont,
    );
    TextStyle? inFace(TextStyle? style) => style == null
        ? null
        : DesignFonts.withArabic(
            face == null
                ? style
                : GoogleFonts.getFont(
                    face.family,
                    textStyle: style,
                    fontWeight: face.weight,
                  ),
          );
    return TextTheme(
      displayLarge: inFace(theme.displayLarge),
      displayMedium: inFace(theme.displayMedium),
      displaySmall: inFace(theme.displaySmall),
      headlineLarge: inFace(theme.headlineLarge),
      headlineMedium: inFace(theme.headlineMedium),
      headlineSmall: inFace(theme.headlineSmall),
      titleLarge: inFace(theme.titleLarge),
      titleMedium: inFace(theme.titleMedium),
      titleSmall: inFace(theme.titleSmall),
      bodyLarge: inFace(theme.bodyLarge),
      bodyMedium: inFace(theme.bodyMedium),
      bodySmall: inFace(theme.bodySmall),
      labelLarge: inFace(theme.labelLarge),
      labelMedium: inFace(theme.labelMedium),
      labelSmall: inFace(theme.labelSmall),
    );
  }

  static TextTheme _monoTextTheme(
    TextTheme base, {
    required String bodyFont,
    required String displayFont,
  }) {
    // Sizes and line heights in px, letter spacing in em, as in tokens.json.
    TextStyle style(
      double size,
      double line,
      FontWeight weight, {
      double em = 0,
      String? family,
      List<FontFeature>? features,
    }) => GoogleFonts.getFont(
      family ?? bodyFont,
      fontSize: size,
      height: line / size,
      fontWeight: weight,
      letterSpacing: em * size,
      fontFeatures: features,
    );
    final headline = style(17, 22, FontWeight.w600);
    return GoogleFonts.getTextTheme(bodyFont, base).copyWith(
      displaySmall: style(
        34,
        41,
        FontWeight.w700,
        em: -0.02,
        family: displayFont,
      ),
      headlineSmall: style(
        24,
        30,
        // Token weight; google_fonts renders the nearest bundled file (600).
        const FontWeight(650),
        em: -0.01,
        family: displayFont,
      ),
      titleLarge: headline,
      titleMedium: headline,
      titleSmall: style(18, 20, FontWeight.w700, em: 0.04),
      bodyLarge: style(17, 22, FontWeight.w400),
      bodyMedium: style(14, 20, FontWeight.w400),
      bodySmall: style(13, 18, FontWeight.w400),
      labelLarge: style(15, 20, FontWeight.w500),
      labelMedium: style(
        13,
        16,
        FontWeight.w600,
        features: const [FontFeature.tabularFigures()],
      ),
      labelSmall: style(12, 16, FontWeight.w600, em: 0.06),
    );
  }

  ThemeData _baseTheme(ThemeData base, DesignColors colors) {
    final control = DesignShape.rounded(shape.sm);
    // No ink anywhere: taps press down (`Pressable`), so stock and
    // third-party Material widgets (sign-in, licences) draw no ripple,
    // highlight or hover wash either.
    const noInk = WidgetStatePropertyAll<Color>(Colors.transparent);
    return base.copyWith(
      extensions: [colors, shape],
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      switchTheme: base.switchTheme.copyWith(overlayColor: noInk),
      checkboxTheme: base.checkboxTheme.copyWith(overlayColor: noInk),
      radioTheme: base.radioTheme.copyWith(overlayColor: noInk),
      sliderTheme: base.sliderTheme.copyWith(overlayColor: Colors.transparent),
      // Every Material component takes its corner from [shape]. Switch and
      // Slider thumbs cannot take one (see CLAUDE.md, exceptions).
      cardTheme: CardThemeData(shape: DesignShape.rounded(shape.md)),
      dialogTheme: DialogThemeData(shape: DesignShape.rounded(shape.lg)),
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: DesignShape.radius(shape.lg),
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(shape: control),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: base.colorScheme.onSurface,
          borderRadius: DesignShape.circular(shape.xs),
        ),
        textStyle: base.textTheme.bodySmall?.copyWith(
          color: base.colorScheme.surface,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        shape: control,
        behavior: SnackBarBehavior.floating,
      ),
      listTileTheme: ListTileThemeData(shape: control),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: DesignShape.rounded(shape.forHeight(40, role: shape.sm)),
          overlayColor: Colors.transparent,
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: base.colorScheme.outlineVariant),
          borderRadius: BorderRadius.vertical(
            top: DesignShape.radius(shape.xs),
          ),
        ),
        hintStyle: base.textTheme.labelSmall?.copyWith(
          color: base.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        labelStyle: base.textTheme.labelMedium?.copyWith(
          color: base.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: base.colorScheme.surface,
        surfaceTintColor: base.colorScheme.surfaceTint,
        foregroundColor: base.colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: base.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: base.colorScheme.onSurface),
        actionsIconTheme: IconThemeData(color: base.colorScheme.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: base.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        overlayColor: noInk,
        elevation: 0,
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          if (states.contains(WidgetState.selected)) {
            return base.textTheme.labelSmall?.copyWith(
              color: base.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            );
          }
          return base.textTheme.labelSmall?.copyWith(
            color: base.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: base.colorScheme.onPrimary, size: 20);
          }
          return IconThemeData(
            color: base.colorScheme.onSurfaceVariant,
            size: 20,
          );
        }),
        indicatorColor: base.colorScheme.primary,
        indicatorShape: DesignShape.rounded(shape.xs),
      ),
      // The selected segment is an accent pill with on-accent text.
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: base.colorScheme.primary,
          selectedForegroundColor: base.colorScheme.onPrimary,
          foregroundColor: base.colorScheme.onSurface,
          side: BorderSide(color: base.colorScheme.outlineVariant),
          shape: control,
          overlayColor: Colors.transparent,
        ),
      ),
      // Our own buttons are `AppButton`. These style the Material buttons
      // third-party screens still draw (FirebaseUI sign-in, the licence
      // page, stock dialogs), with no ink.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: control,
          overlayColor: Colors.transparent,
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: base.colorScheme.primary,
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          shape: control,
          overlayColor: Colors.transparent,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: control,
          overlayColor: Colors.transparent,
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: base.colorScheme.primary,
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          shape: control,
          overlayColor: Colors.transparent,
          side: BorderSide(color: base.colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }

  /// Mono Light.
  ThemeData light() =>
      _baseTheme(theme.theme(monoLightScheme()), DesignColors.light);

  /// Mono Dark: true-black ground, white ink and accent. The default.
  ThemeData black() =>
      _baseTheme(theme.theme(blackScheme()), DesignColors.dark);

  /// The Mono Dark roles on Material's colour scheme.
  static ColorScheme blackScheme() =>
      _mono(MaterialTheme.darkScheme(), DesignColors.dark);

  /// The Mono Light roles on Material's colour scheme.
  static ColorScheme monoLightScheme() =>
      _mono(MaterialTheme.lightScheme(), DesignColors.light);

  /// Maps the design tokens onto the Material roles that stock widgets
  /// (switches, sliders, buttons) read, so they look the same as the
  /// design-system components.
  static ColorScheme _mono(ColorScheme base, DesignColors c) => base.copyWith(
    primary: c.accent,
    onPrimary: c.onAccent,
    primaryContainer: c.surfaceRaised,
    onPrimaryContainer: c.ink,
    secondary: c.accent,
    onSecondary: c.onAccent,
    secondaryContainer: c.controlOff,
    onSecondaryContainer: c.ink,
    error: c.danger,
    surface: c.bg,
    onSurface: c.ink,
    onSurfaceVariant: c.inkMuted,
    outline: c.inkSubtle,
    outlineVariant: c.hairline,
    surfaceDim: c.bg,
    surfaceBright: c.surfaceRaised,
    surfaceContainerLowest: c.bg,
    surfaceContainerLow: c.surfaceSidebar,
    surfaceContainer: c.surface,
    surfaceContainerHigh: c.surfaceRaised,
    surfaceContainerHighest: c.controlOff,
  );

  /// The theme for [mode]; [platformBrightness] decides only for
  /// [AppearanceMode.system].
  ThemeData forMode(AppearanceMode mode, Brightness platformBrightness) =>
      switch (mode) {
        AppearanceMode.system =>
          platformBrightness == Brightness.dark ? black() : light(),
        AppearanceMode.light => light(),
        AppearanceMode.black => black(),
      };
}

/// Which theme `DesignSystemWrapper` applies: [black] is Mono Dark, [light]
/// Mono Light, and [system] follows the platform brightness.
enum AppearanceMode { system, light, black }
