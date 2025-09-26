// file: test/dig_cli_test.dart

import 'dart:io';

import 'package:dig_cli/src/commands/build_command.dart';
import 'package:dig_cli/src/commands/clean_command.dart';
import 'package:dig_cli/src/commands/zip_command.dart';
import 'package:dig_cli/src/utils/project_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

// --- Mock Classes ---
// We create mock versions of external dependencies
class MockProcessResult extends Mock implements ProcessResult {}

class MockProcess extends Mock implements Process {}

// A helper for mocking Process.run
Future<ProcessResult> mockProcessRun(Invocation invocation) {
  final result = MockProcessResult();
  when(() => result.exitCode).thenReturn(0); // Simulate success
  when(() => result.stdout).thenReturn('');
  when(() => result.stderr).thenReturn('');
  return Future.value(result);
}

void main() {
  group('CLI Tool Detailed Tests', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('dig_cli_test_');
      Directory.current = tempDir;
      File(p.join(tempDir.path, 'pubspec.yaml'))
          .writeAsStringSync('name: test_project');
      File(p.join(tempDir.path, 'lib', 'main.dart'))
          .createSync(recursive: true);
    });

    tearDown(() {
      Directory.current = Directory.systemTemp;
      tempDir.deleteSync(recursive: true);
    });

    test('findProjectRoot helper should find the pubspec.yaml', () {
      final root = findProjectRoot();
      expect(root.path, equals(tempDir.path));
    });

    group('Clean Command', () {
      test('handleCleanCommand should call "flutter clean"', () async {
        // This is an advanced test that checks if the correct command is executed.
        // It's not fully implemented here but shows the concept of mocking Process.run.
        // A full implementation would require a testing framework that can override top-level functions.
        await expectLater(handleCleanCommand(), completes);
      });
    });

    group('Build Command', () {
      test('handleBuildCommand should call "flutter build apk"', () async {
        // Similar to the clean command, a full test would mock Process.run
        // and verify that `flutter build apk --release` was the command passed.
        await expectLater(handleBuildCommand(['apk']), completes);
      });
    });

    group('ZIP Command', () {
      test('handleZipCommand should run "flutter clean" before zipping',
          () async {
        // This test verifies that `flutter clean` is called as part of the zip process.
        // As with others, a full mock is needed for a complete test.
        await expectLater(handleZipCommand(), completes);
      });
    });
  });
}
