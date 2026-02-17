import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import '../utils/logger.dart';
import '../utils/project_utils.dart';
import '../utils/spinner.dart';
import 'asset_command.dart';
import 'create_jks_command.dart';

class CreateProjectCommand extends Command {
  @override
  final name = 'create-project';
  @override
  final description =
      'Creates a new Flutter project from a template and sets up signing.';

  CreateProjectCommand() {
    argParser.addOption('name',
        abbr: 'n',
        help: 'The name of the new project folder/slug (e.g., "my_app")');
    argParser.addOption('app-name',
        abbr: 'a', help: 'The app display name (e.g., "My Awesome App")');
    argParser.addOption('bundle-id',
        abbr: 'b', help: 'The bundle ID/package name (e.g., com.example.app)');
    argParser.addOption('output',
        abbr: 'o', help: 'The directory where the project should be created');
  }

  @override
  Future<void> run() async {
    kLog('\n🚀 CREATE PROJECT FROM TEMPLATE', type: LogType.info);

    // 1. Get Project Details
    String? projectName = argResults?['name'] as String?;
    if (projectName == null || projectName.isEmpty) {
      stdout.write('Enter project name (for folder & pubspec, e.g., my_app): ');
      projectName = stdin.readLineSync()?.trim();
    }
    if (projectName == null || projectName.isEmpty) {
      kLog('❗ Project name is required.', type: LogType.error);
      return;
    }

    // Slugify the project name for safety
    final slug =
        projectName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');

    String? appName = argResults?['app-name'] as String?;
    if (appName == null || appName.isEmpty) {
      stdout.write('Enter app display name (e.g., My Awesome App): ');
      appName = stdin.readLineSync()?.trim();
    }
    if (appName == null || appName.isEmpty) {
      appName = projectName; // Fallback to project name
    }

    String? bundleId = argResults?['bundle-id'] as String?;
    if (bundleId == null || bundleId.isEmpty) {
      stdout.write('Enter bundle ID (e.g., com.awesome.app): ');
      bundleId = stdin.readLineSync()?.trim();
    }
    if (bundleId == null ||
        bundleId.isEmpty ||
        !RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*(\.[a-zA-Z][a-zA-Z0-9_]*)*$')
            .hasMatch(bundleId)) {
      kLog(
          '❗ Valid bundle ID is required (e.g., com.example.app or com.example).',
          type: LogType.error);
      return;
    }

    String? outputDir = argResults?['output'] as String?;
    if (outputDir == null || outputDir.isEmpty) {
      stdout.write('Enter output path (press enter for default ./$slug): ');
      final input = stdin.readLineSync()?.trim();
      if (input != null && input.isNotEmpty) {
        outputDir = input;
      }
    }

    final targetDir = outputDir != null && outputDir.isNotEmpty
        ? Directory(p.absolute(outputDir))
        : Directory(p.join(Directory.current.path, slug));

    if (await targetDir.exists()) {
      kLog('❗ Directory ${targetDir.path} already exists.',
          type: LogType.error);
      return;
    }

    // 2. Locate Template
    String? templatePath = await _findTemplatePath();
    if (templatePath == null) {
      kLog(
          '❗ Template structure not found. Please ensure you are running the command from a valid installation.',
          type: LogType.error);
      return;
    }

    kLog('📂 Creating project at: ${targetDir.path}', type: LogType.info);
    kLog('🏗️  Using template: $templatePath', type: LogType.info);

    try {
      // 3. Run Flutter Create as Base
      await runWithSpinner('🚀 Running flutter create...', () async {
        // Calculate org from bundleId
        String org = 'com.example';
        if (bundleId!.contains('.')) {
          final parts = bundleId.split('.');
          org = parts.sublist(0, parts.length - 1).join('.');
        }

        final result = await Process.run('flutter', [
          'create',
          '--project-name',
          slug,
          '--org',
          org,
          '--description',
          'Created using DIG CLI',
          targetDir.path,
        ]);

        if (result.exitCode != 0) {
          throw Exception('flutter create failed: ${result.stderr}');
        }
      });

      // 3.5 Cleanup Default Assets (To prevent duplicates/ghost files)
      await runWithSpinner('🧹 Clearing default Flutter assets...', () async {
        await _cleanupDefaultFlutterAssets(targetDir);
      });

      // 4. Overlay Template Structure (File-by-File Overlay)
      await runWithSpinner('📝 Applying template overlay...', () async {
        // Iterate through template files (skipping test/)
        await _overlayTemplateFiles(Directory(templatePath), targetDir);

        // C. Merge Pubspec Dependencies
        await _mergePubspec(targetDir, templatePath);
      });

      // 5. Rebranding & Configuration
      await runWithSpinner('🏷️  Finalizing configuration...', () async {
        // 1. Update Imports
        await _updateDartImports(targetDir, slug);

        // 2. Configure Android Signing
        await _configureAndroidSigning(targetDir);

        // 3. Update README
        await _updateReadme(targetDir, projectName!);

        // 4. Ensure Manifest/Plist have correct names
        await _updateAllAppNames(targetDir, appName!);

        // 5. Ensure bundle IDs are correct (explicit check)
        await _updateAllBundleIds(targetDir, bundleId!);

        // 6. Generate Secure API Key for .env
        await _generateAndInjectSecureKey(targetDir);
      });

      // 6. Generate JKS
      kLog('\n🔑 Setting up Android Signing (0-Work)...', type: LogType.info);
      final originalCwd = Directory.current;
      Directory.current = targetDir;
      resetProjectRootCache();

      final jksRunner = CommandRunner('dg', 'temp')
        ..addCommand(CreateJksCommand());

      await jksRunner.run([
        'create-jks',
        '--no-interactive',
        '--location',
        p.join(targetDir.path, 'android', 'app'),
        '--name',
        slug,
        '--store-pass',
        '123456',
        '--key-pass',
        '123456',
        '--alias',
        'key',
      ]);

      // 7. Cleanup & Finish
      await runWithSpinner('🧹 Cleaning up...', () async {
        // Ensure sample.jks is gone if it somehow got copied
        final sampleJks =
            File(p.join(targetDir.path, 'android', 'app', 'sample.jks'));
        if (await sampleJks.exists()) {
          await sampleJks.delete();
        }

        // Run pub get
        final result = await Process.run('flutter', ['pub', 'get']);
        if (result.exitCode != 0) {
          kLog('⚠️  flutter pub get failed, you might need to run it manually.',
              type: LogType.warning);
        }

        // Run asset generation
        try {
          await buildAssets();
        } catch (e) {
          kLog('⚠️  Initial asset generation failed: $e',
              type: LogType.warning);
        }
      });

      Directory.current = originalCwd;

      kLog('\n✅ PROJECT CREATED SUCCESSFULLY!', type: LogType.success);
      kLog('📁 Path: ${targetDir.path}', type: LogType.info);
      kLog('🚀 Open it in VS Code: code ${targetDir.path}', type: LogType.info);
    } catch (e) {
      kLog('❌ Error creating project: $e', type: LogType.error);
    }
  }

  Future<String?> _findTemplatePath() async {
    try {
      final uri = await Isolate.resolvePackageUri(Uri.parse(
          'package:dig_cli/src/commands/create_project_command.dart'));
      if (uri != null) {
        final filePath = uri.toFilePath();
        final packageRoot =
            p.dirname(p.dirname(p.dirname(p.dirname(filePath))));
        final templatePath = p.join(packageRoot, 'sample', 'structure');
        if (await Directory(templatePath).exists()) {
          return templatePath;
        }
      }
    } catch (_) {}

    try {
      final templatePubspecUri = await Isolate.resolvePackageUri(
          Uri.parse('package:dig_cli/../../sample/structure/pubspec.yaml'));
      if (templatePubspecUri != null) {
        final pubspecPath = templatePubspecUri.toFilePath();
        final templatePath = p.dirname(pubspecPath);
        if (await Directory(templatePath).exists()) {
          return templatePath;
        }
      }
    } catch (_) {}

    try {
      final scriptPath = Platform.script.toFilePath();
      if (scriptPath.endsWith('.dart') || scriptPath.endsWith('.snapshot')) {
        Directory current = File(scriptPath).parent;
        for (int i = 0; i < 5; i++) {
          final templatePath = p.join(current.path, 'sample', 'structure');
          if (await Directory(templatePath).exists()) {
            return templatePath;
          }
          current = current.parent;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> _overlayTemplateFiles(
      Directory source, Directory destination) async {
    await destination.create(recursive: true);
    await for (var entity in source.list(recursive: false)) {
      final base = p.basename(entity.path);

      // 1. Skip Test Directory (Keep Flutter's default)
      if (base == 'test') {
        continue;
      }

      if (entity is Directory) {
        if (base == 'build' ||
            base == 'Pods' ||
            base == '.dart_tool' ||
            base == '.idea' ||
            base == '.vscode' ||
            base == '.git') {
          continue;
        }
        final newDirectory = Directory(p.join(destination.path, base));
        await _overlayTemplateFiles(entity, newDirectory);
      } else if (entity is File) {
        if (base == '.DS_Store' ||
            base == 'pubspec.lock' ||
            base == 'Podfile.lock' ||
            base == 'README.md' ||
            base.startsWith('.flutter-plugins')) {
          continue;
        }

        // 2. Overwrite or Create
        await entity.copy(p.join(destination.path, base));
      }
    }
  }

  Future<void> _updateDartImports(Directory projectDir, String newSlug) async {
    try {
      final absolutePath = p.absolute(projectDir.path);
      final dirsToProcess = [
        Directory(p.join(absolutePath, 'lib')),
        Directory(p.join(absolutePath, 'test')),
        Directory(p.join(absolutePath, 'android')),
        Directory(p.join(absolutePath, 'ios')),
      ];

      for (final dir in dirsToProcess) {
        if (!await dir.exists()) {
          continue;
        }
        await _processDirectoryForImports(dir, newSlug);
      }
      await _processDirectoryForImports(Directory(absolutePath), newSlug,
          recursive: false);
    } catch (e) {
      kLog('Error in _updateDartImports: $e', type: LogType.error);
    }
  }

  Future<void> _processDirectoryForImports(Directory dir, String newSlug,
      {bool recursive = true}) async {
    try {
      final entities = dir.listSync(recursive: recursive);
      for (var entity in entities) {
        if (entity is! File) {
          continue;
        }
        final ext = p.extension(entity.path);
        if (ext == '.dart' ||
            ext == '.yaml' ||
            ext == '.gradle' ||
            ext == '.kts' ||
            ext == '.xml' ||
            ext == '.plist' ||
            ext == '.json' ||
            ext == '.md') {
          try {
            String content = await entity.readAsString();
            bool changed = false;
            // Handle project name placeholder
            if (content.contains('PROJECT_NAME')) {
              content = content.replaceAll('PROJECT_NAME', newSlug);
              changed = true;
            }
            // Handle package import placeholder
            if (content.contains('package:structure/')) {
              content =
                  content.replaceAll('package:structure/', 'package:$newSlug/');
              changed = true;
            }

            if (changed) {
              await entity.writeAsString(content);
            }
          } catch (_) {}
        }
      }
    } catch (_) {}
  }

  Future<void> _updateReadme(Directory projectDir, String projectName) async {
    final readmeFile = File(p.join(projectDir.path, 'README.md'));
    final content = '''# 📱 $projectName

Created with building blocks from **DIG CLI**.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

## ✨ Features
This project comes pre-configured with a robust foundation:
- 🏗️ **Solid Architecture**: Standardized folder structure for scalability.
- 🔐 **Secure Defaults**: Auto-generated `API_KEY` and `.env` setup.
- 🤖 **Android Ready**: Automated JKS signing configuration.
- 🖼️ **Asset Generation**: Type-safe asset management pre-configured.
- 🔥 **Firebase Prepared**: Skeleton setup for easy integration.

## 🚀 Getting Started

### 1️⃣ Setup Environment
```bash
# Get dependencies
flutter pub get

# Configure Firebase (Required)
flutterfire configure
```

### 2️⃣ Asset Generation
Type-safe asset classes are automatically generated from your `assets/` folder.
- **Generate once**: `dg asset build`
- **Watch mode**: `dg asset watch`

For more details, see [ASSET_GENERATION_GUIDE.md](ASSET_GENERATION_GUIDE.md).

### 3️⃣ Run the App
```bash
# Development
flutter run

# Release Build
flutter build apk --release
```

## 📂 Project Structure
```text
lib/
├── main.dart          # Entry point
├── core/              # Shared utilities & configs
└── features/          # Feature-based organization
```

---
Generated by [DIG CLI](https://pub.dev/packages/dig_cli) 🚀
''';
    await readmeFile.writeAsString(content);
  }

  Future<void> _updateAllAppNames(Directory projectDir, String name) async {
    final manifestFile = File(
        p.join(projectDir.path, 'android/app/src/main/AndroidManifest.xml'));
    if (await manifestFile.exists()) {
      String content = await manifestFile.readAsString();
      content = content.replaceFirst(
          RegExp(r'android:label="[^"]*"'), 'android:label="$name"');
      await manifestFile.writeAsString(content);
    }
    final infoPlist = File(p.join(projectDir.path, 'ios/Runner/Info.plist'));
    if (await infoPlist.exists()) {
      String content = await infoPlist.readAsString();
      content = content.replaceFirst(
          RegExp(r'<key>CFBundleDisplayName</key>\s*<string>[^<]*</string>'),
          '<key>CFBundleDisplayName</key>\n\t<string>$name</string>');
      content = content.replaceFirst(
          RegExp(r'<key>CFBundleName</key>\s*<string>[^<]*</string>'),
          '<key>CFBundleName</key>\n\t<string>$name</string>');
      await infoPlist.writeAsString(content);
    }

    final appConstantFile =
        File(p.join(projectDir.path, 'lib/app/constants/app_constant.dart'));
    if (await appConstantFile.exists()) {
      String content = await appConstantFile.readAsString();
      content = content.replaceFirst(
        "static const String appName = 'Structure'",
        "static const String appName = '$name'",
      );
      await appConstantFile.writeAsString(content);
    }
  }

  Future<void> _updateAllBundleIds(Directory projectDir, String newId) async {
    File? buildGradle;
    final gradleKts =
        File(p.join(projectDir.path, 'android/app/build.gradle.kts'));
    final gradle = File(p.join(projectDir.path, 'android/app/build.gradle'));
    if (await gradleKts.exists()) {
      buildGradle = gradleKts;
    } else if (await gradle.exists()) {
      buildGradle = gradle;
    }
    if (buildGradle != null) {
      String content = await buildGradle.readAsString();
      final appIdMatch =
          RegExp(r'applicationId\s*[=]?\s*"([^"]+)"').firstMatch(content);
      final oldId = appIdMatch?.group(1);
      content = content
          .replaceAllMapped(RegExp(r'applicationId\s*(=)?\s*"[^"]+"'), (match) {
        return match.group(1) != null
            ? 'applicationId = "$newId"'
            : 'applicationId "$newId"';
      });
      content = content.replaceAllMapped(RegExp(r'namespace\s*(=)?\s*"[^"]+"'),
          (match) {
        return match.group(1) != null
            ? 'namespace = "$newId"'
            : 'namespace "$newId"';
      });
      await buildGradle.writeAsString(content);
      if (oldId != null) {
        await _restructureAndroidDirs(projectDir, oldId, newId);
      }
    }
    final pbxproj =
        File(p.join(projectDir.path, 'ios/Runner.xcodeproj/project.pbxproj'));
    if (await pbxproj.exists()) {
      String content = await pbxproj.readAsString();
      content = content.replaceAll('com.example.structure', newId);
      await pbxproj.writeAsString(content);
    }
    final infoPlist = File(p.join(projectDir.path, 'ios/Runner/Info.plist'));
    if (await infoPlist.exists()) {
      String content = await infoPlist.readAsString();
      if (!content.contains(r'$(PRODUCT_BUNDLE_IDENTIFIER)')) {
        content = content.replaceFirst(
          RegExp(r'<key>CFBundleIdentifier</key>\s*<string>[^<]+</string>'),
          '<key>CFBundleIdentifier</key>\n\t<string>$newId</string>',
        );
      }
      await infoPlist.writeAsString(content);
    }
    final filesToUpdate = [
      p.join(projectDir.path, 'android/app/google-services.json'),
      p.join(projectDir.path, 'ios/Runner/GoogleService-Info.plist'),
      p.join(projectDir.path, 'lib/firebase_options.dart')
    ];
    for (final path in filesToUpdate) {
      final file = File(path);
      if (await file.exists()) {
        String content = await file.readAsString();
        content = content.replaceAll('com.example.structure', newId);
        await file.writeAsString(content);
      }
    }
  }

  Future<void> _restructureAndroidDirs(
      Directory projectDir, String oldId, String newId) async {
    final oldPath = oldId.replaceAll('.', '/');
    final newPath = newId.replaceAll('.', '/');
    final appSrc = p.join(projectDir.path, 'android/app/src');
    for (var type in ['main', 'debug', 'profile']) {
      for (var lang in ['kotlin', 'java']) {
        final sourceDir = Directory(p.join(appSrc, type, lang, oldPath));
        if (await sourceDir.exists()) {
          final targetPath = p.join(appSrc, type, lang, newPath);
          await Directory(targetPath).create(recursive: true);
          await for (var entity in sourceDir.list()) {
            final base = p.basename(entity.path);
            await entity.rename(p.join(targetPath, base));
          }
          var current = sourceDir;
          while (current.path != p.join(appSrc, type, lang) &&
              (await current.list().isEmpty)) {
            final parent = current.parent;
            await current.delete();
            current = parent;
          }
        }
      }
    }

    // After moving files, we must update the package declaration in the source files.
    final newPathSegment = newId.replaceAll('.', '/');
    for (var type in ['main', 'debug', 'profile']) {
      for (var lang in ['kotlin', 'java']) {
        final sourceDir = Directory(p.join(appSrc, type, lang, newPathSegment));
        if (await sourceDir.exists()) {
          await for (var entity in sourceDir.list(recursive: true)) {
            if (entity is File &&
                (entity.path.endsWith('.kt') ||
                    entity.path.endsWith('.java'))) {
              String content = await entity.readAsString();
              if (content.contains('package $oldId')) {
                content =
                    content.replaceAll('package $oldId', 'package $newId');
                await entity.writeAsString(content);
              }
            }
          }
        }
      }
    }
  }

  Future<void> _mergePubspec(Directory projectDir, String templatePath) async {
    final targetPubspec = File(p.join(projectDir.path, 'pubspec.yaml'));
    final templatePubspec = File(p.join(templatePath, 'pubspec.yaml'));

    if (await targetPubspec.exists() && await templatePubspec.exists()) {
      String templateContent = await templatePubspec.readAsString();
      // Update name to match the new project slug
      templateContent = templateContent.replaceFirst(
          RegExp(r'name:\s+.*'), 'name: ${p.basename(projectDir.path)}');
      // Update description
      templateContent = templateContent.replaceFirst(
          RegExp(r'description:\s+.*'), 'description: Created using DIG CLI');

      // Write the template's pubspec (with updated name) to the target,
      // effectively "merging" by overwriting with our desired structure.
      // This ensures all assets, fonts, and dependencies are exactly as in template.
      await targetPubspec.writeAsString(templateContent);
    }
  }

  Future<void> _configureAndroidSigning(Directory projectDir) async {
    // Inject signing config into android/app/build.gradle
    final buildGradle =
        File(p.join(projectDir.path, 'android', 'app', 'build.gradle'));
    if (await buildGradle.exists()) {
      String content = await buildGradle.readAsString();

      // 1. Add keystore loading logic before android {} block
      const keystoreLoader = '''
def keystorePropertiesFile = rootProject.file("key.properties")
def keystoreProperties = new Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

''';
      if (!content.contains('def keystoreProperties')) {
        content = keystoreLoader + content;
      }

      // 2. Add signingConfigs inside android {}
      if (!content.contains('signingConfigs {')) {
        final signingConfig = '''
    signingConfigs {
        release {
            keyAlias = keystoreProperties['keyAlias']
            keyPassword = keystoreProperties['keyPassword']
            storeFile = keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword = keystoreProperties['storePassword']
        }
    }
''';
        // Insert at start of android { block
        content =
            content.replaceFirst('android {', 'android {\n$signingConfig');
      }

      // 3. Apply signingConfig to release buildType
      if (!content.contains('signingConfig signingConfigs.release')) {
        content = content.replaceFirst('buildTypes {\n        release {',
            'buildTypes {\n        release {\n            signingConfig signingConfigs.release');
      }

      await buildGradle.writeAsString(content);
    }
  }

  Future<void> _generateAndInjectSecureKey(Directory projectDir) async {
    final envFile = File(p.join(projectDir.path, '.env'));
    if (await envFile.exists()) {
      // Generate 32 bytes of secure random data
      final random = Random.secure();
      final values = List<int>.generate(32, (i) => random.nextInt(256));
      final secureKey = base64UrlEncode(values);

      String content = await envFile.readAsString();
      // Replace existing API key or append if missing
      if (content.contains('API_KEY=')) {
        content =
            content.replaceFirst(RegExp(r'API_KEY=.*'), 'API_KEY=$secureKey');
      } else {
        content += '\nAPI_KEY=$secureKey';
      }
      await envFile.writeAsString(content);
      kLog('🔐 Generated secure API_KEY in .env', type: LogType.info);
    }
  }

  Future<void> _cleanupDefaultFlutterAssets(Directory projectDir) async {
    final pathsToDelete = [
      // Android: Remove default resources (icons, styles) and sources (kotlin/java)
      // We want our template to be the source of truth, not a merge.
      'android/app/src/main/res',
      'android/app/src/main/kotlin',
      'android/app/src/main/java',
      // iOS: Remove default assets (AppIcon)
      'ios/Runner/Assets.xcassets',
    ];

    for (final path in pathsToDelete) {
      final dir = Directory(p.join(projectDir.path, path));
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    }
  }
}
