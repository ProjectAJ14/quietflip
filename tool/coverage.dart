import 'dart:io';
import 'package:path/path.dart' as p;

/// Run from the workspace root: dart run tool/coverage.dart [--report-only].
/// Only compiler-generated serializers/translations are excluded.
/// Packages are tested in parallel (one per CPU); each package's output is
/// printed as one block when it finishes.
Future<void> main(List<String> args) async {
  final root = Directory(Directory.current.resolveSymbolicLinksSync());
  final merged = <String, Map<int, int>>{};
  var failed = false;
  final reportOnly = args.contains('--report-only');
  final members = <({String area, String name, Directory package})>[];
  for (final area in ['apps', 'features', 'packages', 'plugins']) {
    final directory = Directory('${root.path}/$area');
    if (!directory.existsSync()) continue;
    final packages = directory.listSync().whereType<Directory>().toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final package in packages) {
      final manifest = File('${package.path}/pubspec.yaml');
      if (!manifest.existsSync()) continue;
      final name = RegExp(
        r'^name:\s*(\S+)',
        multiLine: true,
      ).firstMatch(manifest.readAsStringSync())!.group(1)!;
      members.add((area: area, name: name, package: package));
    }
  }
  final coveragePackages =
      '^(${members.map((m) => RegExp.escape(m.name)).join('|')})\$';
  final tested = <({String area, String name, Directory package})>[];
  for (final member in members) {
    final testDirectory = Directory('${member.package.path}/test');
    if (!testDirectory.existsSync() ||
        !testDirectory
            .listSync(recursive: true)
            .whereType<File>()
            .any((f) => f.path.endsWith('_test.dart'))) {
      stderr.writeln('${member.area}/${member.name}: missing tests');
      failed = true;
      continue;
    }
    tested.add(member);
  }

  Future<bool> run(String workingDirectory, List<String> arguments) async {
    final result = await Process.run(
      'flutter',
      arguments,
      workingDirectory: workingDirectory,
    );
    stdout.writeln(
      '== ${p.relative(workingDirectory, from: root.path)}: '
      'flutter ${arguments.join(' ')}',
    );
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    return result.exitCode == 0;
  }

  Future<void> test(({String area, String name, Directory package}) m) async {
    final package = m.package;
    final testDirectory = Directory('${package.path}/test');
    final report = File('${package.path}/coverage/lcov.info');
    final imports = File('${testDirectory.path}/coverage_imports_test.dart');
    if (imports.existsSync()) {
      throw StateError('Refusing to overwrite ${imports.path}');
    }
    final sources =
        Directory('${package.path}/lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))
            .where(
              (f) => !RegExp(r'\.(g|freezed|i69n)\.dart$').hasMatch(f.path),
            )
            // Web-only files (dart:js_interop) cannot compile on the VM test
            // runner; keep them to thin browser calls behind a VM-tested
            // contract. They are run in Chrome from test/web/ below.
            .where((f) => !f.path.endsWith('_web.dart'))
            .where(
              (f) => !RegExp(
                r'^part of ',
                multiLine: true,
              ).hasMatch(f.readAsStringSync()),
            )
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    imports.writeAsStringSync(
      [
        '// Generated temporarily by tool/coverage.dart.',
        '// ignore_for_file: unused_import',
        for (final source in sources)
          "import 'package:${m.name}/${p.relative(source.path, from: p.join(package.path, 'lib')).replaceAll(r'\', '/')}';",
        "import 'package:flutter_test/flutter_test.dart';",
        'void main() { TestWidgetsFlutterBinding.ensureInitialized(); }',
      ].join('\n'),
    );
    try {
      if (report.existsSync()) report.deleteSync();
      if (!await run(package.path, [
        'test',
        '--coverage',
        '--coverage-package=$coveragePackages',
      ])) {
        failed = true;
      }
    } finally {
      imports.deleteSync();
    }
    // The VM cannot measure web-only files, so each package that has one
    // must exercise it in Chrome from test/web/ (`@TestOn('browser')`).
    final hasWebSources = Directory(
      '${package.path}/lib',
    ).listSync(recursive: true).any((f) => f.path.endsWith('_web.dart'));
    if (hasWebSources) {
      final webTests = Directory('${testDirectory.path}/web');
      if (!webTests.existsSync()) {
        stderr.writeln(
          '${m.area}/${m.name}: *_web.dart without test/web tests',
        );
        failed = true;
      } else if (!await run(package.path, [
        'test',
        '--platform',
        'chrome',
        'test/web',
      ])) {
        failed = true;
      }
    }
  }

  if (!reportOnly) {
    // Workers pull from one shared queue; Dart's single thread makes it safe.
    final queue = tested.iterator;
    Future<void> worker() async {
      while (queue.moveNext()) {
        await test(queue.current);
      }
    }

    await Future.wait(
      List.generate(Platform.numberOfProcessors, (_) => worker()),
    );
  }

  for (final m in tested) {
    final package = m.package;
    final report = File('${package.path}/coverage/lcov.info');
    if (!report.existsSync()) {
      stderr.writeln('${m.area}/${m.name}: missing coverage report');
      failed = true;
      continue;
    }
    String? source;
    for (final line in report.readAsLinesSync()) {
      if (line.startsWith('SF:')) {
        final path = line.substring(3);
        var absolute = p.normalize(
          p.isAbsolute(path) ? path : p.join(package.path, path),
        );
        // VM reports may use /var while the workspace resolves to /private/var
        // on macOS (or another symlink on Linux). Merge the same real source.
        final sourceFile = File(absolute);
        if (sourceFile.existsSync()) {
          absolute = sourceFile.resolveSymbolicLinksSync();
        }
        source = p.isWithin(root.path, absolute)
            ? p.relative(absolute, from: root.path).replaceAll(r'\', '/')
            : null;
        if (source != null &&
            !RegExp(
              r'^(apps|features|packages|plugins)/[^/]+/lib/',
            ).hasMatch(source)) {
          source = null;
        }
        if (source != null &&
            RegExp(r'\.(g|freezed|i69n)\.dart$').hasMatch(source)) {
          source = null;
        }
      } else if (line.startsWith('DA:') && source != null) {
        final fields = line.substring(3).split(',');
        final number = int.parse(fields[0]);
        final hits = int.parse(fields[1]);
        final lines = merged.putIfAbsent(source, () => {});
        lines[number] = (lines[number] ?? 0) + hits;
      }
    }
  }
  var covered = 0;
  var total = 0;
  final output = StringBuffer();
  for (final source in merged.keys.toList()..sort()) {
    final lines = merged[source]!;
    final missing =
        lines.entries.where((e) => e.value == 0).map((e) => e.key).toList()
          ..sort();
    covered += lines.length - missing.length;
    total += lines.length;
    output.writeln('SF:$source');
    for (final line in lines.keys.toList()..sort()) {
      output.writeln('DA:$line,${lines[line]}');
    }
    output.writeln('LF:${lines.length}');
    output.writeln('LH:${lines.length - missing.length}');
    output.writeln('end_of_record');
    if (missing.isNotEmpty) {
      stdout.writeln('$source: uncovered lines ${missing.join(", ")}');
    }
  }
  Directory('coverage').createSync(recursive: true);
  File('coverage/lcov.info').writeAsStringSync(output.toString());
  stdout.writeln(
    'Coverage: $covered/$total executable lines '
    '(${total == 0 ? "0.00" : (100 * covered / total).toStringAsFixed(2)}%)',
  );
  if (failed || total == 0 || covered != total) exitCode = 1;
}
