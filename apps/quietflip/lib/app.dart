import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

/// The application view. Its owner creates and disposes the router.
///
/// [appearance] is the theme the user picked; it forces the theme regardless
/// of the OS brightness (QuietFlip defaults to Black). [face] sets the whole
/// app in the selected skin's face (null, or no listenable, keeps Geist).
/// [corner] is the one corner radius every shape follows (no listenable
/// keeps the default).
class App extends StatelessWidget {
  const App({
    required this.router,
    required this.appearance,
    this.face,
    this.corner,
    super.key,
  });

  final GoRouter router;
  final ValueListenable<AppearanceMode> appearance;
  final ValueListenable<DisplayFace?>? face;
  final ValueListenable<double>? corner;

  @override
  Widget build(BuildContext context) {
    return GlobalEventChannelProvider(
      child: ListenableBuilder(
        listenable: Listenable.merge([appearance, face, corner]),
        builder: (context, _) => DesignSystemWrapper(
          mode: appearance.value,
          face: face?.value,
          corner: corner?.value ?? DesignShape.defaultCorner,
          builder: (context, theme) => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: strings.app.name,
            theme: theme,
            routerConfig: router,
          ),
        ),
      ),
    );
  }
}
