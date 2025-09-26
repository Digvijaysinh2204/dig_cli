// file: lib/src/utils/project_utils.dart

import 'dart:io';

// Finds the project root by searching upwards for a pubspec.yaml file.
Directory? findProjectRoot() {
  var dir = Directory.current;
  while (true) {
    if (File('${dir.path}/pubspec.yaml').existsSync()) {
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

// Checks if the current directory is a Flutter project.
Future<bool> isFlutterProject() async {
  final pubspecFile = File('pubspec.yaml');
  return await pubspecFile.exists();
}
