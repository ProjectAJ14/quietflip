import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flip_clock/data/models/clock_settings.dart';
import 'package:flip_clock/data/models/skin.dart';
import 'package:flip_clock/data/skins.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flip_clock/ui/components/display_value.dart';
import 'package:flip_clock/ui/components/skin_customizer.dart';
import 'package:flip_clock/ui/components/skin_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';

/// Opens the Skins sheet over the clock. Selecting applies at once; the
/// selected tile's Customize and New skin open the customizer on top.
Future<void> showSkins(
  BuildContext context, {
  required SettingsController settings,
  required DateTime now,
}) => showSheet<void>(
  context,
  BlocBuilder<SettingsController, ClockSettings>(
    bloc: settings,
    builder: (context, s) => SkinPicker(
      custom: s.customSkins,
      selectedId: settings.skin.id,
      now: now,
      use24h: uses24h(context, s),
      onSelect: (skin) => unawaited(settings.selectSkin(skin.id)),
      onDone: () => Navigator.of(context).pop(),
      onCustomize: () =>
          unawaited(customizeSkin(context, settings: settings, now: now)),
      onNew: () => unawaited(
        _customize(
          context,
          settings,
          now,
          // A copy: saving adds it under Your skins.
          _asDrawn(context, settings).copyWith(
            id: '',
            name: strings.clock.customize_copy_name(settings.skin.name),
          ),
        ),
      ),
    ),
  ),
);

/// Opens the customizer on the selected skin (a custom one can be deleted
/// there), from its tile in the Skins sheet or the Appearance strip.
Future<void> customizeSkin(
  BuildContext context, {
  required SettingsController settings,
  required DateTime now,
}) => _customize(context, settings, now, _asDrawn(context, settings));

/// The selected skin in the colours it shows now, as explicit colours: a
/// custom skin made from Mono in Mono Light keeps the light look it was
/// made from.
Skin _asDrawn(BuildContext context, SettingsController settings) =>
    settings.skin.forTheme(DesignColors.of(context)).copyWith(themed: false);

Future<void> _customize(
  BuildContext context,
  SettingsController settings,
  DateTime now,
  Skin start,
) => showSheet<void>(
  context,
  Builder(
    builder: (context) {
      void close() => Navigator.of(context).pop();
      return SkinCustomizer(
        start: start,
        now: now,
        use24h: uses24h(context, settings.state),
        onCancel: close,
        onSave: (skin) {
          unawaited(settings.saveSkin(skin));
          close();
        },
        onDelete: Skins.isCustom(start)
            ? () {
                unawaited(settings.deleteSkin(start.id));
                close();
              }
            : null,
      );
    },
  ),
);
