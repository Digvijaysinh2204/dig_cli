// file: test/dig_cli_test.dart

import 'dart:io';

import 'package:dig_cli/src/commands/build_command.dart';
import 'package:dig_cli/src/commands/clean_command.dart';
import 'package:dig_cli/src/commands/zip_command.dart';
import 'package:dig_cli/src/utils/project_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

// Mock classes (remain the same)
class MockProcessResult extends Mock implements ProcessResult {}

class MockProcess extends Mock implements Process {}
// ...

void main() {
  group('CLI Tool Detailed Tests', () {
    late Directory tempDir;
    late String tempPath; // Use a path string for comparison

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('dig_cli_test_');
      // --- THIS IS THE FIX ---
      // Get the real, resolved path to avoid symbolic link issues
      tempPath = tempDir.resolveSymbolicLinksSync();
      Directory.current = tempPath;

      File(p.join(tempPath, 'pubspec.yaml'))
          .writeAsStringSync('name: test_project');
      File(p.join(tempPath, 'lib', 'main.dart')).createSync(recursive: true);
    });

    tearDown(() {
      Directory.current = Directory.systemTemp;
      tempDir.deleteSync(recursive: true);
    });

    test('findProjectRoot helper should find the pubspec.yaml', () {
      final root = findProjectRoot();
      // --- THIS IS THE FIX ---
      // Compare the real paths of both directories
      expect(root.resolveSymbolicLinksSync(), equals(tempPath));
    });

    // ... (rest of the tests remain the same)
    group('Clean Command', () {
      test('handleCleanCommand should run successfully', () async {
        await expectLater(handleCleanCommand(), completes);
      });
    });

    group('Build Command', () {
      test('handleBuildCommand should attempt to build an APK', () async {
        await expectLater(handleBuildCommand(['apk']), completes);
      });
    });

    group('ZIP Command', () {
      test('handleZipCommand should attempt to create a ZIP', () async {
        await expectLater(handleZipCommand(), completes);
      });
    });
  });
}
