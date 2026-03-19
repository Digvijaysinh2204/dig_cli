import 'dart:io';
import 'package:ansicolor/ansicolor.dart';
import 'package:args/command_runner.dart';
import 'commands/asset_command.dart';
import 'commands/firebase_command.dart';
import 'commands/build_command.dart';
import 'commands/clean_command.dart';
import 'commands/zip_command.dart';
import 'commands/rename_command.dart';

class InteractiveMenu {
  final AnsiPen titlePen = AnsiPen()..cyan(bold: true);
  final AnsiPen highlightPen = AnsiPen()..green(bold: true);
  final AnsiPen grayPen = AnsiPen()..gray();
  final AnsiPen accentPen = AnsiPen()..magenta(bold: true);

  int _selectedIndex = 0;

  List<Map<String, dynamic>> get _options => [
        {
          'label': '🎨 Setup Assets (Auto-detect & Generate)',
          'icon': '✨',
          'action': () => handleAssetSetup(),
        },
        {
          'label': '🔥 Firebase Setup & Configuration',
          'icon': '⚡',
          'action': () async {
            final email = await _getFirebaseEmail();
            final displayTitle =
                email != null ? 'FIREBASE SETUP ($email)' : 'FIREBASE SETUP';
            final subMenu = InteractiveMenu();
            await subMenu.show(
              title: displayTitle,
              options: [
                {
                  'label': 'Login',
                  'icon': '🔑',
                  'cmd': ['firebase', 'login']
                },
                {
                  'label': 'Logout',
                  'icon': '🚪',
                  'cmd': ['firebase', 'logout']
                },
                {
                  'label': 'Configure (flutterfire)',
                  'icon': '⚙️',
                  'cmd': ['firebase', 'configure']
                },
                {
                  'label': 'Check Status',
                  'icon': '🔍',
                  'cmd': ['firebase', 'check']
                },
                {'label': 'Back to Main Menu', 'icon': '⬅️', 'isBack': true},
              ],
              isSubMenu: true,
            );
          },
        },
        {
          'label': '🏗️ Build Project',
          'icon': '🚀',
          'action': () => BuildCommand().run(),
        },
        {
          'label': '🧹 Clean Project',
          'icon': '🧼',
          'action': () => CleanCommand().run(),
        },
        {
          'label': '📦 Zip Source Code',
          'icon': '🗜️',
          'action': () => ZipCommand().run(),
        },
        {
          'label': '🏷️ Rename Project/Bundle',
          'icon': '📝',
          'action': () => RenameCommand().run(),
        },
        {
          'label': '🚪 Exit',
          'icon': '✖️',
          'isExit': true,
          'action': () => exit(0),
        },
      ];

  void _printLogo() {
    print('\x1B[2J\x1B[0;0H'); // Clear console
    print(accentPen('  _____ _____ _____   _____ _      _____ '));
    print(accentPen(' |  __ \\_   _/ ____| / ____| |    |_   _|'));
    print(accentPen(' | |  | || || |  __ | |    | |      | |  '));
    print(accentPen(' | |  | || || | |_ || |    | |      | |  '));
    print(accentPen(' | |__| |_| || |__| || |____| |____ _| |_ '));
    print(accentPen(' |_____/|_____\\_____| \\_____|______|_____|'));
    print('');
    print(grayPen(' ─── Premium Flutter Developer companion ───'));
    print('');
  }

  Future<void> show({
    String title = 'MAIN MENU',
    List<Map<String, dynamic>>? options,
    bool isSubMenu = false,
  }) async {
    final menuOptions = options ?? _options;
    _selectedIndex = 0;

    // Save current terminal state
    final originalEchoMode = stdin.echoMode;
    final originalLineMode = stdin.lineMode;

    try {
      while (true) {
        _drawMenu(title, menuOptions);

        stdin.echoMode = false;
        stdin.lineMode = false;
        final bytes = stdin.readByteSync();

        if (bytes == 27) {
          // Escape sequence
          final b2 = stdin.readByteSync();
          if (b2 == 91) {
            final b3 = stdin.readByteSync();
            if (b3 == 65) {
              // Up arrow
              _selectedIndex = (_selectedIndex - 1) % menuOptions.length;
              if (_selectedIndex < 0) _selectedIndex = menuOptions.length - 1;
            } else if (b3 == 66) {
              // Down arrow
              _selectedIndex = (_selectedIndex + 1) % menuOptions.length;
            }
          }
        } else if (bytes == 13 || bytes == 10) {
          // Enter key
          final selected = menuOptions[_selectedIndex];

          if (selected['isExit'] == true) exit(0);
          if (selected['isBack'] == true) break;

          // Restore terminal state for command output
          stdin.echoMode = originalEchoMode;
          stdin.lineMode = originalLineMode;

          print('\n');
          if (selected['cmd'] != null) {
            final runner = CommandRunner('dg', 'temp')
              ..addCommand(FirebaseCommand());
            await runner.run(selected['cmd']);
          } else if (selected['action'] != null) {
            await selected['action']();
          }

          print(grayPen('\n(Press any key to continue...)'));
          stdin.echoMode = false;
          stdin.lineMode = false;
          stdin.readByteSync();
        }
      }
    } finally {
      stdin.echoMode = originalEchoMode;
      stdin.lineMode = originalLineMode;
    }
  }

  void _drawMenu(String title, List<Map<String, dynamic>> options) {
    _printLogo();
    print(titlePen('  $title'));
    print(grayPen('  ${'─' * (title.length + 2)}'));
    print('');

    for (int i = 0; i < options.length; i++) {
      final isSelected = i == _selectedIndex;
      final option = options[i];
      final prefix = isSelected ? '  ➤ ' : '    ';
      final text = option['label'];
      final icon = option['icon'] ?? '🔹';

      if (isSelected) {
        print(highlightPen('$prefix$icon $text'));
      } else {
        print(grayPen('$prefix$icon $text'));
      }
    }
    print('');
    print(grayPen('  (Use ↑/↓ arrows and Press Enter to select)'));
  }

  Future<String?> _getFirebaseEmail() async {
    try {
      final result = await Process.run('firebase', ['login']);
      final output = result.stdout.toString();
      if (output.contains('Already logged in as')) {
        final match = RegExp(r'Already logged in as ([\w.-]+@[\w.-]+\.\w+)')
            .firstMatch(output);
        return match?.group(1);
      }
    } catch (_) {}
    return null;
  }
}

Future<void> showInteractiveMenu() async {
  final menu = InteractiveMenu();
  await menu.show();
}
