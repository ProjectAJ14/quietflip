import 'package:design_system/design_system.dart';
import 'package:flutter/painting.dart';

/// How a skin shows seconds when "Show seconds" is on.
enum SkinSeconds {
  /// This skin never shows seconds.
  off,

  /// Small `seconds-badge` text in the last card's bottom-right corner.
  badge,

  /// Their own flip card.
  cards,
}

/// Where a skin puts AM/PM (12-hour time only). Always plain text, never a
/// card.
enum SkinMeridiem {
  hidden,

  /// Inside the first card, bottom-left.
  left,

  /// Beside the last card, on its right.
  right,
}

/// The look of the flip display: digit face and colours, card shape and the
/// details it shows. Built-in skins come from `skins.dart`; custom skins are
/// user data saved in `ClockSettings.customSkins`.
class Skin {
  const Skin({
    required this.id,
    required this.name,
    this.face = DisplayFace.barlowCondensed,
    this.digitColor = DesignSkinColors.mono,
    this.cardColor = DesignSkinColors.cardInk,
    this.groundColor = DesignSkinColors.bgInk,
    this.seam = true,
    this.cardRadius = DesignRadius.md,
    this.seconds = SkinSeconds.badge,
    this.meridiem = SkinMeridiem.left,
    this.showDate = false,
  });

  /// Smallest and largest [cardRadius].
  static const double minRadius = 0;
  static const double maxRadius = 32;

  final String id;
  final String name;
  final DisplayFace face;
  final Color digitColor;
  final Color cardColor;

  /// The screen behind the cards; also the colour of the seam.
  final Color groundColor;

  /// The 2px split line at half height.
  final bool seam;

  /// Card corner radius at `radius-md` card sizes, [minRadius]..[maxRadius].
  final double cardRadius;
  final SkinSeconds seconds;
  final SkinMeridiem meridiem;

  /// Shows today's date under the clock, whatever the Show date setting.
  final bool showDate;

  /// Restores a saved skin. Returns null without an [id] (the skin cannot be
  /// selected); any other missing or mistyped field keeps its default.
  static Skin? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final id = json['id'];
    if (id is! String || id.isEmpty) return null;
    const d = Skin(id: '', name: '');
    Color color(String key, Color fallback) =>
        json[key] is int ? Color(json[key]! as int) : fallback;
    T pick<T extends Enum>(List<T> values, String key, T fallback) {
      for (final value in values) {
        if (value.name == json[key]) return value;
      }
      return fallback;
    }

    return Skin(
      id: id,
      name: json['name'] is String ? json['name']! as String : d.name,
      face: pick(DisplayFace.values, 'face', d.face),
      digitColor: color('digitColor', d.digitColor),
      cardColor: color('cardColor', d.cardColor),
      groundColor: color('groundColor', d.groundColor),
      seam: json['seam'] is bool ? json['seam']! as bool : d.seam,
      cardRadius: switch (json['cardRadius']) {
        final num v when !v.isNaN => v.clamp(minRadius, maxRadius).toDouble(),
        _ => d.cardRadius,
      },
      seconds: pick(SkinSeconds.values, 'seconds', d.seconds),
      meridiem: pick(SkinMeridiem.values, 'meridiem', d.meridiem),
      showDate: json['showDate'] is bool
          ? json['showDate']! as bool
          : d.showDate,
    );
  }

  /// Colours are stored as ARGB ints.
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'face': face.name,
    'digitColor': digitColor.toARGB32(),
    'cardColor': cardColor.toARGB32(),
    'groundColor': groundColor.toARGB32(),
    'seam': seam,
    'cardRadius': cardRadius,
    'seconds': seconds.name,
    'meridiem': meridiem.name,
    'showDate': showDate,
  };

  Skin copyWith({
    String? id,
    String? name,
    DisplayFace? face,
    Color? digitColor,
    Color? cardColor,
    Color? groundColor,
    bool? seam,
    double? cardRadius,
    SkinSeconds? seconds,
    SkinMeridiem? meridiem,
    bool? showDate,
  }) => Skin(
    id: id ?? this.id,
    name: name ?? this.name,
    face: face ?? this.face,
    digitColor: digitColor ?? this.digitColor,
    cardColor: cardColor ?? this.cardColor,
    groundColor: groundColor ?? this.groundColor,
    seam: seam ?? this.seam,
    cardRadius: cardRadius ?? this.cardRadius,
    seconds: seconds ?? this.seconds,
    meridiem: meridiem ?? this.meridiem,
    showDate: showDate ?? this.showDate,
  );

  /// WCAG contrast of the digits on the card, 1..21.
  double get contrast {
    final a = digitColor.computeLuminance();
    final b = cardColor.computeLuminance();
    return (a > b ? a + 0.05 : b + 0.05) / (a > b ? b + 0.05 : a + 0.05);
  }

  @override
  bool operator ==(Object other) =>
      other is Skin &&
      other.id == id &&
      other.name == name &&
      other.face == face &&
      other.digitColor == digitColor &&
      other.cardColor == cardColor &&
      other.groundColor == groundColor &&
      other.seam == seam &&
      other.cardRadius == cardRadius &&
      other.seconds == seconds &&
      other.meridiem == meridiem &&
      other.showDate == showDate;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    face,
    digitColor,
    cardColor,
    groundColor,
    seam,
    cardRadius,
    seconds,
    meridiem,
    showDate,
  );
}
