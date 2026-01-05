import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../utils/logger.dart';
import '../utils/project_utils.dart';
import '../utils/spinner.dart';

class RenameCommand extends Command {
  @override
  final name = 'rename';
  @override
  final description =
      'Renames the Flutter app and changes the bundle ID / package name.';

  RenameCommand() {
    argParser.addOption(
      'name',
      abbr: 'n',
      help: 'New display name for the app',
    );
    argParser.addOption(
      'bundle-id',
      abbr: 'b',
      help: 'New bundle ID / package name (e.g., com.example.app)',
    );
  }

  @override
  Future<void> run() async {
    final newName = argResults?['name'] as String?;
    final newBundleId = argResults?['bundle-id'] as String?;

    if (newName == null && newBundleId == null) {
      kLog('❗ Please provide at least --name or --bundle-id.',
          type: LogType.error);
      print(usage);
      return;
    }

    if (!await isFlutterProject()) {
      kLog('❗ This command must be run inside a Flutter project.',
          type: LogType.error);
      exit(1);
    }

    try {
      if (newName != null) {
        await runWithSpinner('🏷️  Updating App Name to "$newName"...',
            () async {
          await _updateAndroidAppName(newName);
          await _updateIOSAppName(newName);
          await _updateMacOSAppName(newName);
          await _updateWindowsAppName(newName);
          await _updateLinuxAppName(newName);
          await _updateWebAppName(newName);
        });
      }

      if (newBundleId != null) {
        if (!_isValidBundleId(newBundleId)) {
          kLog(
              '❗ Invalid bundle ID format. Expected something like "com.example.app".',
              type: LogType.error);
          return;
        }

        await runWithSpinner('📦 Updating Bundle ID to "$newBundleId"...',
            () async {
          await _updateAndroidBundleId(newBundleId);
          await _updateIOSBundleId(newBundleId);
          await _updateMacOSBundleId(newBundleId);
          await _updateWindowsBundleId(newBundleId);
          await _updateLinuxBundleId(newBundleId);
        });
      }

      kLog('✅ App successfully renamed!', type: LogType.success);
      kLog('💡 Run the clean command to ensure all artifacts are refreshed.',
          type: LogType.info);
    } catch (e) {
      kLog('❌ An error occurred while renaming: $e', type: LogType.error);
      exit(1);
    }
  }

  bool _isValidBundleId(String id) {
    return RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$').hasMatch(id);
  }

  // --- Android Logic ---

  Future<void> _updateAndroidAppName(String name) async {
    final manifestFile = File('android/app/src/main/AndroidManifest.xml');
    if (await manifestFile.exists()) {
      final content = await manifestFile.readAsString();
      final updatedContent = content.replaceFirst(
        RegExp(r'android:label="[^"]*"'),
        'android:label="$name"',
      );
      await manifestFile.writeAsString(updatedContent);
    }
  }

  Future<void> _updateAndroidBundleId(String newId) async {
    // Try both Groovy and Kotlin DSL files
    File? buildGradle;

    final groovyFile = File('android/app/build.gradle');
    final kotlinFile = File('android/app/build.gradle.kts');

    if (await kotlinFile.exists()) {
      buildGradle = kotlinFile;
    } else if (await groovyFile.exists()) {
      buildGradle = groovyFile;
    }

    if (buildGradle == null) {
      throw Exception('Could not find build.gradle or build.gradle.kts');
    }

    String content = await buildGradle.readAsString();

    // 1. Detect old package ID from various formats
    String? oldId;

    // Try applicationId with quotes (Groovy: applicationId "com.example")
    final appIdQuotesMatch =
        RegExp(r'applicationId\s*[=]?\s*"([^"]+)"').firstMatch(content);
    if (appIdQuotesMatch != null) {
      oldId = appIdQuotesMatch.group(1);
    }

    // Try namespace (newer Flutter versions)
    if (oldId == null) {
      final namespaceMatch =
          RegExp(r'namespace\s*[=]?\s*"([^"]+)"').firstMatch(content);
      oldId = namespaceMatch?.group(1);
    }

    if (oldId == null) {
      throw Exception(
          'Could not detect old package name in ${buildGradle.path}');
    }

    // 2. Update applicationId - handle both formats:
    //    Groovy: applicationId "com.example"
    //    Kotlin: applicationId = "com.example"
    content = content.replaceAllMapped(
      RegExp(r'applicationId\s*(=)?\s*"[^"]+"'),
      (match) {
        final hasEquals = match.group(1) != null;
        return hasEquals
            ? 'applicationId = "$newId"'
            : 'applicationId "$newId"';
      },
    );

    // 3. Update namespace (for newer Flutter versions)
    content = content.replaceAllMapped(
      RegExp(r'namespace\s*(=)?\s*"[^"]+"'),
      (match) {
        final hasEquals = match.group(1) != null;
        return hasEquals ? 'namespace = "$newId"' : 'namespace "$newId"';
      },
    );

    await buildGradle.writeAsString(content);

    // 4. Update AndroidManifest.xml package
    final manifestFile = File('android/app/src/main/AndroidManifest.xml');
    if (await manifestFile.exists()) {
      String mContent = await manifestFile.readAsString();
      mContent = mContent.replaceAll(
        RegExp(r'package="[^"]*"'),
        'package="$newId"',
      );
      await manifestFile.writeAsString(mContent);
    }

    // 5. Directory Restructuring and Package Declaration Update
    await _restructureAndroidDirectories(oldId, newId);
  }

  Future<void> _restructureAndroidDirectories(
      String oldId, String newId) async {
    final platforms = ['kotlin', 'java'];
    final baseDir = 'android/app/src/main';

    for (final platform in platforms) {
      final sourceDir = Directory(p.join(baseDir, platform));
      if (!await sourceDir.exists()) continue;

      final oldPath = oldId.replaceAll('.', p.separator);
      final newPath = newId.replaceAll('.', p.separator);

      final oldFullDir = Directory(p.join(sourceDir.path, oldPath));
      if (!await oldFullDir.exists()) {
        // If exact path not found, try to find MainActivity.kt/java recursively
        // This handles cases where the folder structure doesn't perfectly match the ID
        continue;
      }

      final newFullDir = Directory(p.join(sourceDir.path, newPath));
      if (!await newFullDir.exists()) {
        await newFullDir.create(recursive: true);
      }

      // Move files
      final entities = oldFullDir.listSync();
      for (final entity in entities) {
        if (entity is File) {
          final newFilePath = p.join(newFullDir.path, p.basename(entity.path));
          String fileContent = await entity.readAsString();

          // Update package declaration
          fileContent = fileContent.replaceFirst(
            RegExp(r'^package\s+[\w\.]+', multiLine: true),
            'package $newId',
          );

          await File(newFilePath).writeAsString(fileContent);
          await entity.delete();
        }
      }

      // Cleanup old empty directories
      await _deleteEmptyParents(oldFullDir, sourceDir);
    }
  }

  Future<void> _deleteEmptyParents(Directory dir, Directory limit) async {
    if (dir.path == limit.path) return;
    if (await dir.exists() && dir.listSync().isEmpty) {
      await dir.delete();
      await _deleteEmptyParents(dir.parent, limit);
    }
  }

  // --- iOS Logic ---

  Future<void> _updateIOSAppName(String name) async {
    final infoPlist = File('ios/Runner/Info.plist');
    if (await infoPlist.exists()) {
      String content = await infoPlist.readAsString();

      // Update CFBundleDisplayName
      content = content.replaceFirst(
        RegExp(r'<key>CFBundleDisplayName</key>\s*<string>[^<]*</string>'),
        '<key>CFBundleDisplayName</key>\n\t<string>$name</string>',
      );

      // Update CFBundleName
      content = content.replaceFirst(
        RegExp(r'<key>CFBundleName</key>\s*<string>[^<]*</string>'),
        '<key>CFBundleName</key>\n\t<string>$name</string>',
      );

      await infoPlist.writeAsString(content);
    }
  }

  Future<void> _updateIOSBundleId(String newId) async {
    // Update project.pbxproj
    final pbxproj = File('ios/Runner.xcodeproj/project.pbxproj');
    if (await pbxproj.exists()) {
      String content = await pbxproj.readAsString();
      // Handle various formats:
      // PRODUCT_BUNDLE_IDENTIFIER = com.example.app;
      // PRODUCT_BUNDLE_IDENTIFIER = "com.example.app";
      content = content.replaceAll(
        RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = "?[^;"]+"?;'),
        'PRODUCT_BUNDLE_IDENTIFIER = $newId;',
      );
      await pbxproj.writeAsString(content);
    }

    // Also update Info.plist CFBundleIdentifier if hardcoded
    final infoPlist = File('ios/Runner/Info.plist');
    if (await infoPlist.exists()) {
      String content = await infoPlist.readAsString();
      // Only update if it's hardcoded (not using $(PRODUCT_BUNDLE_IDENTIFIER))
      if (!content.contains(r'$(PRODUCT_BUNDLE_IDENTIFIER)')) {
        content = content.replaceFirst(
          RegExp(r'<key>CFBundleIdentifier</key>\s*<string>[^<]+</string>'),
          '<key>CFBundleIdentifier</key>\n\t<string>$newId</string>',
        );
        await infoPlist.writeAsString(content);
      }
    }
  }

  // --- macOS Logic ---

  Future<void> _updateMacOSAppName(String name) async {
    final infoPlist = File('macos/Runner/Info.plist');
    if (await infoPlist.exists()) {
      String content = await infoPlist.readAsString();
      content = content.replaceFirst(
        RegExp(r'<key>CFBundleDisplayName</key>\s*<string>[^<]*</string>'),
        '<key>CFBundleDisplayName</key>\n\t<string>$name</string>',
      );
      content = content.replaceFirst(
        RegExp(r'<key>CFBundleName</key>\s*<string>[^<]*</string>'),
        '<key>CFBundleName</key>\n\t<string>$name</string>',
      );
      await infoPlist.writeAsString(content);
    }

    final xcconfig = File('macos/Runner/Configs/AppInfo.xcconfig');
    if (await xcconfig.exists()) {
      String content = await xcconfig.readAsString();
      content = content.replaceFirst(
        RegExp(r'PRODUCT_NAME = .*'),
        'PRODUCT_NAME = $name',
      );
      await xcconfig.writeAsString(content);
    }
  }

  Future<void> _updateMacOSBundleId(String newId) async {
    final pbxproj = File('macos/Runner.xcodeproj/project.pbxproj');
    if (await pbxproj.exists()) {
      String content = await pbxproj.readAsString();
      content = content.replaceAll(
        RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = [^;]+;'),
        'PRODUCT_BUNDLE_IDENTIFIER = $newId;',
      );
      await pbxproj.writeAsString(content);
    }
  }

  // --- Windows Logic ---

  Future<void> _updateWindowsAppName(String name) async {
    final rcFile = File('windows/runner/Runner.rc');
    if (await rcFile.exists()) {
      String content = await rcFile.readAsString();
      content = content.replaceFirst(
        RegExp(r'VALUE "ProductName", "[^"]*"'),
        'VALUE "ProductName", "$name"',
      );
      await rcFile.writeAsString(content);
    }

    final mainCpp = File('windows/runner/main.cpp');
    if (await mainCpp.exists()) {
      String content = await mainCpp.readAsString();
      content = content.replaceFirst(
        RegExp(r'window.CreateAndShow\(L"[^"]*"'),
        'window.CreateAndShow(L"$name"',
      );
      await mainCpp.writeAsString(content);
    }

    final cmake = File('windows/CMakeLists.txt');
    if (await cmake.exists()) {
      String content = await cmake.readAsString();
      content = content.replaceFirst(
        RegExp(r'set\(BINARY_NAME "[^"]*"\)'),
        'set(BINARY_NAME "$name")',
      );
      await cmake.writeAsString(content);
    }
  }

  Future<void> _updateWindowsBundleId(String newId) async {
    // Windows doesn't use bundle ID in the same way, but we can update the org name if found
  }

  // --- Linux Logic ---

  Future<void> _updateLinuxAppName(String name) async {
    final cmake = File('linux/CMakeLists.txt');
    if (await cmake.exists()) {
      String content = await cmake.readAsString();
      content = content.replaceFirst(
        RegExp(r'set\(BINARY_NAME "[^"]*"\)'),
        'set(BINARY_NAME "$name")',
      );
      await cmake.writeAsString(content);
    }

    final myAppCc = File('linux/my_application.cc');
    if (await myAppCc.exists()) {
      // Typically the title is set in my_application.cc
    }
  }

  Future<void> _updateLinuxBundleId(String newId) async {
    // Linux doesn't use bundle ID in the same way
  }

  // --- Web Logic ---

  Future<void> _updateWebAppName(String name) async {
    final indexHtml = File('web/index.html');
    if (await indexHtml.exists()) {
      String content = await indexHtml.readAsString();
      content = content.replaceFirst(
        RegExp(r'<title>[^<]*</title>'),
        '<title>$name</title>',
      );
      content = content.replaceFirst(
        RegExp(r'content="[^"]*"\s+name="apple-mobile-web-app-title"'),
        'content="$name" name="apple-mobile-web-app-title"',
      );
      await indexHtml.writeAsString(content);
    }

    final mainfest = File('web/manifest.json');
    if (await mainfest.exists()) {
      String content = await mainfest.readAsString();
      content =
          content.replaceFirst(RegExp(r'"name": "[^"]*"'), '"name": "$name"');
      content = content.replaceFirst(
          RegExp(r'"short_name": "[^"]*"'), '"short_name": "$name"');
      await mainfest.writeAsString(content);
    }
  }
}

Future<void> handleRenameCommand(List<String> args) async {
  final runner = CommandRunner('dg', 'Rename app')..addCommand(RenameCommand());
  await runner.run(args);
}
