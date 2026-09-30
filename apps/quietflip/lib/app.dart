import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

/// The application view. Its owner creates and disposes the router.
///
/// [appearance] is the theme the user picked; it forces the theme regardless
/// of the OS brightness (QuietFlip defaults to Black).
class App extends StatelessWidget {
  const App({required this.router, required this.appearance, super.key});

  final GoRouter router;
  final ValueListenable<AppearanceMode> appearance;

  @override
  Widget build(BuildContext context) {
    return GlobalEventChannelProvider(
      child: ValueListenableBuilder(
        valueListenable: appearance,
        builder: (context, mode, _) => DesignSystemWrapper(
          mode: mode,
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
