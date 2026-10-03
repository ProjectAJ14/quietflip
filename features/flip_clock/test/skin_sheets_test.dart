import 'dart:async';
import 'dart:ui' show Tristate;

import 'package:core/core.dart' as core;
import 'package:core/core.dart' show Logger;
import 'package:design_system/design_system.dart';
import 'package:di/di.dart';
import 'package:flip_clock/data/models/skin.dart';
import 'package:flip_clock/data/repositories/settings_repository_imp.dart';
import 'package:flip_clock/data/skins.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flip_clock/ui/components/flip_display.dart';
import 'package:flip_clock/ui/components/skin_customizer.dart';
import 'package:flip_clock/ui/components/skin_picker.dart';
import 'package:flip_clock/ui/screens/skins_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';

import 'fakes.dart';
import 'flip_card_probe.dart';
import 'ink.dart';

final now = DateTime(2026, 9, 30, 17, 14);

void main() {
  late SettingsController settings;
  setUp(() async {
    await core.init();
    settings = SettingsController(
      repository: SettingsRepositoryImp(
        store: FakeStore(),
        logger: di.get<Logger>(),
      ),
      alerts: FakeAlerts(),
    );
  });
  tearDown(di.reset);

  Future<void> open(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double textScale = 1,
    AppearanceMode mode = AppearanceMode.black,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      DesignSystemWrapper(
        mode: mode,
        builder: (context, theme) => MaterialApp(
          theme: theme,
          home: MediaQuery(
            data: MediaQueryData(
              size: size,
              textScaler: TextScaler.linear(textScale),
            ),
            child: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => unawaited(
                    showSkins(context, settings: settings, now: now),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    unawaited(settings.close());
    await tester.pump();
  }

  Finder tile(String name) => find.widgetWithText(SkinTile, name);

  /// Scrolls the customizer's controls until [f] shows.
  Future<void> reveal(WidgetTester tester, Finder f) =>
      tester.scrollUntilVisible(
        f,
        200,
        scrollable: find
            .descendant(
              of: find.byType(SkinCustomizer),
              matching: find.byType(Scrollable),
            )
            .first,
      );

  testWidgets('shows every section, all free, Mono selected', (tester) async {
    await open(tester);
    final c = strings.clock;
    expect(find.text(c.skins_title), findsOne);
    expect(find.text(c.skins_yours.toUpperCase()), findsOne);
    expect(find.text(c.skins_classic.toUpperCase()), findsOne);
    expect(find.text(c.skins_new), findsOne);
    // In use and its place under Classic.
    expect(tile(c.skin_mono), findsNWidgets(2));
    await tester.scrollUntilVisible(tile(c.skin_mono).last, 300);
    expect(tester.widget<SkinTile>(tile(c.skin_mono).last).selected, isTrue);
    await tester.scrollUntilVisible(tile(c.skin_orbit), 300);
    expect(find.text(c.skins_type.toUpperCase()), findsOne);
    expect(find.byIcon(Icons.lock_outline), findsNothing);
    await close(tester);
  });

  testWidgets('tapping a tile applies it; Done closes', (tester) async {
    await open(tester);
    await tester.ensureVisible(tile(strings.clock.skin_paper));
    await tester.pumpAndSettle();
    await tester.tap(tile(strings.clock.skin_paper));
    await tester.pumpAndSettle();
    expect(settings.state.skinId, 'paper');
    expect(
      tester.widget<SkinTile>(tile(strings.clock.skin_paper).last).selected,
      isTrue,
    );
    await tester.drag(find.byType(Scrollable).last, const Offset(0, 2000));
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.clock.skins_done));
    await tester.pumpAndSettle();
    expect(find.byType(SkinPicker), findsNothing);
    await close(tester);
  });

  testWidgets('the probe sees a stock ripple', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: InkWell(onTap: () {}, child: const Text('x')),
        ),
      ),
    );
    await tester.tap(find.text('x'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(liveInk(tester), isNotEmpty);
  });

  testWidgets('a skin tile and a sheet button press down without ink', (
    tester,
  ) async {
    await open(tester);
    await tester.ensureVisible(tile(strings.clock.skin_paper));
    await tester.pumpAndSettle();
    await tester.tap(tile(strings.clock.skin_paper));
    await tester.pump(const Duration(milliseconds: 50));
    expect(settings.state.skinId, 'paper');
    expect(liveInk(tester), isEmpty);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).last, const Offset(0, 2000));
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.clock.skins_done));
    await tester.pump(const Duration(milliseconds: 50));
    expect(liveInk(tester), isEmpty);
    await tester.pumpAndSettle();
    expect(find.byType(SkinPicker), findsNothing);
    await close(tester);
  });

  testWidgets('tiles are at least 196px wide: one column on a phone', (
    tester,
  ) async {
    await open(tester);
    // 342px inside the gutters fits one 196px-minimum column.
    final phone = tester.getSize(tile(strings.clock.skin_mono).first).width;
    expect(phone, 390 - 2 * DesignSpace.s6);
    await close(tester);
  });

  testWidgets('wide screens get five or more columns', (tester) async {
    await open(tester, size: const Size(1280, 800));
    final desk = tester.getSize(tile(strings.clock.skin_mono).first).width;
    expect(desk, greaterThanOrEqualTo(SkinPicker.minTileWidth));
    expect(desk * 5, lessThan(1280));
    await close(tester);
  });

  testWidgets('customize edits every option and saves a copy', (tester) async {
    await open(tester, size: const Size(1280, 900));
    final c = strings.clock;
    await tester.tap(find.text(c.skins_customize));
    await tester.pumpAndSettle();
    expect(find.text(c.customize_title), findsOne);
    // A built-in cannot be deleted.
    expect(find.text(c.customize_delete), findsNothing);

    await tester.enterText(find.byType(TextField), 'Night shift');
    await tester.tap(find.bySemanticsLabel('Big Shoulders'));
    await tester.tap(find.bySemanticsLabel(hexOf(DesignSkinColors.amber)));
    await reveal(
      tester,
      find.bySemanticsLabel(hexOf(DesignSkinColors.bgPaper)),
    );
    await tester.tap(find.bySemanticsLabel(hexOf(DesignSkinColors.cardPaper)));
    await tester.tap(find.bySemanticsLabel(hexOf(DesignSkinColors.bgPaper)));
    await tester.pump();
    await reveal(tester, find.text(c.customize_meridiem_right));
    await tester.tap(find.text(c.customize_seconds_badge));
    await tester.tap(find.text(c.customize_meridiem_right));
    await tester.pump();
    await reveal(tester, find.text(c.show_date));
    await tester.tap(find.text(c.show_date));
    await tester.pump();
    await tester.tap(find.text(c.customize_save));
    await tester.pumpAndSettle();

    final saved = settings.state.customSkins.single;
    expect(settings.state.skinId, saved.id);
    expect(saved.name, 'Night shift');
    expect(saved.face, DisplayFace.bigShoulders);
    expect(saved.digitColor, DesignSkinColors.amber);
    expect(saved.cardColor, DesignSkinColors.cardPaper);
    expect(saved.groundColor, DesignSkinColors.bgPaper);
    expect(saved.seconds, SkinSeconds.badge);
    expect(saved.meridiem, SkinMeridiem.right);
    // Mono shows the date; the switch turned it off.
    expect(saved.showDate, isFalse);
    // It is in use, and first under Your skins.
    expect(tile('Night shift'), findsNWidgets(2));
    // Every card has the split line: there is no switch for it.
    expect(find.text('Split line'), findsNothing);
    await close(tester);
  });

  testWidgets('a custom skin can be deleted; empty names keep the old one', (
    tester,
  ) async {
    await settings.saveSkin(const Skin(id: '', name: 'Mine'));
    await open(tester);
    final c = strings.clock;
    await tester.tap(find.text(c.skins_customize));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  ');
    await tester.tap(find.text(c.customize_save));
    await tester.pumpAndSettle();
    expect(settings.state.customSkins.single.name, 'Mine');

    await tester.tap(find.text(c.skins_customize));
    await tester.pumpAndSettle();
    await tester.tap(find.text(c.customize_delete));
    await tester.pumpAndSettle();
    expect(settings.state.customSkins, isEmpty);
    expect(settings.state.skinId, Skins.monoId);
    await close(tester);
  });

  testWidgets('new skin starts as a copy; cancel and reset change nothing', (
    tester,
  ) async {
    await open(tester);
    final c = strings.clock;
    await tester.tap(find.text(c.skins_new));
    await tester.pumpAndSettle();
    expect(find.text(c.customize_copy_name(c.skin_mono)), findsOne);
    // Phone: preview above, controls below.
    expect(
      tester
          .getCenter(
            find.descendant(
              of: find.byType(SkinCustomizer),
              matching: find.byType(FlipDisplay),
            ),
          )
          .dy,
      lessThan(tester.getCenter(find.byType(TextField)).dy),
    );
    await tester.enterText(find.byType(TextField), 'Changed');
    await tester.tap(find.bySemanticsLabel(hexOf(DesignSkinColors.rose)));
    await tester.pump();
    await tester.tap(find.text(c.customize_reset));
    await tester.pump();
    expect(find.text(c.customize_copy_name(c.skin_mono)), findsOne);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(settings.state.customSkins, isEmpty);
    expect(find.byType(SkinPicker), findsOne);
    await close(tester);
  });

  testWidgets('low contrast warns but still saves', (tester) async {
    await open(tester);
    final c = strings.clock;
    await tester.tap(find.text(c.skins_customize));
    await tester.pumpAndSettle();
    expect(find.text(c.customize_low_contrast), findsNothing);
    // Card swatches follow the digit ones: pick ink digits on the ink card.
    await tester.tap(find.bySemanticsLabel(hexOf(DesignSkinColors.inkPaper)));
    await tester.pump();
    expect(find.text(c.customize_low_contrast), findsOne);
    await tester.tap(find.text(c.customize_save));
    await tester.pumpAndSettle();
    expect(
      settings.state.customSkins.single.digitColor,
      DesignSkinColors.inkPaper,
    );
    await close(tester);
  });

  testWidgets('custom colour takes valid hex only', (tester) async {
    await open(tester);
    final c = strings.clock;
    await tester.tap(find.text(c.skins_customize));
    await tester.pumpAndSettle();
    final custom = find.bySemanticsLabel(c.customize_custom_colour);
    await tester.tap(custom.first);
    await tester.pumpAndSettle();
    final field = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(field).controller!.text, '#F5F5F5');
    await tester.enterText(field, 'nope');
    await tester.tap(find.text(c.customize_apply));
    await tester.pump();
    expect(find.text(c.customize_hex_invalid), findsOne);
    await tester.enterText(field, '#123456');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    // The custom swatch now shows the picked colour, selected.
    await tester.tap(custom.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(c.customize_save));
    await tester.pumpAndSettle();
    expect(
      settings.state.customSkins.single.digitColor,
      const Color(0xff123456),
    );
    await close(tester);
  });

  for (final mode in [AppearanceMode.black, AppearanceMode.light]) {
    testWidgets('sheets fit at text scale 2 in ${mode.name}', (tester) async {
      await open(tester, size: const Size(375, 700), textScale: 2, mode: mode);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text(strings.clock.skins_customize));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await close(tester);
    });
  }

  testWidgets('Bold sits between Classic and Type; its presets apply '
      'their seconds', (tester) async {
    await open(tester, size: const Size(1280, 900));
    final c = strings.clock;
    final bold = find.text(c.skins_bold.toUpperCase());
    await tester.scrollUntilVisible(tile(c.skin_nightstand), 300);
    expect(bold, findsOne);
    expect(
      tester.getTopLeft(bold).dy,
      greaterThan(tester.getTopLeft(tile(c.skin_taxi)).dy),
    );
    for (final name in [c.skin_studio, c.skin_arcade, c.skin_minimal]) {
      expect(tile(name), findsOne);
    }
    await tester.tap(tile(c.skin_nightstand));
    await tester.pumpAndSettle();
    expect(settings.state.skinId, 'nightstand');
    expect(settings.state.showSeconds, isTrue);
    await tester.scrollUntilVisible(tile(c.skin_orbit), 300);
    expect(
      tester.getTopLeft(find.text(c.skins_type.toUpperCase())).dy,
      greaterThan(tester.getTopLeft(tile(c.skin_minimal)).dy),
    );
    await close(tester);
  });

  Finder fill(Color color) => find.byWidgetPredicate(
    (w) =>
        w is Container &&
        w.decoration is BoxDecoration &&
        (w.decoration! as BoxDecoration).color == color,
  );

  testWidgets('Mono Light: Mono tile is ink on card over bg, Paper is '
      'unchanged; a copy keeps the light look and is not themed', (
    tester,
  ) async {
    await open(tester, mode: AppearanceMode.light);
    final c = strings.clock;
    const light = DesignColors.light;
    final mono = find.descendant(
      of: tile(c.skin_mono).first,
      matching: fill(light.bg),
    );
    expect(mono, findsOne);
    expect(
      find.descendant(of: tile(c.skin_mono), matching: cardFace(light.card)),
      findsWidgets,
    );
    expect(
      find.descendant(
        of: tile(c.skin_paper),
        matching: cardFace(DesignSkinColors.cardPaper),
      ),
      findsWidgets,
    );
    await tester.tap(find.text(c.skins_new));
    await tester.pumpAndSettle();
    await tester.tap(find.text(c.customize_save));
    await tester.pumpAndSettle();
    final saved = settings.state.customSkins.single;
    expect(saved.themed, isFalse);
    expect(saved.digitColor, light.ink);
    expect(saved.cardColor, light.card);
    expect(saved.groundColor, light.bg);
    await close(tester);
  });

  testWidgets('the preview shows the draft seconds preset', (tester) async {
    await open(tester, size: const Size(1280, 900));
    final c = strings.clock;
    await tester.tap(find.text(c.skins_customize));
    await tester.pumpAndSettle();
    List<String> previewCards() => tester
        .widget<FlipDisplay>(
          find.descendant(
            of: find.byType(SkinCustomizer),
            matching: find.byType(FlipDisplay),
          ),
        )
        .cards;
    // Mono shows seconds as cards.
    expect(previewCards(), hasLength(3));
    await reveal(tester, find.text(c.customize_meridiem_right));
    await tester.tap(find.text(c.customize_seconds_off));
    await tester.pump();
    expect(previewCards(), hasLength(2));
    await close(tester);
  });

  test('hex parsing', () {
    expect(parseHex('#ff7a00'), const Color(0xffff7a00));
    expect(parseHex(' 00FF00 '), const Color(0xff00ff00));
    expect(parseHex('#fff'), isNull);
    expect(parseHex('#gg0000'), isNull);
    expect(hexOf(const Color(0xff0a0b0c)), '#0A0B0C');
  });

  testWidgets('the sheet title sits in the true centre', (tester) async {
    await open(tester, size: const Size(1200, 800));
    final title = tester.getCenter(find.text(strings.clock.skins_title));
    expect(title.dx, closeTo(600, 1));
    // The header keeps Done and the title only: Customize is on the tile.
    expect(
      find.descendant(
        of: find.byType(SheetHeader),
        matching: find.text(strings.clock.skins_customize),
      ),
      findsNothing,
    );
    await close(tester);
  });

  group('In use', () {
    final c = strings.clock;

    /// The In use tile: the first in the sheet.
    SkinTile inUse(WidgetTester tester) =>
        tester.widget<SkinTile>(find.byType(SkinTile).first);

    /// Every section tile's rect, in order (the In use tile left out).
    List<Rect> sectionRects(WidgetTester tester) => [
      for (final e in find.byType(SkinTile).evaluate().skip(1))
        tester.getRect(find.byWidget(e.widget)),
    ];

    testWidgets('comes first with the selected built-in skin', (tester) async {
      await settings.selectSkin('orbit');
      await open(tester);
      final header = find.text(c.skins_in_use.toUpperCase());
      expect(header, findsOne);
      expect(
        tester.getTopLeft(header).dy,
        lessThan(tester.getTopLeft(find.text(c.skins_yours.toUpperCase())).dy),
      );
      final tile = inUse(tester);
      expect(tile.skin.id, 'orbit');
      expect(tile.selected, isTrue);
      expect(tile.onCustomize, isNotNull);
      // Customize sits on the In use tile only.
      expect(find.text(c.skins_customize), findsOne);
      expect(
        find.descendant(
          of: find.byType(SkinTile).first,
          matching: find.text(c.skins_customize),
        ),
        findsOne,
      );
      // Same width as the grid's tiles.
      expect(
        tester.getSize(find.byType(SkinTile).first).width,
        tester.getSize(find.byType(SkinTile).at(1)).width,
      );
      await close(tester);
    });

    testWidgets('shows a selected custom skin', (tester) async {
      await settings.saveSkin(const Skin(id: '', name: 'Mine'));
      await open(tester);
      expect(inUse(tester).skin.name, 'Mine');
      expect(inUse(tester).selected, isTrue);
      // Above Your skins, where Mine also sits.
      expect(
        tester.getTopLeft(find.byType(SkinTile).first).dy,
        lessThan(tester.getTopLeft(find.text(c.skins_yours.toUpperCase())).dy),
      );
      expect(tile('Mine'), findsNWidgets(2));
      await close(tester);
    });

    testWidgets('a tap updates it; the tiles below stay put, the selected '
        'one ringed in place', (tester) async {
      await open(tester, size: const Size(1280, 900));
      expect(inUse(tester).skin.id, Skins.monoId);
      final before = sectionRects(tester);
      await tester.tap(tile(c.skin_rose));
      await tester.pumpAndSettle();
      expect(settings.state.skinId, 'rose');
      expect(inUse(tester).skin.id, 'rose');
      expect(sectionRects(tester), before);
      // The section tile is ringed where it was, and Mono's is not.
      expect(tester.widget<SkinTile>(tile(c.skin_rose).last).selected, isTrue);
      expect(tester.widget<SkinTile>(tile(c.skin_mono)).selected, isFalse);
      await close(tester);
    });

    testWidgets('cross-fades to the new skin', (tester) async {
      await open(tester, size: const Size(1280, 900));
      await tester.tap(tile(c.skin_rose));
      await tester.pump();
      await tester.pump(DesignMotion.fade ~/ 2);
      // Both are drawn half way: Mono fading out, Rose in.
      final fading = find.ancestor(
        of: find.byType(SkinTile),
        matching: find.byType(FadeTransition),
      );
      final opacities = [
        for (final f in tester.widgetList<FadeTransition>(fading))
          f.opacity.value,
      ];
      expect(opacities, hasLength(2));
      for (final o in opacities) {
        expect(o, inExclusiveRange(0, 1));
      }
      await tester.pumpAndSettle();
      expect(tester.widgetList(fading), hasLength(1));
      await close(tester);
    });

    testWidgets('swaps at once with reduced motion', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(reduceMotion: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await open(tester, size: const Size(1280, 900));
      await tester.tap(tile(c.skin_rose));
      await tester.pump();
      await tester.pump();
      expect(inUse(tester).skin.id, 'rose');
      expect(tile(c.skin_mono), findsOne);
      await close(tester);
    });
  });

  group('gallery', () {
    final c = strings.clock;

    /// Cards drawn by [name]'s tile (a card is two halves of one text).
    Set<String> cardsOf(WidgetTester tester, String name) => {
      for (final t in tester.widgetList<Text>(
        find.descendant(
          of: find.descendant(
            of: tile(name),
            matching: find.byType(FlipDisplay),
          ),
          matching: find.byType(Text),
        ),
      ))
        t.data!,
    };

    testWidgets('tiles show seconds and date only for skins that show them', (
      tester,
    ) async {
      deviceOn24h(tester);
      final date = DateTime(2026, 9, 30);
      // Tall enough that every tile is built.
      await open(tester, size: const Size(1400, 3000));
      final plain = c.skin_minimal;
      expect(cardsOf(tester, plain), {'17', '14'});
      final formatted = MaterialLocalizations.of(
        tester.element(find.byType(SkinPicker)),
      ).formatFullDate(date);
      expect(
        find.descendant(of: tile(plain), matching: find.text(formatted)),
        findsNothing,
      );
      final cards = Skins.builtIn().firstWhere(
        (k) => k.seconds == SkinSeconds.cards,
      );
      final badge = Skins.builtIn().firstWhere(
        (k) => k.seconds == SkinSeconds.badge,
      );
      expect(cardsOf(tester, cards.name), {'17', '14', '00'});
      // A badge skin: two cards plus the small seconds in the corner.
      expect(cardsOf(tester, badge.name), containsAll(['17', '14', '00']));
      expect(
        find.descendant(of: tile(badge.name), matching: find.text('00')),
        findsOne,
      );
      // A skin with the date line shows it on its tile.
      final dated = Skins.bold().firstWhere((k) => k.showDate);
      expect(
        find.descendant(of: tile(dated.name), matching: find.text(formatted)),
        findsOne,
      );
      // Mono, the default, shows seconds cards and the date.
      expect(cardsOf(tester, c.skin_mono), {'17', '14', '00'});
      expect(
        find.descendant(of: tile(c.skin_mono), matching: find.text(formatted)),
        findsWidgets,
      );
      // Show seconds and Show date do not leak into previews: Minimal has
      // neither, so its tile stays HH MM with no date.
      await settings.update(
        settings.state.copyWith(showSeconds: true, showDate: true),
      );
      await tester.pumpAndSettle();
      expect(cardsOf(tester, plain), {'17', '14'});
      expect(cardsOf(tester, cards.name), {'17', '14', '00'});
      expect(
        find.descendant(of: tile(plain), matching: find.text(formatted)),
        findsNothing,
      );
      expect(
        find.descendant(of: tile(dated.name), matching: find.text(formatted)),
        findsOne,
      );
      expect(tester.takeException(), isNull);
      await close(tester);
    });

    testWidgets('three groups fit the narrowest tile', (tester) async {
      await settings.update(
        settings.state.copyWith(showSeconds: true, showDate: true),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: DesignSystem.blackScheme()),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: SkinPicker.minTileWidth,
                child: SkinTile(
                  // Three groups and the date line: the fullest tile.
                  skin: Skins.builtIn()
                      .firstWhere((k) => k.seconds == SkinSeconds.cards)
                      .copyWith(showDate: true),
                  selected: true,
                  now: now,
                  use24h: false,
                  onTap: () {},
                  onCustomize: () {},
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final cards = tester.getRect(find.byType(FlipDisplay));
      expect(cards.width, lessThanOrEqualTo(SkinPicker.minTileWidth));
      await close(tester);
    });

    testWidgets(
      'tap selects; Customize sits on the In use tile only and opens it',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await open(tester, size: const Size(1200, 900));
        final customize = find.text(c.skins_customize);
        expect(
          find.descendant(of: tile(c.skin_mono), matching: customize),
          findsOne,
        );
        expect(customize, findsOne);

        await tester.tap(tile(c.skin_rose));
        await tester.pumpAndSettle();
        expect(settings.state.skinId, 'rose');
        expect(
          find.descendant(of: tile(c.skin_rose), matching: customize),
          findsOne,
        );
        expect(customize, findsOne);
        // "Rose, selected" and its own "Customize Rose" button.
        final rose = tester.getSemantics(
          find.bySemanticsLabel(c.skin_rose).first,
        );
        expect(
          rose.getSemanticsData().flagsCollection.isSelected.toBoolOrNull(),
          isTrue,
        );
        final named = tester
            .getSemantics(
              find.bySemanticsLabel(c.skins_customize_named(c.skin_rose)),
            )
            .getSemanticsData();
        expect(named.flagsCollection.isButton, isTrue);
        // Focusable: its focus state is tracked (not `none`).
        expect(named.flagsCollection.isFocused, isNot(Tristate.none));

        await tester.tap(customize);
        await tester.pumpAndSettle();
        final customizer = tester.widget<SkinCustomizer>(
          find.byType(SkinCustomizer),
        );
        expect(customizer.start.id, 'rose');
        expect(customizer.onDelete, isNull);
        semantics.dispose();
        await close(tester);
      },
    );

    testWidgets(
      'keyboard: Enter on a tile applies it, Tab reaches In use Customize',
      (tester) async {
        await open(tester, size: const Size(1200, 900));
        // Focus Rose's tile (its Pressable) and press Enter.
        final rose = find.descendant(
          of: tile(c.skin_rose),
          matching: find.byType(Pressable),
        );
        // Its focus node, found from inside the Pressable.
        Focus.of(
          tester.element(
            find
                .descendant(of: rose.first, matching: find.byType(Column))
                .first,
          ),
        ).requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(settings.state.skinId, 'rose');
        // The In use tile is Rose now; the stop after it is its Customize.
        final inUse = find.byType(SkinTile).first;
        expect(tester.widget<SkinTile>(inUse).skin.id, 'rose');
        Focus.of(
          tester.element(
            find
                .descendant(
                  of: find.descendant(
                    of: inUse,
                    matching: find.byType(Pressable),
                  ),
                  matching: find.byType(Column),
                )
                .first,
          ),
        ).requestFocus();
        await tester.pump();
        // Enter on it re-applies Rose; the next stop is its Customize.
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(settings.state.skinId, 'rose');
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final customize = find.descendant(
          of: inUse,
          matching: find.byType(AppButton),
        );
        expect(
          Focus.of(
            tester.element(
              find.descendant(of: customize, matching: find.byType(Text)),
            ),
          ).hasPrimaryFocus,
          isTrue,
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(
          tester.widget<SkinCustomizer>(find.byType(SkinCustomizer)).start.id,
          'rose',
        );
        await close(tester);
      },
    );

    testWidgets('a custom skin\'s Customize opens its editor with Delete', (
      tester,
    ) async {
      await settings.saveSkin(const Skin(id: '', name: 'Mine'));
      await open(tester);
      await tester.tap(
        find.descendant(
          of: tile('Mine'),
          matching: find.text(c.skins_customize),
        ),
      );
      await tester.pumpAndSettle();
      final customizer = tester.widget<SkinCustomizer>(
        find.byType(SkinCustomizer),
      );
      expect(customizer.start.name, 'Mine');
      expect(customizer.onDelete, isNotNull);
      await close(tester);
    });
  });
}
