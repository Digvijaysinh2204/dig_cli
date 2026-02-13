import '../../services/device_info_service.dart';
import '../../utils/import.dart';

enum DeviceType {
  android,
  ios;

  String get value => name;

  static DeviceType fromString(String type) {
    return type.toLowerCase() == 'ios' ? DeviceType.ios : DeviceType.android;
  }

  static DeviceType get current {
    return GetPlatform.isIOS ? DeviceType.ios : DeviceType.android;
  }
}

class DeviceInfoModel {
  final String deviceToken;
  final DeviceType deviceType;
  final String deviceId;
  final String lang;

  DeviceInfoModel._({
    required this.deviceToken,
    required this.deviceType,
    required this.deviceId,
    required this.lang,
  });

  factory DeviceInfoModel() {
    final token = StoreData.readData<String>(StoreKey.firebaseToken) ?? 'N/A';
    final type = DeviceType.current;
    final id = DeviceInfoService.instance.deviceId ?? 'unknown';
    final lang = Get.find<LanguageService>().locale.languageCode;

    return DeviceInfoModel._(
      deviceToken: token,
      deviceType: type,
      deviceId: id,
      lang: lang,
    );
  }

  Map<String, dynamic> toJson() => {
    'device_token': deviceToken,
    'device_type': deviceType.value,
    'device_id': deviceId,
    'lang': lang,
  };

  String toRawJson() => json.encode(toJson());

  static Map<String, dynamic> currentJson() => DeviceInfoModel().toJson();
}
