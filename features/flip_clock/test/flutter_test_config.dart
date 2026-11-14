import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Loads every bundled face once, before any test, from the bundle (no
/// network): see `DesignFonts.loadAll`.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
    return DesignFonts.loadAll();
  });
  await testMain();
}
