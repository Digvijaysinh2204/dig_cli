import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import '../utils/logger.dart';
import '../ui/box_painter.dart';

class SetupAliasesCommand extends Command {
  @override
  final String name = 'setup-aliases';
  @override
  final String description =
      'Automatically injects DIG CLI aliases (dgm, dgp, dga, etc.) into your shell profile.';

  @override
  Future<void> run() async {
    final home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home == null) {
      kLog('❗ Could not determine home directory to set up aliases.',
          type: LogType.error);
      return;
    }

    final zshrc = File(p.join(home, '.zshrc'));
    final bashrc = File(p.join(home, '.bashrc'));
    final bashProfile = File(p.join(home, '.bash_profile'));

    File? targetProfile;

    if (await zshrc.exists()) {
      targetProfile = zshrc;
    } else if (await bashrc.exists()) {
      targetProfile = bashrc;
    } else if (await bashProfile.exists()) {
      targetProfile = bashProfile;
    }

    if (targetProfile == null) {
      kLog(
          '❗ Could not find .zshrc, .bashrc, or .bash_profile to inject aliases.',
          type: LogType.warning);
      // Create .zshrc as fallback on fresh macs
      targetProfile = File(p.join(home, '.zshrc'));
      kLog('  Creating new ~/.zshrc file.', type: LogType.info);
    }

    // Prompt for custom prefix
    stdout.write('  Enter your preferred shortcut prefix (default: dg): ');
    final input = stdin.readLineSync()?.trim();
    final String prefix = (input == null || input.isEmpty) ? 'dg' : input;

    final aliasesBlock = '''

# --- DIG CLI Custom Aliases ---
alias ${prefix}p="dg create-project"
alias ${prefix}m="dg create-module"
alias ${prefix}rm="dg remove-module"
alias ${prefix}c="dg clean"
alias ${prefix}a="dg asset build"
alias ${prefix}i="dg ios"
alias ${prefix}apk="dg create apk"
# ------------------------------
''';

    String content = '';
    if (await targetProfile.exists()) {
      content = await targetProfile.readAsString();
    }

    if (content.contains('# --- DIG CLI Custom Aliases ---')) {
      kLog(
          '✅ DIG CLI aliases are already installed in ${p.basename(targetProfile.path)}',
          type: LogType.success);
      return;
    }

    await targetProfile.writeAsString(aliasesBlock, mode: FileMode.append);

    final painter = BoxPainter();
    print('');
    painter.drawHeader('ALIASES INSTALLED SUCCESSFULLY', width: 50);
    painter.drawRow('Profile', p.basename(targetProfile.path), width: 50);
    painter.drawRow('Prefix', prefix, width: 50);
    painter.drawRow('Example', '${prefix}m (create-module)', width: 50);
    painter.drawRow('Example', '${prefix}p (create-project)', width: 50);
    painter.drawFooter(width: 50);

    kLog(
        '\n🚀 Run "source ~/${p.basename(targetProfile.path)}" to activate them immediately.',
        type: LogType.info);
  }
}
