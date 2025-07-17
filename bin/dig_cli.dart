#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';
import 'package:args/args.dart';
import 'package:ansicolor/ansicolor.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as p;
import 'version.dart';
import 'package:http/http.dart' as http;
import 'package:pub_semver/pub_semver.dart';

final AnsiPen _infoPen = AnsiPen()..blue();
final AnsiPen _successPen = AnsiPen()..green();
final AnsiPen _warningPen = AnsiPen()..yellow();
final AnsiPen _errorPen = AnsiPen()..red();

void kLog(String message, {String type = 'info'}) {
  switch (type) {
    case 'success':
      print(_successPen(message));
      break;
    case 'warning':
      print(_warningPen(message));
      break;
    case 'error':
      stderr.writeln(_errorPen(message));
      break;
    default:
      print(_infoPen(message));
  }
}

Future<String> _getVersion() async {
  return kDigCliVersion;
}

Future<bool> _isFlutterProject() async {
  final pubspecFile = File('pubspec.yaml');
  if (!await pubspecFile.exists()) return false;
  final content = await pubspecFile.readAsString();
  final yaml = loadYaml(content);
  // Check for flutter dependency
  final dependencies = yaml['dependencies'];
  if (dependencies is Map && dependencies.containsKey('flutter')) {
    return true;
  }
  // Check for flutter SDK in environment
  final environment = yaml['environment'];
  if (environment is Map && environment.containsKey('flutter')) {
    return true;
  }
  return false;
}

Future<bool> _isBetaInstalled() async {
  // Try to detect if installed from GitHub (beta)
  // Option 1: Check if version string contains 'beta'
  final version = await _getVersion();
  if (version.toLowerCase().contains('beta')) return true;
  // Option 2: Check pub cache path for 'git' (fallback)
  final execPath = Platform.resolvedExecutable;
  if (execPath.contains('git')) return true;
  return false;
}

Future<void> main(List<String> arguments) async {
  // Flutter version check
  await _checkFlutterVersion(minRequired: kMinFlutterVersion);

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
    kLog('❌ Invalid arguments: $e', type: 'error');
    kLog(parser.usage, type: 'info');
    exit(64);
  }

  // If no arguments, show interactive menu
  if (arguments.isEmpty) {
    await _showInteractiveMenu();
    return;
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
    kLog('❌ Error: $e', type: 'error');
    _showUsage();
    exit(1);
  }
}

Future<String?> _getLatestStableVersion() async {
  try {
    final url = 'https://pub.dev/api/packages/dig_cli';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['latest']['version'] as String?;
    }
  } catch (_) {}
  return null;
}

Future<String?> _getLatestBetaVersion() async {
  try {
    final url = 'https://api.github.com/repos/Digvijaysinh2204/dig_cli/tags';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final tags = jsonDecode(response.body) as List<dynamic>;
      if (tags.isNotEmpty) {
        // Parse all tags as Version, filter out invalid ones
        final versions = tags
            .map((t) => t['name'] as String)
            .map((name) {
              // Remove leading 'v' or 'V'
              final clean = name.replaceFirst(RegExp(r'^[vV]'), '');
              try {
                return Version.parse(clean);
              } catch (_) {
                return null;
              }
            })
            .whereType<Version>()
            .toList();
        if (versions.isNotEmpty) {
          versions.sort();
          final betaVersions = versions.where((v) => v.isPreRelease).toList();
          if (betaVersions.isNotEmpty) {
            betaVersions.sort();
            return betaVersions.last.toString();
          } else if (versions.isNotEmpty) {
            versions.sort();
            return versions.last.toString();
          }
        }
      }
    }
  } catch (_) {}
  return null;
}

Future<Map<String, String>> _promptBuildNameAndLocation(String ext) async {
  String defaultBuildName = (await _getProjectName()) ?? 'MyBuild';
  stdout.write(
      'Enter build name (or press Enter to use default [$defaultBuildName]): ');
  String? buildName = stdin.readLineSync();
  buildName = buildName?.trim();
  if (buildName == null || buildName.isEmpty) {
    buildName = defaultBuildName;
  }
  stdout.write('Enter location path to save (or press Enter for Desktop): ');
  String? location = stdin.readLineSync();
  location = location?.trim();
  if (location == null || location.isEmpty) {
    location = await _getDesktopPath();
  }
  // No filename construction here
  return {'buildName': buildName, 'location': location};
}

Future<void> _showInteractiveMenu() async {
  String? latestStable = await _getLatestStableVersion();
  String? latestBeta = await _getLatestBetaVersion();

  bool showStableUpdate = false;
  bool showBetaUpdate = false;

  // Only show stable update if a newer stable exists
  if (latestStable != null && isUpdateAvailable(kDigCliVersion, latestStable)) {
    showStableUpdate = true;
  }
  // Only show beta update if a newer beta exists
  if (latestBeta != null) {
    final currentVersion = Version.parse(kDigCliVersion.replaceFirst(RegExp(r'^[vV]'), '').trim());
    final latestVersion = Version.parse(latestBeta.replaceFirst(RegExp(r'^[vV]'), '').trim());
    print('DEBUG: current=$currentVersion, latestBeta=$latestVersion');
    if (latestVersion > currentVersion) {
      showBetaUpdate = true;
    }
  }

  final isBeta = await _isBetaInstalled();
  final canSwitchBetaToStable = isBeta && latestStable != null;

  final menuOptions = <int, Map<String, dynamic>>{};
  int idx = 1;
  menuOptions[idx++] = {
    'label': 'Build APK',
    'action': () async {
      final result = await _promptBuildNameAndLocation('apk');
      await _createBuild(result['location']!, result['buildName']!);
    }
  };
  menuOptions[idx++] = {
    'label': 'Build AAB',
    'action': () async {
      final result = await _promptBuildNameAndLocation('aab');
      await _createBundle(result['location']!, result['buildName']!);
    }
  };
  menuOptions[idx++] = {
    'label': 'Clean Project',
    'action': () async => await _clearBuild(),
  };
  menuOptions[idx++] = {
    'label': 'Show Version',
    'action': () async => await _showVersion(),
  };
  if (showStableUpdate) {
    menuOptions[idx++] = {
      'label': 'Update to latest STABLE (pub.dev) [$latestStable]',
      'action': () async {
        kLog('Updating dig_cli to latest STABLE from pub.dev...', type: 'info');
        final result = await Process.run('flutter', ['pub', 'global', 'activate', 'dig_cli']);
        kLog(result.stdout.toString(), type: 'info');
        kLog('Update complete! Please restart the CLI.', type: 'success');
        exit(0);
      }
    };
  }
  if (showBetaUpdate) {
    menuOptions[idx++] = {
      'label': 'Update to latest BETA (GitHub) [$latestBeta]',
      'action': () async {
        kLog('Updating dig_cli to latest BETA from GitHub...', type: 'info');
        final result = await Process.run('flutter', [
          'pub',
          'global',
          'activate',
          '--source',
          'git',
          'https://github.com/Digvijaysinh2204/dig_cli.git'
        ]);
        kLog(result.stdout.toString(), type: 'info');
        kLog('Update complete! Please restart the CLI.', type: 'success');
        exit(0);
      }
    };
  }
  if (canSwitchBetaToStable) {
    menuOptions[idx++] = {
      'label': 'Switch from BETA to STABLE (pub.dev)',
      'action': () async {
        kLog('Switching from BETA to STABLE (pub.dev)...', type: 'info');
        final result = await Process.run('flutter', ['pub', 'global', 'activate', 'dig_cli']);
        kLog(result.stdout.toString(), type: 'info');
        kLog('Switched to STABLE! Please restart the CLI.', type: 'success');
        exit(0);
      }
    };
  }
  for (final entry in menuOptions.entries) {
    kLog('${entry.key}. ${entry.value['label']}', type: 'info');
  }
  kLog('0. Exit', type: 'info');
  stdout.write('Enter your choice (0-${menuOptions.keys.isEmpty ? 0 : menuOptions.keys.last}): ');
  final input = stdin.readLineSync();
  if (input == '0') {
    kLog('Exiting...', type: 'info');
    exit(0);
  }
  final selected = int.tryParse(input ?? '');
  if (selected != null && menuOptions.containsKey(selected)) {
    await menuOptions[selected]!['action']();
  } else {
    kLog('Invalid choice. Please try again.', type: 'warning');
  }
}

Future<bool> _checkFlutterVersion({required String minRequired}) async {
  try {
    final result = await Process.run('flutter', ['--version', '--machine']);
    if (result.exitCode != 0) {
      kLog('⚠️ Unable to run Flutter to check version.', type: 'warning');
      return false;
    }
    final jsonResult = jsonDecode(result.stdout);
    final versionString = jsonResult['frameworkVersion'] as String?;
    if (versionString == null) {
      kLog('⚠️ Flutter version info not found.', type: 'warning');
      return false;
    }
    if (_compareVersion(versionString, minRequired) < 0) {
      kLog(
          '⚠️ Your Flutter version ($versionString) is older than required ($minRequired).',
          type: 'warning');
      kLog('Please consider updating Flutter for best compatibility.',
          type: 'warning');
      return false;
    }
    return true;
  } catch (e) {
    kLog('⚠️ Failed to check Flutter version: $e', type: 'warning');
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

bool isUpdateAvailable(String current, String latest) {
  try {
    final currentVersion = Version.parse(current.replaceFirst(RegExp(r'^[vV]'), ''));
    final latestVersion = Version.parse(latest.replaceFirst(RegExp(r'^[vV]'), ''));
    return latestVersion > currentVersion;
  } catch (_) {
    return false;
  }
}

bool isPreRelease(String version) {
  try {
    final v = Version.parse(version.replaceFirst(RegExp(r'^[vV]'), ''));
    return v.isPreRelease;
  } catch (_) {
    return false;
  }
}

Future<void> _showVersion() async {
  final version = await _getVersion();
  kLog(
      '''\n📦 $kDigCliName v$version\n🚀 Flutter CLI Tool for Building & Cleaning Projects\n📱 Cross-platform support (Windows, macOS, Linux)\n⏰ Built with Dart & Flutter\n''');
}

Future<void> _showHelp(String usage) async {
  final version = await _getVersion();
  kLog('''\n📖 $kDigCliName Help (v$version)\n
USAGE:
  dig <command> [options]

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
  dig create apk --name MyApp      # Build APK with custom prefix
  dig create bundle                # Build AAB with project name prefix
  dig clean                       # Clean project
  dig alias                       # Setup custom alias

For more information, visit: https://github.com/yourusername/dig_cli
$usage
''');
}

Future<void> _createBuild(String outputDir, String? customName) async {
  if (!await _isFlutterProject()) {
    kLog('❗ This command must be run inside a Flutter project.', type: 'error');
    kLog('💡 Make sure pubspec.yaml contains a flutter dependency or SDK.',
        type: 'warning');
    exit(1);
  }
  try {
    final projectName = customName ?? await _getProjectName();
    if (projectName == null || projectName.isEmpty) {
      kLog(
          '❗ Project name not found in pubspec.yaml and no custom name provided!',
          type: 'error');
      kLog(
          '💡 Make sure you provide --name option or run inside a Flutter project.',
          type: 'warning');
      exit(1);
    }

    final now = DateTime.now();
    final date =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final filename = '$projectName-$date-$hour-$minute.apk';
    final src =
        p.join('build', 'app', 'outputs', 'flutter-apk', 'app-release.apk');

    kLog('🚧 Building APK (release)...', type: 'info');
    kLog('📱 Project: $projectName', type: 'info');
    kLog('📅 Date: $date', type: 'info');
    kLog('⏰ Time: $hour:$minute', type: 'info');

    final result = await Process.run('flutter', ['build', 'apk', '--release']);
    if (result.exitCode != 0) {
      kLog('❗ Build failed: ${result.stderr}', type: 'error');
      kLog('💡 Check your Flutter installation and project configuration.',
          type: 'warning');
      exit(1);
    }

    final srcFile = File(src);
    if (!await srcFile.exists()) {
      kLog('❗ Build failed. APK not found at: $src', type: 'error');
      kLog('💡 Check if the build completed successfully.', type: 'warning');
      exit(1);
    }

    final destFile = File(p.join(outputDir, filename));
    await srcFile.copy(destFile.path);
    await srcFile.delete();

    final fileSize = await destFile.length();
    final sizeInMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);

    kLog('✅ APK created successfully!', type: 'success');
    kLog('📁 Location: ${destFile.path}', type: 'info');
    kLog('📊 Size: ${sizeInMB}MB', type: 'info');
  } catch (e) {
    kLog('❌ Error during APK build: $e', type: 'error');
    exit(1);
  }
}

Future<void> _createBundle(String outputDir, String? customName) async {
  if (!await _isFlutterProject()) {
    kLog('❗ This command must be run inside a Flutter project.', type: 'error');
    kLog('💡 Make sure pubspec.yaml contains a flutter dependency or SDK.',
        type: 'warning');
    exit(1);
  }
  try {
    final projectName = customName ?? await _getProjectName();
    if (projectName == null || projectName.isEmpty) {
      kLog(
          '❗ Project name not found in pubspec.yaml and no custom name provided!',
          type: 'error');
      kLog(
          '💡 Make sure you provide --name option or run inside a Flutter project.',
          type: 'warning');
      exit(1);
    }

    final now = DateTime.now();
    final date =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final filename = '$projectName-$date-$hour-$minute.aab';
    final src = p.join(
        'build', 'app', 'outputs', 'bundle', 'release', 'app-release.aab');

    kLog('🚧 Building App Bundle (release)...', type: 'info');
    kLog('📱 Project: $projectName', type: 'info');
    kLog('📅 Date: $date', type: 'info');
    kLog('⏰ Time: $hour:$minute', type: 'info');

    final result =
        await Process.run('flutter', ['build', 'appbundle', '--release']);
    if (result.exitCode != 0) {
      kLog('❗ Build failed: ${result.stderr}', type: 'error');
      kLog('💡 Check your Flutter installation and project configuration.',
          type: 'warning');
      exit(1);
    }

    final srcFile = File(src);
    if (!await srcFile.exists()) {
      kLog('❗ Build failed. Bundle not found at: $src', type: 'error');
      kLog('💡 Check if the build completed successfully.', type: 'warning');
      exit(1);
    }

    final destFile = File(p.join(outputDir, filename));
    await srcFile.copy(destFile.path);
    await srcFile.delete();

    final fileSize = await destFile.length();
    final sizeInMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);

    kLog('✅ App Bundle created successfully!', type: 'success');
    kLog('📁 Location: ${destFile.path}', type: 'info');
    kLog('📊 Size: ${sizeInMB}MB', type: 'info');
  } catch (e) {
    kLog('❌ Error during AAB build: $e', type: 'error');
    exit(1);
  }
}

Future<void> _clearBuild() async {
  if (!await _isFlutterProject()) {
    kLog('❗ This command must be run inside a Flutter project.', type: 'error');
    kLog('💡 Make sure pubspec.yaml contains a flutter dependency or SDK.',
        type: 'warning');
    exit(1);
  }
  try {
    final now = DateTime.now();
    final startTime =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} ${_formatTime(now)}';

    kLog('🚀 Flutter iOS + Android Project Cleaner', type: 'info');
    kLog('⏰ Started at $startTime', type: 'info');
    kLog('🗂 Current Directory: ${Directory.current.path}', type: 'info');
    kLog(
        '🖥️ Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
        type: 'info');

    final pubspecFile = File('pubspec.yaml');
    if (!await pubspecFile.exists()) {
      kLog('⚠️ Warning: No pubspec.yaml found. Are you in a Flutter project?',
          type: 'warning');
    }

    kLog('📦 Pre-caching Flutter iOS artifacts...', type: 'info');
    await Process.run('flutter', ['precache', '--ios']);

    kLog('🧹 Cleaning Flutter...', type: 'info');
    await Process.run('flutter', ['clean']);

    final buildDir = Directory('build');
    if (await buildDir.exists()) {
      await buildDir.delete(recursive: true);
      kLog('🗑️ Removed build directory', type: 'info');
    }

    kLog('📦 Getting Dart packages...', type: 'info');
    await Process.run('flutter', ['pub', 'get']);

    if (Platform.isMacOS) {
      final iosDir = Directory('ios');
      if (await iosDir.exists()) {
        kLog('🧼 iOS: Cleaning workspace, Pods, build, symlinks...',
            type: 'info');
        final iosPath = iosDir.path;
        await _deleteIfExists(p.join(iosPath, '.symlinks'));
        await _deleteIfExists(p.join(iosPath, 'Podfile.lock'));
        await _deleteIfExists(p.join(iosPath, 'Pods'));
        await _deleteIfExists(p.join(iosPath, 'build'));

        final derivedDataDir = Directory(p.join(iosPath, 'DerivedData'));
        if (await derivedDataDir.exists()) {
          await derivedDataDir.delete(recursive: true);
          kLog('✅ Removed local iOS/DerivedData inside ios/', type: 'info');
        }

        kLog('📥 Installing CocoaPods...', type: 'info');
        await Process.run('pod', ['install'], workingDirectory: iosPath);
      }

      final home = Platform.environment['HOME'];
      if (home != null) {
        final globalDerivedData = Directory(
          p.join(home, 'Library', 'Developer', 'Xcode', 'DerivedData'),
        );
        if (await globalDerivedData.exists()) {
          await globalDerivedData.delete(recursive: true);
          kLog('✅ Removed global Xcode DerivedData', type: 'info');
        } else {
          kLog('ℹ️ No global DerivedData found', type: 'info');
        }
      }
    } else {
      kLog('ℹ️ Skipping iOS cleanup (not on macOS)', type: 'info');
    }

    final androidDir = Directory('android');
    if (await androidDir.exists()) {
      kLog('🧼 Android: Removing build and cache directories...', type: 'info');
      await _deleteIfExists(p.join('android', '.gradle'));
      await _deleteIfExists(p.join('android', '.kotlin'));
      await _deleteIfExists(p.join('android', 'app', '.cxx'));
      await _deleteIfExists(p.join('android', 'build'));
      await _deleteIfExists(p.join('android', 'app', 'build'));
    }

    kLog('✅ All Clean! Flutter, iOS & Android project reset complete.',
        type: 'success');
    kLog('🎉 Your project is ready for a fresh build!', type: 'success');
  } catch (e) {
    kLog('❌ Error during cleanup: $e', type: 'error');
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
  kLog('❓ Unknown command', type: 'error');
  kLog('Usage:', type: 'error');
  kLog('  dig create apk      # Build APK with date-time, move to Desktop',
      type: 'error');
  kLog(
      '  dig create build    # Same as create apk (for backward compatibility)',
      type: 'error');
  kLog(
      '  dig create bundle   # Build app bundle (AAB) with date-time, move to Desktop',
      type: 'error');
  kLog('  dig clear build     # Clean Flutter iOS and Android builds',
      type: 'error');
  kLog('  dig clean           # Same as \'dig clear build\'', type: 'error');
  kLog('  dig help            # Show detailed help', type: 'error');
  kLog('  dig version         # Show version information', type: 'error');
  kLog('  dig --output <dir>  # Specify output directory [optional]',
      type: 'error');
  kLog('  dig --name <name>   # Custom name prefix for build output [optional]',
      type: 'error');
}

void _printAliasInstructions() {
  kLog('''
To use this tool with a custom command (alias), add this to your shell profile:

  alias dig="dig_cli"

You can change "dig" to any name you want.
After adding, restart your terminal or run: source ~/.zshrc or source ~/.bashrc
''');
}
