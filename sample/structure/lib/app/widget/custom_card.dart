import '../utils/import.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color borderColor;
  final double? height;
  final double radius;
  CustomCard({
    super.key,
    required this.child,
    this.height,
    this.padding = const EdgeInsets.all(12),
    this.radius = 10,
    Color? borderColor,
  }) : borderColor = borderColor ?? AppColor.k030303.withValues(alpha: 0.3);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      height: height,
      decoration: BoxDecoration(
        color: AppColor.kWhite,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(radius),
      ),
      padding: padding,
      child: child,
    );
  }
}
