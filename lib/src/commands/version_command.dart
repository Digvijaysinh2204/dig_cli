import 'package:ansicolor/ansicolor.dart';
import 'package:args/command_runner.dart';

import '../version_helper.dart';

class VersionCommand extends Command {
  @override
  final name = 'version';
  @override
  final description =
      'Shows the current version and information about DIG CLI.';

  @override
  Future<void> run() async {
    const currentVersion = kDigCliVersion;
    final borderPen = AnsiPen()..blue();
    final titlePen = AnsiPen()..white(bold: true);
    final textPen = AnsiPen()..cyan();

    final title = 'DIG CLI TOOL v$currentVersion';
    final author = 'Made with ❤️ by Digvijaysinh Chauhan';
    final totalWidth = 42;

    final topBorder = '╔${'═' * (totalWidth - 2)}╗';
    final bottomBorder = '╚${'═' * (totalWidth - 2)}╝';

    print('');
    print(borderPen(topBorder));
    print(borderPen('║') +
        ' ' * ((totalWidth - title.length - 2) / 2).floor() +
        titlePen(title) +
        ' ' * ((totalWidth - title.length - 2) / 2).ceil() +
        borderPen('║'));
    print(borderPen('║') + ' ' * (totalWidth - 2) + borderPen('║'));
    print(borderPen('║') +
        ' ' * ((totalWidth - author.length - 2) / 2).floor() +
        textPen(author) +
        ' ' * ((totalWidth - author.length - 2) / 2).ceil() +
        borderPen('║'));
    print(borderPen(bottomBorder));
    print('');
  }
}

// For backward compatibility while refactoring others
Future<void> handleShowVersionCommand() async {
  await VersionCommand().run();
}
