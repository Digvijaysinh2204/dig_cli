import 'dart:io';
import 'dart:isolate';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import '../utils/logger.dart';
import '../utils/project_utils.dart';
import '../utils/spinner.dart';
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
        !RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$').hasMatch(bundleId)) {
      kLog('❗ Valid bundle ID is required (e.g., com.example.app).',
          type: LogType.error);
      return;
    }

    String? outputDir = argResults?['output'] as String?;
    if (outputDir == null || outputDir.isEmpty) {
      outputDir = p.join(Directory.current.path, slug);
    } else {
      outputDir = p.join(outputDir, slug);
    }

    final targetDir = Directory(outputDir);
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
      // 3. Copy Template
      await runWithSpinner('📝 Copying template files...', () async {
        await _copyDirectory(Directory(templatePath!), targetDir);
        // Create sensitive skeleton files
        await _createSkeletonFiles(targetDir);
      });

      // 4. Rename Project Logic
      final originalCwd = Directory.current;
      Directory.current = targetDir;
      resetProjectRootCache();

      await runWithSpinner('🏷️  Setting project names and bundle IDs...',
          () async {
        // 1. Update pubspec.yaml name
        await _updatePubspecName(targetDir, slug);

        // 2. Global Replacement of "structure" in Dart files (for imports)
        await _updateDartImports(targetDir, 'structure', slug);

        // 3. Update Android settings.gradle
        await _updateSettingsGradle(targetDir, slug);

        // 4. Update Rebranding (Android Display Name, iOS Bundle ID etc)
        await _updateAllAppNames(appName!);
        await _updateAllBundleIds(bundleId!);

        // 5. Update README with credit
        await _updateReadme(targetDir, appName);
      });

      // 5. Setup Signing (Create JKS)
      kLog('\n🔑 Setting up Android Signing (0-Work)...', type: LogType.info);
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

      // 6. Pub Get
      await runWithSpinner('📦 Fetching dependencies (flutter pub get)...',
          () async {
        final result = await Process.run('flutter', ['pub', 'get']);
        if (result.exitCode != 0) {
          kLog('⚠️  flutter pub get failed, you might need to run it manually.',
              type: LogType.warning);
        }
      });

      Directory.current = originalCwd;

      kLog('\n✅ PROJECT CREATED SUCCESSFULLY!', type: LogType.success);
      kLog('📁 Path: ${targetDir.path}', type: LogType.info);
      kLog('🚀 Open it in VS Code: code ${targetDir.path}', type: LogType.info);
      kLog('\n🔔 IMPORTANT: Firebase is pre-configured with skeletons.',
          type: LogType.warning);
      kLog('👉 Run "flutterfire configure" to complete your Firebase setup.',
          type: LogType.info);
    } catch (e) {
      kLog('❌ Error creating project: $e', type: LogType.error);
    }
  }

  Future<String?> _findTemplatePath() async {
    // 1. Try to find relative to the package's lib directory (works for pub global run)
    try {
      final packageUri = await Isolate.resolvePackageUri(Uri.parse(
          'package:dig_cli/src/commands/create_project_command.dart'));
      if (packageUri != null) {
        final packagePath =
            p.dirname(p.dirname(p.dirname(p.fromUri(packageUri))));
        final path = p.join(packagePath, 'sample', 'structure');
        if (await Directory(path).exists()) return path;
      }
    } catch (_) {}

    // 2. Try relative to Platform.script (works for local dev)
    try {
      final scriptFile = Platform.script.toFilePath();
      final cliDir = p.dirname(p.dirname(scriptFile));
      final path = p.join(cliDir, 'sample', 'structure');
      if (await Directory(path).exists()) return path;
    } catch (_) {}

    // 3. Try relative to the executable (works for compiled binaries)
    try {
      final exePath = Platform.resolvedExecutable;
      final exeDir = p.dirname(exePath);
      final path = p.join(exeDir, 'sample', 'structure');
      if (await Directory(path).exists()) return path;

      final parentDir = p.dirname(exeDir);
      final path2 = p.join(parentDir, 'sample', 'structure');
      if (await Directory(path2).exists()) return path2;
    } catch (_) {}

    // 4. Try current directory as last resort
    final localPath = p.join(Directory.current.path, 'sample', 'structure');
    if (await Directory(localPath).exists()) return localPath;

    return null;
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await destination.create(recursive: true);
    await for (var entity in source.list(recursive: false)) {
      final base = p.basename(entity.path);
      if (entity is Directory) {
        // Skip transient/build folders
        if (base == 'build' ||
            base == 'Pods' ||
            base == '.dart_tool' ||
            base == '.idea' ||
            base == '.vscode' ||
            base == '.git') {
          continue;
        }
        final newDirectory = Directory(p.join(destination.path, base));
        await _copyDirectory(entity, newDirectory);
      } else if (entity is File) {
        // Skip transient/lock files and specific system files
        if (base == '.DS_Store' ||
            base == 'pubspec.lock' ||
            base == 'Podfile.lock' ||
            base == 'README.md' ||
            base.startsWith('.flutter-plugins')) {
          continue;
        }

        await entity.copy(p.join(destination.path, base));
      }
    }
  }

  Future<void> _updatePubspecName(Directory projectDir, String slug) async {
    final pubspecFile = File(p.join(projectDir.path, 'pubspec.yaml'));
    if (await pubspecFile.exists()) {
      String content = await pubspecFile.readAsString();
      content = content.replaceFirst(RegExp(r'name:\s+.*'), 'name: $slug');
      await pubspecFile.writeAsString(content);
    }
  }

  Future<void> _updateDartImports(
      Directory projectDir, String oldSlug, String newSlug) async {
    final libDir = Directory(p.join(projectDir.path, 'lib'));
    if (await libDir.exists()) {
      await for (var entity in libDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          String content = await entity.readAsString();
          // Replace package imports
          final oldImport = "package:$oldSlug/";
          final newImport = "package:$newSlug/";
          bool changed = false;
          if (content.contains(oldImport)) {
            content = content.replaceAll(oldImport, newImport);
            changed = true;
          }
          // Also replace any legacy /app/ imports just in case
          if (content.contains("'/app/")) {
            content = content.replaceAll("'/app/", "'package:$newSlug/app/");
            changed = true;
          }
          if (changed) {
            await entity.writeAsString(content);
          }
        }
      }
    }
  }

  Future<void> _updateSettingsGradle(Directory projectDir, String slug) async {
    final settingsGradle =
        File(p.join(projectDir.path, 'android', 'settings.gradle'));
    final settingsGradleKts =
        File(p.join(projectDir.path, 'android', 'settings.gradle.kts'));

    if (await settingsGradle.exists()) {
      String content = await settingsGradle.readAsString();
      // Use a pattern that doesn't clash with delimiters
      content = content.replaceFirst(
          RegExp(r'rootProject.name\s*=\s*["\u0027].*["\u0027]'),
          "rootProject.name = '$slug'");
      await settingsGradle.writeAsString(content);
    } else if (await settingsGradleKts.exists()) {
      String content = await settingsGradleKts.readAsString();
      content = content.replaceFirst(
          RegExp(r'rootProject.name\s*=\s*["\u0027].*["\u0027]'),
          'rootProject.name = "$slug"');
      await settingsGradleKts.writeAsString(content);
    }
  }

  Future<void> _createSkeletonFiles(Directory projectDir) async {
    // This is now handled by copying from template and rebranding.
    // We already neutralized sensitive data in the template.
  }

  Future<void> _updateReadme(Directory projectDir, String projectName) async {
    final readmeFile = File(p.join(projectDir.path, 'README.md'));
    final content = '''
# $projectName

This project was generated using **DIG CLI**, a powerful Flutter companion tool.

## 🛠️ Created With
- **Tool**: DIG CLI (dg)
- **Author**: [Digvijaysinh Chauhan](https://pub.dev/packages?q=Digvijaysinh+Chauhan)
- **Packages**: [Check out my Flutter packages on pub.dev](https://pub.dev/packages?q=Digvijaysinh+Chauhan)
- **Platform**: Flutter

## 🚀 Getting Started

This project is pre-configured with:
- ✅ **Standardized Directory Structure**
- ✅ **Automated Android Signing (JKS)**
- ✅ **Firebase Skeleton Configuration**
- ✅ **Rebranded Package & Bundle IDs**

### Prerequisites
- Flutter SDK
- Java Development Kit (JDK) for Android builds

### Run the App
1. **Firebase Setup**: Run `flutterfire configure` to generate your actual `firebase_options.dart`.
2. **Dependencies**: `flutter pub get`
3. **Launch**: `flutter run`
```bash
flutterfire configure
flutter pub get
flutter run
```

---
*Generated by DIG CLI - Created by [Digvijaysinh Chauhan](https://pub.dev/packages?q=Digvijaysinh+Chauhan).*
''';
    await readmeFile.writeAsString(content);
  }

  // Replicating RenameCommand logic for self-containment and reliability
  Future<void> _updateAllAppNames(String name) async {
    // Android
    final manifestFile = File('android/app/src/main/AndroidManifest.xml');
    if (await manifestFile.exists()) {
      String content = await manifestFile.readAsString();
      content = content.replaceFirst(
          RegExp(r'android:label="[^"]*"'), 'android:label="$name"');
      await manifestFile.writeAsString(content);
    }

    // iOS
    final infoPlist = File('ios/Runner/Info.plist');
    if (await infoPlist.exists()) {
      String content = await infoPlist.readAsString();
      // Update Display Name
      content = content.replaceFirst(
          RegExp(r'<key>CFBundleDisplayName</key>\s*<string>[^<]*</string>'),
          '<key>CFBundleDisplayName</key>\n\t<string>$name</string>');
      // Update Name
      content = content.replaceFirst(
          RegExp(r'<key>CFBundleName</key>\s*<string>[^<]*</string>'),
          '<key>CFBundleName</key>\n\t<string>$name</string>');
      await infoPlist.writeAsString(content);
    }
  }

  Future<void> _updateAllBundleIds(String newId) async {
    // 1. Android build.gradle
    File? buildGradle;
    if (await File('android/app/build.gradle.kts').exists()) {
      buildGradle = File('android/app/build.gradle.kts');
    } else if (await File('android/app/build.gradle').exists()) {
      buildGradle = File('android/app/build.gradle');
    }

    if (buildGradle != null) {
      String content = await buildGradle.readAsString();

      // Detect old id (from sample)
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
        // Restructure directories
        await _restructureAndroidDirs(oldId, newId);
      }
    }

    // 2. iOS pbxproj (Global Replace)
    final pbxproj = File('ios/Runner.xcodeproj/project.pbxproj');
    if (await pbxproj.exists()) {
      String content = await pbxproj.readAsString();
      content = content.replaceAll('com.example.structure', newId);
      await pbxproj.writeAsString(content);
    }

    // 3. iOS Info.plist
    final infoPlist = File('ios/Runner/Info.plist');
    if (await infoPlist.exists()) {
      String content = await infoPlist.readAsString();
      // Ensure PRODUCT_BUNDLE_IDENTIFIER usage, or replace hardcoded
      if (!content.contains(r'$(PRODUCT_BUNDLE_IDENTIFIER)')) {
        content = content.replaceFirst(
          RegExp(r'<key>CFBundleIdentifier</key>\s*<string>[^<]+</string>'),
          '<key>CFBundleIdentifier</key>\n\t<string>$newId</string>',
        );
      }
      await infoPlist.writeAsString(content);
    }

    // 4. Firebase Configs (Thorough)
    final filesToUpdate = [
      'android/app/google-services.json',
      'ios/Runner/GoogleService-Info.plist',
      'lib/firebase_options.dart'
    ];

    for (var path in filesToUpdate) {
      final file = File(path);
      if (await file.exists()) {
        String content = await file.readAsString();
        content = content.replaceAll('com.example.structure', newId);
        await file.writeAsString(content);
      }
    }
  }

  Future<void> _restructureAndroidDirs(String oldId, String newId) async {
    final platforms = ['kotlin', 'java'];
    for (final platform in platforms) {
      final base = 'android/app/src/main/$platform';
      if (!await Directory(base).exists()) continue;

      final oldPath = oldId.replaceAll('.', p.separator);
      final newPath = newId.replaceAll('.', p.separator);
      final oldDir = Directory(p.join(base, oldPath));

      if (await oldDir.exists()) {
        final newDir = Directory(p.join(base, newPath));
        await newDir.create(recursive: true);

        await for (var entity in oldDir.list()) {
          if (entity is File) {
            String content = await entity.readAsString();
            // Replace package declaration
            content = content.replaceFirst(
                RegExp(r'^package\s+[\w\.]+', multiLine: true),
                'package $newId');
            await File(p.join(newDir.path, p.basename(entity.path)))
                .writeAsString(content);
            await entity.delete();
          }
        }

        // Cleanup empty parent directories
        Directory current = oldDir;
        while (current.path != Directory(base).path) {
          try {
            if ((await current.list().toList()).isEmpty) {
              await current.delete();
            } else {
              break;
            }
          } catch (_) {
            break;
          }
          current = current.parent;
        }
      }
    }
  }
}
