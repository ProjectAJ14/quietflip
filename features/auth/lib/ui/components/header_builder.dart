import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

/// The app icon, 72 logical px at 4x, bundled with this package because a
/// feature cannot read the app's assets. Resized from
/// `apps/quietflip/assets/icon/quietflip-master.png`; regenerate it when the
/// icon changes.
const appIconAsset = 'assets/app-icon.png';

/// Banner shown above the sign-in and register forms: the app icon, the app
/// name and why anyone would sign in.
Widget headerBuilder(BuildContext context) {
  final theme = Theme.of(context);

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decorative: the app name below says the same thing.
          ClipRRect(
            borderRadius: DesignShape.circular(DesignShape.of(context).lg),
            child: const AppAssetImage(
              assetPath: appIconAsset,
              package: 'auth',
              width: 72,
              height: 72,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            strings.app.name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // The product's stance: an account is only for syncing.
          Text(
            strings.sync.sign_in_reason,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}
