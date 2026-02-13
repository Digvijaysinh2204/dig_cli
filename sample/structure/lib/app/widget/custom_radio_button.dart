import '../utils/import.dart';

class CustomRadioButton<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final TextStyle? labelStyle;
  const CustomRadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.label,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = (value == groupValue);
    return CustomInkWell(
      clickName: 'Radio Button',
      onTap: () => onChanged?.call(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 20,
            width: 20,
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.kPrimary),
              shape: BoxShape.circle,
            ),
            child: Container(
              height: 15,
              width: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColor.kPrimary : AppColor.kTransparent,
              ),
            ),
          ),
          if (label != null) ...[
            const Gap(8),
            CustomTextView(
              text: label!,
              style:
                  labelStyle ??
                  AppTextStyle.semiBold(size: 16, color: AppColor.k030303),
            ),
          ],
        ],
      ),
    );
  }
}
