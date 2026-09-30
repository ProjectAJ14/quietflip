import 'package:di/di.dart';
import 'package:core/core.dart' as core;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flip_clock/ui/screens/index.dart';
import 'package:quietflip/main.dart' as entrypoint;

import 'clock_support.dart';

void main() {
  tearDown(di.reset);
  testWidgets(
    'cold-start notification routes wait for the router; later routes navigate directly',
    (tester) async {
      late void Function(String) openRoute;
      late Widget app;
      await tester.runAsync(
        () => entrypoint.startApp(
          initialize: (callback) async {
            await core.init();
            await initClock();
            openRoute = callback;
            callback('/error?title=From%20notification');
          },
          mount: (widget) => app = widget,
        ),
      );
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      expect(find.text('From notification'), findsOneWidget);
      openRoute('/home');
      await tester.pumpAndSettle();
      expect(find.byType(FlipClockScreen), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    },
  );
}
