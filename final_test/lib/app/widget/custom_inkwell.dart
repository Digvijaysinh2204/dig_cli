import '../utils/import.dart';

class CustomInkWell extends StatelessWidget {
  const CustomInkWell({
    super.key,
    required this.clickName,
    this.onTap,
    this.onLongPress,
    this.child,
  });

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String clickName;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashFactory: NoSplash.splashFactory,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      onTap: () {
        onTap?.call();
        // Get.find<AnalyticsService>().logButtonClick(clickName);
      },
      onLongPress: onLongPress,
      child: child,
    );
  }
}
