// file: lib/src/commands/zip_command.dart

import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../utils/logger.dart';
import '../utils/spinner.dart';

class IgnoreRules {
  final Set<String> exactDirs;
  final Set<String> exactFiles;
  final Set<String> extensions;
  final Set<String> prefixDirs; // NEW: for patterns like android/app/release/

  IgnoreRules(
      this.exactDirs, this.exactFiles, this.extensions, this.prefixDirs);
}

// --- IMPROVEMENT: Smarter .gitignore parser ---
IgnoreRules _readGitignore() {
  final file = File('.gitignore');
  if (!file.existsSync()) {
    kLog('⚠️ .gitignore not found. ZIP may include unnecessary files.',
        type: LogType.warning);
    return IgnoreRules({}, {}, {}, {});
  }

  final lines = file.readAsLinesSync();
  final exactDirs = <String>{};
  final exactFiles = <String>{};
  final extensions = <String>{};
  final prefixDirs = <String>{}; // NEW

  for (var line in lines) {
    line = line.trim();
    if (line.isEmpty || line.startsWith('#') || line.startsWith('!')) continue;

    if (line.startsWith('*.')) {
      extensions.add(line.substring(1)); // *.log -> .log
    } else if (line.endsWith('/')) {
      if (line.startsWith('**/')) {
        prefixDirs.add(line.substring(3,
            line.length - 1)); // **/android/app/release/ -> android/app/release
      } else if (line.startsWith('/')) {
        prefixDirs.add(line.substring(1,
            line.length - 1)); // /android/app/release/ -> android/app/release
      } else {
        prefixDirs.add(line.substring(
            0, line.length - 1)); // android/app/release/ -> android/app/release
      }
    } else {
      exactFiles.add(line); // pubspec.lock
    }
  }
  return IgnoreRules(exactDirs, exactFiles, extensions, prefixDirs);
}

// Helper: Find project root by searching for pubspec.yaml upwards
Directory findProjectRoot() {
  var dir = Directory.current;
  while (true) {
    if (File('${dir.path}/pubspec.yaml').existsSync()) {
      return dir;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break; // reached filesystem root
    dir = parent;
  }
  throw Exception('pubspec.yaml not found in this or any parent directory.');
}

Future<void> handleZipCommand() async {
  // Switch to project root if not already there
  try {
    final root = findProjectRoot();
    if (Directory.current.path != root.path) {
      kLog('📂 Switching to project root: \n${root.path}', type: LogType.info);
      Directory.current = root.path;
      kLog('✅ Now in directory: ${Directory.current.path}', type: LogType.info);
    }
  } catch (e) {
    kLog(
        '❗This command must be run inside a Flutter project (pubspec.yaml not found).',
        type: LogType.error);
    exit(1);
  }

  // If on MacOS and ios/ exists, run 'pod deintegrate' before zipping
  if (Platform.isMacOS && Directory('ios').existsSync()) {
    await runWithSpinner('🧹 Running pod deintegrate in ios/ ...', () async {
      final deintegrateResult =
          await Process.run('pod', ['deintegrate'], workingDirectory: 'ios');
      if (deintegrateResult.exitCode != 0) {
        kLog('❌ pod deintegrate failed: \n${deintegrateResult.stderr}',
            type: LogType.error);
        exit(1);
      }
      kLog('✅ pod deintegrate completed.', type: LogType.success);
    });
  }
  // Run 'flutter clean' before starting zip
  await runWithSpinner('🧹 Running flutter clean before zipping...', () async {
    final cleanResult = await Process.run('flutter', ['clean']);
    if (cleanResult.exitCode != 0) {
      kLog('❌ flutter clean failed: ${cleanResult.stderr}',
          type: LogType.error);
      exit(1);
    }
    kLog('✅ flutter clean completed.', type: LogType.success);
  });

  if (!await File('pubspec.yaml').exists()) {
    kLog('❗This command must be run inside a Flutter project root.',
        type: LogType.error);
    exit(1);
  }

  final content = await File('pubspec.yaml').readAsString();
  final yaml = loadYaml(content);
  final projectName = yaml['name'] as String? ?? 'project';

  // --- IMPROVEMENT: Add date and time to the filename ---
  final now = DateTime.now();
  final date =
      '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  final hour = now.hour.toString().padLeft(2, '0');
  final minute = now.minute.toString().padLeft(2, '0');
  final zipFileName = '$projectName-$date-$hour-$minute.zip';

  String? home = Platform.isWindows
      ? Platform.environment['USERPROFILE']
      : Platform.environment['HOME'];
  String defaultPath =
      home != null ? p.join(home, 'Desktop') : Directory.current.path;

  stdout.write('Enter save location (default: Desktop): ');
  String? location = stdin.readLineSync()?.trim();
  if (location == null || location.isEmpty) {
    location = defaultPath;
  }
  final outputPath = p.join(location, zipFileName);

  try {
    await runWithSpinner('📦 Creating clean ZIP archive...', () async {
      final encoder = ZipFileEncoder();
      encoder.create(outputPath);

      final rules = _readGitignore();
      final projectDir = Directory.current;
      final entities = projectDir.listSync(recursive: true, followLinks: false);

      for (final entity in entities) {
        final relativePath = p.relative(entity.path, from: projectDir.path);
        final parts = relativePath.split(p.separator);
        final entityName = p.basename(relativePath);

        // --- IMPROVEMENT: Better ignore logic ---
        bool shouldIgnore = rules.prefixDirs.any((prefix) =>
                relativePath.startsWith(prefix)) || // NEW: ignore by prefix dir
            parts.any((part) =>
                    part.startsWith('.') || // Ignore hidden files/folders
                    rules.exactDirs
                        .contains(part) // Ignore exact directory names
                ) ||
            rules.exactFiles.contains(entityName) || // Ignore exact filenames
            rules.extensions
                .any((ext) => entityName.endsWith(ext)); // Ignore by extension

        if (!shouldIgnore && entity is File) {
          encoder.addFileSync(entity, p.join(projectName, relativePath));
        }
      }
      encoder.close();
    });

    kLog('✅ ZIP file created successfully!', type: LogType.success);
    kLog('📁 Location: $outputPath', type: LogType.info);
  } catch (e) {
    kLog('❌ An error occurred while creating ZIP: $e', type: LogType.error);
    exit(1);
  }
}
