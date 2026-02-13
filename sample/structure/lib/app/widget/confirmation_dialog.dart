import '../utils/import.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final Widget? messageWidget;
  final String? message;
  final String confirmButtonText;
  final String cancelButtonText;
  final VoidCallback? onCancel;
  final VoidCallback onConfirm;
  final Color? titleColor;
  final Color? messageColor;
  final Color? confirmButtonColor;
  final Color? cancelButtonColor;

  const ConfirmationDialog({
    super.key,
    required this.title,
    this.message,
    required this.confirmButtonText,
    required this.cancelButtonText,
    this.onCancel,
    required this.onConfirm,
    this.titleColor,
    this.messageWidget,
    this.messageColor,
    this.confirmButtonColor,
    this.cancelButtonColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      backgroundColor: AppColor.kWhite,
      title: CustomTextView(
        text: title,
        style: AppTextStyle.medium(
          size: 16,
          color: titleColor ?? AppColor.k030303,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),

      content: messageWidget != null
          ? Material(color: AppColor.kTransparent, child: messageWidget)
          : CustomTextView(
              text: message ?? '',
              style: AppTextStyle.medium(
                size: 14,
                color: messageColor ?? AppColor.k030303,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            if (onCancel != null) onCancel!();
          },
          style: const ButtonStyle(
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStatePropertyAll(AppColor.kTransparent),
          ),
          child: CustomTextView(
            text: cancelButtonText,
            style: AppTextStyle.medium(
              size: 16,
              color: cancelButtonColor ?? AppColor.k030303,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        TextButton(
          onPressed: () {
            Get.back();
            onConfirm();
          },
          style: const ButtonStyle(
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStatePropertyAll(AppColor.kTransparent),
          ),
          child: CustomTextView(
            text: confirmButtonText,
            style: AppTextStyle.medium(
              size: 16,
              color: confirmButtonColor ?? AppColor.k030303,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
