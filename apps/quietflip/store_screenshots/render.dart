import 'dart:io';
import 'dart:ui' as ui;

import 'package:di/di.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';
import 'package:yaml/yaml.dart';

import 'card.dart';
import 'contact_sheet.dart';
import 'fonts.dart';
import 'scenarios.dart';
import 'targets.dart';

/// Cards are laid out at the slot's pixels over this ratio (every slot's
/// sides are even, so the PNG comes out exactly at the slot's size).
const double _cardRatio = 2;

/// The headlines of [language] (`copy/<language>.yaml`).
Map<String, String> readCopy(String language) {
  final yaml = loadYaml(
    File('store_screenshots/copy/$language.yaml').readAsStringSync(),
  );
  return {
    for (final MapEntry(:key, :value) in (yaml as YamlMap).entries)
      '$key': '$value',
  };
}

/// Width and height from a PNG's IHDR chunk.
Size pngSize(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  return Size(data.getUint32(16).toDouble(), data.getUint32(20).toDouble());
}

/// Renders every store image of [language]: each slot x card (the real app
/// captured, then composed on its card), the feature graphic, the
/// `og:image` (English), the contact sheet, then checks every file is there
/// at its exact size. One test file per language: each runs in its own
/// process, so a script font registered for one never reaches another.
void renderLocale(String language) {
  final locale = storeLocales[language]!;
  late final Map<String, String> copy;
  final expected = <String, Size>{};

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    answerAudioChannels();
    await loadFonts(language);
    copy = readCopy(language);
    // Stale files from a removed card would be uploaded as well.
    for (final dir in [
      'app_store/${locale.appStore}',
      'mac_app_store/${locale.appStore}',
      'google_play/${locale.play}',
      'microsoft_store/${locale.microsoft}',
    ]) {
      final d = Directory('$outputRoot/$dir');
      if (d.existsSync()) d.deleteSync(recursive: true);
    }
  });
  tearDown(di.reset);

  for (final slot in slots) {
    for (final (index, card) in cards.indexed) {
      final path = slot.path(locale, index, card);
      expected[path] = slot.pixels;
      testWidgets('${slot.name} $index $card ($language)', (tester) async {
        final screen = await capture(
          tester,
          card: card,
          language: language,
          device: slot.device,
        );
        await _write(
          tester,
          path,
          slot.pixels,
          StoreCard(
            size: slot.pixels / _cardRatio,
            headline: _line(copy, card, language),
            capture: screen,
            frame: slot.device.frame,
            island:
                slot.device.platform == TargetPlatform.iOS &&
                slot.device.frame == FrameKind.phone,
            language: language,
            label: '${slot.name} $card ($language)',
          ),
        );
      });
    }
  }

  final wordmarks = {
    featureGraphicPath(locale): featureGraphicPixels,
    if (language == 'en') ogImagePath: ogImagePixels,
  };
  for (final MapEntry(key: path, value: pixels) in wordmarks.entries) {
    expected[path] = pixels;
    testWidgets('$path ($language)', (tester) async {
      LocalizationProvider.select([Locale(language)]);
      addTearDown(() => LocalizationProvider.select(const []));
      final logo = await tester.runAsync(() async {
        final data = await rootBundle.load('assets/splash/quietflip-logo.png');
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        return (await codec.getNextFrame()).image;
      });
      await _write(
        tester,
        path,
        pixels,
        WordmarkCard(
          size: pixels / _cardRatio,
          logo: logo!,
          name: strings.app.name,
          line: _line(copy, featureKey, language),
          language: language,
        ),
      );
    });
  }

  final contact = 'contact/$language.png';
  testWidgets('contact sheet ($language)', (tester) async {
    final rows = await tester.runAsync(() async {
      Future<ui.Image> thumb(String path) async {
        final codec = await ui.instantiateImageCodec(
          File('$outputRoot/$path').readAsBytesSync(),
          targetHeight: thumbHeight.toInt(),
        );
        return (await codec.getNextFrame()).image;
      }

      return [
        for (final slot in slots)
          (
            slot.name,
            [
              for (final (i, card) in cards.indexed)
                await thumb(slot.path(locale, i, card)),
            ],
          ),
        ('Wordmarks', [for (final path in wordmarks.keys) await thumb(path)]),
      ];
    });
    final size = ContactSheet.sizeOf(rows!);
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: ContactSheet(rows: rows),
      ),
    );
    await tester.runAsync(GoogleFonts.pendingFonts);
    await tester.pump();
    expectNoError(tester, contact);
    await _save(tester, key, 1, contact);
  });

  test('every $language image is written at its exact size', () {
    for (final MapEntry(key: path, value: pixels) in expected.entries) {
      final file = File('$outputRoot/$path');
      expect(file.existsSync(), isTrue, reason: 'missing $path');
      expect(pngSize(file.readAsBytesSync()), pixels, reason: path);
    }
    expect(File('$outputRoot/$contact').existsSync(), isTrue);
  });
}

String _line(Map<String, String> copy, String key, String language) {
  final line = copy[key];
  if (line == null || line.trim().isEmpty) {
    fail('copy/$language.yaml has no "$key"');
  }
  return line;
}

/// Lays [card] out at [pixels] / [_cardRatio] and writes it to [path],
/// failing on any layout error (an overflowing headline throws).
Future<void> _write(
  WidgetTester tester,
  String path,
  Size pixels,
  Widget card,
) async {
  tester.view
    ..physicalSize = pixels
    ..devicePixelRatio = _cardRatio
    ..resetPadding()
    ..resetViewPadding();
  addTearDown(tester.view.reset);
  final key = GlobalKey();
  await tester.pumpWidget(RepaintBoundary(key: key, child: card));
  await tester.runAsync(GoogleFonts.pendingFonts);
  await tester.pump();
  expectNoError(tester, path);
  final size = await _save(tester, key, _cardRatio, path);
  expect(size, pixels, reason: path);
}

/// Writes the boundary under [key] as a PNG; returns its pixel size.
Future<Size> _save(
  WidgetTester tester,
  GlobalKey key,
  double ratio,
  String path,
) async {
  final bytes = await tester.runAsync(() async {
    final image =
        await (key.currentContext!.findRenderObject()! as RenderRepaintBoundary)
            .toImage(pixelRatio: ratio);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    return png!.buffer.asUint8List();
  });
  File('$outputRoot/$path')
    ..parent.createSync(recursive: true)
    ..writeAsBytesSync(bytes!);
  return pngSize(bytes);
}
