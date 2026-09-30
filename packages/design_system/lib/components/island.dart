import 'package:design_system/constants/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// How much of the chrome (island and corner buttons) is showing.
enum ChromeState {
  /// Invisible, not tappable, not announced.
  hidden,

  /// Collapsed to a dot that only hints the chrome is there.
  dot,

  /// Full controls: the island's tabs, the corner buttons.
  expanded,
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

/// Icon size in the island and the corners (brand book: 22px symbols).
const double _chromeIconSize = 22;

/// Whether chrome should skip its spring and only cross-fade.
bool _reduceMotion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context) ||
    View.of(context).platformDispatcher.accessibilityFeatures.reduceMotion;

/// The top-centre pill: a dot, the tab bar, or a HUD. One dark shape that
/// morphs between them on the island spring; a [hud] wins over [state].
class Island extends StatelessWidget {
  const Island({
    super.key,
    required this.state,
    this.hud,
    required this.tabs,
    required this.selected,
    required this.onSelect,
    required this.tabsLabel,
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

    final Widget content = switch (hud) {
      IslandBrightnessHud() => _hud(hud.label, _brightness(hud, colors, text)),
      IslandTitleHud() => _hud(hud.title, _title(hud, colors, text)),
      null when expanded => _tabBar(context, colors, text),
      null => const SizedBox.square(
        key: ValueKey(ChromeState.dot),
        dimension: DesignSize.islandDot,
      ),
    };
    final height = switch (hud) {
      null when expanded => DesignSize.islandExpandedHeight,
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
                borderRadius: BorderRadius.circular(DesignRadius.pill),
                boxShadow: colors.islandShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(DesignRadius.pill),
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

  Widget _tabBar(BuildContext context, DesignColors colors, TextTheme text) {
    final maxWidth = MediaQuery.sizeOf(context).width - 2 * DesignSpace.s4;
    return ConstrainedBox(
      key: const ValueKey(ChromeState.expanded),
      constraints: BoxConstraints(maxWidth: maxWidth < 0 ? 0 : maxWidth),
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

/// A round chrome button that sits in a screen corner and collapses to a
/// dot toward that corner. Its layout box is always
/// [DesignSize.cornerButton] square, so neighbours never move.
class CornerButton extends StatelessWidget {
  const CornerButton({
    super.key,
    required this.state,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.corner,
  });

  /// Button, dot or hidden. Only the button is tappable.
  final ChromeState state;

  /// The symbol drawn when expanded.
  final IconData icon;

  /// Tooltip and spoken name.
  final String tooltip;

  /// Called when the expanded button is tapped.
  final VoidCallback onPressed;

  /// Which corner the dot shrinks toward, such as [Alignment.topLeft].
  final Alignment corner;

  @override
  Widget build(BuildContext context) {
    final colors = DesignColors.of(context);
    final expanded = state == ChromeState.expanded;
    final size = expanded ? DesignSize.cornerButton : DesignSize.cornerDot;

    final circle = AnimatedContainer(
      duration: _reduceMotion(context)
          ? Duration.zero
          : DesignMotion.islandMorph,
      curve: DesignMotion.islandCurve,
      width: size,
      height: size,
      // The spring overshoots past 1: only the size may ride it. A shadow
      // lerped past 1 (Mono Dark's ring to Mono Light's blur on a theme
      // switch mid-morph) gets a negative blur and asserts.
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.island,
          shape: BoxShape.circle,
          boxShadow: colors.islandShadow,
        ),
        child: ClipOval(child: _content(expanded, colors)),
      ),
    );
    return SizedBox.square(
      dimension: DesignSize.cornerButton,
      child: IgnorePointer(
        ignoring: !expanded,
        child: ExcludeSemantics(
          excluding: !expanded,
          child: AnimatedOpacity(
            opacity: state == ChromeState.hidden ? 0 : 1,
            duration: DesignMotion.fade,
            child: Align(
              alignment: corner,
              // Always built, so the circle keeps animating across states.
              child: Tooltip(
                message: tooltip,
                excludeFromSemantics: true,
                child: Semantics(button: true, label: tooltip, child: circle),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _content(bool expanded, DesignColors colors) => expanded
      ? Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Icon(icon, size: _chromeIconSize, color: colors.islandInk),
          ),
        )
      : null;
}
