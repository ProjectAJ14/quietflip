import 'package:design_system/constants/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// How much of the chrome (the island) is showing.
enum ChromeState {
  /// Invisible, not tappable, not announced.
  hidden,

  /// Collapsed to a dot that only hints the chrome is there.
  dot,

  /// Full controls: the island's tabs and action tray.
  expanded,
}

/// One control in the island's action tray. With an [icon] it is a round
/// icon button ([label] is its tooltip and spoken name); without one it is
/// a text chip showing [label].
@immutable
class IslandAction {
  const IslandAction({
    required this.label,
    this.icon,
    this.onPressed,
    this.primary = false,
  });

  /// Tooltip and spoken name; the visible text of a chip.
  final String label;

  /// The symbol; null makes a text chip.
  final IconData? icon;

  /// Null draws the action disabled.
  final VoidCallback? onPressed;

  /// The main action: a filled button.
  final bool primary;
}

/// A transient readout the island shows in place of its tabs.
sealed class IslandHud {
  const IslandHud();
}

/// Brightness level while it is being dragged.
final class IslandBrightnessHud extends IslandHud {
  const IslandBrightnessHud(this.value, this.label)
    : assert(value >= 0 && value <= 1);

  /// Level from 0 to 1; fills the bar.
  final double value;

  /// Visible and spoken text, such as "72%".
  final String label;
}

/// Name of the current page, with one dot per page.
final class IslandTitleHud extends IslandHud {
  const IslandTitleHud(this.title, this.index, this.count)
    : assert(index >= 0 && index < count);

  /// Visible and spoken name of the page.
  final String title;

  /// Which dot is lit.
  final int index;

  /// How many dots.
  final int count;
}

/// Icon size in the island (brand book: 22px symbols).
const double _chromeIconSize = 22;

/// Whether chrome should skip its spring and only cross-fade.
bool _reduceMotion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context) ||
    View.of(context).platformDispatcher.accessibilityFeatures.reduceMotion;

/// The top-centre pill: a dot, the tab bar over an action tray, or a HUD.
/// One dark shape that morphs between them on the island spring; a [hud]
/// wins over [state]. Tray content cross-fades as it changes. The tray
/// scrolls sideways rather than overflow a narrow window.
class Island extends StatelessWidget {
  const Island({
    super.key,
    required this.state,
    this.hud,
    required this.tabs,
    required this.selected,
    required this.onSelect,
    required this.tabsLabel,
    this.actions = const [],
    this.trailing = const [],
    this.status,
  }) : assert(tabs.length <= 4);

  /// Dot, expanded tabs or hidden; ignored while [hud] is set.
  final ChromeState state;

  /// Readout shown instead of everything else, even when [state] is hidden.
  final IslandHud? hud;

  /// Tab labels, at most four.
  final List<String> tabs;

  /// Index of the selected tab.
  final int selected;

  /// Called with the index of a tapped tab.
  final ValueChanged<int> onSelect;

  /// Spoken name of the tab bar.
  final String tabsLabel;

  /// The tray under the tabs, in order: primary action, then the rest.
  final List<IslandAction> actions;

  /// Tray actions after a hairline, such as Settings.
  final List<IslandAction> trailing;

  /// Text at the start of the tray, announced when it changes, such as
  /// "Time's up".
  final String? status;

  /// Expanded height with a tray: the tab row plus one row of actions.
  static const double trayHeight =
      DesignSize.islandExpandedHeight +
      DesignSize.cornerButton +
      DesignSpace.s1;

  bool get _hasTray =>
      actions.isNotEmpty || trailing.isNotEmpty || status != null;

  /// Page dot diameter in the title HUD (from the Island preview).
  static const double hudDot = 5;

  /// Brightness bar width in the HUD (from the Island preview).
  static const double hudBarWidth = 70;

  /// Brightness bar height in the HUD (from the Island preview).
  static const double hudBarHeight = 5;

  @override
  Widget build(BuildContext context) {
    final colors = DesignColors.of(context);
    final text = Theme.of(context).textTheme;
    final hud = this.hud;
    final expanded = hud == null && state == ChromeState.expanded;
    final visible = hud != null || state != ChromeState.hidden;
    // Two rows are too tall for a stadium: its round ends would clip the
    // outer tabs and actions.
    final radius = expanded && _hasTray ? DesignRadius.lg : DesignRadius.pill;

    final Widget content = switch (hud) {
      IslandBrightnessHud() => _hud(hud.label, _brightness(hud, colors, text)),
      IslandTitleHud() => _hud(hud.title, _title(hud, colors, text)),
      null when expanded => _expanded(context, colors, text),
      null => const SizedBox.square(
        key: ValueKey(ChromeState.dot),
        dimension: DesignSize.islandDot,
      ),
    };
    final height = switch (hud) {
      null when expanded =>
        _hasTray ? trayHeight : DesignSize.islandExpandedHeight,
      null => DesignSize.islandDot,
      _ => DesignSize.islandPillHeight,
    };

    final pill = SizedBox(
      height: height,
      child: Material(
        type: MaterialType.transparency,
        child: AnimatedSwitcher(
          duration: DesignMotion.fade + DesignMotion.fadeDelay,
          switchInCurve: Interval(
            DesignMotion.fadeDelay.inMicroseconds /
                (DesignMotion.fade + DesignMotion.fadeDelay).inMicroseconds,
            1,
          ),
          // Only the incoming content sizes the pill; outgoing
          // content fades at its own size, clipped by the pill.
          layoutBuilder: (current, previous) => Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              for (final child in previous) Positioned(child: child),
              ?current,
            ],
          ),
          child: content,
        ),
      ),
    );

    return IgnorePointer(
      ignoring: !expanded,
      child: ExcludeFocus(
        excluding: !expanded,
        child: ExcludeSemantics(
          excluding: !visible || (hud == null && !expanded),
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: DesignMotion.fade,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.island,
                borderRadius: BorderRadius.circular(radius),
                boxShadow: colors.islandShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: _reduceMotion(context)
                    // AnimatedSize cannot run for zero time (it re-dirties
                    // itself mid-layout), so reduced motion drops it.
                    ? pill
                    : AnimatedSize(
                        duration: DesignMotion.islandMorph,
                        curve: DesignMotion.islandCurve,
                        clipBehavior: Clip.none,
                        child: pill,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _hud(String label, Widget child) => Semantics(
    key: ValueKey(hud.runtimeType),
    container: true,
    liveRegion: true,
    label: label,
    child: ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DesignSpace.s3),
        child: child,
      ),
    ),
  );

  Widget _brightness(
    IslandBrightnessHud hud,
    DesignColors colors,
    TextTheme text,
  ) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: DesignSpace.s2,
    children: [
      Icon(
        Icons.light_mode_outlined,
        size: _chromeIconSize,
        color: colors.islandInk,
      ),
      ClipRRect(
        borderRadius: BorderRadius.circular(DesignRadius.pill),
        child: SizedBox(
          width: hudBarWidth,
          height: hudBarHeight,
          child: ColoredBox(
            // The island is dark in both themes, so its track is the dark one.
            color: DesignColors.dark.controlOff,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: hud.value,
              child: ColoredBox(color: colors.islandInk),
            ),
          ),
        ),
      ),
      Text(
        hud.label,
        style: text.labelMedium?.copyWith(color: colors.islandInkMuted),
      ),
    ],
  );

  Widget _title(IslandTitleHud hud, DesignColors colors, TextTheme text) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: DesignSpace.s2,
    children: [
      Text(
        hud.title,
        style: text.labelMedium?.copyWith(color: colors.islandInk),
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        spacing: DesignSpace.s1,
        children: [
          for (var i = 0; i < hud.count; i++)
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == hud.index
                    ? colors.islandInk
                    : colors.islandInkMuted,
              ),
              child: const SizedBox.square(dimension: hudDot),
            ),
        ],
      ),
    ],
  );

  Widget _expanded(BuildContext context, DesignColors colors, TextTheme text) {
    final maxWidth = MediaQuery.sizeOf(context).width - 2 * DesignSpace.s4;
    // Scales down while fading out into a smaller pill.
    return FittedBox(
      key: const ValueKey(ChromeState.expanded),
      fit: BoxFit.scaleDown,
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth < 0 ? 0 : maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: DesignSize.islandExpandedHeight,
              child: _tabBar(colors, text),
            ),
            if (_hasTray)
              SizedBox(
                height: trayHeight - DesignSize.islandExpandedHeight,
                child: _tray(context, colors, text),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tray(BuildContext context, DesignColors colors, TextTheme text) {
    final status = this.status;
    final children = [
      if (status != null)
        Semantics(
          liveRegion: true,
          container: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignSpace.s2),
            child: Text(
              status,
              maxLines: 1,
              style: text.labelLarge?.copyWith(color: colors.islandInk),
            ),
          ),
        ),
      for (final a in actions) _action(a, colors, text),
      if (trailing.isNotEmpty && (actions.isNotEmpty || status != null))
        SizedBox(
          width: 1,
          height: DesignSpace.s6,
          // The island is dark in both themes, so its rule is the dark one.
          child: ColoredBox(color: DesignColors.dark.hairline),
        ),
      for (final a in trailing) _action(a, colors, text),
    ];
    return AnimatedSwitcher(
      duration: DesignMotion.fade,
      child: SingleChildScrollView(
        key: ValueKey(
          [
            status,
            for (final a in [...actions, ...trailing]) a.label,
          ].join('|'),
        ),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          DesignSpace.s1,
          0,
          DesignSpace.s1,
          DesignSpace.s1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: DesignSpace.s1,
          children: children,
        ),
      ),
    );
  }

  Widget _action(IslandAction a, DesignColors colors, TextTheme text) {
    final enabled = a.onPressed != null;
    final ink = a.primary
        ? colors.islandOnActive
        : enabled
        ? colors.islandInk
        : colors.islandInkMuted;
    final icon = a.icon;
    final Widget face = icon == null
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignSpace.s3),
            child: Center(
              widthFactor: 1,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  a.label,
                  maxLines: 1,
                  style: text.labelLarge?.copyWith(color: ink),
                ),
              ),
            ),
          )
        : SizedBox.square(
            dimension: DesignSize.cornerButton,
            child: Icon(icon, size: _chromeIconSize, color: ink),
          );
    return Tooltip(
      message: a.label,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: a.label,
        excludeSemantics: true,
        onTap: a.onPressed,
        child: InkWell(
          onTap: a.onPressed,
          customBorder: const StadiumBorder(),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: a.primary
                  ? colors.islandActive
                  : icon == null
                  // The island is dark in both themes: the dark chip fill.
                  ? DesignColors.dark.controlOff
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(DesignRadius.pill),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: DesignSize.cornerButton,
                minHeight: DesignSize.cornerButton,
              ),
              child: face,
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabBar(DesignColors colors, TextTheme text) {
    return Center(
      widthFactor: 1,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Semantics(
          role: SemanticsRole.tabBar,
          label: tabsLabel,
          container: true,
          child: Padding(
            padding: const EdgeInsets.all(DesignSpace.s1),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: DesignSpace.s2,
              children: [
                for (var i = 0; i < tabs.length; i++) _tab(i, colors, text),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(int i, DesignColors colors, TextTheme text) {
    final isSelected = i == selected;
    return Semantics(
      container: true,
      role: SemanticsRole.tab,
      selected: isSelected,
      button: true,
      label: tabs[i],
      excludeSemantics: true,
      onTap: () => onSelect(i),
      child: InkWell(
        onTap: () => onSelect(i),
        customBorder: const StadiumBorder(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isSelected ? colors.islandActive : Colors.transparent,
            borderRadius: BorderRadius.circular(DesignRadius.pill),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: DesignSize.cornerButton,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignSpace.s4),
              child: Center(
                widthFactor: 1,
                child: Text(
                  tabs[i],
                  style: text.labelLarge?.copyWith(
                    color: isSelected
                        ? colors.islandOnActive
                        : colors.islandInkMuted,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
