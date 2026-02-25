import '../utils/import.dart';

class LanguageService extends GetxService {
  late Locale locale;

  @override
  void onInit() {
    final code = StoreData.readData<String>(StoreKey.languageCode) ??
        AppConstant.defaultLanguage;
    locale = Locale(code);
    super.onInit();
  }

  void changeLocale(String code) {
    locale = Locale(code);
    StoreData.setData(StoreKey.languageCode, code);
    Get.updateLocale(locale);
  }
}
