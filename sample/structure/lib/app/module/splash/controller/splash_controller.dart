import '../../../utils/import.dart';

class SplashController extends GetxController {
  RxBool isLoading = false.obs;
  @override
  void onInit() {
    routeNextScreen();
    super.onInit();
  }

  Future<void> routeNextScreen() async {
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAllNamed(AppRoute.mainView);
    });
  }
}
