import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:yaml/yaml.dart';

/// Command to generate asset constants from dig.yaml
class AssetCommand extends Command {
  @override
  final name = 'asset';

  @override
  final description = 'Generate asset constants from dig.yaml configuration';

  AssetCommand() {
    addSubcommand(_AssetBuildCommand());
    addSubcommand(_AssetWatchCommand());
  }
}

class _AssetBuildCommand extends Command {
  @override
  final name = 'build';

  @override
  final description = 'Generate asset constants once';

  @override
  Future<void> run() async {
    await _buildAssets();
  }
}

class _AssetWatchCommand extends Command {
  @override
  final name = 'watch';

  @override
  final description = 'Watch and auto-generate asset constants on changes';

  @override
  Future<void> run() async {
    await _watchAssets();
  }
}

Future<void> _buildAssets() async {
  print('🎨 Generating asset constants...\n');

  // Read configuration from dig.yaml
  final configFile = File('dig.yaml');
  if (!configFile.existsSync()) {
    print('❌ dig.yaml not found!');
    print('💡 Create dig.yaml file with configuration:');
    print('''
assets-dir: assets/
output-file: assets.dart
output-dir: lib/generated
''');
    exit(1);
  }

  final configContent = configFile.readAsStringSync();
  final config = loadYaml(configContent);

  final assetsDir = Directory(config['assets-dir'] as String? ?? 'assets/');
  if (!assetsDir.existsSync()) {
    print('❌ Assets directory not found: ${assetsDir.path}');
    exit(1);
  }

  final outputDir = config['output-dir'] as String? ?? 'lib/generated';
  final outputFileName = config['output-file'] as String? ?? 'assets.dart';
  final outputPath = '$outputDir/$outputFileName';

  final assets = _scanAssets(assetsDir);
  final generatedCode = _generateCode(assets);

  final outputFile = File(outputPath);
  outputFile.createSync(recursive: true);
  outputFile.writeAsStringSync(generatedCode);

  print(
      '✅ Generated ${assets.values.fold(0, (sum, list) => sum + list.length)} asset constants');
  print('📝 Updated: ${outputFile.path}\n');

  // Print summary
  assets.forEach((category, files) {
    print('  $category: ${files.length} files');
  });
}

Future<void> _watchAssets() async {
  print('👀 Watching assets directory for changes...\n');

  final assetsDir = Directory('assets');
  if (!assetsDir.existsSync()) {
    print('❌ Assets directory not found!');
    exit(1);
  }

  // Generate once on start
  await _buildAssets();

  // Watch for changes
  assetsDir.watch(recursive: true).listen((event) {
    final path = event.path;
    if (path.endsWith('.svg') ||
        path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg')) {
      print('\n📁 Detected change: ${path.split(Platform.pathSeparator).last}');
      _buildAssets();
    }
  });

  print('\n🔄 Watching for changes... (Press Ctrl+C to stop)');

  // Keep the process running
  await ProcessSignal.sigint.watch().first;
  print('\n👋 Stopped watching');
}

Map<String, List<_AssetInfo>> _scanAssets(Directory dir) {
  final assets = <String, List<_AssetInfo>>{
    'ImageAssetPNG': [],
    'ImageAssetSVG': [],
    'ImageAssetJPG': [],
    'IconAssetSVG': [],
  };

  final allFiles = dir.listSync(recursive: true);

  for (final entity in allFiles) {
    if (entity is File) {
      final path = entity.path.replaceAll('\\', '/');
      final extension = path.split('.').last.toLowerCase();
      final relativePath = path.substring(path.indexOf('assets/'));

      String? matchedCategory;

      if (path.contains('icons/svg') && extension == 'svg') {
        matchedCategory = 'IconAssetSVG';
      } else if (extension == 'svg') {
        matchedCategory = 'ImageAssetSVG';
      } else if (extension == 'png') {
        matchedCategory = 'ImageAssetPNG';
      } else if (extension == 'jpg' || extension == 'jpeg') {
        matchedCategory = 'ImageAssetJPG';
      }

      if (matchedCategory != null) {
        final fileName = path.split('/').last.split('.').first;
        final constantName = _toConstantName(fileName);
        assets[matchedCategory]!.add(_AssetInfo(constantName, relativePath));
      }
    }
  }

  return assets;
}

String _toConstantName(String fileName) {
  // Preserve original file name structure
  // ic_back.svg -> icBack
  // my_icon.svg -> myIcon
  // some-icon.svg -> someIcon

  // Replace hyphens with underscores for consistency
  final normalized = fileName.replaceAll('-', '_');

  // Split by underscore
  final parts = normalized.split('_').where((p) => p.isNotEmpty).toList();

  if (parts.isEmpty) return fileName;

  // First part lowercase, rest capitalized
  final first = parts.first.toLowerCase();
  final rest = parts
      .skip(1)
      .map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase());

  return first + rest.join('');
}

String _generateCode(Map<String, List<_AssetInfo>> assets) {
  final buffer = StringBuffer();

  // Add comprehensive header similar to l10n
  buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  buffer.writeln('// Generated by: dg asset build');
  buffer.writeln('// Configuration: dig.yaml');
  buffer.writeln();
  buffer.writeln('// ignore_for_file: type=lint');
  buffer.writeln();
  buffer.writeln('/// Asset constants generated from your assets directory.');
  buffer.writeln('///');
  buffer.writeln('/// To use these assets in your application:');
  buffer.writeln('///');
  buffer.writeln('/// ```dart');
  buffer.writeln('/// import \'package:flutter_svg/flutter_svg.dart\';');
  buffer.writeln('/// import \'package:your_app/generated/assets.dart\';');
  buffer.writeln('///');
  buffer.writeln('/// // For SVG icons');
  buffer.writeln('/// SvgPicture.asset(IconAssetSVG.icBack);');
  buffer.writeln('///');
  buffer.writeln('/// // For PNG images');
  buffer.writeln('/// Image.asset(ImageAssetPNG.logo);');
  buffer.writeln('///');
  buffer.writeln('/// // For JPG images');
  buffer.writeln('/// Image.asset(ImageAssetJPG.banner);');
  buffer.writeln('/// ```');
  buffer.writeln('///');
  buffer.writeln('/// ## Regenerating Assets');
  buffer.writeln('///');
  buffer.writeln('/// To regenerate this file after adding/removing assets:');
  buffer.writeln('///');
  buffer.writeln('/// ```bash');
  buffer.writeln('/// dg asset build');
  buffer.writeln('/// ```');
  buffer.writeln('///');
  buffer.writeln('/// Or use watch mode for automatic regeneration:');
  buffer.writeln('///');
  buffer.writeln('/// ```bash');
  buffer.writeln('/// dg asset watch');
  buffer.writeln('/// ```');
  buffer.writeln('///');
  buffer.writeln('/// ⚠️ **WARNING**: Do not modify this file manually.');
  buffer.writeln('/// All changes will be overwritten on next generation.');
  buffer.writeln();

  // Generate classes for each asset type
  for (final entry in assets.entries) {
    final className = entry.key;
    final files = entry.value;

    // Skip if no files
    if (files.isEmpty) continue;

    buffer.writeln('/// Asset constants for $className');
    buffer.writeln('class $className {');
    buffer.writeln('  const $className._();');
    buffer.writeln();

    files.sort((a, b) => a.name.compareTo(b.name));

    for (final asset in files) {
      buffer.writeln('  /// ${asset.path}');
      buffer.writeln("  static const String ${asset.name} = '${asset.path}';");
      if (asset != files.last) buffer.writeln();
    }

    buffer.writeln('}');
    buffer.writeln();
  }

  return buffer.toString();
}

class _AssetInfo {
  final String name;
  final String path;

  _AssetInfo(this.name, this.path);
}
