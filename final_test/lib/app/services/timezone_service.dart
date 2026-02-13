import 'package:flutter_timezone/flutter_timezone.dart';
import '../utils/import.dart';

class TimezoneService extends GetxService {
  static TimezoneService get instance => Get.find();

  String timezone = 'UTC';

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initTimezone();
  }

  Future<void> _initTimezone() async {
    try {
      timezone = (await FlutterTimezone.getLocalTimezone()).identifier;
    } catch (e) {
      kLog(title: 'TIMEZONE_ERROR', content: e);
      timezone = 'UTC';
    }
    kLog(title: 'TIMEZONE', content: timezone);
  }
}
