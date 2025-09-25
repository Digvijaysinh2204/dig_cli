// file: lib/src/commands/build_command.dart

import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../utils/logger.dart';
import '../utils/spinner.dart';

Future<void> handleBuildCommand(List<String> args) async {
  final parser = ArgParser()
    ..addOption('output', abbr: 'o', help: 'Specify output directory')
    ..addOption('name',
        abbr: 'n', help: 'Custom name prefix for the output file');

  final argResults = parser.parse(args);
  final buildType = argResults.rest.isNotEmpty ? argResults.rest.first : 'apk';

  final outputDir = argResults['output'] as String? ?? await _getDesktopPath();
  final customName = argResults['name'] as String?;

  if (buildType == 'apk' || buildType == 'build') {
    await _runBuildProcess(
      outputDir: outputDir,
      customName: customName,
      buildType: 'APK',
      buildArgs: ['build', 'apk', '--release'],
      sourcePath:
          p.join('build', 'app', 'outputs', 'flutter-apk', 'app-release.apk'),
      fileExtension: 'apk',
    );
  } else if (buildType == 'bundle') {
    await _runBuildProcess(
      outputDir: outputDir,
      customName: customName,
      buildType: 'App Bundle',
      buildArgs: ['build', 'appbundle', '--release'],
      sourcePath: p.join(
          'build', 'app', 'outputs', 'bundle', 'release', 'app-release.aab'),
      fileExtension: 'aab',
    );
  } else {
    kLog('Unknown build type: "$buildType". Use "apk" or "bundle".',
        type: LogType.error);
    exit(64);
  }
}

Future<void> _runBuildProcess({
  required String outputDir,
  String? customName,
  required String buildType,
  required List<String> buildArgs,
  required String sourcePath,
  required String fileExtension,
}) async {
  if (!await _isFlutterProject()) {
    kLog('❗ This command must be run inside a Flutter project.',
        type: LogType.error);
    exit(1);
  }

  try {
    final projectName = customName ?? await _getProjectName();
    if (projectName == null || projectName.isEmpty) {
      kLog('❗ Project name not found and no custom name was provided!',
          type: LogType.error);
      exit(1);
    }

    final now = DateTime.now();
    final date =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final filename = '$projectName-$date-$hour-$minute.$fileExtension';

    kLog('📱 APP PREFIX: $projectName');
    kLog('📅 Date: $date @ $hour:$minute');

    final result = await runWithSpinner(
      '🚧 Building $buildType (release)...',
      () => Process.run('flutter', buildArgs),
    );

    if (result.exitCode != 0) {
      kLog('❗ Build failed. See error below:', type: LogType.error);
      stderr.writeln(result.stderr);
      exit(1);
    }

    final srcFile = File(sourcePath);
    if (!await srcFile.exists()) {
      kLog('❗ Build failed. Output file not found at: $sourcePath',
          type: LogType.error);
      exit(1);
    }

    final destFile = File(p.join(outputDir, filename));
    await srcFile.copy(destFile.path);
    await srcFile.delete();

    final fileSize = await destFile.length();
    final sizeInMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);

    kLog('✅ $buildType created successfully!', type: LogType.success);
    kLog('📁 Location: ${destFile.path}', type: LogType.info);
    kLog('📊 Size: ${sizeInMB}MB', type: LogType.info);
  } catch (e) {
    kLog('❌ An unexpected error occurred during the build: $e',
        type: LogType.error);
    exit(1);
  }
}

Future<String?> _getProjectName() async {
  final pubspecFile = File('pubspec.yaml');
  if (!await pubspecFile.exists()) return null;
  final content = await pubspecFile.readAsString();
  final yaml = loadYaml(content);
  return yaml['name'] as String?;
}

Future<bool> _isFlutterProject() async {
  final pubspecFile = File('pubspec.yaml');
  return await pubspecFile.exists();
}

Future<String> _getDesktopPath() async {
  String? home = Platform.isWindows
      ? Platform.environment['USERPROFILE']
      : Platform.environment['HOME'];
  if (home == null) throw Exception('Could not find home directory.');
  return p.join(home, 'Desktop');
}
