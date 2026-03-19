import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constants/app_config.dart';
import '../constants/app_constant.dart';
import '../utils/logger.dart';
import 'crypto_helper.dart';
import 'endpoints.dart';
import 'result.dart';
import '../storage/store_data.dart';
import '../storage/store_key.dart';
import '../services/app_loading_service.dart';
import '../services/network_service.dart';
import '../services/language_service.dart';
import '../services/timezone_service.dart';
import '../services/notification_services.dart';
import '../../generated/localization_key.dart';

enum RequestMethod { get, post, put, delete, patch }

extension RequestMethodExtension on RequestMethod {
  String get name {
    switch (this) {
      case RequestMethod.get:
        return 'GET';
      case RequestMethod.post:
        return 'POST';
      case RequestMethod.put:
        return 'PUT';
      case RequestMethod.delete:
        return 'DELETE';
      case RequestMethod.patch:
        return 'PATCH';
    }
  }
}

class ApiService {
  static final http.Client _client = http.Client();
  static Future<Result<T>> request<T>({
    required String url,
    required RequestMethod method,
    required T Function(dynamic data) fromJson,
    dynamic body,
    Map<String, dynamic>? queryParams,
    Map<String, List<String>>? arrayParams,
    bool showLoader = true,
    List<http.MultipartFile>? files,
    Map<String, String>? customHeaders,
    Future<void> Function()? onUnauthorized,
    Duration? timeout,
  }) async {
    final loader = Get.find<AppLoadingService>();
    if (!Get.find<NetworkService>().isConnected.value) {
      if (showLoader) loader.stopLoading();
      return Result.error(
        AppLocalizations.of(Get.context!)!.noConnection,
        null,
      );
    }
    if (showLoader) loader.startLoading();

    try {
      final baseUrl = url.startsWith('http') ? url : '${Endpoints.baseUrl}$url';

      final uri = _buildUri(baseUrl, queryParams, arrayParams);
      final headers = _buildHeaders(customHeaders);
      final isMultipart = files != null && files.isNotEmpty;

      final encryptedPayload = (method == RequestMethod.get || body == null)
          ? null
          : _prepareBody(body);

      final stopwatch = Stopwatch()..start();

      final response = await _send(
        uri: uri,
        method: method,
        headers: headers,
        encryptedPayload: encryptedPayload,
        files: files,
        isMultipart: isMultipart,
        timeout: timeout ?? AppConstant.apiTimeout,
      );

      stopwatch.stop();

      final parsed = await _parseResponse(response);

      if (!kReleaseMode) {
        _logDetailed(
          url: uri.toString(),
          method: method.name,
          originalBody: body,
          encryptedBody: encryptedPayload,
          headers: headers,
          files: files,
          rawResponse: response.body,
          decryptedResponse: parsed,
          statusCode: response.statusCode,
          duration: stopwatch.elapsedMilliseconds,
        );
      }

      if (response.statusCode == 401) {
        if (onUnauthorized != null) {
          await onUnauthorized();
        } else {
          await handleUnauthorized();
        }
        return Result.error(
          _extractErrorMessage(parsed, response.statusCode),
          response.statusCode,
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return Result.error(
          _extractErrorMessage(parsed, response.statusCode),
          response.statusCode,
        );
      }

      return Result.success(fromJson(parsed), response.statusCode);
    } catch (e, s) {
      final l10n = AppLocalizations.of(Get.context!)!;
      String errorMessage = l10n.somethingWentWrong;

      if (e is SocketException) {
        errorMessage = l10n.noInternetConnection(e.message);
      } else if (e is TimeoutException) {
        errorMessage = l10n.requestTimedOut(e.duration?.inSeconds ?? 0);
      } else if (e is FormatException) {
        errorMessage = l10n.badResponseFormat(e.message);
      } else if (e is HandshakeException) {
        errorMessage = l10n.connectionNotSecure;
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      if (!kReleaseMode) {
        kLog(title: 'HTTP EXCEPTION', content: '$errorMessage\n$e\n$s');
      }
      return Result.error(errorMessage, null);
    } finally {
      if (showLoader) loader.stopLoading();
    }
  }

  static Uri _buildUri(
    String baseUrl,
    Map<String, dynamic>? queryParams,
    Map<String, List<String>>? arrayParams,
  ) {
    if ((queryParams == null || queryParams.isEmpty) &&
        (arrayParams == null || arrayParams.isEmpty)) {
      return Uri.parse(baseUrl);
    }

    final queryParts = <String>[];

    queryParams?.forEach((key, value) {
      queryParts.add('$key=${Uri.encodeComponent(value.toString())}');
    });

    arrayParams?.forEach((key, values) {
      for (var value in values) {
        queryParts.add('$key=${Uri.encodeComponent(value)}');
      }
    });

    final queryString = queryParts.join('&');
    return Uri.parse('$baseUrl?$queryString');
  }

  static Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    final token = StoreData.readData<String>(StoreKey.accessToken) ?? '';
    final lang = Get.find<LanguageService>().locale.languageCode;
    final now = DateTime.now();
    final timezone = Get.find<TimezoneService>().timezone;

    return {
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Accept-Language': lang,
      'X-Timezone-Name': now.timeZoneName,
      'X-Timezone-Offset': now.timeZoneOffset.inMinutes.toString(),
      'X-Local-Timezone': timezone,
      ...?customHeaders,
    };
  }

  static Map<String, dynamic> _prepareBody(dynamic body) {
    if (!AppConfig.encrypt) {
      return body is Map<String, dynamic> ? body : jsonDecode(jsonEncode(body));
    }

    final encrypted = CryptoHelper.encryptGCM(
      body is String ? body : jsonEncode(body),
    );

    return {'iv': encrypted['iv'], 'encrypted': encrypted['encrypted']};
  }

  static Future<http.Response> _send({
    required Uri uri,
    required RequestMethod method,
    required Map<String, String> headers,
    Map<String, dynamic>? encryptedPayload,
    List<http.MultipartFile>? files,
    required bool isMultipart,
    required Duration timeout,
  }) {
    if (method == RequestMethod.get) {
      return _client.get(uri, headers: headers).timeout(timeout);
    }

    if (isMultipart) {
      return _sendMultipart(
        uri,
        method,
        headers,
        encryptedPayload,
        files!,
        timeout,
      );
    }

    return _sendJson(uri, method, headers, encryptedPayload, timeout);
  }

  static Future<http.Response> _sendJson(
    Uri uri,
    RequestMethod method,
    Map<String, String> headers,
    Map<String, dynamic>? encryptedPayload,
    Duration timeout,
  ) {
    headers['Content-Type'] = 'application/json';

    final body = encryptedPayload == null ? null : jsonEncode(encryptedPayload);

    return _getClientMethod(method)(
      uri,
      headers: headers,
      body: body,
    ).timeout(timeout);
  }

  static Future<http.Response> _sendMultipart(
    Uri uri,
    RequestMethod method,
    Map<String, String> headers,
    Map<String, dynamic>? encryptedPayload,
    List<http.MultipartFile> files,
    Duration timeout,
  ) async {
    final req = http.MultipartRequest(method.name, uri)
      ..headers.addAll(headers);

    encryptedPayload?.forEach((k, v) {
      if (v is List) {
        for (var i = 0; i < v.length; i++) {
          req.fields['$k[$i]'] = v[i].toString();
        }
      } else if (v is String) {
        req.fields[k] = v;
      } else {
        req.fields[k] = jsonEncode(v);
      }
    });

    req.files.addAll(files);

    final streamed = await req.send().timeout(timeout);
    return http.Response.fromStream(streamed);
  }

  static dynamic Function(Uri, {Map<String, String>? headers, Object? body})
  _getClientMethod(RequestMethod method) {
    switch (method) {
      case RequestMethod.post:
        return _client.post;
      case RequestMethod.put:
        return _client.put;
      case RequestMethod.patch:
        return _client.patch;
      case RequestMethod.delete:
        return _client.delete;
      default:
        throw UnsupportedError('Unsupported method');
    }
  }

  static Future<dynamic> _parseResponse(http.Response response) async {
    try {
      final contentType = response.headers['content-type'] ?? '';
      final parsed = contentType.contains('application/json')
          ? await compute(jsonDecode, response.body)
          : response.body;

      if (!AppConfig.encrypt) return parsed;

      if (parsed is Map &&
          parsed.containsKey('iv') &&
          parsed.containsKey('encrypted')) {
        final decrypted = CryptoHelper.decryptGCM(
          encryptedText: parsed['encrypted'],
          ivBase64: parsed['iv'],
        );
        return compute(jsonDecode, decrypted);
      }

      return parsed;
    } catch (_) {
      return response.body;
    }
  }

  static String _extractErrorMessage(dynamic parsed, int statusCode) {
    if (parsed is Map) {
      if (parsed['statusMessage'] != null) {
        return parsed['statusMessage'].toString();
      }
      if (parsed['message'] != null) {
        return parsed['message'].toString();
      }
      if (parsed['error'] != null) {
        return parsed['error'].toString();
      }
      if (parsed['msg'] != null) {
        return parsed['msg'].toString();
      }
      if (parsed['data'] != null && parsed['data'] is Map) {
        if (parsed['data']['message'] != null) {
          return parsed['data']['message'].toString();
        }
      }
    }

    // Fallback for HTML or unparsed strings
    if (parsed is String && parsed.isNotEmpty) {
      // If it's a short string, might be the error. If it's HTML/long, don't show it.
      if (parsed.length < 200 && !parsed.contains('<html')) {
        return parsed;
      }
    }

    return 'Error $statusCode: Something went wrong';
  }

  static void _logDetailed({
    required String url,
    required String method,
    dynamic originalBody,
    Map<String, dynamic>? encryptedBody,
    required Map<String, String> headers,
    List<http.MultipartFile>? files,
    required String rawResponse,
    dynamic decryptedResponse,
    required int statusCode,
    required int duration,
  }) {
    final pretty = const JsonEncoder.withIndent('  ');

    kLog(title: 'METHOD', content: method);
    kLog(title: 'URL', content: url);
    kLog(title: 'STATUS', content: statusCode.toString());
    kLog(title: 'DURATION', content: '$duration ms');
    kLog(title: 'HEADERS', content: jsonEncode(headers));

    if (originalBody != null) {
      kLog(title: 'BODY', content: pretty.convert(originalBody));
    }

    if (files != null && files.isNotEmpty) {
      final fileInfo = files
          .asMap()
          .entries
          .map((entry) {
            final idx = entry.key;
            final file = entry.value;
            return 'files[$idx]: ${file.filename ?? 'unnamed'} (${file.length} bytes)';
          })
          .join('\n');
      kLog(title: 'FILES', content: fileInfo);
    }

    if (encryptedBody != null && AppConfig.encrypt) {
      kLog(title: 'ENCRYPTED BODY', content: jsonEncode(encryptedBody));
    }

    kLog(title: 'RAW RESPONSE', content: rawResponse);

    if (decryptedResponse != null) {
      kLog(title: 'DECRYPTED', content: pretty.convert(decryptedResponse));
    }

    _logCurl(
      url: url,
      method: method,
      headers: headers,
      body: originalBody,
      encryptedBody: encryptedBody,
      files: files,
    );
  }

  static void _logCurl({
    required String url,
    required String method,
    required Map<String, String> headers,
    dynamic body,
    Map<String, dynamic>? encryptedBody,
    List<http.MultipartFile>? files,
  }) {
    final b = StringBuffer();
    b.writeln('curl -X $method \\');

    headers.forEach((k, v) {
      b.writeln('  -H "$k: $v" \\');
    });

    final isMultipart = files != null && files.isNotEmpty;

    if (method != 'GET') {
      final payload = AppConfig.encrypt ? encryptedBody : body;

      if (isMultipart) {
        if (payload != null && payload is Map) {
          payload.forEach((k, v) {
            if (v is List) {
              for (var i = 0; i < v.length; i++) {
                b.writeln('  --form \'$k[$i]=${v[i]}\' \\');
              }
            } else if (v is String) {
              b.writeln('  --form \'$k=$v\' \\');
            } else {
              final jsonValue = jsonEncode(v).replaceAll('"', '\\"');
              b.writeln('  --form \'$k=$jsonValue\' \\');
            }
          });
        }

        for (var i = 0; i < files.length; i++) {
          final file = files[i];
          b.writeln(
            '  --form \'${file.field}=@${file.filename ?? 'file$i'}\' \\',
          );
        }
      } else if (payload != null) {
        b.writeln(
          "  -d '${jsonEncode(payload).replaceAll("'", "'\"'\"'")}' \\",
        );
      }
    }

    b.write('  "$url"');
    kLog(title: 'CURL', content: b.toString());
  }

  static Future<void> handleUnauthorized() async {
    final loader = Get.find<AppLoadingService>();
    loader.startLoading();
    await StoreData.clear();
    await Get.find<NotificationService>().messaging.deleteToken();
    Get.find<NotificationService>().getFirebaseToken();
    // Get.offAllNamed(AppRoute.authView);
    loader.stopLoading();
  }
}
