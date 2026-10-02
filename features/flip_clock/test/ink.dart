import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every ink feature (splash, ripple, sparkle, highlight) live on any
/// `Material` in the tree. Empty when nothing drew ink.
List<InkFeature> liveInk(WidgetTester tester) => [
  for (final r in tester.allRenderObjects)
    if (r is MaterialInkController)
      // `debugInkFeatures` lives on Material's private render object.
      ...?((r as dynamic).debugInkFeatures as List<InkFeature>?),
];
