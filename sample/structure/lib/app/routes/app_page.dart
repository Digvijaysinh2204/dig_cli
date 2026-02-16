import '../module/module_export.dart';
import '../utils/import.dart';

class AppPage {
  AppPage._();

  static final routers = <GetPage>[
    GetPage(
      name: AppRoute.splashView,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoute.mainView,
      page: () => const MainView(),
      binding: MainBinding(),
    ),
  ];
}
