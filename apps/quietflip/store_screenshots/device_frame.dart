import 'dart:ui' as ui;

import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';

import 'targets.dart';

/// A drawn device around [screen] (a capture): phone, tablet, laptop or
/// desktop monitor. Every proportion is a fraction of the screen's shorter
/// side, so the frame looks the same at any card size; colours are Mono
/// Dark tokens. No third-party frame art.
class DeviceFrame extends StatelessWidget {
  const DeviceFrame({
    required this.screen,
    required this.kind,
    this.island = false,
    super.key,
  });

  final ui.Image screen;
  final FrameKind kind;

  /// Draws the iPhone's camera pill (else a punch-hole on phones).
  final bool island;

  static const DesignColors _c = DesignColors.dark;

  @override
  Widget build(BuildContext context) {
    final w = screen.width.toDouble();
    final h = screen.height.toDouble();
    final s = w < h ? w : h;
    // Bezel, outer corner, extra under the screen and the stand, in
    // screen-short-side units.
    final (bezel, corner, chin) = switch (kind) {
      FrameKind.phone => (0.035, 0.15, 0.0),
      FrameKind.tablet => (0.04, 0.06, 0.0),
      FrameKind.laptop => (0.025, 0.03, 0.02),
      FrameKind.monitor => (0.025, 0.02, 0.02),
    };
    final base = switch (kind) {
      FrameKind.laptop => 0.06,
      FrameKind.monitor => 0.2,
      _ => 0.0,
    };
    final outerW = w + 2 * bezel * s;
    final bodyH = h + (2 * bezel + chin) * s;
    final outerH = bodyH + base * s;
    return FittedBox(
      child: SizedBox(
        width: outerW,
        height: outerH,
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            if (kind == FrameKind.monitor) ..._stand(outerW, bodyH, s),
            if (kind == FrameKind.laptop) _deck(outerW, bodyH, s),
            Container(
              width: outerW,
              height: bodyH,
              padding: EdgeInsetsDirectional.fromSTEB(
                bezel * s,
                bezel * s,
                bezel * s,
                (bezel + chin) * s,
              ),
              decoration: BoxDecoration(
                color: _c.surface,
                borderRadius: BorderRadius.all(Radius.circular(corner * s)),
                border: Border.all(color: _c.inkSubtle, width: 0.006 * s),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular((corner - bezel).clamp(0.004, 1) * s),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    RawImage(
                      image: screen,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                    ),
                    if (kind == FrameKind.phone) _camera(w > h, s),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The iPhone pill or an Android punch-hole, at the top edge (the start
  /// edge in landscape, where a rotated phone keeps it).
  Widget _camera(bool landscape, double s) {
    final long = island ? 0.29 * s : 0.06 * s;
    final short = island ? 0.085 * s : 0.06 * s;
    final dot = Container(
      width: landscape ? short : long,
      height: landscape ? long : short,
      decoration: BoxDecoration(
        color: _c.bg,
        borderRadius: BorderRadius.all(Radius.circular(short / 2)),
      ),
    );
    return Align(
      // Geometry of the hardware, not of the reading direction.
      alignment: landscape ? const Alignment(-1, 0) : const Alignment(0, -1),
      child: Padding(padding: EdgeInsets.all(0.03 * s), child: dot),
    );
  }

  /// A laptop's keyboard deck: a slab wider than the lid under it.
  Widget _deck(double width, double top, double s) => Positioned.fill(
    top: top,
    child: OverflowBox(
      maxWidth: width * 1.12,
      alignment: AlignmentDirectional.topCenter,
      child: Container(
        width: width * 1.12,
        decoration: BoxDecoration(
          color: _c.surfaceRaised,
          border: Border.all(color: _c.inkSubtle, width: 0.006 * s),
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(0.03 * s),
            top: Radius.circular(0.005 * s),
          ),
        ),
        alignment: AlignmentDirectional.topCenter,
        // The thumb notch.
        child: Container(
          width: width * 0.14,
          height: 0.018 * s,
          decoration: BoxDecoration(
            color: _c.hairline,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(0.012 * s),
            ),
          ),
        ),
      ),
    ),
  );

  /// A monitor's neck and foot.
  List<Widget> _stand(double width, double top, double s) => [
    Positioned(
      top: top - 0.02 * s,
      bottom: 0.025 * s,
      child: Container(width: width * 0.12, color: _c.surfaceRaised),
    ),
    PositionedDirectional(
      bottom: 0,
      child: Container(
        width: width * 0.34,
        height: 0.03 * s,
        decoration: BoxDecoration(
          color: _c.surfaceRaised,
          border: Border.all(color: _c.inkSubtle, width: 0.006 * s),
          borderRadius: BorderRadius.all(Radius.circular(0.015 * s)),
        ),
      ),
    ),
  ];
}
