// file: lib/version.dart

import 'dart:io';

import 'package:yaml/yaml.dart';

Future<String> getCurrentCliVersion() async {
  try {
    final pubspecFile = File('pubspec.yaml');
    if (await pubspecFile.exists()) {
      final content = await pubspecFile.readAsString();
      final yaml = loadYaml(content);
      return yaml['version'] as String? ?? '0.0.0';
    }
    return '0.0.0'; // Fallback version
  } catch (e) {
    return '0.0.0'; // Fallback in case of any error
  }
}
