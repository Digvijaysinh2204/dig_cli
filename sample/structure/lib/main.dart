import 'app/bindings/initial_bindings.dart';
import 'app/utils/import.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await FirebaseUtils.safeInitialize();
  kLog(content: message.toMap(), title: 'BACKGROUND NOTIFICATION');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBindings().dependencies();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    const ToastificationWrapper(
      config: ToastificationConfig(
        animationDuration: Duration(milliseconds: 250),
        alignment: Alignment.topCenter,
        maxToastLimit: 1,
      ),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      getPages: AppPage.routers,
      initialRoute: AppRoute.splashView,
      theme: Themes.light,
      locale: Get.find<LanguageService>().locale,
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
      ],
      initialBinding: InitialBindings(),
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        final network = Get.find<NetworkService>();

        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: Obx(
            () => PopScope(
              canPop: network.isConnected.value,
              child: Stack(
                children: [
                  AbsorbPointer(
                    absorbing: !network.isConnected.value,
                    child: child ?? const SizedBox.shrink(),
                  ),
                  const NetworkBanner(),
                  const GlobalLoader(),
                  if (!network.isConnected.value)
                    const Positioned.fill(
                      child: ModalBarrier(
                        dismissible: false,
                        color: Colors.transparent,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
