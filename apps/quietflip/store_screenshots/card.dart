import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'device_frame.dart';
import 'targets.dart';

const DesignColors _c = DesignColors.dark;

/// Mono type on Material roles, with the Arabic fallback in Arabic: the
/// same text theme the app builds.
TextTheme _type(String language) => DesignSystem.monoTextTheme(
  ThemeData.dark().textTheme,
  arabic: language == 'ar',
);

/// The ground every card shares: Mono Dark, lit from the top.
final BoxDecoration _ground = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [_c.surfaceRaised, _c.bg],
  ),
);

/// Sets [child] in [language]'s reading direction.
Widget _direction(String language, Widget child) => Directionality(
  textDirection: language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
  child: child,
);

/// One store screenshot: [headline] above [capture] in a drawn device, on
/// the Mono ground. [size] is the card's logical size (the slot's pixels at
/// a fixed ratio); type and spacing follow its shorter side.
class StoreCard extends StatelessWidget {
  const StoreCard({
    required this.size,
    required this.headline,
    required this.capture,
    required this.frame,
    required this.language,
    required this.label,
    this.island = false,
    super.key,
  });

  final Size size;
  final String headline;
  final ui.Image capture;
  final FrameKind frame;
  final String language;

  /// Names the card in an overflow failure.
  final String label;
  final bool island;

  @override
  Widget build(BuildContext context) {
    final portrait = size.height > size.width;
    final unit = size.shortestSide;
    final top = size.height * (portrait ? 0.05 : 0.06);
    final box = size.height * (portrait ? 0.15 : 0.2);
    // Room for three lines in the box; narrow phones are bound by width.
    final fontSize = portrait
        ? math.min(size.width * 0.085, size.height * 0.04)
        : unit * 0.068;
    // The large-title token, scaled to the card (its -0.02 em tracking too).
    final style = _type(language).displaySmall!.copyWith(
      color: _c.ink,
      fontSize: fontSize,
      height: 1.15,
      letterSpacing: -0.02 * fontSize,
    );
    return _direction(
      language,
      DecoratedBox(
        decoration: _ground,
        child: SizedBox.fromSize(
          size: size,
          child: Column(
            children: [
              SizedBox(height: top),
              _Headline(
                text: headline,
                style: style,
                size: Size(size.width * 0.86, box),
                label: label,
              ),
              SizedBox(height: size.height * 0.025),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    size.width * 0.07,
                    0,
                    size.width * 0.07,
                    size.height * 0.05,
                  ),
                  child: Center(
                    child: DeviceFrame(
                      screen: capture,
                      kind: frame,
                      island: island,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A centred headline that must fit [size] in three lines: it throws
/// instead of clipping, so a long translation fails the run.
class _Headline extends StatelessWidget {
  const _Headline({
    required this.text,
    required this.style,
    required this.size,
    required this.label,
    this.align = TextAlign.center,
  });

  final String text;
  final TextAlign align;
  final TextStyle style;
  final Size size;
  final String label;

  static const int maxLines = 3;

  @override
  Widget build(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textAlign: align,
      maxLines: maxLines,
    )..layout(maxWidth: size.width);
    final fits =
        !painter.didExceedMaxLines &&
        painter.height <= size.height &&
        painter.width <= size.width;
    painter.dispose();
    if (!fits) {
      throw StateError(
        'Headline overflows its box on $label: "$text". Shorten it in '
        'store_screenshots/copy/.',
      );
    }
    return SizedBox.fromSize(
      size: size,
      child: Align(
        alignment: align == TextAlign.center
            ? Alignment.center
            : AlignmentDirectional.topStart,
        child: Text(text, style: style, textAlign: align, maxLines: maxLines),
      ),
    );
  }
}

/// The wordmark card with no capture: Google Play's feature graphic and the
/// web `og:image`. The launch logo, the app name and one [line].
class WordmarkCard extends StatelessWidget {
  const WordmarkCard({
    required this.size,
    required this.logo,
    required this.name,
    required this.line,
    required this.language,
    super.key,
  });

  final Size size;
  final ui.Image logo;
  final String name;
  final String line;
  final String language;

  @override
  Widget build(BuildContext context) {
    final type = _type(language);
    final unit = size.height;
    return _direction(
      language,
      DecoratedBox(
        decoration: _ground,
        child: SizedBox.fromSize(
          size: size,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: Row(
              children: [
                SizedBox(
                  width: unit * 0.42,
                  child: RawImage(
                    image: logo,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                SizedBox(width: unit * 0.1),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: type.displaySmall!.copyWith(
                          color: _c.ink,
                          fontSize: unit * 0.17,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: unit * 0.04),
                      _Headline(
                        text: line,
                        style: type.bodyLarge!.copyWith(
                          color: _c.inkMuted,
                          fontSize: unit * 0.075,
                          height: 1.3,
                        ),
                        size: Size(
                          size.width * 0.84 - unit * 0.52,
                          unit * 0.32,
                        ),
                        label: 'wordmark ($language)',
                        align: TextAlign.start,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
