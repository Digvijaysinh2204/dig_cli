import '../utils/import.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.onTap,
    this.height,
    this.width,
    this.bgColor = AppColor.k030303,
    this.isCenter = true,
    this.text,
    this.imagePath,
    this.customTextWidget,
    required this.clickName,
    this.borderRadius,
    this.textColors,
    this.border,
    this.useGradient = false,
    this.isLoading = false,
    this.isDisabled = false,
  });

  final VoidCallback? onTap;
  final double? height;
  final double? width;

  final Color bgColor;
  final bool isCenter;

  final String? text;
  final Widget? customTextWidget;
  final String? imagePath;
  final String clickName;

  final BorderRadiusGeometry? borderRadius;
  final Color? textColors;
  final BoxBorder? border;

  final bool useGradient;
  final bool isLoading;
  final bool isDisabled;

  bool get _canTap => !isLoading && !isDisabled && onTap != null;

  @override
  Widget build(BuildContext context) {
    return CustomInkWell(
      clickName: '$clickName click',
      onTap: _canTap ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isDisabled ? 0.6 : 1,
        child: Container(
          height: height ?? 56,
          width: width,
          decoration: BoxDecoration(
            color: _backgroundColor,
            gradient: _gradient,
            borderRadius: borderRadius ?? BorderRadius.circular(10),
            border: _border,
          ),
          child: isLoading
              ? _loader
              : Row(
                  mainAxisAlignment: isCenter
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 10,
                  children: [
                    if (imagePath != null)
                      imagePath!.toLowerCase().endsWith('.svg')
                          ? SvgPicture.asset(
                              imagePath!,
                              colorFilter: ColorFilter.mode(
                                _contentColor,
                                BlendMode.srcIn,
                              ),
                            )
                          : Image.asset(imagePath!),
                    _textWidget,
                  ],
                ),
        ),
      ),
    );
  }

  Widget get _loader => Center(
        child: SizedBox(
          height: 22,
          width: 22,
          child:
              CircularProgressIndicator(strokeWidth: 2.5, color: _contentColor),
        ),
      );

  Widget get _textWidget =>
      customTextWidget ??
      CustomTextView(
        textAlign: TextAlign.center,
        text: text ?? '',
        toUpperCase: true,
        style: AppTextStyle.semiBold(
          size: 15,
          fontWeight: FontWeight.w600,
          color: _contentColor,
        ),
      );

  Color get _backgroundColor {
    if (isDisabled) return AppColor.kEEF0F5;
    if (useGradient) return Colors.transparent;
    return bgColor;
  }

  Gradient? get _gradient {
    if (isDisabled || !useGradient) return null;
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFFBAA9FF), Color(0xFF604ABD)],
    );
  }

  BoxBorder? get _border =>
      isDisabled ? Border.all(color: AppColor.kE2E6EF) : border;

  Color get _contentColor {
    if (isDisabled) return AppColor.k9FA4AF;

    final isLightBg =
        bgColor == AppColor.kWhite || bgColor.computeLuminance() > 0.5;

    return textColors ?? (isLightBg ? AppColor.kBlack : AppColor.kWhite);
  }
}
