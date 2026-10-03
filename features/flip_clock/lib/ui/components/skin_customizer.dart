import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flip_clock/data/models/skin.dart';
import 'package:flip_clock/ui/components/display_value.dart';
import 'package:flip_clock/ui/components/flip_display.dart';
import 'package:flip_clock/ui/components/skin_picker.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

/// Below this contrast of digits on card, the customizer warns (it never
/// blocks saving).
const double lowContrast = 3;

/// "#FF7A00" or "ff7a00" as an opaque colour; null for anything else.
Color? parseHex(String input) {
  final hex = input.trim().replaceFirst('#', '');
  if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(hex)) return null;
  return Color(0xff000000 | int.parse(hex, radix: 16));
}

/// "#FF7A00" for [color].
String hexOf(Color color) =>
    '#${(color.toARGB32() & 0xffffff).toRadixString(16).padLeft(6, '0').toUpperCase()}';

/// Builds a skin with a live preview: face, digit / card / background
/// colour, corner radius, split line, seconds, AM/PM and date. Reset returns
/// to [start]; Save hands the edited skin to [onSave].
class SkinCustomizer extends StatefulWidget {
  const SkinCustomizer({
    super.key,
    required this.start,
    required this.now,
    required this.use24h,
    required this.onSave,
    required this.onCancel,
    this.onDelete,
  });

  final Skin start;

  /// The time the preview shows.
  final DateTime now;
  final bool use24h;
  final ValueChanged<Skin> onSave;
  final VoidCallback onCancel;

  /// Shown for custom skins only.
  final VoidCallback? onDelete;

  /// Swatches, all `skin-*` tokens.
  static const List<Color> digitSwatches = [
    DesignSkinColors.mono,
    DesignSkinColors.rose,
    DesignSkinColors.violet,
    DesignSkinColors.amber,
    DesignSkinColors.red,
    DesignSkinColors.green,
    DesignSkinColors.mint,
    DesignSkinColors.cyan,
    DesignSkinColors.yellow,
    DesignSkinColors.inkPaper,
  ];
  static const List<Color> cardSwatches = [
    DesignSkinColors.cardInk,
    DesignSkinColors.bgInk,
    DesignSkinColors.cardPaper,
  ];
  static const List<Color> groundSwatches = [
    DesignSkinColors.bgInk,
    DesignSkinColors.cardInk,
    DesignSkinColors.bgPaper,
  ];

  /// From this width the preview sits left of a 340px control column.
  static const double splitWidth = 600;
  static const double controlsWidth = 340;

  @override
  State<SkinCustomizer> createState() => _SkinCustomizerState();
}

class _SkinCustomizerState extends State<SkinCustomizer> {
  late Skin _draft = widget.start;
  late final TextEditingController _name = TextEditingController(
    text: widget.start.name,
  );

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// Applies [change] to the current draft (not the one a control was
  /// built with, so quick successive edits all stick).
  void _edit(Skin Function(Skin) change) =>
      setState(() => _draft = change(_draft));

  void _reset() => setState(() {
    _draft = widget.start;
    _name.text = widget.start.name;
  });

  void _save() {
    final name = _name.text.trim();
    widget.onSave(
      _draft.copyWith(name: name.isEmpty ? widget.start.name : name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = strings.clock;
    final preview = _Preview(
      skin: _draft,
      now: widget.now,
      use24h: widget.use24h,
    );
    final controls = _Controls(draft: _draft, name: _name, onChanged: _edit);
    return Column(
      children: [
        SheetHeader(
          title: c.customize_title,
          leading: AppButton.text(
            onPressed: widget.onCancel,
            label: MaterialLocalizations.of(context).cancelButtonLabel,
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) => box.maxWidth >= SkinCustomizer.splitWidth
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: preview),
                      SizedBox(
                        width: SkinCustomizer.controlsWidth,
                        child: controls,
                      ),
                    ],
                  )
                : Column(
                    children: [
                      SizedBox(height: box.maxHeight / 3, child: preview),
                      Expanded(child: controls),
                    ],
                  ),
          ),
        ),
        _Footer(onReset: _reset, onSave: _save, onDelete: widget.onDelete),
      ],
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.skin, required this.now, required this.use24h});

  final Skin skin;
  final DateTime now;
  final bool use24h;

  @override
  Widget build(BuildContext context) {
    final skin = this.skin.forTheme(DesignColors.of(context));
    // The preview shows the skin's own seconds preset.
    final value = clockValue(
      now,
      use24h: use24h,
      showSeconds: skin.seconds != SkinSeconds.off,
      skin: skin,
      meridiem: meridiemOf(context),
    );
    final date = MaterialLocalizations.of(context).formatFullDate(now);
    return ColoredBox(
      color: skin.groundColor,
      child: Padding(
        padding: const EdgeInsets.all(DesignSpace.s6),
        child: Column(
          children: [
            Expanded(
              child: FlipDisplay(
                cards: value.cards,
                badge: value.badge,
                meridiem: value.meridiem,
                skin: skin,
                semanticsLabel: skin.name,
              ),
            ),
            if (skin.showDate)
              Padding(
                padding: const EdgeInsets.only(top: DesignSpace.s3),
                child: Text(
                  date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: skin.digitColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.draft,
    required this.name,
    required this.onChanged,
  });

  final Skin draft;
  final TextEditingController name;
  final ValueChanged<Skin Function(Skin)> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = strings.clock;
    final colors = DesignColors.of(context);
    final footnote = Theme.of(
      context,
    ).textTheme.bodySmall!.copyWith(color: colors.inkMuted);
    // Sits on the sheet's `surface`.
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpace.s4,
        vertical: DesignSpace.s2,
      ),
      children: [
        TextField(
          controller: name,
          decoration: InputDecoration(labelText: c.customize_name),
        ),
        SectionHeader(c.customize_font),
        Wrap(
          spacing: DesignSpace.s2,
          runSpacing: DesignSpace.s2,
          children: [
            for (final face in DisplayFace.values)
              _FaceTile(
                face: face,
                selected: face == draft.face,
                onTap: () => onChanged((d) => d.copyWith(face: face)),
              ),
          ],
        ),
        SectionHeader(c.customize_digits),
        _Swatches(
          colors: SkinCustomizer.digitSwatches,
          value: draft.digitColor,
          onChanged: (v) => onChanged((d) => d.copyWith(digitColor: v)),
        ),
        if (draft.contrast < lowContrast)
          Padding(
            padding: const EdgeInsets.only(top: DesignSpace.s2),
            child: Semantics(
              liveRegion: true,
              child: Text(c.customize_low_contrast, style: footnote),
            ),
          ),
        SectionHeader(c.customize_card),
        _Swatches(
          colors: SkinCustomizer.cardSwatches,
          value: draft.cardColor,
          onChanged: (v) => onChanged((d) => d.copyWith(cardColor: v)),
        ),
        SectionHeader(c.customize_ground),
        _Swatches(
          colors: SkinCustomizer.groundSwatches,
          value: draft.groundColor,
          onChanged: (v) => onChanged((d) => d.copyWith(groundColor: v)),
        ),
        SectionHeader(c.customize_details),
        Text(c.customize_seconds),
        const SizedBox(height: DesignSpace.s2),
        SegmentedButton<SkinSeconds>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: SkinSeconds.off,
              label: Text(c.customize_seconds_off),
            ),
            ButtonSegment(
              value: SkinSeconds.badge,
              label: Text(c.customize_seconds_badge),
            ),
            ButtonSegment(
              value: SkinSeconds.cards,
              label: Text(c.customize_seconds_cards),
            ),
          ],
          selected: {draft.seconds},
          onSelectionChanged: (v) =>
              onChanged((d) => d.copyWith(seconds: v.single)),
        ),
        const SizedBox(height: DesignSpace.s4),
        Text(c.customize_meridiem),
        const SizedBox(height: DesignSpace.s2),
        SegmentedButton<SkinMeridiem>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: SkinMeridiem.hidden,
              label: Text(c.customize_meridiem_hidden),
            ),
            ButtonSegment(
              value: SkinMeridiem.left,
              label: Text(c.customize_meridiem_left),
            ),
            ButtonSegment(
              value: SkinMeridiem.right,
              label: Text(c.customize_meridiem_right),
            ),
          ],
          selected: {draft.meridiem},
          onSelectionChanged: (v) =>
              onChanged((d) => d.copyWith(meridiem: v.single)),
        ),
        _SwitchRow(
          label: c.show_date,
          value: draft.showDate,
          onChanged: (v) => onChanged((d) => d.copyWith(showDate: v)),
        ),
      ],
    );
  }
}

/// A label and a switch, flush with the sheet's other controls; tapping
/// anywhere on the row toggles it. (`SettingsSwitchRow` pads its cell by
/// `space-4`, which would indent it past the headers here.)
class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Pressable(
      onTap: () => onChanged(!value),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: DesignSize.cornerButton),
        child: Row(
          spacing: DesignSpace.s3,
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: DesignColors.of(context).ink,
                ),
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    ),
  );
}

/// A face choice: "17" set in that face.
class _FaceTile extends StatelessWidget {
  const _FaceTile({
    required this.face,
    required this.selected,
    required this.onTap,
  });

  final DisplayFace face;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = DesignColors.of(context);
    return Pressable(
      onTap: onTap,
      selected: selected,
      semanticsLabel: face.family,
      focusRadius: DesignShape.circular(DesignShape.of(context).xs),
      child: ExcludeSemantics(
        child: Container(
          width: 56,
          height: 48,
          alignment: Alignment.center,
          decoration: _ring(
            colors,
            selected: selected,
            radius: DesignShape.of(context).xs,
          ),
          child: Text(
            '17',
            textScaler: TextScaler.noScaling,
            style: face.style(color: colors.ink, fontSize: 24),
          ),
        ),
      ),
    );
  }
}

/// The selected ring (2px accent with a surface gap) or a hairline.
BoxDecoration _ring(
  DesignColors colors, {
  required bool selected,
  required double radius,
  Color? fill,
}) => BoxDecoration(
  color: fill ?? colors.surfaceRaised,
  borderRadius: DesignShape.circular(radius),
  boxShadow: selected
      ? [
          BoxShadow(color: colors.surface, spreadRadius: 2),
          BoxShadow(color: colors.accent, spreadRadius: 4),
        ]
      : [BoxShadow(color: colors.hairline, spreadRadius: 1)],
);

/// A row of colour swatches plus a custom-colour button.
class _Swatches extends StatelessWidget {
  const _Swatches({
    required this.colors,
    required this.value,
    required this.onChanged,
  });

  final List<Color> colors;
  final Color value;
  final ValueChanged<Color> onChanged;

  Future<void> _custom(BuildContext context) async {
    final picked = await showDialog<Color>(
      context: context,
      builder: (_) => _HexDialog(initial: value),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DesignColors.of(context);
    Widget swatch({
      required String label,
      required bool selected,
      required VoidCallback onTap,
      Color? fill,
      Widget? child,
    }) => Pressable(
      onTap: onTap,
      selected: selected,
      semanticsLabel: label,
      focusRadius: DesignShape.circular(
        DesignShape.of(context).forHeight(DesignSize.cornerButton),
      ),
      // 28px visible, 44px to hit.
      child: SizedBox.square(
        dimension: DesignSize.cornerButton,
        child: Center(
          child: Container(
            width: 28,
            height: 28,
            decoration: _ring(
              tokens,
              selected: selected,
              radius: DesignShape.of(context).forHeight(28),
              fill: fill,
            ),
            child: child,
          ),
        ),
      ),
    );
    final known = colors.contains(value);
    return Wrap(
      children: [
        for (final color in colors)
          swatch(
            label: hexOf(color),
            selected: color == value,
            fill: color,
            onTap: () => onChanged(color),
          ),
        swatch(
          label: strings.clock.customize_custom_colour,
          selected: !known,
          fill: known ? null : value,
          onTap: () => unawaited(_custom(context)),
          child: known
              ? Icon(Icons.colorize_rounded, size: 16, color: tokens.ink)
              : null,
        ),
      ],
    );
  }
}

/// Asks for a hex colour; pops it, or null on cancel.
class _HexDialog extends StatefulWidget {
  const _HexDialog({required this.initial});

  final Color initial;

  @override
  State<_HexDialog> createState() => _HexDialogState();
}

class _HexDialogState extends State<_HexDialog> {
  late final TextEditingController _text = TextEditingController(
    text: hexOf(widget.initial),
  );
  bool _invalid = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _apply() {
    final color = parseHex(_text.text);
    if (color == null) {
      setState(() => _invalid = true);
    } else {
      Navigator.of(context).pop(color);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = strings.clock;
    return AlertDialog(
      title: Text(c.customize_custom_colour),
      content: TextField(
        controller: _text,
        autofocus: true,
        onSubmitted: (_) => _apply(),
        decoration: InputDecoration(
          hintText: c.customize_hex_hint,
          errorText: _invalid ? c.customize_hex_invalid : null,
        ),
      ),
      actions: [
        AppButton.text(
          onPressed: () => Navigator.of(context).pop(),
          label: MaterialLocalizations.of(context).cancelButtonLabel,
        ),
        AppButton.text(onPressed: _apply, label: c.customize_apply),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.onReset, required this.onSave, this.onDelete});

  final VoidCallback onReset;
  final VoidCallback onSave;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final c = strings.clock;
    final colors = DesignColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.hairline)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSpace.s4,
          vertical: DesignSpace.s3,
        ),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: DesignSpace.s2,
          runSpacing: DesignSpace.s2,
          children: [
            AppButton.text(
              danger: true,
              onPressed: onReset,
              label: c.customize_reset,
            ),
            if (onDelete != null)
              AppButton.text(
                danger: true,
                onPressed: onDelete,
                label: c.customize_delete,
              ),
            AppButton.filled(onPressed: onSave, label: c.customize_save),
          ],
        ),
      ),
    );
  }
}
