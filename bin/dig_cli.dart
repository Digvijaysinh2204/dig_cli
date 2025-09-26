// file: bin/dig_cli.dart

import 'dart:io';

import 'package:args/args.dart';
import 'package:dig_cli/src/commands/build_command.dart';
import 'package:dig_cli/src/commands/clean_command.dart';
import 'package:dig_cli/src/commands/version_command.dart';
import 'package:dig_cli/src/commands/zip_command.dart';
import 'package:dig_cli/src/interactive_menu.dart';
import 'package:dig_cli/src/utils/logger.dart';

void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    await showInteractiveMenu();
    return;
  }

  final parser = ArgParser()
    ..addFlag('version', abbr: 'v', negatable: false, help: 'Show version')
    ..addCommand('create', ArgParser(allowTrailingOptions: true))
    ..addCommand('clean')
    ..addCommand('zip');

  ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } catch (e) {
    kLog('❌ Invalid arguments: $e', type: LogType.error);
    exit(64);
  }

  if (argResults['version']) {
    await handleShowVersionCommand();
    return;
  }

  if (argResults.command != null) {
    switch (argResults.command?.name) {
      case 'create':
        await handleBuildCommand(argResults.command!.arguments);
        break;
      case 'clean':
        await handleCleanCommand();
        break;
      case 'zip':
        await handleZipCommand();
        break;
      default:
        kLog('Unknown command: ${argResults.command?.name}',
            type: LogType.error);
        exit(64);
    }
  } else {
    kLog('Usage: dig <command> [options]');
    kLog('Commands: create, clean, zip');
  }
}
