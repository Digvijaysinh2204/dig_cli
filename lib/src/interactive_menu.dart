// file: lib/src/interactive_menu.dart

import 'dart:convert';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

import 'commands/build_command.dart';
import 'commands/clean_command.dart';
import 'commands/zip_command.dart';
import 'utils/logger.dart';
import 'version_helper.dart';

// Helper function to get the latest version from pub.dev
Future<String?> _getLatestStableVersion(String currentVersionStr) async {
  try {
    final url = Uri.parse('https://pub.dev/api/packages/dig_cli');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final latestVersion = json['latest']['version'] as String;
      final currentVersion = Version.parse(currentVersionStr);
      final latestSemVer = Version.parse(latestVersion);
      if (latestSemVer > currentVersion) {
        return latestVersion;
      }
    }
  } catch (_) {
    // Fails silently if there is no internet etc.
  }
  return null;
}

// Helper function to run the update process with live output
Future<void> _runUpdateProcess() async {
  kLog('\n🚀 Starting CLI update...', type: LogType.info);
  try {
    final process = await Process.start('dart', [
      'pub',
      'global',
      'activate',
      'dig_cli',
    ]);
    await stdout.addStream(process.stdout);
    await stderr.addStream(process.stderr);
    final exitCode = await process.exitCode;
    if (exitCode == 0) {
      kLog(
        '\n✅ CLI updated successfully! Please restart the tool.',
        type: LogType.success,
      );
    } else {
      kLog('\n❗ Update failed.', type: LogType.error);
    }
  } catch (e) {
    kLog('\n❌ An error occurred: $e', type: LogType.error);
  }
  exit(0);
}

// Helper function to prompt the user for build details
Future<Map<String, String>> _promptBuildDetails() async {
  final pubspecFile = File('pubspec.yaml');
  String defaultName = 'app-build';
  if (await pubspecFile.exists()) {
    final content = await pubspecFile.readAsString();
    final yaml = loadYaml(content);
    defaultName = yaml['name'] as String? ?? 'app-build';
  }

  stdout.write('Enter build name (default: $defaultName): ');
  String? buildName = stdin.readLineSync()?.trim();
  if (buildName == null || buildName.isEmpty) {
    buildName = defaultName;
  }

  String? home = Platform.isWindows
      ? Platform.environment['USERPROFILE']
      : Platform.environment['HOME'];
  String defaultPath = home != null
      ? p.join(home, 'Desktop')
      : Directory.current.path;

  stdout.write('Enter save location (default: Desktop): ');
  String? location = stdin.readLineSync()?.trim();
  if (location == null || location.isEmpty) {
    location = defaultPath;
  }

  return {'name': buildName, 'location': location};
}

// Helper: Find project root by searching for pubspec.yaml upwards
Directory findProjectRoot() {
  var dir = Directory.current;
  while (true) {
    if (File('${dir.path}/pubspec.yaml').existsSync()) {
      return dir;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  throw Exception('pubspec.yaml not found in this or any parent directory.');
}

// The main function to display the beautiful, interactive menu
Future<void> showInteractiveMenu() async {
  final AnsiPen titlePen = AnsiPen()..white(bold: true);
  final AnsiPen optionPen = AnsiPen()..cyan();
  final AnsiPen promptPen = AnsiPen()..yellow();
  final AnsiPen borderPen = AnsiPen()..blue();
  final AnsiPen updatePen = AnsiPen()..green(bold: true);
  final AnsiPen disabledPen = AnsiPen()..gray(level: 0.5);

  final projectRoot = findProjectRoot();
  final isBuildable = await File(
    p.join(projectRoot.path, 'lib/main.dart'),
  ).exists();
  final String currentVersion = kDigCliVersion;

  stdout.write('Checking for updates...');
  final String? latestStable = await _getLatestStableVersion(currentVersion);
  stdout.write('\r${' ' * 25}\r');

  final menuOptions = <int, Map<String, dynamic>>{};
  int optionIndex = 1;

  if (isBuildable) {
    menuOptions[optionIndex++] = {
      'label': '🚀 Build APK',
      'action': () async {
        final details = await _promptBuildDetails();
        await handleBuildCommand([
          'apk',
          '--name',
          details['name']!,
          '--output',
          details['location']!,
        ]);
      },
    };
    menuOptions[optionIndex++] = {
      'label': '📦 Build AAB',
      'action': () async {
        final details = await _promptBuildDetails();
        await handleBuildCommand([
          'bundle',
          '--name',
          details['name']!,
          '--output',
          details['location']!,
        ]);
      },
    };
  }

  menuOptions[optionIndex++] = {
    'label': '🧹 Clean Project',
    'action': () => handleCleanCommand(),
  };
  menuOptions[optionIndex++] = {
    'label': '🤐 Create Project ZIP',
    'action': () => handleZipCommand(),
  };

  if (latestStable != null) {
    menuOptions[optionIndex] = {
      'label': '✨ Update to v$latestStable',
      'action': () => _runUpdateProcess(),
      'isUpdate': true,
    };
  }

  final int totalWidth = 42;
  final String title = 'DIG CLI TOOL v$currentVersion';
  final int titlePaddingTotal = totalWidth - title.length - 2;
  final int titlePaddingLeft = (titlePaddingTotal / 2).floor();
  final int titlePaddingRight = (titlePaddingTotal / 2).ceil();

  final String topBorder = '╔${'═' * (totalWidth - 2)}╗';
  final String middleBorder = '╠${'═' * (totalWidth - 2)}╣';
  final String bottomBorder = '╚${'═' * (totalWidth - 2)}╝';

  print('');
  print(borderPen(topBorder));
  print(
    borderPen('║') +
        ' ' * titlePaddingLeft +
        titlePen(title) +
        ' ' * titlePaddingRight +
        borderPen('║'),
  );
  print(borderPen(middleBorder));

  if (!isBuildable) {
    final warningText = ' Build options hidden: lib/main.dart not found.';
    final int padding = totalWidth - warningText.length - 2;
    print(
      borderPen('║') +
          disabledPen(warningText) +
          ' ' * (padding > 0 ? padding : 0) +
          borderPen('║'),
    );
    print(borderPen(middleBorder));
  }

  void printMenuLine(String text, {bool isUpdate = false}) {
    final AnsiPen pen = isUpdate ? updatePen : optionPen;
    final strippedText = text.replaceAll(
      RegExp(
        r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])',
      ),
      '',
    );
    final int padding = totalWidth - strippedText.length - 5;
    print(
      '${borderPen('║')}  ${pen(text)}${' ' * (padding > 0 ? padding : 0)}${borderPen('║')}',
    );
  }

  final displayOptions = menuOptions.values.toList();
  for (int i = 0; i < displayOptions.length; i++) {
    printMenuLine(
      '${i + 1}. ${displayOptions[i]['label']}',
      isUpdate: displayOptions[i]['isUpdate'] ?? false,
    );
  }
  printMenuLine('0. 🚪 Exit');
  print(borderPen(bottomBorder));

  stdout.write(promptPen('\n› Enter your choice: '));
  final input = stdin.readLineSync();
  final selected = int.tryParse(input ?? '');

  if (selected != null && selected > 0 && selected <= displayOptions.length) {
    print('');
    await displayOptions[selected - 1]['action']();
  } else if (selected == 0) {
    kLog('\nExiting...', type: LogType.info);
    exit(0);
  } else {
    kLog('\nInvalid choice.', type: LogType.warning);
  }
}
