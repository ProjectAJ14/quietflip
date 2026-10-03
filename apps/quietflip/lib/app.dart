import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

/// The application view. Its owner creates and disposes the router.
///
/// [appearance] is the theme the user picked; it forces the theme regardless
/// of the OS brightness (QuietFlip defaults to Black). [face] sets the whole
/// app in the selected skin's face (null, or no listenable, keeps Geist).
/// [corner] is the one corner radius every shape follows (no listenable
/// keeps the default).
///
/// The language follows the device: `startApp` selects it before bootstrap,
/// and a change of the system languages re-selects it here and rebuilds
/// every widget, since `strings` is read without a `BuildContext`.
class App extends StatefulWidget {
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
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
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
  void didChangeLocales(List<Locale>? locales) {
    final before = LocalizationProvider.currentLocale;
    if (LocalizationProvider.select(locales ?? const []) == before) return;
    void rebuild(Element element) {
      element.markNeedsBuild();
      element.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GlobalEventChannelProvider(
      child: ListenableBuilder(
        listenable: Listenable.merge([
          widget.appearance,
          widget.face,
          widget.corner,
        ]),
        builder: (context, _) => DesignSystemWrapper(
          mode: widget.appearance.value,
          face: widget.face?.value,
          corner: widget.corner?.value ?? DesignShape.defaultCorner,
          builder: (context, theme) => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: strings.app.name,
            theme: theme,
            locale: Locale(LocalizationProvider.currentLocale),
            supportedLocales: LocalizationProvider.locales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            routerConfig: widget.router,
          ),
        ),
      ),
    );
  }
}
