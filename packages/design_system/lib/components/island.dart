import 'dart:math' as math;

import 'package:design_system/constants/design_shape.dart';
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
    this.semanticsLabel,
  });

  /// Tooltip and spoken name; the visible text of a chip.
  final String label;

  /// Spoken name when [label] is an abbreviation, such as "5 minute timer"
  /// for a `5m` chip.
  final String? semanticsLabel;

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

/// Icon size in the island (brand book: 22px symbols).
const double _chromeIconSize = 22;

/// The top-centre pill: a dot, the tab bar over an action tray, or a HUD.
/// One dark shape that morphs between them: it grows on the island spring
/// and shrinks on [DesignMotion.collapseCurve] (no bounce on the way out);
/// a [hud] wins over [state]. Hiding from a bigger shape shrinks to the dot
/// first, then fades it. Tray content cross-fades as it changes. The tray
/// scrolls sideways rather than overflow a narrow window.
class Island extends StatefulWidget {
  const Island({
    super.key,
    required this.state,
    this.hud,
    required this.tabs,
    required this.selected,
    required this.onSelect,
    required this.tabsLabel,
    this.actions = const [],
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

  /// Text at the start of the tray, announced when it changes, such as
  /// "Time's up".
  final String? status;

  /// Expanded height with a tray: inset, tab row, row gap, one row of
  /// actions, inset.
  static const double trayHeight =
      DesignSpace.islandInset * 2 +
      DesignSize.cornerButton * 2 +
      DesignSpace.islandRowGap;

  /// Brightness bar width in the HUD (from the Island preview).
  static const double hudBarWidth = 70;

  /// Brightness bar height in the HUD (from the Island preview).
  static const double hudBarHeight = 5;

  bool get _hasTray => actions.isNotEmpty || status != null;

  bool get _expanded => hud == null && state == ChromeState.expanded;

  bool get _visible => hud != null || state != ChromeState.hidden;

  double get _height => switch (hud) {
    null when _expanded =>
      _hasTray ? trayHeight : DesignSize.islandExpandedHeight,
    null => DesignSize.islandDot,
    _ => DesignSize.islandPillHeight,
  };

  @override
  State<Island> createState() => _IslandState();

  Widget _build(
    BuildContext context, {
    required bool shrinking,
    required bool fadeAfterShrink,
    required double maxWidth,
  }) {
    final colors = DesignColors.of(context);
    final text = Theme.of(context).textTheme;
    final hud = this.hud;
    final expanded = _expanded;
    final visible = _visible;
    final reduceMotion = reducedMotion(context);
    final shape = DesignShape.of(context);
    // Two rows take the large role; anything shorter is capped at half its
    // height, so the dot stays a dot.
    final radius = shape.forHeight(
      _height,
      role: expanded && _hasTray ? shape.lg : shape.md,
    );

    final Widget content = switch (hud) {
      IslandBrightnessHud() => _hud(
        hud.label,
        _brightness(hud, colors, shape, text),
      ),
      null when expanded => _expandedContent(context, colors, text, maxWidth),
      null => const SizedBox.square(
        key: ValueKey(ChromeState.dot),
        dimension: DesignSize.islandDot,
      ),
    };

    Widget sized(Widget? current) {
      final box = SizedBox(height: _height, child: current);
      return reduceMotion
          // AnimatedSize cannot run for zero time (it re-dirties itself
          // mid-layout), so reduced motion drops it.
          ? box
          : AnimatedSize(
              duration: shrinking
                  ? DesignMotion.islandCollapse
                  : DesignMotion.islandMorph,
              curve: shrinking
                  ? DesignMotion.collapseCurve
                  : DesignMotion.islandCurve,
              clipBehavior: Clip.none,
              child: box,
            );
    }

    final pill = Material(
      type: MaterialType.transparency,
      child: AnimatedSwitcher(
        duration: DesignMotion.fade + DesignMotion.fadeDelay,
        // Outgoing content fades with the shrink, not ahead of it.
        reverseDuration: DesignMotion.islandCollapse,
        switchInCurve: Interval(
          DesignMotion.fadeDelay.inMicroseconds /
              (DesignMotion.fade + DesignMotion.fadeDelay).inMicroseconds,
          1,
        ),
        // Only the incoming content sizes the pill (first, so the size
        // animation keeps its state across switches); outgoing content is
        // laid out in the morphing pill, so it scales down as it shrinks.
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            sized(current),
            for (final child in previous)
              Positioned.fill(
                child: FittedBox(fit: BoxFit.scaleDown, child: child),
              ),
          ],
        ),
        child: content,
      ),
    );

    final fadeAfter = fadeAfterShrink && !reduceMotion;
    return IgnorePointer(
      ignoring: !expanded,
      child: ExcludeFocus(
        excluding: !expanded,
        child: ExcludeSemantics(
          excluding: !visible || (hud == null && !expanded),
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: fadeAfter
                ? DesignMotion.islandCollapse
                : DesignMotion.fade,
            curve: fadeAfter ? DesignMotion.collapseFade : Curves.linear,
            child: _Surface(
              radius: radius,
              reduceMotion: reduceMotion,
              child: pill,
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
    DesignShape shape,
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
        borderRadius: DesignShape.circular(shape.forHeight(hudBarHeight)),
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

  Widget _expandedContent(
    BuildContext context,
    DesignColors colors,
    TextTheme text,
    double available,
  ) {
    // Inside its own box (the corner buttons sit beside it) and never
    // closer than space-4 to the window edges.
    final maxWidth = math.min(
      available,
      MediaQuery.sizeOf(context).width - 2 * DesignSpace.s4,
    );
    // Scales down while fading out into a smaller pill.
    return FittedBox(
      key: const ValueKey(ChromeState.expanded),
      fit: BoxFit.scaleDown,
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth < 0 ? 0 : maxWidth),
        child: Padding(
          padding: const EdgeInsets.all(DesignSpace.islandInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: DesignSpace.islandRowGap,
            children: [
              SizedBox(
                height: DesignSize.cornerButton,
                child: _tabBar(context, colors, text),
              ),
              if (_hasTray)
                SizedBox(
                  height: DesignSize.cornerButton,
                  child: _tray(context, colors, text),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tray(BuildContext context, DesignColors colors, TextTheme text) {
    final status = this.status;
    // Groups are runs of one kind (status, icon actions, chips), set apart
    // by space alone.
    const groupBreak = SizedBox(
      width: DesignSpace.islandGroupGap - 2 * DesignSpace.islandItemGap,
    );
    final children = <Widget>[
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
      for (final (i, a) in actions.indexed) ...[
        if ((i == 0 && status != null) ||
            (i > 0 && (actions[i - 1].icon == null) != (a.icon == null)))
          groupBreak,
        _action(a, colors, DesignShape.of(context), text),
      ],
    ];
    return AnimatedSwitcher(
      duration: DesignMotion.fade,
      child: SingleChildScrollView(
        key: ValueKey([status, for (final a in actions) a.label].join('|')),
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: DesignSpace.islandItemGap,
          children: children,
        ),
      ),
    );
  }

  Widget _action(
    IslandAction a,
    DesignColors colors,
    DesignShape shape,
    TextTheme text,
  ) {
    final item = shape.forHeight(DesignSize.cornerButton);
    final enabled = a.onPressed != null;
    final ink = a.primary
        ? colors.islandOnActive
        : enabled
        ? colors.islandInk
        : colors.islandInkMuted;
    final icon = a.icon;
    final Widget face = icon == null
        ? Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSpace.islandItemPadding,
            ),
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
        label: a.semanticsLabel ?? a.label,
        excludeSemantics: true,
        onTap: a.onPressed,
        child: InkWell(
          onTap: a.onPressed,
          customBorder: DesignShape.rounded(item),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: a.primary
                  ? colors.islandActive
                  : icon == null
                  // The island is dark in both themes: the dark chip fill.
                  ? DesignColors.dark.controlOff
                  : Colors.transparent,
              borderRadius: DesignShape.circular(item),
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

  /// The tab row: every tab as wide as the widest label, over one
  /// selected pill that slides to [selected] on the island spring while
  /// the labels cross-fade their colours.
  Widget _tabBar(BuildContext context, DesignColors colors, TextTheme text) {
    final shape = DesignShape.of(context);
    final item = shape.forHeight(DesignSize.cornerButton);
    final reduceMotion = reducedMotion(context);
    // Measured as the labels draw (the ambient style under labelLarge, at
    // the current text scale), so no tab is wider than another.
    final style = DefaultTextStyle.of(context).style.merge(text.labelLarge);
    final painter = TextPainter(
      textScaler: MediaQuery.textScalerOf(context),
      textDirection: Directionality.of(context),
      maxLines: 1,
    );
    var widest = 0.0;
    for (final tab in tabs) {
      painter
        ..text = TextSpan(text: tab, style: style)
        ..layout();
      widest = math.max(widest, painter.width);
    }
    painter.dispose();
    final width = widest.ceilToDouble() + 2 * DesignSpace.islandItemPadding;
    const gap = DesignSpace.islandItemGap;
    return Center(
      widthFactor: 1,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Semantics(
          role: SemanticsRole.tabBar,
          label: tabsLabel,
          container: true,
          child: SizedBox(
            width: tabs.length * width + (tabs.length - 1) * gap,
            height: DesignSize.cornerButton,
            child: Stack(
              // The spring overshoots: the pill may pass the row's ends.
              clipBehavior: Clip.none,
              children: [
                AnimatedPositionedDirectional(
                  // Reduced motion: the pill jumps.
                  duration: reduceMotion
                      ? Duration.zero
                      : DesignMotion.islandMorph,
                  curve: DesignMotion.islandCurve,
                  start: selected * (width + gap),
                  top: 0,
                  width: width,
                  height: DesignSize.cornerButton,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.islandActive,
                      borderRadius: DesignShape.circular(item),
                    ),
                  ),
                ),
                Row(
                  spacing: gap,
                  children: [
                    for (var i = 0; i < tabs.length; i++)
                      _tab(i, width, item, colors, style, reduceMotion),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(
    int i,
    double width,
    double item,
    DesignColors colors,
    TextStyle style,
    bool reduceMotion,
  ) {
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
        customBorder: DesignShape.rounded(item),
        child: SizedBox(
          width: width,
          height: DesignSize.cornerButton,
          child: Center(
            // Colours only, so the fade never overshoots.
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(
                end: isSelected ? colors.islandOnActive : colors.islandInkMuted,
              ),
              duration: reduceMotion ? Duration.zero : DesignMotion.fade,
              builder: (context, color, _) => Text(
                tabs[i],
                maxLines: 1,
                style: style.copyWith(color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IslandState extends State<Island> {
  /// The last size change made the island smaller: it collapses without
  /// overshoot. Kept until the height changes again, so a rebuild mid-morph
  /// never swaps the curve.
  bool _shrinking = false;

  /// Hiding started from more than the dot: the fade waits for the shrink.
  bool _fadeAfterShrink = false;

  @override
  void initState() {
    super.initState();
    // Tab widths are measured in build; a font that loads later (bundled
    // fonts load asynchronously) changes them.
    PaintingBinding.instance.systemFonts.addListener(_fontsChanged);
  }

  @override
  void dispose() {
    PaintingBinding.instance.systemFonts.removeListener(_fontsChanged);
    super.dispose();
  }

  void _fontsChanged() => setState(() {});

  @override
  void didUpdateWidget(Island old) {
    super.didUpdateWidget(old);
    if (old._height != widget._height) {
      _shrinking = widget._height < old._height;
    }
    if (old._visible != widget._visible) {
      _fadeAfterShrink = !widget._visible && old._height > DesignSize.islandDot;
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) => widget._build(
      context,
      shrinking: _shrinking,
      fadeAfterShrink: _fadeAfterShrink,
      maxWidth: box.maxWidth,
    ),
  );
}

/// A chrome button in a screen corner that follows the island's
/// [ChromeState]: a 44px button when expanded, a [DesignSize.cornerDot] dot
/// toward [corner] when idle, gone when hidden. It grows on the island
/// spring and shrinks like the island (no overshoot; hiding from the button
/// shrinks to the dot before it fades), on the same surface and corner
/// rules. Its layout box is always [DesignSize.cornerButton] square, so
/// neighbours never move. Only the expanded button is tappable.
class CornerButton extends StatefulWidget {
  const CornerButton({
    super.key,
    required this.state,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.corner,
  });

  /// Button, dot or hidden.
  final ChromeState state;

  /// The symbol drawn when expanded.
  final IconData icon;

  /// Tooltip and spoken name.
  final String tooltip;

  /// Called when the expanded button is tapped.
  final VoidCallback onPressed;

  /// Which corner the dot shrinks toward, such as [Alignment.topLeft].
  final Alignment corner;

  double get _size => state == ChromeState.expanded
      ? DesignSize.cornerButton
      : DesignSize.cornerDot;

  @override
  State<CornerButton> createState() => _CornerButtonState();
}

class _CornerButtonState extends State<CornerButton> {
  /// As in the island: the last size change was a shrink.
  bool _shrinking = false;

  /// Hiding started from the button: the fade waits for the shrink.
  bool _fadeAfterShrink = false;

  @override
  void didUpdateWidget(CornerButton old) {
    super.didUpdateWidget(old);
    if (old._size != widget._size) _shrinking = widget._size < old._size;
    final hidden = widget.state == ChromeState.hidden;
    if ((old.state == ChromeState.hidden) != hidden) {
      // Reset on every show, so it never delays the next fade-in.
      _fadeAfterShrink = hidden && old.state == ChromeState.expanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = DesignColors.of(context);
    final shape = DesignShape.of(context);
    final reduceMotion = reducedMotion(context);
    final expanded = widget.state == ChromeState.expanded;
    final size = widget._size;
    final fadeAfter = _fadeAfterShrink && !reduceMotion;
    final box = AnimatedContainer(
      duration: reduceMotion
          ? Duration.zero
          : _shrinking
          ? DesignMotion.islandCollapse
          : DesignMotion.islandMorph,
      curve: _shrinking ? DesignMotion.collapseCurve : DesignMotion.islandCurve,
      width: size,
      height: size,
      // Only the size rides the spring; the surface is drawn un-animated.
      child: _Surface(
        radius: shape.forHeight(size),
        reduceMotion: reduceMotion,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onPressed,
            customBorder: DesignShape.rounded(
              shape.forHeight(DesignSize.cornerButton),
            ),
            // The symbol scales down and fades with the shrink.
            child: AnimatedOpacity(
              opacity: expanded ? 1 : 0,
              duration: expanded
                  ? DesignMotion.fade
                  : DesignMotion.islandCollapse,
              child: FittedBox(
                child: SizedBox.square(
                  dimension: DesignSize.cornerButton,
                  child: Icon(
                    widget.icon,
                    size: _chromeIconSize,
                    color: colors.islandInk,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return SizedBox.square(
      dimension: DesignSize.cornerButton,
      child: IgnorePointer(
        ignoring: !expanded,
        child: ExcludeFocus(
          excluding: !expanded,
          child: ExcludeSemantics(
            excluding: !expanded,
            child: AnimatedOpacity(
              opacity: widget.state == ChromeState.hidden ? 0 : 1,
              duration: fadeAfter
                  ? DesignMotion.islandCollapse
                  : DesignMotion.fade,
              curve: fadeAfter ? DesignMotion.collapseFade : Curves.linear,
              child: Align(
                alignment: widget.corner,
                // Always built, so the shape keeps morphing across states.
                child: Tooltip(
                  message: widget.tooltip,
                  excludeFromSemantics: true,
                  child: Semantics(
                    button: true,
                    label: widget.tooltip,
                    child: box,
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

/// The island's raised dark surface (fill, [DesignColors.islandElevation]
/// and the top highlight), clipped to [radius]. The corner is tweened on a
/// curve that never overshoots, so it cannot snap ahead of a shrinking
/// shape (and a decoration never lerps past 1).
class _Surface extends StatelessWidget {
  const _Surface({
    required this.radius,
    required this.reduceMotion,
    required this.child,
  });

  final double radius;
  final bool reduceMotion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = DesignColors.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: radius),
      duration: reduceMotion ? Duration.zero : DesignMotion.islandCollapse,
      curve: DesignMotion.collapseCurve,
      builder: (context, radius, child) => DecoratedBox(
        decoration: BoxDecoration(
          color: colors.island,
          borderRadius: DesignShape.circular(radius),
          boxShadow: colors.islandElevation.shadows,
        ),
        child: CustomPaint(
          foregroundPainter: _EdgeHighlight(
            radius,
            colors.islandElevation.highlight,
          ),
          child: ClipRRect(
            borderRadius: DesignShape.circular(radius),
            child: child,
          ),
        ),
      ),
      child: child,
    );
  }
}

/// The island's 1px top-edge highlight: [color] at the top, clear by
/// mid-height. Gives depth where shadows vanish (pure black).
class _EdgeHighlight extends CustomPainter {
  const _EdgeHighlight(this.radius, this.color);

  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(0.5), DesignShape.radius(radius)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color, color.withValues(alpha: 0)],
          stops: const [0, 0.5],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_EdgeHighlight old) =>
      old.radius != radius || old.color != color;
}
