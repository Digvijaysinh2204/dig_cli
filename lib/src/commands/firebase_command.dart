import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import '../utils/logger.dart';
import '../utils/project_utils.dart';

class FirebaseCommand extends Command {
  @override
  final name = 'firebase';
  @override
  final description = 'Firebase configuration and setup tools';

  FirebaseCommand() {
    addSubcommand(_FirebaseLoginCommand(this));
    addSubcommand(_FirebaseLogoutCommand());
    addSubcommand(_FirebaseConfigureCommand(this));
    addSubcommand(_FirebaseCheckCommand());
  }

  Future<bool> ensureToolInstalled(
      String cmd, String installCmd, String friendlyName) async {
    try {
      final result =
          await Process.run(Platform.isWindows ? 'where' : 'which', [cmd]);
      if (result.exitCode == 0) return true;
    } catch (_) {}

    kLog('\n⚠️  $friendlyName is not installed.', type: LogType.warning);
    stdout.write('› Would you like to install it now? (y/N): ');
    final response = stdin.readLineSync()?.trim().toLowerCase();

    if (response == 'y') {
      kLog('🚀 Installing $friendlyName...', type: LogType.info);
      final parts = installCmd.split(' ');
      final process = await Process.start(parts[0], parts.sublist(1),
          mode: ProcessStartMode.inheritStdio);
      final exitCode = await process.exitCode;

      if (exitCode == 0) {
        kLog('✅ $friendlyName installed successfully!', type: LogType.success);
        return true;
      } else {
        kLog('❌ Failed to install $friendlyName.', type: LogType.error);
        return false;
      }
    }

    return false;
  }
}

class _FirebaseLoginCommand extends Command {
  final FirebaseCommand firebaseParent;

  @override
  final name = 'login';
  @override
  final description = 'Log into Firebase using firebase-tools';

  _FirebaseLoginCommand(this.firebaseParent);

  @override
  Future<void> run() async {
    if (!await firebaseParent.ensureToolInstalled(
        'firebase', 'npm install -g firebase-tools', 'Firebase Tools')) {
      return;
    }

    kLog('🔥 Running firebase login...', type: LogType.info);
    try {
      final process = await Process.start('firebase', ['login'],
          mode: ProcessStartMode.inheritStdio);
      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        kLog('❌ firebase login failed.', type: LogType.error);
      }
    } catch (e) {
      kLog('❌ Error running firebase command: $e', type: LogType.error);
    }
  }
}

class _FirebaseLogoutCommand extends Command {
  @override
  final name = 'logout';
  @override
  final description = 'Log out of Firebase';

  @override
  Future<void> run() async {
    kLog('🔥 Running firebase logout...', type: LogType.info);
    try {
      final process = await Process.start('firebase', ['logout'],
          mode: ProcessStartMode.inheritStdio);
      await process.exitCode;
    } catch (e) {
      kLog('❌ Error: firebase command not found.', type: LogType.error);
    }
  }
}

class _FirebaseConfigureCommand extends Command {
  final FirebaseCommand firebaseParent;

  @override
  final name = 'configure';
  @override
  final description = 'Configure Firebase for your Flutter project';

  _FirebaseConfigureCommand(this.firebaseParent);

  @override
  Future<void> run() async {
    if (!await firebaseParent.ensureToolInstalled('flutterfire',
        'dart pub global activate flutterfire_cli', 'FlutterFire CLI')) {
      return;
    }

    kLog('🔥 Running flutterfire configure...', type: LogType.info);
    try {
      final process = await Process.start('flutterfire', ['configure'],
          mode: ProcessStartMode.inheritStdio);
      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        kLog('❌ flutterfire configure failed.', type: LogType.error);
      }
    } catch (e) {
      kLog('❌ Error running flutterfire command: $e', type: LogType.error);
    }
  }
}

class _FirebaseCheckCommand extends Command {
  @override
  final name = 'check';
  @override
  final description = 'Check Firebase configuration files';

  @override
  Future<void> run() async {
    final root = findProjectRoot();
    if (root == null) {
      kLog('❌ Not inside a Flutter project.', type: LogType.error);
      return;
    }

    kLog('🔍 Checking Firebase configuration...', type: LogType.info);

    final files = {
      'Android (google-services.json)':
          p.join(root.path, 'android', 'app', 'google-services.json'),
      'iOS (GoogleService-Info.plist)':
          p.join(root.path, 'ios', 'Runner', 'GoogleService-Info.plist'),
      'Firebase Options (lib/firebase_options.dart)':
          p.join(root.path, 'lib', 'firebase_options.dart'),
    };

    bool allFound = true;
    files.forEach((name, path) {
      if (File(path).existsSync()) {
        kLog('✅ found: $name', type: LogType.success);
      } else {
        kLog('❌ missing: $name', type: LogType.warning);
        allFound = false;
      }
    });

    if (allFound) {
      kLog('\n✨ Firebase seems to be configured correctly!',
          type: LogType.success);
    } else {
      kLog('\n⚠️  Some Firebase configuration files are missing.',
          type: LogType.warning);
      kLog('💡 Run `dg firebase configure` to set them up.',
          type: LogType.info);
    }
  }
}
