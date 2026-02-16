import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:path/path.dart' as p;

import '../src/version_helper.dart';
import 'utils/version_utils.dart'; // Import the new VersionUtils
import 'commands/build_command.dart';
import 'commands/clean_command.dart';
import 'commands/create_jks_command.dart';
import 'commands/create_project_command.dart';
import 'commands/hash_key_command.dart';
import 'commands/ios_build_command.dart';
import 'commands/pub_cache_command.dart';
import 'commands/rename_command.dart';
import 'commands/sha_keys_command.dart';
import 'commands/version_command.dart';
import 'commands/zip_command.dart';
import 'utils/logger.dart';
import 'utils/project_utils.dart';
import 'utils/spinner.dart';

Future<void> _runUpdateProcess() async {
  kLog('\n🚀 Starting CLI update...', type: LogType.info);
  try {
    final process =
        await Process.start('dart', ['pub', 'global', 'activate', 'dig_cli']);
    await stdout.addStream(process.stdout);
    await stderr.addStream(process.stderr);
    if (await process.exitCode == 0) {
      kLog('\n✅ CLI updated successfully! Please restart the tool.',
          type: LogType.success);
    } else {
      kLog('\n❗ Update failed.', type: LogType.error);
    }
  } catch (e) {
    kLog('\n❌ An error occurred: $e', type: LogType.error);
  }
  exit(0);
}

Future<Map<String, String>> _promptBuildDetails() async {
  final projectName = await getProjectName() ?? 'app-build';

  stdout.write('Enter build name (default: $projectName): ');
  String? buildName = stdin.readLineSync()?.trim();
  if (buildName == null || buildName.isEmpty) buildName = projectName;

  final defaultPath = await getDesktopPath();
  stdout.write('Enter save location (default: Desktop): ');
  String? location = stdin.readLineSync()?.trim();
  if (location == null || location.isEmpty) location = defaultPath;

  return {'name': buildName, 'location': location};
}

Future<void> showInteractiveMenu() async {
  final AnsiPen titlePen = AnsiPen()..white(bold: true);
  final AnsiPen optionPen = AnsiPen()..cyan();
  final AnsiPen promptPen = AnsiPen()..yellow();
  final AnsiPen borderPen = AnsiPen()..blue();
  final AnsiPen updatePen = AnsiPen()..green(bold: true);
  final AnsiPen disabledPen = AnsiPen()..gray(level: 0.5);

  final projectRoot = findProjectRoot();
  final isInsideProject = projectRoot != null;

  if (isInsideProject) {
    Directory.current = projectRoot;
  }

  final isBuildable = isInsideProject &&
      await File(p.join(projectRoot.path, 'lib', 'main.dart')).exists();

  String? latestStable;
  await runWithSpinner('🔍 Checking for updates...', () async {
    latestStable = await VersionUtils.getLatestStableVersion();
  });

  final displayOptions = <Map<String, dynamic>>[];
  displayOptions.add({
    'label': '🚀 Create New Project from Template',
    'action': () async {
      final command = CreateProjectCommand();
      await command.run();
    },
  });

  if (isInsideProject) {
    if (isBuildable) {
      displayOptions.add({
        'label': '🚀 Build APK',
        'action': () async {
          final details = await _promptBuildDetails();
          await handleBuildCommand([
            'apk',
            '--name',
            details['name']!,
            '--output',
            details['location']!
          ]);
        }
      });
      displayOptions.add({
        'label': '📦 Build AAB',
        'action': () async {
          final details = await _promptBuildDetails();
          await handleBuildCommand([
            'bundle',
            '--name',
            details['name']!,
            '--output',
            details['location']!
          ]);
        }
      });
      // iOS build option only available on macOS
      if (Platform.isMacOS) {
        displayOptions.add({
          'label': '🍎 Build iOS IPA',
          'action': () async {
            final details = await _promptBuildDetails();

            kLog('\nSelect Export Method:');
            kLog('1. Ad-hoc (Testing on devices)');
            kLog('2. Development (Dev builds)');
            kLog('3. App Store (Production)');
            kLog('4. Enterprise');
            stdout.write('\n› Enter choice (1-4, default: 1): ');

            final choice = stdin.readLineSync()?.trim();
            String method;
            switch (choice) {
              case '2':
                method = 'development';
                break;
              case '3':
                method = 'app-store';
                break;
              case '4':
                method = 'enterprise';
                break;
              case '1':
              default:
                method = 'ad-hoc';
                break;
            }

            await handleIosBuildCommand([
              '--name',
              details['name']!,
              '--output',
              details['location']!,
              '--method',
              method
            ]);
          }
        });
      }
      displayOptions.add({
        'label': '🔐 Get SHA Keys',
        'action': () => getShaKeys(),
      });
      displayOptions.add({
        'label': '🔑 Get Hash Key (Base64)',
        'action': () async {
          kLog('\nSelect configuration:');
          kLog('1. Debug');
          kLog('2. Release');
          stdout.write('\n› Enter choice (1 or 2): ');
          final choice = stdin.readLineSync()?.trim();
          if (choice == '1') {
            await handleHashKeyCommand(['--debug']);
          } else if (choice == '2') {
            await handleHashKeyCommand(['--release']);
          } else {
            kLog('Invalid choice.', type: LogType.warning);
          }
        },
      });
      displayOptions.add({
        'label': '🔑 Create JKS & Setup Signing',
        'action': () => handleCreateJksCommand(),
      });
    }
    displayOptions.add(
        {'label': '🧹 Clean Project', 'action': () => CleanCommand().run()});
    displayOptions.add({
      'label': '🏷️  Rename App',
      'action': () async {
        stdout.write('Enter new app name (leave empty to skip): ');
        final name = stdin.readLineSync()?.trim();
        stdout.write(
            'Enter new bundle ID (e.g., com.example.app, leave empty to skip): ');
        final bundleId = stdin.readLineSync()?.trim();

        if ((name == null || name.isEmpty) &&
            (bundleId == null || bundleId.isEmpty)) {
          kLog('No changes provided.', type: LogType.warning);
          return;
        }

        // Simpler to just use CommandRunner for now but with better error handling
        final args = <String>[];
        if (name != null && name.isNotEmpty) args.addAll(['--name', name]);
        if (bundleId != null && bundleId.isNotEmpty) {
          args.addAll(['--bundle-id', bundleId]);
        }

        try {
          await handleRenameCommand(['rename', ...args]);
        } catch (e) {
          kLog('Failed to rename: $e', type: LogType.error);
        }
      }
    });
    displayOptions.add(
        {'label': '🤐 Create Project ZIP', 'action': () => ZipCommand().run()});
  }
  displayOptions
      .add({'label': '� Pub Cache Repair', 'action': () => repairPubCache()});
  displayOptions.add(
      {'label': '�📖 Version & Info', 'action': () => VersionCommand().run()});
  if (latestStable != null &&
      VersionUtils.isNewer(latestStable!, kDigCliVersion)) {
    displayOptions.add({
      'label': '✨ Update to v$latestStable',
      'action': () => _runUpdateProcess(),
      'isUpdate': true
    });
  }

  const int totalWidth = 42;
  final String title = 'DIG CLI TOOL v$kDigCliVersion';
  final int titlePaddingTotal = totalWidth - title.length - 2;
  final int titlePaddingLeft = (titlePaddingTotal / 2).floor();
  final int titlePaddingRight = (titlePaddingTotal / 2).ceil();

  final String topBorder = '╔${'═' * (totalWidth - 2)}╗';
  final String middleBorder = '╠${'═' * (totalWidth - 2)}╣';
  final String bottomBorder = '╚${'═' * (totalWidth - 2)}╝';

  print('');
  print(borderPen(topBorder));
  print(borderPen('║') +
      ' ' * titlePaddingLeft +
      titlePen(title) +
      ' ' * titlePaddingRight +
      borderPen('║'));
  print(borderPen(middleBorder));

  if (!isInsideProject) {
    const warningText = ' You are not inside a Flutter project.';
    final int padding = totalWidth - warningText.length - 2;
    print(borderPen('║') +
        disabledPen(warningText) +
        ' ' * (padding > 0 ? padding : 0) +
        borderPen('║'));
    print(borderPen(middleBorder));
  } else if (!isBuildable) {
    const warningText = ' Build options hidden: lib/main.dart not found.';
    final int padding = totalWidth - warningText.length - 2;
    print(borderPen('║') +
        disabledPen(warningText) +
        ' ' * (padding > 0 ? padding : 0) +
        borderPen('║'));
    print(borderPen(middleBorder));
  }

  void printMenuLine(String text, {bool isUpdate = false}) {
    final AnsiPen pen = isUpdate ? updatePen : optionPen;
    // Strip emojis for correct padding calculation
    final strippedText = text.replaceAll(
        RegExp(
            r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'),
        '');
    final int padding = totalWidth - strippedText.length - 5;
    print(
        '${borderPen('║')}  ${pen(text)}${' ' * (padding > 0 ? padding : 0)}${borderPen('║')}');
  }

  for (int i = 0; i < displayOptions.length; i++) {
    printMenuLine('${i + 1}. ${displayOptions[i]['label']}',
        isUpdate: displayOptions[i]['isUpdate'] ?? false);
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
