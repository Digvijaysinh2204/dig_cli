import '../utils/import.dart';

class NetworkBanner extends StatelessWidget {
  const NetworkBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final network = Get.find<NetworkService>();
    final topPadding = MediaQuery.of(context).padding.top;

    return Obx(() {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        child: network.isConnected.value
            ? const SizedBox.shrink()
            : Material(
                key: const ValueKey('network_error'),
                color: Colors.red,
                elevation: 4,
                child: Container(
                  width: double.infinity,
                  height: topPadding + 55,
                  padding: EdgeInsets.only(top: topPadding + 8),
                  alignment: Alignment.center,
                  child: CustomTextView(
                    text: loc.noConnection,
                    style: AppTextStyle.bold(
                      color: AppColor.kWhite,
                      fontWeight: FontWeight.w600,
                      size: 16,
                    ),
                  ),
                ),
              ),
      );
    });
  }
}
