import 'package:design_system/design_system.dart' as ds;
import 'package:design_system/utils/extensions/string.dart';
import 'package:design_system/generated/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';

void main() {
  test(
    'extended palettes retain custom color families for each contrast mode',
    () {
      final family = ColorFamily(
        color: Colors.red,
        onColor: Colors.white,
        colorContainer: Colors.pink,
        onColorContainer: Colors.black,
      );
      final extended = ExtendedColor(
        seed: Colors.red,
        value: Colors.pink,
        light: family,
        lightHighContrast: family,
        lightMediumContrast: family,
        dark: family,
        darkHighContrast: family,
        darkMediumContrast: family,
      );
      expect(extended.seed, Colors.red);
      expect(extended.light.color, Colors.red);
      expect(extended.dark.onColorContainer, Colors.black);
    },
  );
  testWidgets(
    'date filters select another period without deselecting the current one',
    (tester) async {
      final changes = <ds.DateFilterType>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ds.DateFilterChips(
              selectedFilter: ds.DateFilterType.week,
              onFilterChanged: changes.add,
            ),
          ),
        ),
      );
      await tester.tap(find.text(strings.common.week));
      expect(changes, isEmpty);
      await tester.tap(find.text(strings.common.month));
      expect(changes, [ds.DateFilterType.month]);
    },
  );

  testWidgets('error view explains failures and exposes retry', (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ds.DefaultErrorView(
            error: StateError('failure'),
            stackTrace: StackTrace.current,
            descriptionBuilder: (_) => 'Try another connection',
            onRetry: () {
              retries++;
            },
          ),
        ),
      ),
    );
    expect(find.text('Try another connection'), findsOneWidget);
    await tester.tap(find.text(strings.generic.try_again));
    expect(retries, 1);
  });

  testWidgets('error screen provides retry and home actions', (tester) async {
    var retries = 0;
    var homes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ds.ErrorScreen(
          title: 'Unavailable',
          message: 'Try later',
          error: 'Details',
          onRetry: () {
            retries++;
          },
          onGoHome: () {
            homes++;
          },
        ),
      ),
    );
    expect(find.text('Unavailable'), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    await tester.tap(find.byType(OutlinedButton));
    expect(retries, 1);
    expect(homes, 1);
  });

  for (final extension in ['png', 'svg']) {
    testWidgets('missing $extension assets render a fallback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ds.AppAssetImage(assetPath: 'missing.$extension')),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.image), findsOneWidget);
    });
  }

  testWidgets(
    'all theme variants expose appropriate brightness and selected styles',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final design = ds.DesignSystem(context);
              for (final theme in [design.light(), design.black()]) {
                expect(
                  theme.navigationBarTheme.iconTheme!.resolve({
                    WidgetState.selected,
                  })!.size,
                  20,
                );
                expect(
                  theme.navigationBarTheme.iconTheme!.resolve({})!.size,
                  20,
                );
                expect(
                  theme.navigationBarTheme.labelTextStyle!.resolve({
                    WidgetState.selected,
                  })!.fontWeight,
                  FontWeight.w600,
                );
                expect(
                  theme.navigationBarTheme.labelTextStyle!
                      .resolve({})!
                      .fontWeight,
                  FontWeight.w500,
                );
              }
              final palette = design.theme;
              for (final theme in [
                palette.light(),
                palette.lightMediumContrast(),
                palette.lightHighContrast(),
              ]) {
                expect(theme.brightness, Brightness.light);
              }
              for (final theme in [
                palette.dark(),
                palette.darkMediumContrast(),
                palette.darkHighContrast(),
              ]) {
                expect(theme.brightness, Brightness.dark);
              }
              expect(palette.extendedColors, isEmpty);
              return const SizedBox();
            },
          ),
        ),
      );
    },
  );

  testWidgets('wrapper changes brightness and supports loader show and hide', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    late BuildContext loaderContext;
    await tester.pumpWidget(
      ds.DesignSystemWrapper(
        builder: (_, theme) => MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              loaderContext = context;
              return Scaffold(body: Text(theme.brightness.name));
            },
          ),
        ),
      ),
    );
    expect(find.text('light'), findsOneWidget);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(find.text('dark'), findsOneWidget);
    ds.Loader.show(loaderContext);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ds.DefaultLoader), findsOneWidget);
    ds.Loader.hide(loaderContext);
    await tester.pumpAndSettle();
    expect(find.byType(ds.DefaultLoader), findsNothing);
  });

  testWidgets('wrapper mode forces a theme regardless of platform', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final seen = <ds.AppearanceMode, ThemeData>{};
    for (final mode in ds.AppearanceMode.values) {
      await tester.pumpWidget(
        ds.DesignSystemWrapper(
          key: ValueKey(mode),
          mode: mode,
          builder: (_, theme) {
            seen[mode] = theme;
            return const SizedBox();
          },
        ),
      );
    }
    expect(seen[ds.AppearanceMode.system]!.brightness, Brightness.light);
    final light = seen[ds.AppearanceMode.light]!;
    expect(light.brightness, Brightness.light);
    expect(light.colorScheme.surface, const Color(0xfff2f2f4));
    expect(light.colorScheme.primary, const Color(0xff0a0a0a));
    expect(light.extension<ds.DesignColors>(), ds.DesignColors.light);
    final black = seen[ds.AppearanceMode.black]!;
    expect(black.brightness, Brightness.dark);
    expect(black.colorScheme.surface, const Color(0xff000000));
    expect(black.colorScheme.onSurface, const Color(0xffffffff));
    expect(black.colorScheme.onSurfaceVariant, const Color(0xffa1a1a1));
    expect(black.colorScheme.surfaceContainerHigh, const Color(0xff1c1c1e));
    expect(black.colorScheme.outlineVariant, const Color(0xff2c2c2e));
    expect(black.colorScheme.primary, const Color(0xffffffff));
    expect(black.colorScheme.onPrimary, const Color(0xff000000));
    expect(black.scaffoldBackgroundColor, const Color(0xff000000));
    expect(black.appBarTheme.backgroundColor, const Color(0xff000000));
    expect(black.extension<ds.DesignColors>(), ds.DesignColors.dark);
  });

  testWidgets('system mode follows the platform to Mono Dark', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    late ThemeData seen;
    await tester.pumpWidget(
      ds.DesignSystemWrapper(
        builder: (_, theme) {
          seen = theme;
          return const SizedBox();
        },
      ),
    );
    expect(seen.extension<ds.DesignColors>(), ds.DesignColors.dark);
  });

  testWidgets('interface text uses Geist at the token sizes', (tester) async {
    late ThemeData theme;
    await tester.pumpWidget(
      ds.DesignSystemWrapper(
        mode: ds.AppearanceMode.black,
        builder: (_, t) {
          theme = t;
          return const SizedBox();
        },
      ),
    );
    final text = theme.textTheme;
    for (final style in [
      text.displaySmall,
      text.headlineSmall,
      text.titleMedium,
      text.bodyLarge,
      text.labelSmall,
    ]) {
      expect(style!.fontFamily, startsWith('Geist'));
    }
    expect(text.displaySmall!.fontSize, 34);
    expect(text.displaySmall!.height, 41 / 34);
    // Title is 650; the nearest bundled Geist file is SemiBold.
    expect(text.headlineSmall!.fontWeight, FontWeight.w600);
    expect(text.titleMedium!.fontSize, 17);
    expect(text.titleSmall!.fontSize, 18);
    expect(text.bodyLarge!.fontSize, 17);
    expect(text.bodyMedium!.fontSize, 14);
    expect(text.bodySmall!.fontSize, 13);
    expect(text.labelLarge!.fontSize, 15);
    expect(text.labelMedium!.fontFeatures, [
      const FontFeature.tabularFigures(),
    ]);
    expect(text.labelSmall!.letterSpacing, closeTo(0.72, 1e-9));
    expect(text.bodyLarge!.color, const Color(0xffffffff));
  });

  testWidgets('DesignColors falls back to Mono Dark and never blends', (
    tester,
  ) async {
    late ds.DesignColors colors;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            colors = ds.DesignColors.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    const dark = ds.DesignColors.dark;
    const light = ds.DesignColors.light;
    expect(colors, dark);
    expect(dark.copyWith(), dark);
    expect(dark.lerp(light, 0.4), dark);
    expect(dark.lerp(light, 0.5), light);
    expect(dark.lerp(null, 1), dark);
    for (final c in [dark, light]) {
      expect(c.islandInk, const Color(0xffffffff));
      expect(c.islandInkMuted, const Color(0xff9a9a9a));
      expect(c.islandActive, const Color(0xffffffff));
      expect(c.islandOnActive, const Color(0xff000000));
    }
    expect(dark.islandShadow.single.spreadRadius, 1);
    expect(light.sheetShadow.single.blurRadius, 48);
  });

  test('size and motion tokens match tokens.json', () {
    expect(ds.DesignSize.islandDot, 10);
    expect(ds.DesignSize.islandPillHeight, 36);
    expect(ds.DesignSize.islandExpandedHeight, 52);
    expect(ds.DesignSize.cornerButton, 44);
    expect(ds.DesignSize.cornerDot, 6);
    expect(ds.DesignSize.sidebarWidth, 300);
    expect(ds.DesignMotion.flip, const Duration(milliseconds: 360));
    expect(ds.DesignMotion.islandMorph, const Duration(milliseconds: 460));
    expect(ds.DesignMotion.fade, const Duration(milliseconds: 180));
    expect(ds.DesignMotion.fadeDelay, const Duration(milliseconds: 60));
    expect(ds.DesignMotion.controlsIdle, const Duration(seconds: 4));
    expect(ds.DesignMotion.dotIdle, const Duration(seconds: 3));
    expect(ds.DesignMotion.hudHold, const Duration(milliseconds: 1200));
    expect(ds.DesignMotion.islandSpring.stiffness, 320);
    expect(ds.DesignRadius.md, 14);
    expect(ds.DesignSpace.s6, 24);
  });

  test('nullable string helpers preserve nonempty text', () {
    expect((null as String?).asEmptyIfNull, '');
    expect('text'.asEmptyIfNull, 'text');
    expect((null as String?).isNotNullAndNotEmpty, isFalse);
    expect(''.isNotNullAndNotEmpty, isFalse);
    expect('text'.isNotNullAndNotEmpty, isTrue);
    expect(ds.HeaderType.image.ratio, 4);
    expect(ds.HeaderType.asset.ratio, 1);
  });

  testWidgets('a face sets every text role, at its one bundled weight', (
    tester,
  ) async {
    late ThemeData theme;
    await tester.pumpWidget(
      ds.DesignSystemWrapper(
        mode: ds.AppearanceMode.black,
        face: ds.DisplayFace.orbitron,
        builder: (_, t) {
          theme = t;
          return const SizedBox();
        },
      ),
    );
    final text = theme.textTheme;
    final roles = [
      text.displayLarge,
      text.displayMedium,
      text.displaySmall,
      text.headlineLarge,
      text.headlineMedium,
      text.headlineSmall,
      text.titleLarge,
      text.titleMedium,
      text.titleSmall,
      text.bodyLarge,
      text.bodyMedium,
      text.bodySmall,
      text.labelLarge,
      text.labelMedium,
      text.labelSmall,
    ];
    for (final style in roles) {
      expect(style!.fontFamily, startsWith('Orbitron'));
      expect(style.fontWeight, FontWeight.w700);
    }
    // Sizes stay the design system's.
    expect(text.bodyLarge!.fontSize, 17);
    expect(text.displaySmall!.fontSize, 34);
    expect(text.bodyLarge!.color, const Color(0xffffffff));
  });
}
