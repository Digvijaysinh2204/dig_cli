import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dig_cli/src/commands/build_command.dart';
import 'package:dig_cli/src/commands/clean_command.dart';
import 'package:dig_cli/src/commands/rename_command.dart';
import 'package:dig_cli/src/commands/version_command.dart';
import 'package:dig_cli/src/commands/zip_command.dart';
import 'package:dig_cli/src/interactive_menu.dart';

void main(List<String> arguments) async {
  final runner = CommandRunner('dig', 'DIG CLI - A powerful Flutter companion')
    ..addCommand(BuildCommand())
    ..addCommand(CleanCommand())
    ..addCommand(ZipCommand())
    ..addCommand(RenameCommand())
    ..addCommand(VersionCommand());

  // Add global version flag
  runner.argParser.addFlag('version', abbr: 'v', negatable: false, help: 'Show version');

  if (arguments.isEmpty) {
    await showInteractiveMenu();
    return;
  }

  // Handle global flags before commands
  try {
    final argResults = runner.argParser.parse(arguments);
    if (argResults['version']) {
      await handleShowVersionCommand();
      return;
    }
  } catch (_) {
    // If parsing fails here, let the runner handle it
  }

  try {
    await runner.run(arguments);
  } on UsageException catch (e) {
    print(e);
    exit(64);
  } catch (e) {
    print('❌ An error occurred: $e');
    exit(1);
  }
}
