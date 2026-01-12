import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../utils/logger.dart';
import '../utils/project_utils.dart';
import '../utils/spinner.dart';

/// Command to build iOS IPA and save it to desktop
class IosBuildCommand extends Command {
  @override
  final name = 'ios';
  @override
  final description = 'Builds the Flutter project into an iOS IPA file.';

  IosBuildCommand() {
    argParser.addOption('output', abbr: 'o', help: 'Specify output directory');
    argParser.addOption(
      'name',
      abbr: 'n',
      help: 'Custom name prefix for the output file',
    );
  }

  @override
  Future<void> run() async {
    final outputDir =
        argResults?['output'] as String? ?? await getDesktopPath();
    final customName = argResults?['name'] as String?;

    await buildIos(outputDir: outputDir, customName: customName);
  }
}

/// Builds iOS IPA and saves it directly to the specified directory
Future<void> buildIos({
  String? outputDir,
  String? customName,
}) async {
  // Check if running on macOS
  if (!Platform.isMacOS) {
    kLog('❗ iOS builds can only be created on macOS.', type: LogType.error);
    return;
  }

  if (!await isFlutterProject()) {
    kLog(
      '❗ This command must be run inside a Flutter project.',
      type: LogType.error,
    );
    return;
  }

  final savePath = outputDir ?? await getDesktopPath();

  try {
    final projectName = customName ?? await getProjectName();
    if (projectName == null || projectName.isEmpty) {
      kLog(
        '❗ Project name not found and no custom name was provided!',
        type: LogType.error,
      );
      return;
    }

    final now = DateTime.now();
    final date =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final filename = '$projectName-$date-$hour-$minute.ipa';

    kLog('\n🍎 iOS BUILD', type: LogType.info);
    kLog('📱 APP PREFIX: $projectName');
    kLog('📅 Date: $date @ $hour:$minute');

    final projectRoot = findProjectRoot();
    if (projectRoot == null) {
      kLog('❗ Could not find project root.', type: LogType.error);
      return;
    }

    // Step 1: Build the iOS archive using Flutter
    kLog('\n📦 Building iOS IPA...', type: LogType.info);

    final buildResult = await runWithSpinner(
      '🚧 Running flutter build ipa --release...',
      () => Process.run(
        'flutter',
        ['build', 'ipa', '--release'],
        workingDirectory: projectRoot.path,
      ),
    );

    if (buildResult.exitCode != 0) {
      kLog('❗ iOS build failed. See error below:', type: LogType.error);
      stderr.writeln(buildResult.stderr);
      kLog('\n💡 Make sure you have:', type: LogType.info);
      kLog('   • Xcode installed and configured', type: LogType.info);
      kLog('   • Valid signing certificates', type: LogType.info);
      kLog('   • Provisioning profiles set up', type: LogType.info);
      return;
    }

    // Find the IPA file in build/ios/ipa/
    final ipaDir = Directory(p.join(projectRoot.path, 'build', 'ios', 'ipa'));

    if (!await ipaDir.exists()) {
      kLog('❗ IPA output directory not found.', type: LogType.error);
      return;
    }

    final ipaFiles = await ipaDir
        .list()
        .where((entity) => entity.path.endsWith('.ipa'))
        .toList();

    if (ipaFiles.isEmpty) {
      kLog('❗ No IPA file found in build output.', type: LogType.error);
      return;
    }

    // Copy and rename the IPA to the destination
    final srcFile = File(ipaFiles.first.path);
    final destFile = File(p.join(savePath, filename));

    await srcFile.copy(destFile.path);

    // Delete the source IPA after copying
    await srcFile.delete();

    final fileSize = await destFile.length();
    final sizeInMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);

    kLog('\n✅ iOS IPA created successfully!', type: LogType.success);
    kLog('📁 Location: ${destFile.path}', type: LogType.info);
    kLog('📊 Size: ${sizeInMB}MB', type: LogType.info);
  } catch (e) {
    kLog(
      '❌ An unexpected error occurred during the iOS build: $e',
      type: LogType.error,
    );
  }
}

/// Handles the iOS build command from the interactive menu
Future<void> handleIosBuildCommand(List<String> args) async {
  final runner = CommandRunner('dig', 'DIG CLI tool');
  runner.addCommand(IosBuildCommand());
  await runner.run(['ios', ...args]);
}
