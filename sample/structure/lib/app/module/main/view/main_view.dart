import '../../../utils/import.dart';
import '../controller/main_controller.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    // final loc = AppLocalizations.of(context)!;
    return CustomScaffold(
      isAppBar: false,
      isSafeAreaTop: false,
      backgroundColor: AppColor.kEEEAEC,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColor.kWhite,
          boxShadow: [
            BoxShadow(
              color: AppColor.k161A25.withValues(alpha: 0.1),
              blurRadius: 44,
              offset: const Offset(0, -16),
            ),
          ],
        ),
        child: const SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [],
          ),
        ),
      ),
      body: const SizedBox.shrink(),
    );
  }
}
