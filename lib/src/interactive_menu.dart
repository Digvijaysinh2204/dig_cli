import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'commands/asset_command.dart';
import 'commands/firebase_command.dart';
import 'commands/build_command.dart';
import 'commands/ios_build_command.dart';
import 'commands/sha_keys_command.dart';
import 'commands/hash_key_command.dart';
import 'commands/create_jks_command.dart';
import 'commands/create_module_command.dart';
import 'commands/create_project_command.dart';
import 'commands/clean_command.dart';
import 'commands/zip_command.dart';
import 'commands/rename_command.dart';
import 'commands/version_command.dart';
import 'utils/version_utils.dart';
import 'version_helper.dart';
import 'utils/logger.dart';

class InteractiveMenu {
  Future<void> show() async {
    while (true) {
      print('\x1B[2J\x1B[0;0H'); // Clear console
      kLog('================= 🚀 DIG CLI =================',
          type: LogType.info);
      kLog('   🚀 Made with ❤️  by Digvijaysinh Chauhan 🚀   ',
          type: LogType.success);
      kLog('=============================================\n',
          type: LogType.info);

      kLog('📦 BUILD & RELEASE', type: LogType.info);
      kLog('1) 🏗️  Build APK', type: LogType.info);
      kLog('2) 📦 Build App Bundle (AAB)', type: LogType.info);
      kLog('3) 🍎 Build iOS (IPA)', type: LogType.info);

      kLog('\n🧹 CLEAN & FIX', type: LogType.info);
      kLog('4) 🧼 Clean (flutter clean only)', type: LogType.info);
      kLog('5) ☢️  Clean & Full Reset (with Nuclear opt)', type: LogType.info);

      kLog('\n🔐 SIGNING & KEYS', type: LogType.info);
      kLog('6) 🔐 Create JKS (Keystore)', type: LogType.info);
      kLog('7) 🔑 Generate SHA Keys', type: LogType.info);
      kLog('8) 🔑 Generate Hash Key (for Facebook)', type: LogType.info);

      kLog('\n🔥 CONFIGURATION', type: LogType.info);
      kLog('9) 🔥 Firebase Setup', type: LogType.info);
      kLog('10) ✨ Setup Assets (Auto)', type: LogType.info);

      kLog('\n🏗️ PROJECT MANAGEMENT', type: LogType.info);
      kLog('11) 🧱 Create New Project', type: LogType.info);
      kLog('12) 📂 Create GetX Module', type: LogType.info);
      kLog('13) 🏷️ Rename App / Bundle', type: LogType.info);

      kLog('\n📦 UTILITIES', type: LogType.info);
      kLog('14) 🗜️  Zip Source Code', type: LogType.info);
      kLog('15) 🚀 Check for Updates', type: LogType.info);

      kLog('\n---------------------------------------------',
          type: LogType.info);
      kLog('0) 🚪 Exit', type: LogType.info);
      kLog('=============================================', type: LogType.info);

      stdout.write('\nSelect option (0-15): ');
      final response = stdin.readLineSync()?.trim();

      if (response == '0') exit(0);

      final runner = CommandRunner('dg', 'temp');

      switch (response) {
        case '1':
          runner.addCommand(BuildCommand());
          await runner.run(['create', 'apk']);
          break;
        case '2':
          runner.addCommand(BuildCommand());
          await runner.run(['create', 'bundle']);
          break;
        case '3':
          await IosBuildCommand().run();
          break;
        case '4':
          kLog('🚀 Running flutter clean...', type: LogType.info);
          await Process.run('flutter', ['clean']);
          kLog('✅ Clean complete.', type: LogType.success);
          break;
        case '5':
          await _handleFullReset();
          break;
        case '6':
          await CreateJksCommand().run();
          break;
        case '7':
          await ShaKeysCommand().run();
          break;
        case '8':
          await HashKeyCommand().run();
          break;
        case '9':
          await _showFirebaseSubMenu();
          break;
        case '10':
          await handleAssetSetup();
          break;
        case '11':
          await CreateProjectCommand().run();
          break;
        case '12':
          await CreateModuleCommand().run();
          break;
        case '13':
          await RenameCommand().run();
          break;
        case '14':
          await ZipCommand().run();
          break;
        case '15':
          await _handleUpdateCheck();
          break;
        default:
          kLog('⚠️ Invalid option. Please try again.', type: LogType.warning);
          break;
      }

      kLog('\n(Press Enter to continue...)', type: LogType.info);
      stdin.readLineSync();
    }
  }

  Future<void> _handleFullReset() async {
    stdout.write(
        '☢️  Wipe global build caches too (Xcode DerivedData, Gradle)? (y/N): ');
    final response = stdin.readLineSync()?.trim().toLowerCase();

    final runner = CommandRunner('dg', 'temp')..addCommand(CleanCommand());
    if (response == 'y') {
      await runner.run(['clean', '--global']);
    } else {
      await runner.run(['clean']);
    }
  }

  Future<void> _handleUpdateCheck() async {
    kLog('🔎 Checking for updates...', type: LogType.info);
    await VersionCommand().run();

    final latest = await VersionUtils.getLatestStableVersion();
    if (latest != null && VersionUtils.isNewer(latest, kDigCliVersion)) {
      final isLocal = Platform.script.toFilePath().contains('bin/dig_cli.dart');
      if (isLocal) {
        kLog(
            '\n⚠️  Note: You are running from source code. Updating the global package will not change this local instance.',
            type: LogType.warning);
      }

      stdout.write('\n› Update to v$latest now? (y/N): ');
      final response = stdin.readLineSync()?.trim().toLowerCase();
      if (response == 'y') {
        kLog('🚀 Updating DIG CLI...', type: LogType.info);
        final process = await Process.start(
            'dart', ['pub', 'global', 'activate', 'dig_cli'],
            mode: ProcessStartMode.inheritStdio);
        await process.exitCode;
      }
    }
  }

  Future<void> _showFirebaseSubMenu() async {
    while (true) {
      final email = await _getFirebaseEmail();
      final header =
          email != null ? '🔥 FIREBASE SETUP ($email)' : '🔥 FIREBASE SETUP';

      kLog('\n$header', type: LogType.info);
      kLog('------------------------------------------', type: LogType.info);

      final Map<String, List<String>> optionsMap = {};
      int index = 1;

      if (email == null) {
        kLog('$index) 🔑 Login', type: LogType.info);
        optionsMap['$index'] = ['firebase', 'login'];
        index++;
      } else {
        kLog('$index) 🚪 Logout', type: LogType.info);
        optionsMap['$index'] = ['firebase', 'logout'];
        index++;
      }

      kLog('$index) ⚙️ Configure (flutterfire)', type: LogType.info);
      optionsMap['$index'] = ['firebase', 'configure'];
      index++;

      kLog('$index) 🔍 Check Status', type: LogType.info);
      optionsMap['$index'] = ['firebase', 'check'];
      index++;

      kLog('0) ⬅️ Back to Main Menu', type: LogType.info);

      stdout.write('\nSelect option (0-${index - 1}): ');
      final response = stdin.readLineSync()?.trim();
      if (response == '0') break;

      final cmd = optionsMap[response];

      if (cmd != null) {
        final runner = CommandRunner('dg', 'temp')
          ..addCommand(FirebaseCommand());
        try {
          await runner.run(cmd);
        } catch (e) {
          kLog('❌ Error: $e', type: LogType.error);
        }
        kLog('\n(Press Enter to continue...)', type: LogType.info);
        stdin.readLineSync();
      }
    }
  }

  Future<String?> _getFirebaseEmail() async {
    try {
      final home = Platform.environment['HOME'] ??
          Platform.environment['USERPROFILE'] ??
          '';
      if (home.isNotEmpty) {
        final configPath =
            p.join(home, '.config', 'configstore', 'firebase-tools.json');
        final configFile = File(configPath);
        if (await configFile.exists()) {
          final data = json.decode(await configFile.readAsString());
          final email = data['user']?['email'] ?? data['activeAccount'];
          if (email != null && email is String && email.contains('@')) {
            return email;
          }
        }
      }
    } catch (_) {}
    return null;
  }
}

Future<void> showInteractiveMenu() async {
  final menu = InteractiveMenu();
  await menu.show();
}
