import '../../../utils/import.dart';

class MainController extends GetxController {
  RxInt selectedIndex = 0.obs;
  RxBool isLoading = false.obs;
  RxString firebaseStatus = 'Checking...'.obs;
  final deviceInfo = Get.find<DeviceInfoService>();

  @override
  void onInit() {
    super.onInit();
    _checkFirebaseStatus();
  }

  void _checkFirebaseStatus() {
    if (AppConfig.firebaseOptions == null) {
      firebaseStatus.value = 'Not Configured (Skipped)';
    } else if (Firebase.apps.isNotEmpty) {
      firebaseStatus.value = 'Configured & Initialized';
    } else {
      firebaseStatus.value = 'Initialization Failed';
    }
  }

  void changeTab(int index) {
    if (selectedIndex.value == index) return;
    selectedIndex.value = index;
  }

  RxInt counter = 0.obs;

  void incrementCounter() {
    counter.value++;
  }
}
