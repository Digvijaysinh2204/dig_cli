import '../utils/import.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({
    super.key,
    this.onPressed,
    this.color,
    this.iconColor,
  });

  final Color? color;
  final Color? iconColor;

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomCircleIconWidget(
          onTap: () {
            if (onPressed != null) {
              onPressed!.call();
            } else {
              Get.back(closeOverlays: true);
            }
          },
          color: color ?? AppColor.k40434C,
          child: SvgPicture.asset(
            IconsSvg.icBack,
            fit: BoxFit.scaleDown,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              iconColor ?? Colors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }
}
