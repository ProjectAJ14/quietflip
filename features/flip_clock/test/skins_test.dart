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
      cardRadius: 20,
      seconds: SkinSeconds.cards,
      meridiem: SkinMeridiem.right,
      showDate: true,
    );

    test('round-trips through json with ARGB int colours', () {
      final json = full.toJson();
      expect(json['digitColor'], 0xffff7a00);
      expect(json['face'], 'bigShoulders');
      expect(Skin.fromJson(json), full);
      expect(Skin.fromJson(json).hashCode, full.hashCode);
      expect(full.copyWith(), full);
      expect(full, isNot(full.copyWith(name: 'Day shift')));
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
      })!;
      expect(skin, const Skin(id: 'custom-2', name: ''));
      expect(skin.face, DisplayFace.barlowCondensed);
      expect(skin.digitColor, DesignSkinColors.mono);
    });

    test('radius clamps to 0..32', () {
      double read(num v) =>
          Skin.fromJson({'id': 'a', 'cardRadius': v})!.cardRadius;
      expect(read(-4), 0);
      expect(read(99), 32);
      expect(read(12), 12);
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
      // One skin per bundled face besides the default.
      expect(
        Skins.type().map((s) => s.face).toSet(),
        DisplayFace.values.toSet()..remove(DisplayFace.barlowCondensed),
      );
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

    test('selects, and an unknown saved id shows Mono', () async {
      expect(c.skin.id, Skins.monoId);
      await c.selectSkin('paper');
      expect(c.state.skinId, 'paper');
      expect(c.skin.id, 'paper');
      await c.selectSkin('deleted');
      expect(c.skin.id, Skins.monoId);
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
