import '../utils/import.dart';

class AppBindings extends Bindings {
  @override
  Future<void> dependencies() async {
    await StoreData.init();
    await dotenv.load(fileName: '.env');
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // TODO(Developer): Uncomment when you have configured Firebase.
    // await Firebase.initializeApp(options: AppConfig.firebaseOptions);
    Get.put<ThemeService>(ThemeService(), permanent: true);
    Get.put<LanguageService>(LanguageService(), permanent: true);
    await Get.putAsync(() => NetworkService().init());
  }
}
