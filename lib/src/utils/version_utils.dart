import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pub_semver/pub_semver.dart';
import '../version_helper.dart';

class VersionUtils {
  static Future<String?> getLatestStableVersion() async {
    try {
      final url = Uri.parse('https://pub.dev/api/packages/dig_cli');
      final response = await http.get(url).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final latestVersion = json['latest']['version'] as String;
        return latestVersion;
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> isUpdateAvailable() async {
    final latest = await getLatestStableVersion();
    if (latest != null) {
      return Version.parse(latest) > Version.parse(kDigCliVersion);
    }
    return false;
  }
}
