import '../utils/import.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.hintText = '',
    this.textInputType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.controller,
    this.isPassword = false,
    this.readOnly = false,
    this.validator,
    this.onTap,
    this.borderColor,
    this.textStyle,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.borderRadius = 10,
    this.inputFormatters,
    this.hintStyle,
    this.fillColor,
    this.enableBorderColor,
    this.focusBorderColor,
    this.disableBorderColor,
    this.focusNode,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.cursorColor,
    this.contentPadding,
    this.isDense,
  });
  final Color? cursorColor;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final TextEditingController? controller;
  final bool isPassword;
  final bool readOnly;
  final VoidCallback? onTap;

  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Color? borderColor;
  final TextStyle? textStyle;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double borderRadius;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final int? maxLines;
  final Color? fillColor;
  final Color? enableBorderColor;
  final Color? focusBorderColor;
  final Color? disableBorderColor;
  final FocusNode? focusNode;
  final EdgeInsets scrollPadding;
  final EdgeInsets? contentPadding;
  final bool? isDense;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      cursorColor: cursorColor ?? AppColor.kPrimary,
      maxLines: maxLines,
      scrollPadding: scrollPadding,
      onTap: onTap ?? () {},
      decoration: InputDecoration(
        isDense: isDense,
        filled: true,
        fillColor: fillColor ?? AppColor.kWhite,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: InputBorder.none,
        hintText: hintText.toString(),
        hintStyle: hintStyle ??
            AppTextStyle.medium(
              size: 15,
              color: AppColor.k030303.withValues(alpha: 0.52),
              fontWeight: FontWeight.w600,
            ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1.2,
            color: enableBorderColor ?? AppColor.k030303.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1.2,
            color: focusBorderColor ?? AppColor.k9D3D6C,
          ),
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1.2,
            color:
                disableBorderColor ?? AppColor.k030303.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1.2,
            color: borderColor ?? AppColor.k030303.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1.2,
            color: AppColor.kFF5757.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
      ),
      keyboardType: textInputType,
      textInputAction: textInputAction,
      controller: controller,
      obscureText: isPassword,
      focusNode: focusNode,
      onEditingComplete: () {
        if (suffixIcon != null) FocusScope.of(context).nextFocus();
        FocusScope.of(context).nextFocus();
      },
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: [
        FilteringTextInputFormatter.deny(
          RegExp(
            r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])',
          ),
        ),
        ...?inputFormatters,
      ],
      readOnly: readOnly,
      validator: validator,
      autofocus: false,
      style:
          textStyle ?? AppTextStyle.semiBold(size: 16, color: AppColor.k030303),
      onChanged: (value) {
        if (onChanged != null) {
          onChanged!(value);
        }
      },
    );
  }
}
