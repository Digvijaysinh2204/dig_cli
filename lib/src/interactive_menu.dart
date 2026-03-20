import 'dart:convert';
import 'dart:io';
import 'package:ansicolor/ansicolor.dart';
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
import 'commands/pub_cache_command.dart';
import 'utils/version_utils.dart';
import 'version_helper.dart';
import 'utils/logger.dart';

/// Interactive dashboard: one bordered "card" per screen (aligned with [dg version] width).
class InteractiveMenu {
  static const int _totalWidth = 50;
  static const int _innerWidth = _totalWidth - 4;

  AnsiPen get _borderPen => AnsiPen()..blue();
  AnsiPen get _titlePen => AnsiPen()..white(bold: true);
  AnsiPen get _mutedPen => AnsiPen()..gray(level: 0.55);
  AnsiPen get _bodyPen => AnsiPen()..cyan();

  bool get _ansi => kAnsiStdoutEnabled;

  void _clearScreen() {
    try {
      if (stdout.hasTerminal) {
        print('\x1B[2J\x1B[0;0H');
      } else {
        print('');
      }
    } catch (_) {
      print('');
    }
  }

  void _boxTop() {
    final line = '╔${'═' * (_totalWidth - 2)}╗';
    print(_ansi ? _borderPen(line) : line);
  }

  void _boxBottom() {
    final line = '╚${'═' * (_totalWidth - 2)}╝';
    print(_ansi ? _borderPen(line) : line);
  }

  void _hrDouble() {
    final line = '╠${'═' * (_totalWidth - 2)}╣';
    print(_ansi ? _borderPen(line) : line);
  }

  /// One content row: `║` + space + [inner] + space + `║`  ([inner] is exactly [_innerWidth] cells).
  void _rowInnerPlain(String text, {bool center = false}) {
    var t = text.length > _innerWidth ? text.substring(0, _innerWidth) : text;
    if (center) {
      final pad = _innerWidth - t.length;
      final left = pad ~/ 2;
      t = '${' ' * left}$t${' ' * (pad - left)}';
    } else {
      t = t.padRight(_innerWidth);
    }
    final plain = '║ $t ║';
    if (_ansi) {
      print('${_borderPen('║')} $t ${_borderPen('║')}');
    } else {
      print(plain);
    }
  }

  void _rowTitleVersion(String left, String right) {
    var l = left;
    final rightPlain = right;
    var gap = _innerWidth - l.length - rightPlain.length;
    while (gap < 1 && l.length > 4) {
      l = '${l.substring(0, l.length - 3)}...';
      gap = _innerWidth - l.length - rightPlain.length;
    }
    if (gap < 1) gap = 1;
    if (_ansi) {
      print(
        '${_borderPen('║')} '
        '${_titlePen(l)}'
        '${_mutedPen(' ' * gap + rightPlain)}'
        ' ${_borderPen('║')}',
      );
    } else {
      _rowInnerPlain('$l${' ' * gap}$rightPlain');
    }
  }

  void _rowSectionLabel(String text) {
    final t = text.length > _innerWidth ? text.substring(0, _innerWidth) : text;
    final padded = t.padRight(_innerWidth);
    if (_ansi) {
      print('${_borderPen('║')} ${_mutedPen(padded)} ${_borderPen('║')}');
    } else {
      print('║ $padded ║');
    }
  }

  void _rowMenuOption(int n, String label) {
    var line = '  $n  $label';
    if (line.length > _innerWidth) {
      line = '${line.substring(0, _innerWidth - 3)}...';
    } else {
      line = line.padRight(_innerWidth);
    }
    if (_ansi) {
      print('${_borderPen('║')} ${_bodyPen(line)} ${_borderPen('║')}');
    } else {
      print('║ $line ║');
    }
  }

  void _rowMenuBack(String actionLabel) {
    var line = '  0  $actionLabel';
    if (line.length > _innerWidth) {
      line = '${line.substring(0, _innerWidth - 3)}...';
    } else {
      line = line.padRight(_innerWidth);
    }
    if (_ansi) {
      print('${_borderPen('║')} ${_mutedPen(line)} ${_borderPen('║')}');
    } else {
      print('║ $line ║');
    }
  }

  void _outsideTip(String text) {
    if (_ansi) {
      print(_mutedPen('  $text'));
    } else {
      print('  $text');
    }
  }

  void _outsidePrompt(String range) {
    final msg = '  Enter [$range]: ';
    if (_ansi) {
      stdout.write(_mutedPen(msg));
    } else {
      stdout.write(msg);
    }
  }

  void _renderMainMenu() {
    print('');
    _boxTop();
    _rowTitleVersion('DIG CLI', 'v$kDigCliVersion');
    _rowInnerPlain('');
    _rowInnerPlain('Made with love by', center: true);
    _rowInnerPlain('Digvijaysinh Chauhan', center: true);
    _rowInnerPlain('');
    _hrDouble();
    _rowSectionLabel('Select a category');
    _rowInnerPlain('');
    _rowMenuOption(1, 'Build & release');
    _rowMenuOption(2, 'Clean & fix');
    _rowMenuOption(3, 'Signing & keys');
    _rowMenuOption(4, 'Configuration');
    _rowMenuOption(5, 'Project management');
    _rowMenuOption(6, 'Utilities');
    _rowInnerPlain('');
    _rowMenuBack('Exit');
    _boxBottom();
    print('');
    _outsideTip('Tip: run `dg <command>` for non-interactive use.');
    _outsidePrompt('0-6');
  }

  void _beginSubCard(String title, {String? detail}) {
    print('');
    _boxTop();
    _rowTitleVersion(title, 'v$kDigCliVersion');
    if (detail != null && detail.isNotEmpty) {
      var d = detail.length > _innerWidth
          ? '${detail.substring(0, _innerWidth - 3)}...'
          : detail;
      _rowInnerPlain(d);
    }
    _rowInnerPlain('');
    _hrDouble();
    _rowSectionLabel('Select an action');
    _rowInnerPlain('');
  }

  void _endSubCard({required bool exitToShell}) {
    _rowInnerPlain('');
    _rowMenuBack(exitToShell ? 'Exit' : 'Back');
    _boxBottom();
    print('');
  }

  Future<void> _pause() async {
    kLog('\nPress Enter to continue...', type: LogType.info);
    stdin.readLineSync();
  }

  Future<void> show() async {
    while (true) {
      _clearScreen();
      _renderMainMenu();
      final response = stdin.readLineSync()?.trim();

      switch (response) {
        case '0':
          exit(0);
        case '1':
          await _buildReleaseMenu();
          break;
        case '2':
          await _cleanFixMenu();
          break;
        case '3':
          await _signingMenu();
          break;
        case '4':
          await _configurationMenu();
          break;
        case '5':
          await _projectMenu();
          break;
        case '6':
          await _utilitiesMenu();
          break;
        default:
          kLog('Invalid option. Press Enter...', type: LogType.warning);
          stdin.readLineSync();
      }
    }
  }

  Future<void> _buildReleaseMenu() async {
    while (true) {
      _clearScreen();
      _beginSubCard('Build & release');
      _rowMenuOption(1, 'Build APK');
      _rowMenuOption(2, 'Build App Bundle (AAB)');
      _rowMenuOption(3, 'Build iOS (IPA)');
      _endSubCard(exitToShell: false);
      _outsidePrompt('0-3');
      final r = stdin.readLineSync()?.trim();
      if (r == '0') return;

      final runner = CommandRunner('dg', 'temp');
      switch (r) {
        case '1':
          runner.addCommand(BuildCommand());
          await runner.run(['create', 'apk']);
          await _pause();
          break;
        case '2':
          runner.addCommand(BuildCommand());
          await runner.run(['create', 'bundle']);
          await _pause();
          break;
        case '3':
          await IosBuildCommand().run();
          await _pause();
          break;
        default:
          kLog('Invalid option.', type: LogType.warning);
          await _pause();
      }
    }
  }

  Future<void> _cleanFixMenu() async {
    while (true) {
      _clearScreen();
      _beginSubCard('Clean & fix');
      _rowMenuOption(1, 'Flutter clean only');
      _rowMenuOption(2, 'Full reset (pub get, pods, optional global wipe)');
      _rowMenuOption(3, 'Repair pub cache');
      _endSubCard(exitToShell: false);
      _outsidePrompt('0-3');
      final r = stdin.readLineSync()?.trim();
      if (r == '0') return;

      switch (r) {
        case '1':
          kLog('Running flutter clean...', type: LogType.info);
          await Process.run('flutter', ['clean']);
          kLog('Done.', type: LogType.success);
          await _pause();
          break;
        case '2':
          await _handleFullReset();
          await _pause();
          break;
        case '3':
          final pubRunner = CommandRunner('dg', 'temp')
            ..addCommand(PubCacheCommand());
          await pubRunner.run(['pub-cache']);
          await _pause();
          break;
        default:
          kLog('Invalid option.', type: LogType.warning);
          await _pause();
      }
    }
  }

  Future<void> _signingMenu() async {
    while (true) {
      _clearScreen();
      _beginSubCard('Signing & keys');
      _rowMenuOption(1, 'Create JKS keystore');
      _rowMenuOption(2, 'Generate SHA keys (SHA1 / SHA256)');
      _rowMenuOption(3, 'Generate hash key (Facebook / Google login)');
      _endSubCard(exitToShell: false);
      _outsidePrompt('0-3');
      final r = stdin.readLineSync()?.trim();
      if (r == '0') return;

      switch (r) {
        case '1':
          await CreateJksCommand().run();
          await _pause();
          break;
        case '2':
          await ShaKeysCommand().run();
          await _pause();
          break;
        case '3':
          await HashKeyCommand().run();
          await _pause();
          break;
        default:
          kLog('Invalid option.', type: LogType.warning);
          await _pause();
      }
    }
  }

  Future<void> _configurationMenu() async {
    while (true) {
      _clearScreen();
      _beginSubCard('Configuration');
      _rowMenuOption(1, 'Firebase (login / configure / check)');
      _rowMenuOption(2, 'Auto-setup assets');
      _endSubCard(exitToShell: false);
      _outsidePrompt('0-2');
      final r = stdin.readLineSync()?.trim();
      if (r == '0') return;

      switch (r) {
        case '1':
          await _showFirebaseSubMenu();
          break;
        case '2':
          await handleAssetSetup();
          await _pause();
          break;
        default:
          kLog('Invalid option.', type: LogType.warning);
          await _pause();
      }
    }
  }

  Future<void> _projectMenu() async {
    while (true) {
      _clearScreen();
      _beginSubCard('Project management');
      _rowMenuOption(1, 'Create new Flutter project');
      _rowMenuOption(2, 'Create GetX module');
      _rowMenuOption(3, 'Rename app / bundle ID');
      _endSubCard(exitToShell: false);
      _outsidePrompt('0-3');
      final r = stdin.readLineSync()?.trim();
      if (r == '0') return;

      switch (r) {
        case '1':
          await CreateProjectCommand().run();
          await _pause();
          break;
        case '2':
          await CreateModuleCommand().run();
          await _pause();
          break;
        case '3':
          await RenameCommand().run();
          await _pause();
          break;
        default:
          kLog('Invalid option.', type: LogType.warning);
          await _pause();
      }
    }
  }

  Future<void> _utilitiesMenu() async {
    while (true) {
      _clearScreen();
      _beginSubCard('Utilities');
      _rowMenuOption(1, 'Zip source code');
      _rowMenuOption(2, 'Check for updates (stable)');
      _rowMenuOption(3, 'Beta / dev update');
      _endSubCard(exitToShell: false);
      _outsidePrompt('0-3');
      final r = stdin.readLineSync()?.trim();
      if (r == '0') return;

      switch (r) {
        case '1':
          await ZipCommand().run();
          await _pause();
          break;
        case '2':
          await _handleUpdateCheck();
          await _pause();
          break;
        case '3':
          await _handleBetaUpdateCheck();
          await _pause();
          break;
        default:
          kLog('Invalid option.', type: LogType.warning);
          await _pause();
      }
    }
  }

  Future<void> _handleFullReset() async {
    stdout.write(
        'Wipe global build caches too (Xcode DerivedData, Gradle)? (y/N): ');
    final response = stdin.readLineSync()?.trim().toLowerCase();

    final runner = CommandRunner('dg', 'temp')..addCommand(CleanCommand());
    if (response == 'y') {
      await runner.run(['clean', '--global']);
    } else {
      await runner.run(['clean']);
    }
  }

  Future<void> _handleUpdateCheck() async {
    kLog('Checking for updates...', type: LogType.info);
    await VersionCommand().run();

    final latest = await VersionUtils.getLatestStableVersion();
    if (latest != null && VersionUtils.isNewer(latest, kDigCliVersion)) {
      final isLocal = Platform.script.toFilePath().contains('bin/dig_cli.dart');
      if (isLocal) {
        kLog(
            '\nNote: running from source; global activate will not change this checkout.',
            type: LogType.warning);
      }

      stdout.write('\nUpdate to v$latest now? (y/N): ');
      final response = stdin.readLineSync()?.trim().toLowerCase();
      if (response == 'y') {
        kLog('Updating DIG CLI...', type: LogType.info);
        final process = await Process.start(
            'dart', ['pub', 'global', 'activate', 'dig_cli'],
            mode: ProcessStartMode.inheritStdio);
        await process.exitCode;
      }
    }
  }

  Future<void> _handleBetaUpdateCheck() async {
    kLog('Checking for beta/dev updates...', type: LogType.info);
    await VersionCommand().run();

    final latest = await VersionUtils.getLatestPreReleaseVersion();
    if (latest != null && VersionUtils.isNewer(latest, kDigCliVersion)) {
      kLog(
        '\nBeta version available: v$latest',
        type: LogType.success,
      );
      stdout.write('\nInstall beta v$latest now? (y/N): ');
      final response = stdin.readLineSync()?.trim().toLowerCase();
      if (response == 'y') {
        kLog('Installing beta...', type: LogType.info);
        final process = await Process.start(
          'dart',
          ['pub', 'global', 'activate', 'dig_cli', latest],
          mode: ProcessStartMode.inheritStdio,
        );
        await process.exitCode;
      }
    } else {
      kLog(
        '\nNo newer beta/dev version.',
        type: LogType.success,
      );
    }
  }

  Future<void> _showFirebaseSubMenu() async {
    while (true) {
      _clearScreen();
      final email = await _getFirebaseEmail();
      _beginSubCard('Firebase', detail: email);
      final Map<String, List<String>> optionsMap = {};
      var index = 1;

      if (email == null) {
        _rowMenuOption(index, 'Login');
        optionsMap['$index'] = ['firebase', 'login'];
        index++;
      } else {
        _rowMenuOption(index, 'Logout');
        optionsMap['$index'] = ['firebase', 'logout'];
        index++;
      }

      _rowMenuOption(index, 'Configure (flutterfire)');
      optionsMap['$index'] = ['firebase', 'configure'];
      index++;

      _rowMenuOption(index, 'Check status');
      optionsMap['$index'] = ['firebase', 'check'];
      index++;

      _endSubCard(exitToShell: false);
      _outsidePrompt('0-${index - 1}');
      final response = stdin.readLineSync()?.trim();
      if (response == '0') break;

      final cmd = optionsMap[response];

      if (cmd != null) {
        final runner = CommandRunner('dg', 'temp')
          ..addCommand(FirebaseCommand());
        try {
          await runner.run(cmd);
        } catch (e) {
          kLog('Error: $e', type: LogType.error);
        }
        await _pause();
      } else {
        kLog('Invalid option.', type: LogType.warning);
        await _pause();
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
