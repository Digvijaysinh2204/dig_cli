import 'dart:io';

import 'package:path/path.dart' as p;

import '../utils/logger.dart';
import '../utils/project_utils.dart';
import '../utils/spinner.dart';

Future<void> handleCleanCommand() async {
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
      '❗ This command must be run inside a Flutter project (pubspec.yaml not found).',
      type: LogType.error,
    );
    exit(1);
  }
  try {
    kLog('🚀 Starting thorough project cleanup...', type: LogType.info);

    await runWithSpinner(
      '🧹 Cleaning Flutter project (flutter clean)',
      () => Process.run('flutter', ['clean']),
    );
    await _deleteIfExists('build');
    kLog('🗑️  Removed build directory', type: LogType.info);
    await runWithSpinner(
      '📦 Getting Dart packages (flutter pub get)',
      () => Process.run('flutter', ['pub', 'get']),
    );

    String? homeDir = Platform.isWindows
        ? Platform.environment['USERPROFILE']
        : Platform.environment['HOME'];

    if (Platform.isMacOS) {
      kLog(' macOS: Running iOS specific cleanup...', type: LogType.info);
      await runWithSpinner(
        '📦 Pre-caching Flutter iOS artifacts',
        () => Process.run('flutter', ['precache', '--ios']),
      );

      final iosDir = Directory('ios');
      if (await iosDir.exists()) {
        await _deleteIfExists(p.join(iosDir.path, '.symlinks'));
        await _deleteIfExists(p.join(iosDir.path, 'Podfile.lock'));
        await _deleteIfExists(p.join(iosDir.path, 'Pods'));
        await _deleteIfExists(p.join(iosDir.path, 'build'));
        kLog('🧼 Cleaned local iOS workspace.', type: LogType.info);
        await runWithSpinner(
          '📥 Installing CocoaPods (pod install)',
          () => Process.run('pod', ['install'], workingDirectory: iosDir.path),
        );
        await runWithSpinner(
          '📥 Updating CocoaPods (pod update)',
          () => Process.run('pod', ['update'], workingDirectory: iosDir.path),
        );
      }

      if (homeDir != null) {
        final derivedData = Directory(
          p.join(homeDir, 'Library', 'Developer', 'Xcode', 'DerivedData'),
        );
        if (await derivedData.exists()) {
          kLog('🧹 Cleaning global Xcode DerivedData...', type: LogType.info);
          await derivedData.delete(recursive: true);
        }
      }
    } else if (Platform.isWindows) {
      kLog(
        '🪟 Windows: Running platform specific cleanup...',
        type: LogType.info,
      );
      await _deleteIfExists('windows/build');
      await _deleteIfExists('windows/flutter/ephemeral');
      kLog('🧼 Cleaned local Windows build artifacts.', type: LogType.info);

      if (homeDir != null) {
        final gradleCache = Directory(p.join(homeDir, '.gradle', 'caches'));
        if (await gradleCache.exists()) {
          kLog('🧹 Cleaning global Gradle caches...', type: LogType.info);
          await gradleCache.delete(recursive: true);
        }
      }
    } else if (Platform.isLinux) {
      kLog(
        '🐧 Linux: Running platform specific cleanup...',
        type: LogType.info,
      );
      await _deleteIfExists('linux/build');
      await _deleteIfExists('linux/flutter/ephemeral');
      kLog('🧼 Cleaned local Linux build artifacts.', type: LogType.info);

      if (homeDir != null) {
        final gradleCache = Directory(p.join(homeDir, '.gradle', 'caches'));
        if (await gradleCache.exists()) {
          kLog('🧹 Cleaning global Gradle caches...', type: LogType.info);
          await gradleCache.delete(recursive: true);
        }
      }
    }

    kLog('✅ All Clean! Project reset complete.', type: LogType.success);
  } catch (e) {
    kLog('❌ An error occurred during cleanup: $e', type: LogType.error);
    exit(1);
  }
}

Future<void> _deleteIfExists(String path) async {
  try {
    final entity = Directory(path);
    if (await entity.exists()) {
      await entity.delete(recursive: true);
    } else {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  } catch (e) {
    kLog('⚠️  Could not delete "$path": $e', type: LogType.warning);
  }
}
