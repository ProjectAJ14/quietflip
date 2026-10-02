import 'package:design_system/design_system.dart';
import 'package:flip_clock/flip_clock.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

/// First frame the user sees.
///
/// Continues the native launch screen (`flutter_native_splash.yaml`): the
/// same logo, at the same size and centred, on the same black, so the
/// hand-off does not jump. Then goes straight to the clock: QuietFlip has no
/// sign-in and no dashboard in its UI.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// The logo every launch screen draws: 608px wide at 4x.
  static const logoAsset = 'assets/splash/quietflip-logo.png';

  /// Logical width of [logoAsset], matching the native launch screens.
  static const logoWidth = 152.0;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirect());
  }

  Future<void> _redirect() async {
    if (!mounted) return;
    context.go(FlipClockRouter.home);
  }

  @override
  Widget build(BuildContext context) {
    // Always the Black ground, whatever the chosen appearance: the native
    // screen cannot read that setting, so it is black too.
    return Scaffold(
      backgroundColor: DesignColors.dark.bg,
      body: Center(
        child: Semantics(
          label: strings.app.name,
          image: true,
          child: const ExcludeSemantics(
            child: AppAssetImage(
              assetPath: SplashScreen.logoAsset,
              width: SplashScreen.logoWidth,
              boxFit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
