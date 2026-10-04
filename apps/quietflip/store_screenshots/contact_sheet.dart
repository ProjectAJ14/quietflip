import 'dart:ui' as ui;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Thumbnail height on the sheet, in pixels.
const double thumbHeight = 360;
const double _gap = DesignSpace.s6;
const double _label = 40;

/// Every image of one language on one page, a row per slot, for review.
class ContactSheet extends StatelessWidget {
  const ContactSheet({required this.rows, super.key});

  /// Slot name -> its images, already decoded at [thumbHeight].
  final List<(String, List<ui.Image>)> rows;

  /// The sheet's size for [rows].
  static Size sizeOf(List<(String, List<ui.Image>)> rows) {
    var width = 0.0;
    for (final (_, images) in rows) {
      // Each image carries its trailing gap.
      final row = images.fold(0.0, (sum, i) => sum + i.width + _gap);
      if (row > width) width = row;
    }
    return Size(
      width + 2 * _gap,
      rows.length * (_label + thumbHeight + _gap) + 2 * _gap,
    );
  }

  @override
  Widget build(BuildContext context) {
    const c = DesignColors.dark;
    final style = DesignSystem.monoTextTheme(
      ThemeData.dark().textTheme,
    ).labelLarge!.copyWith(color: c.inkMuted);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: c.bg,
        child: Padding(
          padding: const EdgeInsets.all(_gap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (name, images) in rows) ...[
                SizedBox(
                  height: _label,
                  child: Text(name, style: style),
                ),
                Row(
                  children: [
                    for (final image in images) ...[
                      RawImage(image: image),
                      const SizedBox(width: _gap),
                    ],
                  ],
                ),
                const SizedBox(height: _gap),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
