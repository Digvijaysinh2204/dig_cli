// file: lib/src/commands/zip_command.dart

import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../utils/logger.dart';
import '../utils/project_utils.dart';
import '../utils/spinner.dart';

class IgnoreRules {
  final Set<String> exactDirs;
  final Set<String> exactFiles;
  final Set<String> extensions;

  IgnoreRules(this.exactDirs, this.exactFiles, this.extensions);
}

IgnoreRules _readGitignore() {
  final file = File('.gitignore');
  if (!file.existsSync()) {
    kLog('⚠️ .gitignore not found. ZIP may include unnecessary files.',
        type: LogType.warning);
    return IgnoreRules({}, {}, {});
  }

  final lines = file.readAsLinesSync();
  final exactDirs = <String>{};
  final exactFiles = <String>{};
  final extensions = <String>{};

  for (var line in lines) {
    line = line.trim();
    if (line.isEmpty || line.startsWith('#') || line.startsWith('!')) continue;

    if (line.startsWith('*.')) {
      extensions.add(line.substring(1));
    } else if (line.endsWith('/')) {
      exactDirs.add(line.substring(0, line.length - 1));
    } else {
      exactFiles.add(line);
    }
  }
  return IgnoreRules(exactDirs, exactFiles, extensions);
}

Future<void> handleZipCommand() async {
  final root = findProjectRoot();

  if (root == null) {
    kLog('❗ This command must be run inside a Flutter project.',
        type: LogType.error);
    exit(1);
  }
  Directory.current = root;

  try {
    // Run 'flutter clean' before starting zip
    await runWithSpinner('🧹 Running flutter clean before zipping...',
        () async {
      final cleanResult = await Process.run('flutter', ['clean']);
      if (cleanResult.exitCode != 0) {
        throw Exception('flutter clean failed: ${cleanResult.stderr}');
      }
    });

    final content = await File('pubspec.yaml').readAsString();
    final yaml = loadYaml(content);
    final projectName = yaml['name'] as String? ?? 'project';

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

        bool shouldIgnore = parts.any((part) =>
                part.startsWith('.') || rules.exactDirs.contains(part)) ||
            rules.exactFiles.contains(entityName) ||
            rules.extensions.any((ext) => entityName.endsWith(ext));

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
