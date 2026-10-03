import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';
import 'package:yaml/yaml.dart';

/// Every `$name` / `${name}` placeholder in [value], sorted.
List<String> _placeholders(String value) =>
    RegExp(r'\$\{?(\w+)').allMatches(value).map((m) => m[1]!).toList()..sort();

Map<String, String> _flatten(File file) {
  final yaml = loadYaml(file.readAsStringSync()) as YamlMap;
  return {
    for (final group in yaml.entries)
      for (final entry in (group.value as YamlMap).entries)
        '${group.key}.${entry.key}': '${entry.value}',
  };
}

void main() {
  final english = _flatten(File('lib/messages.i69n.yaml'));

  test('there is one translation file per supported locale', () {
    final codes = Directory('lib')
        .listSync()
        .whereType<File>()
        .map((f) => RegExp(r'messages_(\w+)\.i69n\.yaml$').firstMatch(f.path))
        .nonNulls
        .map((m) => m[1]!)
        .toSet();
    expect(codes, LocalizationProvider.supportedLocales.skip(1).toSet());
  });

  for (final code in LocalizationProvider.supportedLocales.skip(1)) {
    group(code, () {
      final translated = _flatten(File('lib/messages_$code.i69n.yaml'));

      test('has exactly the English keys', () {
        expect(
          english.keys.toSet().difference(translated.keys.toSet()),
          isEmpty,
          reason: 'missing in $code',
        );
        expect(
          translated.keys.toSet().difference(english.keys.toSet()),
          isEmpty,
          reason: 'unknown in $code',
        );
      });

      test('keeps every placeholder', () {
        for (final key in english.keys) {
          expect(
            _placeholders(translated[key] ?? ''),
            _placeholders(english[key]!),
            reason: '$code $key',
          );
        }
      });

      test('has no empty text', () {
        for (final MapEntry(:key, :value) in translated.entries) {
          expect(value.trim(), isNotEmpty, reason: '$code $key');
        }
      });
    });
  }
}
