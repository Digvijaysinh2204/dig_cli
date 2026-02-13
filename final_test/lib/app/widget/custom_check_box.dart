import '../utils/import.dart';

class CustomCheckBox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double size;
  final Color activeColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsets margin;
  final EdgeInsets padding;

  const CustomCheckBox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 20.0,
    this.activeColor = AppColor.kPrimary, // your purple
    this.borderColor = AppColor.k7B7B7B,
    this.borderWidth = 2.0,
    this.borderRadius = 6.0,
    this.margin = const EdgeInsets.all(4),
    this.padding = const EdgeInsets.all(2),
  });

  @override
  Widget build(BuildContext context) {
    return CustomInkWell(
      clickName: 'Check Box',
      onTap: () => onChanged?.call(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: size,
        width: size,
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: value ? activeColor : AppColor.kTransparent,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: value ? activeColor : borderColor,
            width: borderWidth,
          ),
        ),
        child: value
            ? Center(
                child: Icon(
                  Icons.check,
                  size: size * 0.6,
                  color: AppColor.kWhite,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
