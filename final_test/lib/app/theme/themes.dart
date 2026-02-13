import '../utils/import.dart';

class Themes {
  static final light = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColor.kPrimary,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColor.kPrimary,
    // scaffoldBackgroundColor: AppColor.kBlack,
    // appBarTheme: const AppBarTheme(
    //   // backgroundColor: AppColors.darkPrimary,
    //   foregroundColor: Colors.white,
    // ),
  );
}
