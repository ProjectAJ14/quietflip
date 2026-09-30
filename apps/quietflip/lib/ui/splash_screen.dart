import 'package:design_system/design_system.dart';
import 'package:flip_clock/flip_clock.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

/// First frame the user sees.
///
/// Shown only while the first frame settles, then goes straight to the
/// clock: QuietFlip has no sign-in and no dashboard in its UI.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              strings.app.name,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            const DefaultLoader(),
          ],
        ),
      ),
    );
  }
}
