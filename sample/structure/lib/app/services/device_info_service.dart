import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

import '../utils/import.dart';

class DeviceInfoService extends GetxService {
  DeviceInfoService._();
  static final DeviceInfoService instance = DeviceInfoService._();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  late Map<String, dynamic> deviceData;
  PackageInfo? packageInfo;
  String? deviceId;

  @override
  void onInit() {
    super.onInit();
    fetchAndLogDeviceInfo();
  }

  Future<void> fetchAndLogDeviceInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    deviceData = await getDeviceInfo();
    deviceId =
        deviceData['id'] ?? deviceData['identifierForVendor'] ?? 'unknown';
    kLog(title: 'DEVICE_INFO', content: deviceData);
    if (packageInfo != null) {
      kLog(
        title: 'PACKAGE_INFO',
        content: {
          'appName': packageInfo!.appName,
          'packageName': packageInfo!.packageName,
          'version': packageInfo!.version,
          'buildNumber': packageInfo!.buildNumber,
        },
      );
    }
  }

  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final android = await _deviceInfo.androidInfo;
        return _toMap(android);
      } else if (Platform.isIOS) {
        final ios = await _deviceInfo.iosInfo;
        return _toMap(ios);
      } else {
        return {'platform': 'unknown'};
      }
    } catch (e) {
      kLog(title: 'DEVICE_INFO_ERROR', content: e);
      return {'error': e.toString()};
    }
  }

  Map<String, dynamic> _toMap(dynamic info) {
    try {
      final data = info.data;
      final map = <String, dynamic>{};

      if (data is Map) {
        data.forEach((key, value) {
          if (key is String) {
            map[key] = value;
          } else {
            map[key.toString()] = value;
          }
        });
      }

      map['platform'] = Platform.operatingSystem;
      return map;
    } catch (e) {
      return {'error': 'Failed to parse device info: $e'};
    }
  }
}
