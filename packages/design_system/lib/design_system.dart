import 'package:design_system/generated/theme.dart';
import 'package:design_system/generated/util.dart';
import 'package:flutter/material.dart';

export 'components/index.dart';
export 'constants/navigation_icons.dart';
export 'dialogs/index.dart';
export 'generated/theme.dart';
export 'generated/util.dart';
export 'loader/loader.dart';
export 'screens/index.dart';
export 'toast/toasts.dart';
export 'wrapper/wrappers.dart';

class DesignSystem {
  final MaterialTheme theme;

  DesignSystem(
    BuildContext context, {
    String bodyFont = "Open Sans",
    String displayFont = "Open Sans",
  }) : theme = buildTheme(
         context,
         bodyFont: bodyFont,
         displayFont: displayFont,
       );

  static MaterialTheme buildTheme(
    BuildContext context, {
    String bodyFont = "Open Sans",
    String displayFont = "Open Sans",
  }) {
    final textTheme = createTextTheme(context, bodyFont, displayFont);
    return MaterialTheme(textTheme);
  }

  ThemeData _baseTheme(ThemeData base) {
    return base.copyWith(
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: base.colorScheme.outlineVariant),
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
        indicatorShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          side: BorderSide(color: base.colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }

  ThemeData light() => _baseTheme(theme.light());

  ThemeData dark() => _baseTheme(theme.dark());

  /// True-black surfaces with white foreground, derived from the dark scheme.
  ThemeData black() => _baseTheme(theme.theme(blackScheme()));

  /// The generated dark scheme with black surfaces and white text on them.
  static ColorScheme blackScheme() => MaterialTheme.darkScheme().copyWith(
    surface: Colors.black,
    surfaceDim: Colors.black,
    surfaceContainerLowest: Colors.black,
    // Neutral greys (not the dark palette's tinted ones) for cards on black.
    surfaceContainerLow: const Color(0xff121212),
    surfaceContainer: const Color(0xff1a1a1a),
    surfaceContainerHigh: const Color(0xff242424),
    surfaceContainerHighest: const Color(0xff2e2e2e),
    surfaceBright: const Color(0xff2e2e2e),
    onSurface: Colors.white,
    onSurfaceVariant: Colors.white70,
  );

  /// The theme for [mode]; [platformBrightness] decides only for
  /// [AppearanceMode.system].
  ThemeData forMode(AppearanceMode mode, Brightness platformBrightness) =>
      switch (mode) {
        AppearanceMode.system =>
          platformBrightness == Brightness.dark ? dark() : light(),
        AppearanceMode.light => light(),
        AppearanceMode.dark => dark(),
        AppearanceMode.black => black(),
      };
}

/// Which theme `DesignSystemWrapper` applies, regardless of the OS setting
/// except for [system].
enum AppearanceMode { system, light, dark, black }
