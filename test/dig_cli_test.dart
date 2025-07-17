import 'dart:io';
import 'package:test/test.dart';

void main() {
  test('dig_cli --version prints version', () async {
    final result = await Process.run(
      'dart',
      ['run', 'bin/dig_cli.dart', '--version'],
    );
    expect(result.exitCode, 0);
    expect(result.stdout, contains('dig_cli v'));
  });

  test('dig_cli help prints help', () async {
    final result = await Process.run(
      'dart',
      ['run', 'bin/dig_cli.dart', 'help'],
    );
    expect(result.exitCode, 0);
    expect(result.stdout, contains('Help'));
  });
}
