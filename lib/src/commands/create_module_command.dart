import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import '../utils/logger.dart';
import '../utils/project_utils.dart';
import '../utils/spinner.dart';

class CreateModuleCommand extends Command {
  @override
  final name = 'create-module';
  @override
  final description =
      'Creates a new GetX module (View, Controller, Binding) and registers routes.';

  CreateModuleCommand() {
    argParser.addOption('name',
        abbr: 'n', help: 'The name of the new module (e.g., "auth")');
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
        stdout.write('Enter module name (e.g., auth): ');
        moduleName = stdin.readLineSync()?.trim();
      }
    }

    if (moduleName == null || moduleName.isEmpty) {
      kLog('❗ Module name is required.', type: LogType.error);
      return;
    }

    final String finalModuleName = moduleName;

    // Strip suffixes
    final String cleanModuleName = finalModuleName
        .replaceAll(
            RegExp(r'(View|Controller|Binding|Module)$', caseSensitive: false),
            '')
        .trim();

    final slug = _toSnakeCase(cleanModuleName);
    final className = _toPascalCase(cleanModuleName);
    final moduleDir = Directory(p.join('lib', 'app', 'module', slug));

    if (await moduleDir.exists()) {
      kLog('❗ Module $slug already exists.', type: LogType.error);
      return;
    }

    await runWithSpinner('🏗️  Scaffolding $className module...', () async {
      await Directory(p.join(moduleDir.path, 'view')).create(recursive: true);
      await Directory(p.join(moduleDir.path, 'controller'))
          .create(recursive: true);
      await Directory(p.join(moduleDir.path, 'binding'))
          .create(recursive: true);

      await _createController(moduleDir, className, slug);
      await _createBinding(moduleDir, className, slug);
      await _createView(moduleDir, className, slug);
      await _createExport(moduleDir, slug);
    });

    await runWithSpinner('🏷️  Registering Routes...', () async {
      await _registerRoute(className, slug);
      await _registerModuleExport(slug);
      await _registerPage(className, slug);
    });

    kLog('✅ Module $className created successfully!', type: LogType.success);
    kLog('💡 Route: AppRoute.${_toCamelCase(slug)}View', type: LogType.info);
  }

  Future<void> _createController(
      Directory dir, String className, String slug) async {
    final file =
        File(p.join(dir.path, 'controller', '${slug}_controller.dart'));
    final content = '''
import '../../../utils/import.dart';

class ${className}Controller extends GetxController {
  RxBool isLoading = false.obs;
}
''';
    await file.writeAsString(content);
  }

  Future<void> _createBinding(
      Directory dir, String className, String slug) async {
    final file = File(p.join(dir.path, 'binding', '${slug}_binding.dart'));
    final content = '''
import '../controller/${slug}_controller.dart';
import '../../../utils/import.dart';

class ${className}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<${className}Controller>(
      () => ${className}Controller(),
    );
  }
}
''';
    await file.writeAsString(content);
  }

  Future<void> _createView(Directory dir, String className, String slug) async {
    final file = File(p.join(dir.path, 'view', '${slug}_view.dart'));
    final content = '''
import '../../../utils/import.dart';
import '../controller/${slug}_controller.dart';

class ${className}View extends GetView<${className}Controller> {
  const ${className}View({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isAppBar: true,
      title: CustomTextView(
        text: '$className',
        style: AppTextStyle.appBarTitle(),
      ),
      body: Center(
        child: CustomTextView(
          text: '$className View is working',
          style: AppTextStyle.medium(size: 16),
        ),
      ),
    );
  }
}
''';
    await file.writeAsString(content);
  }

  Future<void> _createExport(Directory dir, String slug) async {
    final file = File(p.join(dir.path, '${slug}_export.dart'));
    final content = '''
export 'binding/${slug}_binding.dart';
export 'view/${slug}_view.dart';
export 'controller/${slug}_controller.dart';
''';
    await file.writeAsString(content);
  }

  Future<void> _registerModuleExport(String slug) async {
    final exportFile =
        File(p.join('lib', 'app', 'module', 'module_export.dart'));
    if (!await exportFile.exists()) return;

    final content = await exportFile.readAsString();
    final exportLine = "export '$slug/${slug}_export.dart';";
    if (content.contains(exportLine)) return;
    await exportFile.writeAsString('$content$exportLine\n');
  }

  Future<void> _registerRoute(String className, String slug) async {
    final file = File(p.join('lib', 'app', 'routes', 'app_route.dart'));
    if (!await file.exists()) return;

    final content = await file.readAsString();
    final routeName = _toCamelCase(slug);
    if (content.contains('${routeName}View =')) return;

    final updatedContent = content.replaceFirst(
        '}', "  static const ${routeName}View = '/${className}View';\n}");
    await file.writeAsString(updatedContent);
  }

  Future<void> _registerPage(String className, String slug) async {
    final file = File(p.join('lib', 'app', 'routes', 'app_page.dart'));
    if (!await file.exists()) return;

    String content = await file.readAsString();
    final routeName = _toCamelCase(slug);

    if (!content.contains('AppRoute.${routeName}View')) {
      final newPage = '''
    GetPage(
      name: AppRoute.${routeName}View,
      page: () => const ${className}View(),
      binding: ${className}Binding(),
    ),''';
      content = content.replaceFirst('];', '$newPage\n  ];');
    }
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
    final snake = _toSnakeCase(input);
    return snake
        .split('_')
        .map((s) => s[0].toUpperCase() + s.substring(1))
        .join();
  }

  String _toCamelCase(String input) {
    final pascal = _toPascalCase(input);
    return pascal[0].toLowerCase() + pascal.substring(1);
  }
}
