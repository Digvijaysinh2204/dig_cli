import '../utils/import.dart';

class ThemeService extends GetxService {
  ThemeMode themeMode = ThemeMode.light;

  @override
  void onInit() {
    final isDark = StoreData.readData<bool>(StoreKey.isDarkMode) ?? false;
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    super.onInit();
  }

  void switchTheme() {
    final isDarkNow = themeMode == ThemeMode.dark;
    themeMode = isDarkNow ? ThemeMode.light : ThemeMode.dark;
    StoreData.setData(StoreKey.isDarkMode, !isDarkNow);
    Get.changeThemeMode(themeMode);
  }
}
