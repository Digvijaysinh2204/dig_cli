#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';
import 'package:args/args.dart';
import 'package:ansicolor/ansicolor.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as p;

const String appName = 'dig_cli';
const String appVersion = '0.0.1';
const String minFlutterVersion = '3.0.0';

final AnsiPen infoPen = AnsiPen()..blue();
final AnsiPen successPen = AnsiPen()..green();
final AnsiPen warningPen = AnsiPen()..yellow();
final AnsiPen errorPen = AnsiPen()..red();

void printInfo(String message) => print(infoPen(message));
void printSuccess(String message) => print(successPen(message));
void printWarning(String message) => print(warningPen(message));
void printError(String message) => stderr.writeln(errorPen(message));

Future<void> main(List<String> arguments) async {
  // Flutter version check
  await _checkFlutterVersion(minRequired: minFlutterVersion);

  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help')
    ..addFlag('version', abbr: 'v', negatable: false, help: 'Show version')
    ..addOption('output',
        abbr: 'o',
        help: 'Specify output directory for build products (default: Desktop)')
    ..addOption('name',
        abbr: 'n',
        help:
            'Custom name prefix for the build output file (overrides project name)');

  ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } catch (e) {
    printError('❌ Invalid arguments: $e');
    printInfo(parser.usage);
    exit(64);
  }

  if (argResults['help'] as bool) {
    await _showHelp(parser.usage);
    return;
  }
  if (argResults['version'] as bool) {
    await _showVersion();
    return;
  }

  final outputDir = argResults['output'] != null &&
          (argResults['output'] as String).isNotEmpty
      ? argResults['output'] as String
      : await _getDesktopPath();

  final customName =
      argResults['name'] != null && (argResults['name'] as String).isNotEmpty
          ? argResults['name'] as String
          : null;

  if (argResults.rest.isEmpty) {
    _showUsage();
    return;
  }

  final command = argResults.rest[0];
  final subcommand = argResults.rest.length > 1 ? argResults.rest[1] : null;

  try {
    if (command == 'create' && (subcommand == 'build' || subcommand == 'apk')) {
      await _createBuild(outputDir, customName);
    } else if (command == 'create' && subcommand == 'bundle') {
      await _createBundle(outputDir, customName);
    } else if (command == 'clear' || command == 'clean') {
      await _clearBuild();
    } else if (command == 'alias') {
      _printAliasInstructions();
    } else if (command == 'version') {
      await _showVersion();
    } else if (command == 'help') {
      await _showHelp(parser.usage);
    } else {
      _showUsage();
    }
  } catch (e) {
    printError('❌ Error: $e');
    _showUsage();
    exit(1);
  }
}

Future<bool> _checkFlutterVersion({required String minRequired}) async {
  try {
    final result = await Process.run('flutter', ['--version', '--machine']);
    if (result.exitCode != 0) {
      printWarning('⚠️ Unable to run Flutter to check version.');
      return false;
    }
    final jsonResult = jsonDecode(result.stdout);
    final versionString = jsonResult['frameworkVersion'] as String?;
    if (versionString == null) {
      printWarning('⚠️ Flutter version info not found.');
      return false;
    }
    if (_compareVersion(versionString, minRequired) < 0) {
      printWarning(
          '⚠️ Your Flutter version ($versionString) is older than required ($minRequired).');
      printWarning('Please consider updating Flutter for best compatibility.');
      return false;
    }
    return true;
  } catch (e) {
    printWarning('⚠️ Failed to check Flutter version: $e');
    return false;
  }
}

/// Compares semantic versions, returns:
/// -1 if v1 < v2
///  0 if equal
///  1 if v1 > v2
int _compareVersion(String v1, String v2) {
  List<int> parseVersion(String v) =>
      v.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  final a = parseVersion(v1);
  final b = parseVersion(v2);
  for (int i = 0; i < a.length && i < b.length; i++) {
    if (a[i] < b[i]) return -1;
    if (a[i] > b[i]) return 1;
  }
  if (a.length < b.length) return -1;
  if (a.length > b.length) return 1;
  return 0;
}

Future<void> _showVersion() async {
  printInfo(
      '''\n📦 $appName v$appVersion\n🚀 Flutter CLI Tool for Building & Cleaning Projects\n📱 Cross-platform support (Windows, macOS, Linux)\n⏰ Built with Dart & Flutter\n''');
}

Future<void> _showHelp(String usage) async {
  printInfo('''\n📖 $appName Help (v$appVersion)\n
USAGE:
  dig_cli <command> [options]

COMMANDS:
  create apk      Build APK with date-time, move to Desktop or custom directory
  create build    Same as create apk (backward compatibility)
  create bundle   Build app bundle (AAB) with date-time, move to Desktop or custom directory
  clean           Clean Flutter iOS and Android builds
  clear build     Same as clean
  alias           Show alias setup instructions
  version         Show version information
  help            Show this help message

OPTIONS:
  -h, --help      Show help
  -v, --version   Show version
  -o, --output    Specify output directory
  -n, --name      Custom name prefix for output file (overrides project name)

EXAMPLES:
  dig_cli create apk --name MyApp      # Build APK with custom prefix
  dig_cli create bundle                # Build AAB with project name prefix
  dig_cli clean                       # Clean project
  dig_cli alias                       # Setup custom alias

For more information, visit: https://github.com/yourusername/dig_cli
$usage
''');
}

Future<void> _createBuild(String outputDir, String? customName) async {
  try {
    final projectName = customName ?? await _getProjectName();
    if (projectName == null || projectName.isEmpty) {
      printError(
          '❗ Project name not found in pubspec.yaml and no custom name provided!');
      printWarning(
          '💡 Make sure you provide --name option or run inside a Flutter project.');
      exit(1);
    }

    final now = DateTime.now();
    final date =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    final time = _formatTime(now).replaceAll(':', '.');
    final filename = '$projectName-$date-$time.apk';
    final src =
        p.join('build', 'app', 'outputs', 'flutter-apk', 'app-release.apk');

    printInfo('🚧 Building APK (release)...');
    printInfo('📱 Project: $projectName');
    printInfo('📅 Date: $date');
    printInfo('⏰ Time: $time');

    final result = await Process.run('flutter', ['build', 'apk', '--release']);
    if (result.exitCode != 0) {
      printError('❗ Build failed: ${result.stderr}');
      printWarning(
          '💡 Check your Flutter installation and project configuration.');
      exit(1);
    }

    final srcFile = File(src);
    if (!await srcFile.exists()) {
      printError('❗ Build failed. APK not found at: $src');
      printWarning('💡 Check if the build completed successfully.');
      exit(1);
    }

    final destFile = File(p.join(outputDir, filename));
    await srcFile.copy(destFile.path);
    await srcFile.delete();

    final fileSize = await destFile.length();
    final sizeInMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);

    printSuccess('✅ APK created successfully!');
    printInfo('📁 Location: ${destFile.path}');
    printInfo('📊 Size: ${sizeInMB}MB');
  } catch (e) {
    printError('❌ Error during APK build: $e');
    exit(1);
  }
}

Future<void> _createBundle(String outputDir, String? customName) async {
  try {
    final projectName = customName ?? await _getProjectName();
    if (projectName == null || projectName.isEmpty) {
      printError(
          '❗ Project name not found in pubspec.yaml and no custom name provided!');
      printWarning(
          '💡 Make sure you provide --name option or run inside a Flutter project.');
      exit(1);
    }

    final now = DateTime.now();
    final date =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    final time = _formatTime(now).replaceAll(':', '.');
    final filename = '$projectName-$date-$time.aab';
    final src = p.join(
        'build', 'app', 'outputs', 'bundle', 'release', 'app-release.aab');

    printInfo('🚧 Building App Bundle (release)...');
    printInfo('📱 Project: $projectName');
    printInfo('📅 Date: $date');
    printInfo('⏰ Time: $time');

    final result =
        await Process.run('flutter', ['build', 'appbundle', '--release']);
    if (result.exitCode != 0) {
      printError('❗ Build failed: ${result.stderr}');
      printWarning(
          '💡 Check your Flutter installation and project configuration.');
      exit(1);
    }

    final srcFile = File(src);
    if (!await srcFile.exists()) {
      printError('❗ Build failed. Bundle not found at: $src');
      printWarning('💡 Check if the build completed successfully.');
      exit(1);
    }

    final destFile = File(p.join(outputDir, filename));
    await srcFile.copy(destFile.path);
    await srcFile.delete();

    final fileSize = await destFile.length();
    final sizeInMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);

    printSuccess('✅ App Bundle created successfully!');
    printInfo('📁 Location: ${destFile.path}');
    printInfo('📊 Size: ${sizeInMB}MB');
  } catch (e) {
    printError('❌ Error during AAB build: $e');
    exit(1);
  }
}

Future<void> _clearBuild() async {
  try {
    final now = DateTime.now();
    final startTime =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} ${_formatTime(now)}';

    printInfo('🚀 Flutter iOS + Android Project Cleaner');
    printInfo('⏰ Started at $startTime');
    printInfo('🗂 Current Directory: ${Directory.current.path}');
    printInfo(
        '🖥️ Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');

    final pubspecFile = File('pubspec.yaml');
    if (!await pubspecFile.exists()) {
      printWarning(
          '⚠️ Warning: No pubspec.yaml found. Are you in a Flutter project?');
    }

    printInfo('📦 Pre-caching Flutter iOS artifacts...');
    await Process.run('flutter', ['precache', '--ios']);

    printInfo('🧹 Cleaning Flutter...');
    await Process.run('flutter', ['clean']);

    final buildDir = Directory('build');
    if (await buildDir.exists()) {
      await buildDir.delete(recursive: true);
      printInfo('🗑️ Removed build directory');
    }

    printInfo('📦 Getting Dart packages...');
    await Process.run('flutter', ['pub', 'get']);

    if (Platform.isMacOS) {
      final iosDir = Directory('ios');
      if (await iosDir.exists()) {
        printInfo('🧼 iOS: Cleaning workspace, Pods, build, symlinks...');
        final iosPath = iosDir.path;
        await _deleteIfExists(p.join(iosPath, '.symlinks'));
        await _deleteIfExists(p.join(iosPath, 'Podfile.lock'));
        await _deleteIfExists(p.join(iosPath, 'Pods'));
        await _deleteIfExists(p.join(iosPath, 'build'));

        final derivedDataDir = Directory(p.join(iosPath, 'DerivedData'));
        if (await derivedDataDir.exists()) {
          await derivedDataDir.delete(recursive: true);
          printInfo('✅ Removed local iOS/DerivedData inside ios/');
        }

        printInfo('📥 Installing CocoaPods...');
        await Process.run('pod', ['install'], workingDirectory: iosPath);
      }

      final home = Platform.environment['HOME'];
      if (home != null) {
        final globalDerivedData = Directory(
          p.join(home, 'Library', 'Developer', 'Xcode', 'DerivedData'),
        );
        if (await globalDerivedData.exists()) {
          await globalDerivedData.delete(recursive: true);
          printInfo('✅ Removed global Xcode DerivedData');
        } else {
          printInfo('ℹ️ No global DerivedData found');
        }
      }
    } else {
      printInfo('ℹ️ Skipping iOS cleanup (not on macOS)');
    }

    final androidDir = Directory('android');
    if (await androidDir.exists()) {
      printInfo('🧼 Android: Removing build and cache directories...');
      await _deleteIfExists(p.join('android', '.gradle'));
      await _deleteIfExists(p.join('android', '.kotlin'));
      await _deleteIfExists(p.join('android', 'app', '.cxx'));
      await _deleteIfExists(p.join('android', 'build'));
      await _deleteIfExists(p.join('android', 'app', 'build'));
    }

    printSuccess('✅ All Clean! Flutter, iOS & Android project reset complete.');
    printSuccess('🎉 Your project is ready for a fresh build!');
  } catch (e) {
    printError('❌ Error during cleanup: $e');
    exit(1);
  }
}

Future<String?> _getProjectName() async {
  try {
    final pubspecFile = File('pubspec.yaml');
    if (!await pubspecFile.exists()) return null;
    final content = await pubspecFile.readAsString();
    final yaml = loadYaml(content);
    return yaml['name'] as String?;
  } catch (e) {
    return null;
  }
}

Future<String> _getDesktopPath() async {
  String? home;
  if (Platform.isWindows) {
    home = Platform.environment['USERPROFILE'];
  } else {
    home = Platform.environment['HOME'];
  }
  if (home == null) {
    throw Exception('Could not find home directory.');
  }
  final desktop = Directory(p.join(home, 'Desktop'));
  if (await desktop.exists()) {
    return desktop.path;
  }
  return p.join(home, 'Desktop');
}

Future<void> _deleteIfExists(String path) async {
  final entity = Directory(path);
  if (await entity.exists()) {
    await entity.delete(recursive: true);
  } else {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

String _formatTime(DateTime time) {
  final hour = (time.hour > 12
      ? time.hour - 12
      : (time.hour == 0 ? 12 : time.hour)); // 12h format
  final minute = time.minute.toString().padLeft(2, '0');
  final ampm = time.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $ampm ${time.timeZoneName}';
}

void _showUsage() {
  printError('❓ Unknown command');
  printError('Usage:');
  printError(
      '  dig_cli create apk      # Build APK with date-time, move to Desktop');
  printError(
      '  dig_cli create build    # Same as create apk (for backward compatibility)');
  printError(
      '  dig_cli create bundle   # Build app bundle (AAB) with date-time, move to Desktop');
  printError(
      '  dig_cli clear build     # Clean Flutter iOS and Android builds');
  printError('  dig_cli clean           # Same as \'dig_cli clear build\'');
  printError('  dig_cli help            # Show detailed help');
  printError('  dig_cli version         # Show version information');
  printError('  dig_cli --output <dir>  # Specify output directory [optional]');
  printError(
      '  dig_cli --name <name>   # Custom name prefix for build output [optional]');
}

void _printAliasInstructions() {
  printInfo('''
To use this tool with a custom command (alias), add this to your shell profile:

  alias dig="dig_cli"

You can change "dig" to any name you want.
After adding, restart your terminal or run: source ~/.zshrc or source ~/.bashrc
''');
}
