import 'dart:ui' show lerpDouble;

import 'package:design_system/components/pressable.dart';
import 'package:design_system/constants/design_shape.dart';
import 'package:design_system/constants/design_tokens.dart';
import 'package:flutter/material.dart';

enum _Variant { text, filled, outlined, icon }

/// [opacity] as Material's 8-bit alpha, so disabled colours match it exactly.
int _alpha(double opacity) => (opacity * 255).round();

/// The app's buttons: a [Pressable] around a decorated box, so every button
/// presses down and none draws ink. Colours, type, padding and corner are
/// the Material 3 button values the theme used to set (`sm` corner,
/// `labelLarge` w600, padding that shrinks as text grows), at least
/// [DesignSize.cornerButton] high. A null `onPressed` draws it disabled.
class AppButton extends StatelessWidget {
  /// Accent text on no fill; [danger] colours it `DesignColors.danger`.
  const AppButton.text({
    super.key,
    required String this.label,
    required this.onPressed,
    this.icon,
    this.semanticsLabel,
    this.danger = false,
  }) : _variant = _Variant.text,
       tooltip = null;

  /// On-accent text on an accent fill: the one primary action.
  const AppButton.filled({
    super.key,
    required String this.label,
    required this.onPressed,
    this.icon,
    this.semanticsLabel,
  }) : _variant = _Variant.filled,
       tooltip = null,
       danger = false;

  /// Accent text inside a 1.5 px accent outline.
  const AppButton.outlined({
    super.key,
    required String this.label,
    required this.onPressed,
    this.icon,
    this.semanticsLabel,
  }) : _variant = _Variant.outlined,
       tooltip = null,
       danger = false;

  /// A 44 px icon-only button; [tooltip] is its tooltip and spoken name.
  const AppButton.icon({
    super.key,
    required IconData this.icon,
    required String this.tooltip,
    required this.onPressed,
  }) : _variant = _Variant.icon,
       label = null,
       semanticsLabel = null,
       danger = false;

  final _Variant _variant;

  /// Visible text (not on [AppButton.icon]).
  final String? label;

  /// Leading icon; the only content of [AppButton.icon].
  final IconData? icon;

  /// Replaces [label] for screen readers, such as a name spelled out.
  final String? semanticsLabel;

  /// Tooltip and spoken name of [AppButton.icon].
  final String? tooltip;

  /// Text button in the danger colour (delete, reset).
  final bool danger;

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = DesignShape.of(context);
    final enabled = onPressed != null;
    final disabledInk = scheme.onSurface.withAlpha(_alpha(0.38));
    final accent = danger ? DesignColors.of(context).danger : scheme.primary;
    final foreground = !enabled
        ? disabledInk
        : switch (_variant) {
            _Variant.filled => scheme.onPrimary,
            _Variant.icon => scheme.onSurfaceVariant,
            _ => accent,
          };
    final fill = _variant != _Variant.filled
        ? null
        : enabled
        ? scheme.primary
        : scheme.onSurface.withAlpha(_alpha(0.12));
    final side = _variant == _Variant.outlined
        ? BorderSide(color: scheme.primary, width: 1.5)
        : BorderSide.none;

    if (_variant == _Variant.icon) {
      return Tooltip(
        message: tooltip,
        excludeFromSemantics: true,
        child: Pressable(
          onTap: onPressed,
          semanticsLabel: tooltip,
          focusRadius: DesignShape.circular(
            shape.forHeight(DesignSize.cornerButton, role: shape.sm),
          ),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              shape: DesignShape.rounded(
                shape.forHeight(DesignSize.cornerButton, role: shape.sm),
              ),
            ),
            child: SizedBox.square(
              dimension: DesignSize.cornerButton,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(icon, size: 24, color: foreground),
              ),
            ),
          ),
        ),
      );
    }

    final textStyle = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
    );
    // Material's text scale for padding and the icon gap.
    final textScale =
        MediaQuery.textScalerOf(context).scale(textStyle?.fontSize ?? 14) / 14;
    final (at1x, at2x, at3x) = _padding(icon != null);
    final padding = ButtonStyleButton.scaledPadding(
      at1x,
      at2x,
      at3x,
      textScale,
    );
    return Pressable(
      onTap: onPressed,
      focusRadius: DesignShape.circular(shape.sm),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: fill,
          shape: DesignShape.rounded(shape.sm, side: side),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 64,
            minHeight: DesignSize.cornerButton,
          ),
          child: Padding(
            padding: padding,
            child: Align(
              widthFactor: 1,
              heightFactor: 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: lerpDouble(8, 4, textScale.clamp(1, 2) - 1)!,
                children: [
                  if (icon != null) Icon(icon, size: 18, color: foreground),
                  Flexible(
                    child: Text(
                      label!,
                      semanticsLabel: semanticsLabel,
                      style: textStyle?.copyWith(color: foreground),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Material 3's padding at 1x, 2x and 3x text, with and without an icon.
  (EdgeInsetsGeometry, EdgeInsetsGeometry, EdgeInsetsGeometry) _padding(
    bool withIcon,
  ) => switch ((_variant, withIcon)) {
    (_Variant.text, false) => (
      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      const EdgeInsets.symmetric(horizontal: 8),
      const EdgeInsets.symmetric(horizontal: 4),
    ),
    (_Variant.text, true) => (
      const EdgeInsetsDirectional.fromSTEB(12, 8, 16, 8),
      const EdgeInsets.symmetric(horizontal: 4),
      const EdgeInsets.symmetric(horizontal: 4),
    ),
    (_, false) => (
      const EdgeInsets.symmetric(horizontal: 24),
      const EdgeInsets.symmetric(horizontal: 12),
      const EdgeInsets.symmetric(horizontal: 6),
    ),
    (_, true) => (
      const EdgeInsetsDirectional.fromSTEB(16, 0, 24, 0),
      const EdgeInsetsDirectional.fromSTEB(8, 0, 12, 0),
      const EdgeInsetsDirectional.fromSTEB(4, 0, 6, 0),
    ),
  };
}
