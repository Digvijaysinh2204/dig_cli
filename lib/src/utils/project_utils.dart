import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

Directory? _cachedProjectRoot;

// Finds the project root by searching upwards for a pubspec.yaml file.
Directory? findProjectRoot() {
  if (_cachedProjectRoot != null) return _cachedProjectRoot;

  var dir = Directory.current;
  while (true) {
    if (File(p.join(dir.path, 'pubspec.yaml')).existsSync()) {
      _cachedProjectRoot = dir;
      return dir;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      // Reached filesystem root and found nothing
      return null;
    }
    dir = parent;
  }
}

// Checks if the current directory or its root is a Flutter project.
Future<bool> isFlutterProject() async {
  final root = findProjectRoot();
  if (root == null) return false;
  return await File(p.join(root.path, 'pubspec.yaml')).exists();
}

// Gets the project name from pubspec.yaml.
Future<String?> getProjectName() async {
  final root = findProjectRoot();
  if (root == null) return null;
  final pubspecFile = File(p.join(root.path, 'pubspec.yaml'));
  if (!await pubspecFile.exists()) return null;

  final content = await pubspecFile.readAsString();
  final yaml = loadYaml(content);
  return yaml['name'] as String?;
}

// Gets the user's desktop path.
Future<String> getDesktopPath() async {
  final home = Platform.isWindows
      ? Platform.environment['USERPROFILE']
      : Platform.environment['HOME'];
  if (home == null) throw Exception('Could not find home directory.');
  return p.join(home, 'Desktop');
}
