import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flip_clock/data/models/skin.dart';
import 'package:flip_clock/data/skins.dart';
import 'package:flip_clock/ui/components/display_value.dart';
import 'package:flip_clock/ui/components/flip_display.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

/// The Skins sheet: live tiles of every skin, drawn with the user's
/// seconds and date settings; tapping one applies it at once, and the
/// selected tile offers Customize. Custom skins come first under Your
/// skins, with a New skin tile. Every built-in skin is free: no locks, no
/// ribbons.
class SkinPicker extends StatelessWidget {
  const SkinPicker({
    super.key,
    required this.custom,
    required this.selectedId,
    required this.now,
    required this.use24h,
    required this.onSelect,
    required this.onCustomize,
    required this.onNew,
    required this.onDone,
  });

  final List<Skin> custom;
  final String selectedId;

  /// The time the tiles show.
  final DateTime now;
  final bool use24h;

  final ValueChanged<Skin> onSelect;

  /// Opens the customizer on the selected skin (its tile's Customize).
  final VoidCallback onCustomize;

  /// Starts a new skin from the current one.
  final VoidCallback onNew;
  final VoidCallback onDone;

  /// Tiles are at least this wide (two columns on a phone).
  static const double minTileWidth = 196;

  @override
  Widget build(BuildContext context) {
    final c = strings.clock;
    return Column(
      children: [
        SheetHeader(
          title: c.skins_title,
          leading: TextButton(onPressed: onDone, child: Text(c.skins_done)),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              const gap = DesignSpace.s4;
              final inner = box.maxWidth - 2 * DesignSpace.s6;
              final columns = math.max(
                1,
                (inner + gap) ~/ (minTileWidth + gap),
              );
              final width = (inner - gap * (columns - 1)) / columns;
              Widget grid(List<Widget> tiles) =>
                  Wrap(spacing: gap, runSpacing: gap, children: tiles);
              Widget tile(Skin skin) => SizedBox(
                width: width,
                child: SkinTile(
                  skin: skin,
                  selected: skin.id == selectedId,
                  now: now,
                  use24h: use24h,
                  onTap: () => onSelect(skin),
                  onCustomize: onCustomize,
                ),
              );
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  DesignSpace.s6,
                  0,
                  DesignSpace.s6,
                  DesignSpace.s8,
                ),
                children: [
                  SectionHeader(c.skins_yours),
                  grid([
                    ...custom.map(tile),
                    SizedBox(
                      width: width,
                      child: _NewTile(onTap: onNew),
                    ),
                  ]),
                  SectionHeader(c.skins_classic),
                  grid(Skins.classic().map(tile).toList()),
                  SectionHeader(c.skins_bold),
                  grid(Skins.bold().map(tile).toList()),
                  SectionHeader(c.skins_type),
                  grid(Skins.type().map(tile).toList()),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A sheet's top row: [leading] action, centred [title], [trailing]
/// action, over a hairline.
class SheetHeader extends StatelessWidget {
  const SheetHeader({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: DesignColors.of(context).hairline),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSpace.s2,
          vertical: DesignSpace.s1,
        ),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: leading,
              ),
            ),
            // Expanded (not Flexible), so both side slots get equal width
            // and the title sits in the true centre.
            Expanded(
              flex: 2,
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: trailing,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// An uppercase `section` group header in `ink-subtle`.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: DesignSpace.s6, bottom: DesignSpace.s3),
    child: Semantics(
      header: true,
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
          color: DesignColors.of(context).inkSubtle,
        ),
      ),
    ),
  );
}

/// One skin: its own ground with mini cards at the current time, drawn as
/// that skin is configured (seconds only when the skin shows them, in its
/// style: what selecting it gives; the date above only when the skin
/// shows it), the
/// name and face below, always in one row. Selected: a 2px accent ring, a
/// check badge, and a Customize button in place of the face name.
/// A selectable tile's outline: a hairline, or when [selected] the accent
/// ring with a gap. Skin tiles and sound tiles share it.
List<BoxShadow> selectionRing(DesignColors colors, {required bool selected}) =>
    selected
    ? [
        BoxShadow(color: colors.surface, spreadRadius: 2),
        BoxShadow(color: colors.accent, spreadRadius: 4),
      ]
    : [BoxShadow(color: colors.hairline, spreadRadius: 1)];

/// The selected tile's check badge (top right of its preview).
class SelectionCheck extends StatelessWidget {
  const SelectionCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = DesignColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: DesignShape.circular(
          DesignShape.of(context).forHeight(SkinTile.checkSize),
        ),
      ),
      child: SizedBox.square(
        dimension: SkinTile.checkSize,
        child: Icon(Icons.check_rounded, size: 16, color: colors.onAccent),
      ),
    );
  }
}

class SkinTile extends StatelessWidget {
  const SkinTile({
    super.key,
    required this.skin,
    required this.selected,
    required this.now,
    required this.use24h,
    required this.onTap,
    this.onCustomize,
  });

  final Skin skin;
  final bool selected;
  final DateTime now;
  final bool use24h;
  final VoidCallback onTap;

  /// Opens the customizer on this skin; offered on the selected tile only.
  final VoidCallback? onCustomize;

  /// Height of the tile's preview.
  static const double faceHeight = 118;

  /// The selected tile's check badge.
  static const double checkSize = 22;

  @override
  Widget build(BuildContext context) {
    final colors = DesignColors.of(context);
    final skin = this.skin.forTheme(colors);
    final text = Theme.of(context).textTheme.bodySmall!;
    final value = clockValue(
      now,
      use24h: use24h,
      // Selecting a skin applies its seconds preset, so the tile shows it.
      showSeconds: skin.seconds != SkinSeconds.off,
      skin: skin,
    );
    final customize = selected ? onCustomize : null;
    final date = skin.showDate
        ? MaterialLocalizations.of(context).formatFullDate(now)
        : null;
    // The tile is one button ("Rose, selected"); Customize is its own.
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      label: skin.name,
      child: InkWell(
        onTap: onTap,
        borderRadius: DesignShape.circular(DesignShape.of(context).md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: faceHeight,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSpace.s4,
                vertical: DesignSpace.s4,
              ),
              decoration: BoxDecoration(
                color: skin.groundColor,
                borderRadius: DesignShape.circular(DesignShape.of(context).md),
                boxShadow: selectionRing(colors, selected: selected),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ExcludeSemantics(
                      child: Column(
                        spacing: DesignSpace.s1,
                        children: [
                          if (date != null)
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                date,
                                maxLines: 1,
                                textScaler: TextScaler.noScaling,
                                style: skin.face.style(
                                  color: skin.digitColor.withValues(alpha: 0.7),
                                  fontSize: text.fontSize!,
                                ),
                              ),
                            ),
                          Expanded(
                            child: FlipDisplay(
                              cards: value.cards,
                              badge: value.badge,
                              meridiem: value.meridiem,
                              skin: skin,
                              semanticsLabel: skin.name,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (selected)
                    const Align(
                      alignment: Alignment.topRight,
                      child: SelectionCheck(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: DesignSpace.s1),
            // Every caption is a hit target tall, so the selected tile's
            // button never makes its row taller than the others.
            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: DesignSize.cornerButton,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ExcludeSemantics(
                      child: Text(
                        skin.name,
                        overflow: TextOverflow.ellipsis,
                        style: text.copyWith(
                          color: selected ? colors.ink : colors.inkMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  if (customize != null)
                    // Its own focusable button, spoken with the skin name.
                    TextButton.icon(
                      onPressed: customize,
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(
                        strings.clock.skins_customize,
                        semanticsLabel: strings.clock.skins_customize_named(
                          skin.name,
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ExcludeSemantics(
                        child: Text(
                          skin.face.family,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: text.copyWith(color: colors.inkMuted),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "New skin": copies the current skin into the customizer.
class _NewTile extends StatelessWidget {
  const _NewTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = DesignColors.of(context);
    final text = Theme.of(
      context,
    ).textTheme.bodySmall!.copyWith(color: colors.inkMuted);
    return Semantics(
      button: true,
      label: strings.clock.skins_new,
      child: InkWell(
        onTap: onTap,
        borderRadius: DesignShape.circular(DesignShape.of(context).md),
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: SkinTile.faceHeight,
                decoration: BoxDecoration(
                  borderRadius: DesignShape.circular(
                    DesignShape.of(context).md,
                  ),
                  border: Border.all(color: colors.hairline, width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: colors.inkMuted),
                    const SizedBox(height: DesignSpace.s1),
                    Text(strings.clock.skins_new, style: text),
                  ],
                ),
              ),
              const SizedBox(height: DesignSpace.s2),
              Text(strings.clock.skins_from_current, style: text),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens [child] as a sheet on `surface`, rounded `DesignShape.lg` on top with a
/// hairline edge, 90% of the screen tall.
Future<T?> showSheet<T>(BuildContext context, Widget child) {
  final colors = DesignColors.of(context);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: colors.surface,
    // Full width: Material caps sheets at 640px, too narrow for the
    // desktop grid and the side-by-side customizer.
    constraints: const BoxConstraints(),
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: colors.hairline),
      borderRadius: BorderRadius.vertical(
        top: DesignShape.radius(DesignShape.of(context).lg),
      ),
    ),
    builder: (context) => FractionallySizedBox(heightFactor: 0.9, child: child),
  );
}
