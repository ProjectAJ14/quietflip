import 'dart:io';

import 'package:core/core.dart' as core;
import 'package:core/core.dart' show Logger;
import 'package:design_system/design_system.dart';
import 'package:di/di.dart';
import 'package:flip_clock/data/models/skin.dart';
import 'package:flip_clock/data/repositories/settings_repository_imp.dart';
import 'package:flip_clock/data/skins.dart';
import 'package:flip_clock/flip_clock.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  group('Skin', () {
    const full = Skin(
      id: 'custom-1',
      name: 'Night shift',
      face: DisplayFace.bigShoulders,
      digitColor: DesignSkinColors.amber,
      cardColor: DesignSkinColors.cardInk,
      groundColor: DesignSkinColors.bgInk,
      seam: false,
      seconds: SkinSeconds.cards,
      meridiem: SkinMeridiem.right,
      showDate: true,
      themed: true,
    );

    test('round-trips through json with ARGB int colours', () {
      final json = full.toJson();
      expect(json['digitColor'], 0xffff7a00);
      expect(json['face'], 'bigShoulders');
      expect(Skin.fromJson(json), full);
      expect(Skin.fromJson(json).hashCode, full.hashCode);
      expect(full.copyWith(), full);
      expect(full, isNot(full.copyWith(name: 'Day shift')));
      expect(json['themed'], isTrue);
      expect(full, isNot(full.copyWith(themed: false)));
    });

    test('unknown face, bad colour and missing fields keep defaults', () {
      final skin = Skin.fromJson({
        'id': 'custom-2',
        'face': 'comicSans',
        'digitColor': '#ff0000',
        'cardColor': null,
        'cardRadius': double.nan,
        'seconds': 3,
        'meridiem': 'top',
        'seam': 'yes',
        'showDate': 1,
        'themed': 'yes',
      })!;
      expect(skin, const Skin(id: 'custom-2', name: ''));
      expect(skin.face, DisplayFace.barlowCondensed);
      expect(skin.digitColor, DesignSkinColors.mono);
      expect(skin.seconds, SkinSeconds.off);
      expect(skin.themed, isFalse);
    });

    test('forTheme: themed skins take the light tokens in Mono Light only', () {
      const light = DesignColors.light;
      final mono = Skins.classic().first;
      expect(mono.themed, isTrue);
      final inLight = mono.forTheme(light);
      expect(inLight.digitColor, light.ink);
      expect(inLight.cardColor, light.card);
      expect(inLight.groundColor, light.bg);
      expect(inLight.contrast, greaterThanOrEqualTo(4.5));
      final inDark = mono.forTheme(DesignColors.dark);
      expect(inDark, mono);
      expect(inDark.digitColor, DesignSkinColors.mono);
      expect(inDark.cardColor, DesignSkinColors.cardInk);
      expect(inDark.groundColor, DesignSkinColors.bgInk);
      expect(inDark.contrast, greaterThanOrEqualTo(4.5));
      final paper = Skins.resolve('paper', const []);
      expect(paper.forTheme(light), same(paper));
      expect(paper.forTheme(DesignColors.dark), same(paper));
    });

    test('an old saved cardRadius is ignored: corners are global', () {
      final skin = Skin.fromJson({'id': 'a', 'cardRadius': 20, 'seam': false});
      expect(skin, const Skin(id: 'a', name: '', seam: false));
      expect(skin!.toJson().containsKey('cardRadius'), isFalse);
    });

    test('a skin without an id, or not a map, cannot be read', () {
      expect(Skin.fromJson({'name': 'x'}), isNull);
      expect(Skin.fromJson({'id': ''}), isNull);
      expect(Skin.fromJson('mono'), isNull);
    });

    test('contrast is symmetric WCAG', () {
      const bw = Skin(
        id: 'a',
        name: 'a',
        digitColor: Color(0xff000000),
        cardColor: Color(0xffffffff),
      );
      expect(bw.contrast, closeTo(21, 0.01));
      expect(
        bw
            .copyWith(
              digitColor: const Color(0xffffffff),
              cardColor: const Color(0xff000000),
            )
            .contrast,
        closeTo(21, 0.01),
      );
    });
  });

  group('catalogue', () {
    test('Mono first, every id unique, every skin free', () {
      final all = Skins.builtIn();
      expect(all.first.id, Skins.monoId);
      expect(all.map((s) => s.id).toSet(), hasLength(all.length));
      expect(all.where(Skins.isCustom), isEmpty);
      expect(Skins.classic(), hasLength(10));
      expect(Skins.builtIn().where((s) => s.themed).map((s) => s.id), [
        Skins.monoId,
      ]);
      // One skin per bundled face besides the default.
      expect(
        Skins.type().map((s) => s.face).toSet(),
        DisplayFace.values.toSet()..remove(DisplayFace.barlowCondensed),
      );
    });

    test('Bold presets each show a different mix of options', () {
      final bold = Skins.bold();
      expect(bold.length, greaterThanOrEqualTo(6));
      expect(Skins.builtIn(), containsAll(bold));
      String mix(Skin s) =>
          '${s.face}|${s.seconds}|${s.meridiem}|${s.seam}|'
          '${s.showDate}|${s.digitColor}|${s.cardColor}';
      expect(bold.map(mix).toSet(), hasLength(bold.length));
      // Between them they show off every seconds style and the date.
      expect(bold.map((s) => s.seconds).toSet(), SkinSeconds.values.toSet());
      expect(bold.where((s) => s.showDate), isNotEmpty);
      expect(bold.where((s) => !s.seam), isNotEmpty);
      expect(bold.every((s) => s.name.isNotEmpty), isTrue);
      final minimal = bold.firstWhere((s) => s.id == 'minimal');
      expect(minimal.seconds, SkinSeconds.off);
    });

    test('Mono is skin-mono on skin-card-ink over black', () {
      final mono = Skins.classic().first;
      expect(mono.digitColor, DesignSkinColors.mono);
      expect(mono.cardColor, DesignSkinColors.cardInk);
      expect(mono.groundColor, const Color(0xff000000));
      expect(mono.face, DisplayFace.barlowCondensed);
    });

    test('every built-in skin passes 4.5:1 digits on card', () {
      for (final skin in Skins.builtIn()) {
        expect(skin.contrast, greaterThanOrEqualTo(4.5), reason: skin.id);
      }
    });

    test('every face in the catalogue has a bundled, declared asset', () {
      const ds = '../../packages/design_system';
      expect(
        File('$ds/pubspec.yaml').readAsStringSync(),
        contains('- assets/google_fonts/'),
      );
      for (final skin in Skins.builtIn()) {
        final file = File('$ds/assets/google_fonts/${skin.face.assetName}');
        expect(file.existsSync(), isTrue, reason: skin.face.assetName);
      }
    });

    test('resolve falls back to Mono; custom ids never collide', () {
      const mine = Skin(id: 'custom-1', name: 'Mine');
      expect(Skins.resolve('custom-1', [mine]), mine);
      expect(Skins.resolve('paper', const []).id, 'paper');
      expect(Skins.resolve('gone', const []).id, Skins.monoId);
      expect(Skins.nextCustomId(const []), 'custom-1');
      expect(
        Skins.nextCustomId(const [
          Skin(id: 'custom-1', name: ''),
          Skin(id: 'custom-3', name: ''),
        ]),
        'custom-2',
      );
      expect(Skins.isCustom(mine), isTrue);
    });
  });

  group('ClockSettings skins', () {
    test('default Mono, no custom skins', () {
      const s = ClockSettings();
      expect(s.skinId, 'mono');
      expect(s.customSkins, isEmpty);
    });

    test('round-trips custom skins; unreadable ones are dropped', () {
      const mine = Skin(id: 'custom-1', name: 'Mine');
      final s = const ClockSettings().copyWith(
        skinId: 'custom-1',
        customSkins: [mine],
      );
      expect(ClockSettings.fromJson(s.toJson()), s);
      expect(s, isNot(const ClockSettings()));
      final read = ClockSettings.fromJson({
        'skinId': 7,
        'customSkins': [
          mine.toJson(),
          {'name': 'no id'},
          'junk',
        ],
      });
      expect(read.skinId, 'mono');
      expect(read.customSkins, [mine]);
      expect(ClockSettings.fromJson({'customSkins': 'x'}).customSkins, isEmpty);
    });
  });

  group('SettingsController skins', () {
    late SettingsController c;
    setUp(() async {
      await core.init();
      c = SettingsController(
        repository: SettingsRepositoryImp(
          store: FakeStore(),
          logger: di.get<Logger>(),
        ),
        alerts: FakeAlerts(),
      );
    });
    tearDown(() async {
      await c.close();
      await di.reset();
    });

    test('the app face follows the skin; Barlow keeps Geist', () async {
      expect(c.face.value, isNull);
      await c.selectSkin('orbit');
      expect(c.face.value, DisplayFace.orbitron);
      await c.selectSkin('rose');
      expect(c.face.value, isNull);
      await c.selectSkin('terminal');
      expect(c.face.value, DisplayFace.jetBrainsMono);
    });

    test('selects, and an unknown saved id shows Mono', () async {
      expect(c.skin.id, Skins.monoId);
      await c.selectSkin('paper');
      expect(c.state.skinId, 'paper');
      expect(c.skin.id, 'paper');
      await c.selectSkin('deleted');
      expect(c.skin.id, Skins.monoId);
    });

    test('selecting a skin applies its seconds preset', () async {
      await c.selectSkin('nightstand');
      expect(c.state.showSeconds, isTrue);
      await c.selectSkin('desk');
      expect(c.state.showSeconds, isTrue);
      await c.selectSkin(Skins.monoId);
      expect(c.state.showSeconds, isFalse);
      // The user can still toggle it after.
      await c.update(c.state.copyWith(showSeconds: true));
      expect(c.state.skinId, Skins.monoId);
      expect(c.state.showSeconds, isTrue);
      await c.selectSkin('gone');
      expect(c.state.showSeconds, isFalse);
    });

    test('saving sets Show seconds from the skin; custom skins are never '
        'themed', () async {
      final mono = Skins.classic().first;
      await c.saveSkin(mono.copyWith(id: '', seconds: SkinSeconds.cards));
      expect(c.state.showSeconds, isTrue);
      expect(c.state.customSkins.single.themed, isFalse);
      await c.saveSkin(c.state.customSkins.single.copyWith(themed: true));
      expect(c.state.customSkins.single.themed, isFalse);
      await c.saveSkin(mono.copyWith(id: ''));
      expect(c.state.showSeconds, isFalse);
    });

    test('saving a built-in adds a copy first and selects it', () async {
      final paper = Skins.resolve('paper', const []);
      await c.saveSkin(paper.copyWith(name: 'My paper'));
      expect(c.state.customSkins.single.id, 'custom-1');
      expect(c.state.customSkins.single.name, 'My paper');
      expect(c.state.skinId, 'custom-1');
      // Built-ins are unchanged.
      expect(Skins.resolve('paper', const []).name, paper.name);
      await c.saveSkin(paper.copyWith(id: ''));
      expect(c.state.customSkins.map((s) => s.id), ['custom-2', 'custom-1']);
    });

    test('saving a custom skin replaces it in place', () async {
      await c.saveSkin(const Skin(id: '', name: 'A'));
      await c.saveSkin(const Skin(id: '', name: 'B'));
      await c.saveSkin(const Skin(id: 'custom-1', name: 'A2'));
      expect(c.state.customSkins.map((s) => s.name), ['B', 'A2']);
      expect(c.state.skinId, 'custom-1');
    });

    test('deleting the selected skin selects Mono', () async {
      await c.saveSkin(const Skin(id: '', name: 'A'));
      await c.saveSkin(const Skin(id: '', name: 'B'));
      await c.deleteSkin('custom-1');
      expect(c.state.customSkins.map((s) => s.id), ['custom-2']);
      expect(c.state.skinId, 'custom-2');
      await c.deleteSkin('custom-2');
      expect(c.state.customSkins, isEmpty);
      expect(c.state.skinId, Skins.monoId);
    });
  });
}
