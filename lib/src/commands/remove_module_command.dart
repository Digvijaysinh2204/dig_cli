import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import '../utils/logger.dart';
import '../utils/project_utils.dart';
import '../utils/spinner.dart';
import '../ui/box_painter.dart';

class RemoveModuleCommand extends Command {
  @override
  final name = 'remove-module';
  @override
  final description =
      'Removes an existing GetX module and unregisters its routes.';

  RemoveModuleCommand() {
    argParser.addOption('name',
        abbr: 'n', help: 'The name of the module to remove (e.g., "auth")');
  }

  @override
  Future<void> run() async {
    if (!await isFlutterProject()) {
      kLog('❗ This command must be run inside a Flutter project.',
          type: LogType.error);
      return;
    }

    String? moduleName = argResults?['name'] as String?;
    if (moduleName == null || moduleName.isEmpty) {
      if (argResults!.rest.isNotEmpty) {
        moduleName = argResults!.rest.first;
      } else {
        stdout.write('Enter module name to remove (e.g., auth): ');
        moduleName = stdin.readLineSync()?.trim();
      }
    }

    if (moduleName == null || moduleName.isEmpty) {
      kLog('❗ Module name is required.', type: LogType.error);
      return;
    }

    final cleanModuleName = moduleName
        .replaceAll(
            RegExp(r'_?(View|Controller|Binding|Module)$',
                caseSensitive: false),
            '')
        .trim();

    final slug = _toSnakeCase(cleanModuleName);
    final className = _toPascalCase(cleanModuleName);
    final moduleDir = Directory(p.join('lib', 'app', 'module', slug));

    if (!await moduleDir.exists()) {
      kLog('❗ Module $slug does not exist.', type: LogType.error);
      return;
    }

    await runWithSpinner('🗑️  Removing $className module...', () async {
      // 1. Delete Module Directory
      await moduleDir.delete(recursive: true);

      // 2. Unregister Module Export
      await _unregisterModuleExport(slug);

      // 3. Unregister Route
      await _unregisterRoute(className, slug);

      // 4. Unregister Page
      await _unregisterPage(className, slug);
    });

    final painter = BoxPainter();
    print('');
    painter.drawHeader('MODULE REMOVED SUCCESSFULLY', width: 50);
    painter.drawRow('Module', className, width: 50);
    painter.drawRow('Route', 'AppRoute.${_toCamelCase(slug)}', width: 50);
    painter.drawRow('Status', 'Cleaned up all code blocks', width: 50);
    painter.drawFooter(width: 50);

    kLog('\n✅ Module $className has been completely removed!', type: LogType.success);
  }

  Future<void> _unregisterModuleExport(String slug) async {
    final exportFile =
        File(p.join('lib', 'app', 'module', 'module_export.dart'));
    if (!await exportFile.exists()) return;

    final content = await exportFile.readAsString();
    final exportLine = "export '$slug/${slug}_export.dart';";
    if (!content.contains(exportLine)) return;

    final lines = content.split('\n');
    lines.removeWhere((l) => l.trim() == exportLine);
    await exportFile.writeAsString(lines.join('\n'));
  }

  Future<void> _unregisterRoute(String className, String slug) async {
    final file = File(p.join('lib', 'app', 'routes', 'app_route.dart'));
    if (!await file.exists()) return;

    final content = await file.readAsString();
    final routeName = _toCamelCase(slug);

    final lines = content.split('\n');
    lines.removeWhere((l) => l.contains('static const String $routeName ='));
    await file.writeAsString(lines.join('\n'));
  }

  Future<void> _unregisterPage(String className, String slug) async {
    final file = File(p.join('lib', 'app', 'routes', 'app_page.dart'));
    if (!await file.exists()) return;

    String content = await file.readAsString();
    final routeName = _toCamelCase(slug);

    final blockRegex = RegExp(
        r'\s*GetPage\([\s\S]*?name:\s*AppRoute\.' +
            routeName +
            r',[\s\S]*?\),?',
        multiLine: true);

    content = content.replaceAll(blockRegex, '');
    await file.writeAsString(content);
  }

  String _toSnakeCase(String input) {
    return input
        .replaceAllMapped(
            RegExp(r'([A-Z])'), (match) => '_${match.group(1)!.toLowerCase()}')
        .replaceAll(RegExp(r'^\_'), '')
        .toLowerCase();
  }

  String _toPascalCase(String input) {
    if (input.isEmpty) return '';
    final snake = _toSnakeCase(input);
    return snake
        .split('_')
        .where((s) => s.isNotEmpty)
        .map((s) => s[0].toUpperCase() + s.substring(1))
        .join();
  }

  String _toCamelCase(String input) {
    if (input.isEmpty) return '';
    final pascal = _toPascalCase(input);
    if (pascal.isEmpty) return '';
    return pascal[0].toLowerCase() + pascal.substring(1);
  }
}
