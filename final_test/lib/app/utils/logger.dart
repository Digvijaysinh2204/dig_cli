import 'dart:developer' show log;

import '../constants/app_config.dart';
import 'import.dart';

void kLog({required dynamic content, String title = ''}) {
  if (kReleaseMode || AppConfig.currentEnvironment == Environment.live) return;

  try {
    final encoded = _toJsonIfNeeded(content);
    log(encoded, name: title);
  } catch (_) {
    log(content.toString(), name: title);
  }
}

String _toJsonIfNeeded(dynamic content) {
  if (content is Map || content is List) {
    return jsonEncode(content);
  }
  return content.toString();
}
