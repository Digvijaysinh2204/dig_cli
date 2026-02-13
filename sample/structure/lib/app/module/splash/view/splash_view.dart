import '../../../utils/import.dart';
import '../splash_export.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isAppBar: false,
      appBarColor: AppColor.kTransparent,
      showBackButton: false,
      statusBarDarkIcons: true,
      body: Obx(
        () => Visibility(
          visible: !controller.isLoading.value,
          child: const Center(child: Text('SplashView')),
        ),
      ),
    );
  }
}
