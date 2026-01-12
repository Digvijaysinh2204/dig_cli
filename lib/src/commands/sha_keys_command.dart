import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../utils/logger.dart';
import '../utils/project_utils.dart';
import '../utils/spinner.dart';

/// Command to get SHA1 and SHA256 keys using Gradle signing report
class ShaKeysCommand extends Command {
  @override
  final name = 'sha-keys';
  @override
  final description = 'Gets SHA1 and SHA256 keys using Gradle signingReport.';

  @override
  Future<void> run() async {
    await getShaKeys();
  }
}

/// Gets SHA1 and SHA256 keys by running `./gradlew signingReport`
Future<void> getShaKeys() async {
  final projectRoot = findProjectRoot();

  if (projectRoot == null) {
    kLog('❗ This command must be run inside a Flutter project.',
        type: LogType.error);
    return;
  }

  final androidDir = Directory(p.join(projectRoot.path, 'android'));
  if (!await androidDir.exists()) {
    kLog('❗ Android directory not found.', type: LogType.error);
    kLog('💡 Make sure you are in a Flutter project with Android support.',
        type: LogType.info);
    return;
  }

  // Check for gradlew
  final gradlewPath = Platform.isWindows
      ? p.join(androidDir.path, 'gradlew.bat')
      : p.join(androidDir.path, 'gradlew');

  final gradlewFile = File(gradlewPath);
  if (!await gradlewFile.exists()) {
    kLog('❗ Gradle wrapper not found.', type: LogType.error);
    kLog('💡 Run "flutter build apk" first to generate it.',
        type: LogType.info);
    return;
  }

  kLog('\n🔐 Getting SHA Keys using Gradle Signing Report...',
      type: LogType.info);
  kLog('📁 Project: ${projectRoot.path}', type: LogType.info);
  kLog('📂 Running in: ${androidDir.path}\n', type: LogType.info);

  // Save current directory to restore later
  final originalDir = Directory.current;

  try {
    // Change to android directory
    Directory.current = androidDir;

    // Use absolute path for gradlew
    final result = await runWithSpinner(
      '🔍 Running signingReport...',
      () => Process.run(
        gradlewPath,
        ['signingReport'],
        workingDirectory: androidDir.path,
      ),
    );

    if (result.exitCode != 0) {
      kLog('❗ Signing report failed.', type: LogType.error);
      kLog('Error: ${result.stderr}', type: LogType.error);
      return;
    }

    final output = result.stdout.toString();

    // Parse and display the signing report
    _parseAndDisplaySigningReport(output);
  } catch (e) {
    kLog('❌ An error occurred: $e', type: LogType.error);
  } finally {
    // Restore original directory
    Directory.current = originalDir;
  }
}

/// Parses the signing report output and displays it in a formatted way
void _parseAndDisplaySigningReport(String output) {
  // Find all variants with their SHA keys
  final lines = output.split('\n');

  String? currentVariant;
  String? currentConfig;
  String? sha1;
  String? sha256;

  final reports = <Map<String, String>>[];

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i].trim();

    if (line.startsWith('Variant:')) {
      // Save previous entry if exists
      if (currentVariant != null && (sha1 != null || sha256 != null)) {
        reports.add({
          'variant': currentVariant,
          'config': currentConfig ?? '',
          'sha1': sha1 ?? 'N/A',
          'sha256': sha256 ?? 'N/A',
        });
      }
      currentVariant = line.replaceFirst('Variant:', '').trim();
      currentConfig = null;
      sha1 = null;
      sha256 = null;
    } else if (line.startsWith('Config:')) {
      currentConfig = line.replaceFirst('Config:', '').trim();
    } else if (line.startsWith('SHA1:')) {
      sha1 = line.replaceFirst('SHA1:', '').trim();
    } else if (line.startsWith('SHA-256:')) {
      sha256 = line.replaceFirst('SHA-256:', '').trim();
    }
  }

  // Save last entry
  if (currentVariant != null && (sha1 != null || sha256 != null)) {
    reports.add({
      'variant': currentVariant,
      'config': currentConfig ?? '',
      'sha1': sha1 ?? 'N/A',
      'sha256': sha256 ?? 'N/A',
    });
  }

  if (reports.isEmpty) {
    kLog('❗ No signing information found in the report.', type: LogType.error);
    kLog('\n📋 Raw output:', type: LogType.info);
    print(output);
    return;
  }

  kLog('✅ SHA Keys extracted successfully!\n', type: LogType.success);

  // Group by config (debug/release)
  final debugReports =
      reports.where((r) => r['config']?.toLowerCase() == 'debug').toList();
  final releaseReports =
      reports.where((r) => r['config']?.toLowerCase() == 'release').toList();

  if (debugReports.isNotEmpty) {
    kLog('═══════════════════════════════════════════', type: LogType.info);
    kLog('🔓 DEBUG KEYS', type: LogType.info);
    kLog('═══════════════════════════════════════════', type: LogType.info);
    _displayReport(debugReports.first);
  }

  if (releaseReports.isNotEmpty) {
    kLog('\n═══════════════════════════════════════════', type: LogType.info);
    kLog('🔐 RELEASE KEYS', type: LogType.info);
    kLog('═══════════════════════════════════════════', type: LogType.info);
    _displayReport(releaseReports.first);
  }

  kLog('\n💡 Tips:', type: LogType.info);
  kLog('   • Use SHA1 for Google Sign-In, Maps API, Firebase, etc.',
      type: LogType.info);
  kLog('   • Use SHA256 for App Links and Play Integrity.', type: LogType.info);
  kLog('   • Add both debug & release keys to Firebase/Google Console.',
      type: LogType.info);
}

/// Displays a single signing report entry
void _displayReport(Map<String, String> report) {
  final sha1 = report['sha1'] ?? 'N/A';
  final sha256 = report['sha256'] ?? 'N/A';

  kLog('\n🔑 SHA1:', type: LogType.info);
  kLog('   $sha1', type: LogType.success);
  if (sha1 != 'N/A') {
    kLog('   (No colons: ${sha1.replaceAll(':', '')})', type: LogType.info);
  }

  kLog('\n🔑 SHA256:', type: LogType.info);
  kLog('   $sha256', type: LogType.success);
  if (sha256 != 'N/A') {
    kLog('   (No colons: ${sha256.replaceAll(':', '')})', type: LogType.info);
  }
}
