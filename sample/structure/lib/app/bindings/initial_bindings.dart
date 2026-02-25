import 'package:get/get.dart';
import '../services/device_info_service.dart';
import '../services/notification_services.dart';
import '../services/timezone_service.dart';
import '../services/app_loading_service.dart';
import '../services/download_manager.dart';

class InitialBindings extends Bindings {
  @override
  Future<void> dependencies() async {
    Get.put<DeviceInfoService>(DeviceInfoService.instance, permanent: true);
    // TODO(Developer): Uncomment when you want to enable notifications
    // Get.put<NotificationService>(NotificationService(), permanent: true);
    Get.put<TimezoneService>(TimezoneService(), permanent: true);
    Get.put<AppLoadingService>(AppLoadingService(), permanent: true);
    Get.put<DownloadManager>(DownloadManager(), permanent: true);
  }
}
