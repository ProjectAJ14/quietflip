import 'dart:math' as math;

import 'package:design_system/constants/design_shape.dart';
import 'package:design_system/constants/design_tokens.dart';
import 'package:flutter/material.dart';

/// One entry of a [SettingsShell]: a sidebar or root row, and the detail
/// page of [groups] it opens.
class SettingsCategory {
  const SettingsCategory({
    required this.icon,
    required this.label,
    required this.groups,
  });

  /// Symbol in the category's icon tile.
  final IconData icon;

  /// Row label, and the detail page's title.
  final String label;

  /// The detail page's grouped cells, top to bottom.
  final List<SettingsGroup> groups;
}

/// Rows drawn as one grouped inset cell, with an optional header and footer.
class SettingsGroup {
  const SettingsGroup({
    this.header,
    this.hint,
    required this.rows,
    this.footer,
  });

  /// Section label above the cell, shown uppercase.
  final String? header;

  /// A muted note at the end of the header line, shown as given; it wraps
  /// under the header when the line is too narrow. Needs a [header].
  final String? hint;

  /// The rows, usually the `Settings*Row` widgets, separated by hairlines.
  final List<Widget> rows;

  /// Note under the cell.
  final String? footer;
}

/// A settings screen laid out three ways from one [categories] model:
///
/// - **Phone** (narrower than 600): a root list with a large title; a
///   category opens its detail with a back button. A system back while a
///   category is open returns to the root instead of leaving the screen.
/// - **Split** (600 to 1100): a [DesignSize.sidebarWidth] sidebar beside the
///   selected category's detail.
/// - **Desktop density** (1100 or wider, or [desktop]): the split layout
///   with a narrower sidebar and denser rows.
///
/// An optional [pinned] category is drawn as its own card ([pinnedCard]):
/// after the list on the phone, at the bottom of the sidebar (outside its
/// scroll) in the split layouts. It opens like any other category.
class SettingsShell extends StatefulWidget {
  const SettingsShell({
    super.key,
    required this.title,
    required this.categories,
    this.doneLabel,
    this.onDone,
    this.desktop = false,
    this.initialCategory = 0,
    this.openInitialCategory = false,
    this.pinned,
    this.pinnedCard,
  }) : assert(categories.length > 0),
       assert((pinned == null) == (pinnedCard == null)),
       assert(
         initialCategory >= 0 &&
             initialCategory < categories.length + (pinned == null ? 0 : 1),
       );

  /// Large title on the phone root, sidebar title, and the back label.
  final String title;

  /// The categories, in order.
  final List<SettingsCategory> categories;

  /// Label of the Done button; no button when null.
  final String? doneLabel;

  /// Called when Done is tapped.
  final VoidCallback? onDone;

  /// Forces desktop density at any width (pass true on desktop and web).
  final bool desktop;

  /// Category selected first in the split and desktop layouts;
  /// `categories.length` addresses [pinned].
  final int initialCategory;

  /// The phone layout also starts on [initialCategory]'s page (a deep
  /// link), with Done beside its title so closing returns to the caller.
  final bool openInitialCategory;

  /// A category kept apart from [categories], opened from [pinnedCard].
  final SettingsCategory? pinned;

  /// What the pinned card shows (the shell draws the card around it).
  final Widget? pinnedCard;

  /// Minimum height of the pinned card.
  static const double pinnedCardHeight = 72;

  /// Split layout from this width.
  static const double splitBreakpoint = 600;

  /// Desktop density from this width.
  static const double desktopBreakpoint = 1100;

  /// Sidebar width in desktop density.
  static const double desktopSidebarWidth = 230;

  /// Sidebar row height in desktop density.
  static const double desktopNavHeight = 30;

  /// Minimum row height in desktop density.
  static const double desktopRowHeight = 36;

  /// Category icon tile (phone rows and split sidebar).
  static const double iconTileSize = 28;

  @override
  State<SettingsShell> createState() => _SettingsShellState();
}

class _SettingsShellState extends State<SettingsShell> {
  /// Category open on the phone layout; null shows the root.
  late int? _open = widget.openInitialCategory ? widget.initialCategory : null;

  /// The phone layout is still on the page it was opened on.
  late bool _direct = widget.openInitialCategory;

  /// Category selected in the split and desktop layouts.
  late int _selected = widget.initialCategory;

  /// Index of the pinned category: one past the list.
  int get _pinnedIndex => widget.categories.length;

  SettingsCategory _category(int i) =>
      i < widget.categories.length ? widget.categories[i] : widget.pinned!;

  Widget? _pinnedCard({required bool selected, required VoidCallback onTap}) =>
      switch (widget.pinnedCard) {
        final card? => _PinnedCard(
          selected: selected,
          onTap: onTap,
          child: card,
        ),
        null => null,
      };

  @override
  Widget build(BuildContext context) {
    final colors = DesignColors.of(context);
    return Material(
      color: colors.bg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          // Under 600px it is always the phone stack, even with pointer
          // density (a phone browser), since no sidebar fits.
          if (width < SettingsShell.splitBreakpoint) {
            return _SettingsDensity(
              desktop: false,
              child: _phone(context, colors),
            );
          }
          final desktop =
              widget.desktop || width >= SettingsShell.desktopBreakpoint;
          return _SettingsDensity(
            desktop: desktop,
            child: _split(context, colors, desktop),
          );
        },
      ),
    );
  }

  Widget? _done() => widget.doneLabel == null
      ? null
      : Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: widget.onDone,
            child: Text(widget.doneLabel!),
          ),
        );

  Widget _phone(BuildContext context, DesignColors colors) {
    final text = Theme.of(context).textTheme;
    final open = _open;
    return PopScope(
      canPop: open == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _root();
      },
      child: open == null
          ? ListView(
              padding: const EdgeInsets.all(DesignSpace.s4),
              children: [
                ?_done(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignSpace.s4,
                    vertical: DesignSpace.s2,
                  ),
                  child: Text(
                    widget.title,
                    style: text.displaySmall?.copyWith(color: colors.ink),
                  ),
                ),
                _Group(
                  SettingsGroup(
                    rows: [
                      for (var i = 0; i < widget.categories.length; i++)
                        _Cell(
                          onTap: () => setState(() => _open = i),
                          leading: _IconTile(
                            widget.categories[i].icon,
                            size: SettingsShell.iconTileSize,
                          ),
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: colors.inkSubtle,
                          ),
                          child: _Label(widget.categories[i].label),
                        ),
                    ],
                  ),
                ),
                if (_pinnedCard(
                      selected: false,
                      onTap: () => setState(() => _open = _pinnedIndex),
                    )
                    case final card?) ...[
                  const SizedBox(height: DesignSpace.s6),
                  card,
                ],
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          onPressed: _root,
                          icon: const Icon(Icons.chevron_left_rounded),
                          label: Text(widget.title),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        _category(open).label,
                        textAlign: TextAlign.center,
                        style: text.titleMedium?.copyWith(color: colors.ink),
                      ),
                    ),
                    // Balances the back button so the title stays centred;
                    // holds Done on a page opened directly.
                    Expanded(
                      child: _direct
                          ? Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: _done(),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
                Expanded(
                  child: _Detail(_category(open), padding: DesignSpace.s4),
                ),
              ],
            ),
    );
  }

  void _root() => setState(() {
    _open = null;
    _direct = false;
  });

  Widget _split(BuildContext context, DesignColors colors, bool desktop) {
    final text = Theme.of(context).textTheme;
    // The list may have shrunk since the selection was made.
    final selected = math.min(
      _selected,
      widget.categories.length - (widget.pinned == null ? 1 : 0),
    );
    final pinned = _pinnedCard(
      selected: selected == _pinnedIndex,
      onTap: () => setState(() => _selected = _pinnedIndex),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: desktop
              ? SettingsShell.desktopSidebarWidth
              : DesignSize.sidebarWidth,
          child: ColoredBox(
            color: colors.surfaceSidebar,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(DesignSpace.s3),
                    children: [
                      ?_done(),
                      Padding(
                        padding: const EdgeInsets.all(DesignSpace.s2),
                        child: Text(
                          widget.title,
                          style: text.headlineSmall?.copyWith(
                            color: colors.ink,
                          ),
                        ),
                      ),
                      for (var i = 0; i < widget.categories.length; i++)
                        _NavRow(
                          widget.categories[i],
                          selected: i == selected,
                          desktop: desktop,
                          onTap: () => setState(() => _selected = i),
                        ),
                    ],
                  ),
                ),
                if (pinned != null)
                  Padding(
                    padding: const EdgeInsets.all(DesignSpace.s4),
                    child: pinned,
                  ),
              ],
            ),
          ),
        ),
        VerticalDivider(width: 1, thickness: 1, color: colors.hairline),
        Expanded(
          child: _Detail(
            _category(selected),
            padding: DesignSpace.s8,
            title: true,
          ),
        ),
      ],
    );
  }
}

/// Whether the rows below use desktop density; phone density when absent.
class _SettingsDensity extends InheritedWidget {
  const _SettingsDensity({required this.desktop, required super.child});

  final bool desktop;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SettingsDensity>()?.desktop ??
      false;

  @override
  bool updateShouldNotify(_SettingsDensity oldWidget) =>
      desktop != oldWidget.desktop;
}

/// A category's groups in a scrolling list, with its title in split views.
class _Detail extends StatelessWidget {
  const _Detail(this.category, {required this.padding, this.title = false});

  final SettingsCategory category;
  final double padding;
  final bool title;

  @override
  Widget build(BuildContext context) => ListView(
    padding: EdgeInsets.all(padding),
    children: [
      if (title)
        Text(
          category.label,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: DesignColors.of(context).ink,
          ),
        ),
      for (var i = 0; i < category.groups.length; i++) ...[
        if (title || i > 0) const SizedBox(height: DesignSpace.s8),
        _Group(category.groups[i]),
      ],
    ],
  );
}

/// Header, the rows in one raised cell split by hairlines, footer.
class _Group extends StatelessWidget {
  const _Group(this.group);

  final SettingsGroup group;

  @override
  Widget build(BuildContext context) {
    final colors = DesignColors.of(context);
    final text = Theme.of(context).textTheme;
    final header = group.header;
    final footer = group.footer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignSpace.s4,
              DesignSpace.s6,
              DesignSpace.s4,
              DesignSpace.s2,
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: DesignSpace.s3,
              children: [
                Text(
                  header.toUpperCase(),
                  style: text.labelSmall?.copyWith(color: colors.inkSubtle),
                ),
                if (group.hint case final hint?)
                  Text(
                    hint,
                    style: text.bodySmall?.copyWith(color: colors.inkSubtle),
                  ),
              ],
            ),
          ),
        Material(
          color: colors.surfaceRaised,
          borderRadius: DesignShape.circular(DesignShape.of(context).sm),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < group.rows.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: DesignSpace.s4,
                    color: colors.hairline,
                  ),
                group.rows[i],
              ],
            ],
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignSpace.s4,
              DesignSpace.s2,
              DesignSpace.s4,
              0,
            ),
            child: Text(
              footer,
              style: text.bodySmall?.copyWith(color: colors.inkSubtle),
            ),
          ),
      ],
    );
  }
}

/// The pinned category's card: raised surface, hairline border (an accent
/// ring when selected), the app's `md` corner, at least
/// [SettingsShell.pinnedCardHeight] tall. Focusable; Enter or Space opens it.
class _PinnedCard extends StatelessWidget {
  const _PinnedCard({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = DesignColors.of(context);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: colors.surfaceRaised,
        clipBehavior: Clip.antiAlias,
        shape: DesignShape.rounded(
          DesignShape.of(context).md,
          side: BorderSide(
            color: selected ? colors.accent : colors.hairline,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: SettingsShell.pinnedCardHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.all(DesignSpace.s4),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A sidebar row: icon tile and label; the selected one is an accent pill.
class _NavRow extends StatelessWidget {
  const _NavRow(
    this.category, {
    required this.selected,
    required this.desktop,
    required this.onTap,
  });

  final SettingsCategory category;
  final bool selected;
  final bool desktop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = DesignColors.of(context);
    final text = Theme.of(context).textTheme;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? colors.accent : Colors.transparent,
        borderRadius: DesignShape.circular(DesignShape.of(context).sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: DesignShape.circular(DesignShape.of(context).sm),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: desktop
                  ? SettingsShell.desktopNavHeight
                  : DesignSize.cornerButton,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignSpace.s2),
              child: Row(
                spacing: DesignSpace.s3,
                children: [
                  _IconTile(
                    category.icon,
                    size: desktop ? 20 : SettingsShell.iconTileSize,
                    iconSize: desktop ? 14 : 20,
                    inverted: selected,
                  ),
                  Expanded(
                    child: Text(
                      category.label,
                      style: (desktop ? text.bodyMedium : text.bodyLarge)
                          ?.copyWith(
                            color: selected ? colors.onAccent : colors.ink,
                          ),
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
}

/// The rounded square behind a category icon; [inverted] on the accent pill.
class _IconTile extends StatelessWidget {
  const _IconTile(
    this.icon, {
    required this.size,
    this.iconSize = 20,
    this.inverted = false,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final colors = DesignColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: inverted ? colors.onAccent : colors.controlOff,
        borderRadius: DesignShape.circular(DesignShape.of(context).xs),
      ),
      child: SizedBox.square(
        dimension: size,
        child: Icon(
          icon,
          size: iconSize,
          color: inverted ? colors.accent : colors.ink,
        ),
      ),
    );
  }
}

/// A row's label (body, or body-desktop in desktop density) and subtitle.
class _Label extends StatelessWidget {
  const _Label(this.label, {this.subtitle});

  final String label;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = DesignColors.of(context);
    final text = Theme.of(context).textTheme;
    final subtitle = this.subtitle;
    final style = _SettingsDensity.of(context)
        ? text.bodyMedium
        : text.bodyLarge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: style?.copyWith(color: colors.ink)),
        if (subtitle != null)
          Text(
            subtitle,
            style: text.bodySmall?.copyWith(color: colors.inkMuted),
          ),
      ],
    );
  }
}

/// The shared row frame: density padding and minimum height, an expanding
/// [child] between an optional [leading] and [trailing].
class _Cell extends StatelessWidget {
  const _Cell({required this.child, this.leading, this.trailing, this.onTap});

  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final desktop = _SettingsDensity.of(context);
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: desktop
              ? SettingsShell.desktopRowHeight
              : DesignSize.cornerButton,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: desktop ? DesignSpace.s3 : DesignSpace.s4,
            vertical: desktop ? DesignSpace.s1 : DesignSpace.s2,
          ),
          child: Row(
            spacing: DesignSpace.s3,
            children: [
              ?leading,
              Expanded(child: child),
              // Values and switches sit at the row's end.
              if (trailing != null)
                Flexible(
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: trailing,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A label over a control: [DesignSpace.s2] between them and
/// [DesignSpace.s2] under the control, on top of the cell padding, so the
/// control never sits on the cell's bottom edge in either density.
class _ControlBlock extends StatelessWidget {
  const _ControlBlock({
    required this.crossAxisAlignment,
    required this.children,
  });

  final CrossAxisAlignment crossAxisAlignment;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: DesignSpace.s2),
    child: Column(
      crossAxisAlignment: crossAxisAlignment,
      spacing: DesignSpace.s2,
      children: children,
    ),
  );
}

/// A label with an accent switch; tapping anywhere on the row toggles it.
class SettingsSwitchRow extends StatelessWidget {
  const SettingsSwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  /// Optional line under the label.
  final String? subtitle;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: _Cell(
      onTap: () => onChanged(!value),
      trailing: Switch(value: value, onChanged: onChanged),
      child: _Label(label, subtitle: subtitle),
    ),
  );
}

/// A label with a muted value; a chevron and tap target when [onTap] is
/// set; an optional [trailing] control (such as a delete button) at the end.
class SettingsValueRow extends StatelessWidget {
  const SettingsValueRow({
    super.key,
    required this.label,
    this.value,
    this.onTap,
    this.trailing,
    this.semanticsLabel,
  });

  final String label;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;

  /// Spoken instead of [label] when the label is an abbreviation.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final colors = DesignColors.of(context);
    final value = this.value;
    return _Cell(
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: colors.inkMuted),
              ),
            ),
          if (onTap != null)
            Icon(Icons.chevron_right_rounded, color: colors.inkSubtle),
          ?trailing,
        ],
      ),
      child: Semantics(
        container: semanticsLabel != null,
        label: semanticsLabel,
        excludeSemantics: semanticsLabel != null,
        child: _Label(label),
      ),
    );
  }
}

/// A label above a segmented control of [options] (value, visible text).
class SettingsSegmentedRow<T> extends StatelessWidget {
  const SettingsSegmentedRow({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => _Cell(
    child: _ControlBlock(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        // Shrinks instead of overflowing on narrow screens and large text.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: SegmentedButton<T>(
            showSelectedIcon: false,
            segments: [
              for (final (value, text) in options)
                ButtonSegment(value: value, label: Text(text)),
            ],
            selected: {selected},
            onSelectionChanged: (values) => onChanged(values.first),
          ),
        ),
      ],
    ),
  );
}

/// A label and its [valueLabel] above a slider; [valueLabel] is also spoken.
class SettingsSliderRow extends StatelessWidget {
  const SettingsSliderRow({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.valueLabel,
    required this.onChanged,
    this.minLabel,
    this.maxLabel,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;

  /// Stop labels under the track's two ends, such as "Square" and "Round".
  final String? minLabel;
  final String? maxLabel;

  /// Visible and spoken value, such as "72%".
  final String valueLabel;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => _Cell(
    child: _ControlBlock(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          spacing: DesignSpace.s2,
          children: [
            Expanded(child: _Label(label)),
            Text(
              valueLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: DesignColors.of(context).inkMuted,
              ),
            ),
          ],
        ),
        Semantics(
          container: true,
          label: label,
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            semanticFormatterCallback: (_) => valueLabel,
          ),
        ),
        if (minLabel != null || maxLabel != null)
          DefaultTextStyle.merge(
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: DesignColors.of(context).inkMuted,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(minLabel ?? ''), Text(maxLabel ?? '')],
            ),
          ),
      ],
    ),
  );
}

/// A label with a keyboard shortcut drawn as a keycap.
class SettingsKeyRow extends StatelessWidget {
  const SettingsKeyRow({super.key, required this.label, required this.keycap});

  final String label;

  /// Key text, such as "Space".
  final String keycap;

  @override
  Widget build(BuildContext context) {
    final colors = DesignColors.of(context);
    return _Cell(
      trailing: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.bg,
          borderRadius: DesignShape.circular(DesignShape.of(context).xs),
          border: Border.all(color: colors.hairline),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSpace.s2,
            vertical: DesignSpace.s1,
          ),
          child: Text(
            keycap,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: colors.ink),
          ),
        ),
      ),
      child: _Label(label),
    );
  }
}

/// A muted paragraph in a cell, such as a permission note.
class SettingsNoteRow extends StatelessWidget {
  const SettingsNoteRow({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => _Cell(
    child: Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: DesignColors.of(context).inkMuted),
    ),
  );
}
