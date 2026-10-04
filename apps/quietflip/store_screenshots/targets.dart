import 'package:flutter/widgets.dart';

/// Every store image is written under this directory (relative to
/// `apps/quietflip`, where `flutter test store_screenshots/` runs).
const String outputRoot = 'build/store_screenshots';

/// How a capture is framed on its card.
enum FrameKind { phone, tablet, laptop, monitor }

/// A device the app is captured on: logical size, pixel ratio, safe-area
/// insets (logical, portrait) and the platform it pretends to be.
class Device {
  const Device({
    required this.size,
    required this.ratio,
    required this.platform,
    required this.frame,
    this.insets = EdgeInsets.zero,
    this.landscapeInsets = EdgeInsets.zero,
  });

  final Size size;
  final double ratio;
  final TargetPlatform platform;
  final FrameKind frame;
  final EdgeInsets insets;
  final EdgeInsets landscapeInsets;

  /// Tablets turn sideways for a landscape card; desktops are landscape
  /// already. Phones stay upright: a sideways phone leaves half of a
  /// portrait store card empty.
  bool get rotates => frame == FrameKind.tablet;
}

const _iPhone = Device(
  // iPhone 16 Pro Max / 17 Pro Max: 440 x 956 pt at 3x.
  size: Size(440, 956),
  ratio: 3,
  platform: TargetPlatform.iOS,
  frame: FrameKind.phone,
  insets: EdgeInsets.only(top: 62, bottom: 34),
);
const _iPad = Device(
  // iPad Pro 13": 1032 x 1376 pt at 2x.
  size: Size(1032, 1376),
  ratio: 2,
  platform: TargetPlatform.iOS,
  frame: FrameKind.tablet,
  insets: EdgeInsets.only(top: 24, bottom: 20),
  landscapeInsets: EdgeInsets.only(top: 24, bottom: 20),
);
const _mac = Device(
  size: Size(1440, 900),
  ratio: 2,
  platform: TargetPlatform.macOS,
  frame: FrameKind.laptop,
);
const _androidPhone = Device(
  size: Size(412, 915),
  ratio: 2.625,
  platform: TargetPlatform.android,
  frame: FrameKind.phone,
  insets: EdgeInsets.only(top: 24, bottom: 24),
);
const _android7 = Device(
  size: Size(600, 960),
  ratio: 2,
  platform: TargetPlatform.android,
  frame: FrameKind.tablet,
  insets: EdgeInsets.only(top: 24, bottom: 24),
  landscapeInsets: EdgeInsets.only(top: 24, bottom: 24),
);
const _android10 = Device(
  size: Size(800, 1280),
  ratio: 2,
  platform: TargetPlatform.android,
  frame: FrameKind.tablet,
  insets: EdgeInsets.only(top: 24, bottom: 24),
  landscapeInsets: EdgeInsets.only(top: 24, bottom: 24),
);
const _windows = Device(
  size: Size(1280, 800),
  ratio: 1.5,
  platform: TargetPlatform.windows,
  frame: FrameKind.monitor,
);

/// The per-store language codes of one app language.
typedef StoreLocales = ({String appStore, String play, String microsoft});

/// App language -> store folder names (fastlane `deliver` / `supply` codes;
/// Microsoft Store uses lower-case BCP 47).
const Map<String, StoreLocales> storeLocales = {
  'en': (appStore: 'en-US', play: 'en-US', microsoft: 'en-us'),
  'ar': (appStore: 'ar-SA', play: 'ar', microsoft: 'ar-sa'),
  'de': (appStore: 'de-DE', play: 'de-DE', microsoft: 'de-de'),
  'es': (appStore: 'es-ES', play: 'es-ES', microsoft: 'es-es'),
  'fr': (appStore: 'fr-FR', play: 'fr-FR', microsoft: 'fr-fr'),
  'hi': (appStore: 'hi', play: 'hi-IN', microsoft: 'hi-in'),
  'id': (appStore: 'id', play: 'id', microsoft: 'id-id'),
  'it': (appStore: 'it', play: 'it-IT', microsoft: 'it-it'),
  'ja': (appStore: 'ja', play: 'ja-JP', microsoft: 'ja-jp'),
  'ko': (appStore: 'ko', play: 'ko-KR', microsoft: 'ko-kr'),
  'pt': (appStore: 'pt-BR', play: 'pt-BR', microsoft: 'pt-br'),
  'ru': (appStore: 'ru', play: 'ru-RU', microsoft: 'ru-ru'),
  'tr': (appStore: 'tr', play: 'tr-TR', microsoft: 'tr-tr'),
  'zh': (appStore: 'zh-Hans', play: 'zh-CN', microsoft: 'zh-cn'),
};

/// One store image slot: exact pixel size, the device captured for it and
/// where its file goes for card [index] (0-based) with id [card].
class Slot {
  const Slot({
    required this.name,
    required this.pixels,
    required this.device,
    required this.path,
  });

  final String name;
  final Size pixels;
  final Device device;
  final String Function(StoreLocales locale, int index, String card) path;
}

String _nn(int index) => '${index + 1}'.padLeft(2, '0');

/// Store screenshot slots with an app capture. Sizes checked against the
/// stores' docs (see `apps/quietflip/CLAUDE.md`).
final List<Slot> slots = [
  Slot(
    name: 'App Store iPhone 6.9"',
    pixels: const Size(1320, 2868),
    device: _iPhone,
    // deliver tells iPhone from iPad by pixel size; one folder per locale.
    path: (l, i, c) => 'app_store/${l.appStore}/${_nn(i)}_${c}_iphone.png',
  ),
  Slot(
    name: 'App Store iPad 13"',
    pixels: const Size(2064, 2752),
    device: _iPad,
    path: (l, i, c) => 'app_store/${l.appStore}/${_nn(i)}_${c}_ipad.png',
  ),
  Slot(
    name: 'Mac App Store',
    pixels: const Size(2880, 1800),
    device: _mac,
    path: (l, i, c) => 'mac_app_store/${l.appStore}/${_nn(i)}_$c.png',
  ),
  Slot(
    name: 'Google Play phone',
    pixels: const Size(1080, 1920),
    device: _androidPhone,
    path: (l, i, c) =>
        'google_play/${l.play}/images/phoneScreenshots/${i + 1}_$c.png',
  ),
  Slot(
    name: 'Google Play 7" tablet',
    pixels: const Size(1200, 1920),
    device: _android7,
    path: (l, i, c) =>
        'google_play/${l.play}/images/sevenInchScreenshots/${i + 1}_$c.png',
  ),
  Slot(
    name: 'Google Play 10" tablet',
    pixels: const Size(1600, 2560),
    device: _android10,
    path: (l, i, c) =>
        'google_play/${l.play}/images/tenInchScreenshots/${i + 1}_$c.png',
  ),
  Slot(
    name: 'Microsoft Store',
    pixels: const Size(1920, 1080),
    device: _windows,
    path: (l, i, c) => 'microsoft_store/${l.microsoft}/${_nn(i)}_$c.png',
  ),
];

/// Google Play feature graphic (no capture).
const Size featureGraphicPixels = Size(1024, 500);
String featureGraphicPath(StoreLocales l) =>
    'google_play/${l.play}/images/featureGraphic.png';

/// Web social preview (`og:image`), English only.
const Size ogImagePixels = Size(1200, 630);
const String ogImagePath = 'web/og_image.png';

/// The card set, in store order. Each id is a scenario in `scenarios.dart`
/// and a headline key in `copy/<locale>.yaml`.
const List<String> cards = [
  'clock',
  'pomodoro',
  'stopwatch',
  'skins',
  'customize',
  'nightstand',
];

/// Copy key of the feature graphic and `og:image` line.
const String featureKey = 'feature';

/// Cards captured in landscape on tablets.
const Set<String> landscapeCards = {'nightstand'};
