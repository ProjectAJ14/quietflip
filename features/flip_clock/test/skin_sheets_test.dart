import 'dart:async';

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
import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';

import 'fakes.dart';

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
    expect(tester.widget<SkinTile>(tile(c.skin_mono)).selected, isTrue);
    await tester.scrollUntilVisible(tile(c.skin_orbit), 300);
    expect(find.text(c.skins_type.toUpperCase()), findsOne);
    expect(find.byIcon(Icons.lock_outline), findsNothing);
    await close(tester);
  });

  testWidgets('tapping a tile applies it; Done closes', (tester) async {
    await open(tester);
    await tester.tap(tile(strings.clock.skin_paper));
    await tester.pumpAndSettle();
    expect(settings.state.skinId, 'paper');
    expect(
      tester.widget<SkinTile>(tile(strings.clock.skin_paper)).selected,
      isTrue,
    );
    await tester.tap(find.text(strings.clock.skins_done));
    await tester.pumpAndSettle();
    expect(find.byType(SkinPicker), findsNothing);
    await close(tester);
  });

  testWidgets('tiles are at least 196px wide: one column on a phone', (
    tester,
  ) async {
    await open(tester);
    // 342px inside the gutters fits one 196px-minimum column.
    final phone = tester.getSize(tile(strings.clock.skin_mono)).width;
    expect(phone, 390 - 2 * DesignSpace.s6);
    await close(tester);
  });

  testWidgets('wide screens get five or more columns', (tester) async {
    await open(tester, size: const Size(1280, 800));
    final desk = tester.getSize(tile(strings.clock.skin_mono)).width;
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
    await tester.tap(find.text(c.customize_seconds_cards));
    await tester.tap(find.text(c.customize_meridiem_right));
    await tester.pump();
    await tester.drag(find.byType(Slider), const Offset(-400, 0));
    await reveal(tester, find.text(c.show_date));
    await tester.tap(find.text(c.customize_seam));
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
    expect(saved.seconds, SkinSeconds.cards);
    expect(saved.meridiem, SkinMeridiem.right);
    expect(saved.cardRadius, 0);
    expect(saved.seam, isFalse);
    expect(saved.showDate, isTrue);
    // It shows first, under Your skins.
    expect(tile('Night shift'), findsOne);
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
      of: tile(c.skin_mono),
      matching: fill(light.bg),
    );
    expect(mono, findsOne);
    expect(
      find.descendant(of: tile(c.skin_mono), matching: fill(light.card)),
      findsWidgets,
    );
    expect(
      find.descendant(
        of: tile(c.skin_paper),
        matching: fill(DesignSkinColors.cardPaper),
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
    expect(previewCards(), hasLength(2));
    await reveal(tester, find.text(c.customize_meridiem_right));
    await tester.tap(find.text(c.customize_seconds_cards));
    await tester.pump();
    expect(previewCards(), hasLength(3));
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
    // Customize sits at the right end.
    expect(
      tester.getRect(find.text(strings.clock.skins_customize)).right,
      greaterThan(1200 - 80),
    );
    await close(tester);
  });
}
