import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:toastification/toastification.dart';

class DesignSystemWrapper extends StatefulWidget {
  const DesignSystemWrapper({
    super.key,
    required this.builder,
    this.mode = AppearanceMode.system,
    this.face,
    this.corner = DesignShape.defaultCorner,
    this.arabic = false,
  });

  final Widget Function(BuildContext context, ThemeData theme) builder;

  /// Forces a theme; [AppearanceMode.system] follows platform brightness.
  final AppearanceMode mode;

  /// Sets every text style in this face (the app following a skin); null
  /// keeps Geist.
  final DisplayFace? face;

  /// The base corner radius of every shape ([DesignShape]); 0 is square.
  final double corner;

  /// Falls every text style back to the bundled Arabic font; set it only
  /// while the app is in Arabic, since it loads that font.
  final bool arabic;

  @override
  State<DesignSystemWrapper> createState() => _DesignSystemWrapperState();
}

class _DesignSystemWrapperState extends State<DesignSystemWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final theme = DesignSystem(
      context,
      face: widget.face,
      corner: widget.corner,
      arabic: widget.arabic,
    ).forMode(widget.mode, brightness);

    return Theme(
      data: theme,
      child: GlobalLoaderOverlay(
        overlayColor: theme.colorScheme.surface.withValues(alpha: 0.8),
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: ToastificationWrapper(child: widget.builder(context, theme)),
      ),
    );
  }
}
