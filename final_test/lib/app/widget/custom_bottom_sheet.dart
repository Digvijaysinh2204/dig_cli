import '../utils/import.dart';

class CustomBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    Widget? titleWidget,
    TextAlign titleAlign = TextAlign.center,
    required Widget child,
    Widget? footer,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onClose,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showCloseButton = true,
    bool autoHideFooterOnKeyboard = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => PopScope(
        canPop: isDismissible,
        child: _CustomBottomSheetContainer(
          title: title,
          titleWidget: titleWidget,
          titleAlign: titleAlign,
          footer: footer,
          leading: leading,
          trailing: trailing,
          onClose: onClose,
          showCloseButton: showCloseButton,
          autoHideFooterOnKeyboard: autoHideFooterOnKeyboard,
          child: child,
        ),
      ),
    ).whenComplete(() {
      onClose?.call();
    });
  }
}

class _CustomBottomSheetContainer extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final TextAlign titleAlign;
  final Widget child;
  final Widget? footer;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onClose;
  final bool showCloseButton;
  final bool autoHideFooterOnKeyboard;

  const _CustomBottomSheetContainer({
    this.title,
    this.titleWidget,
    this.titleAlign = TextAlign.center,
    required this.child,
    this.footer,
    this.leading,
    this.trailing,
    this.onClose,
    required this.showCloseButton,
    required this.autoHideFooterOnKeyboard,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _SheetBody(
        title: title,
        titleWidget: titleWidget,
        titleAlign: titleAlign,
        footer: footer,
        leading: leading,
        trailing: trailing,
        onClose: onClose,
        showCloseButton: showCloseButton,
        autoHideFooterOnKeyboard: autoHideFooterOnKeyboard,
        child: child,
      ),
    );
  }
}

class _SheetBody extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final TextAlign titleAlign;
  final Widget child;
  final Widget? footer;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onClose;
  final bool showCloseButton;
  final bool autoHideFooterOnKeyboard;

  const _SheetBody({
    this.title,
    this.titleWidget,
    required this.titleAlign,
    required this.child,
    this.footer,
    this.leading,
    this.trailing,
    this.onClose,
    required this.showCloseButton,
    required this.autoHideFooterOnKeyboard,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasTitle = title != null || titleWidget != null;
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Container(
      decoration: const BoxDecoration(
        color: AppColor.kWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Gap(10),
              Container(
                width: 130,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColor.k242E49,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const Gap(10),
              if (hasTitle ||
                  showCloseButton ||
                  leading != null ||
                  trailing != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      leading ??
                          (showCloseButton
                              ? GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    height: 36,
                                    width: 36,
                                    decoration: const BoxDecoration(
                                      color: AppColor.kECEDEE,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: AppColor.k222B45,
                                    ),
                                  ),
                                )
                              : const SizedBox(width: 36)),
                      Expanded(
                        child: Center(
                          child: titleWidget ??
                              (title != null
                                  ? CustomTextView(
                                      text: title!,
                                      textAlign: titleAlign,
                                      style: AppTextStyle.bold(
                                        size: 20,
                                        fontWeight: FontWeight.w700,
                                        color: AppColor.kBlack,
                                      ),
                                    )
                                  : const SizedBox.shrink()),
                        ),
                      ),
                      trailing ?? const SizedBox(width: 36),
                    ],
                  ),
                ),
              const Gap(10),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    footer != null ? 90 : 20,
                  ),
                  child: child,
                ),
              ),
            ],
          ),
          if (footer != null && !(autoHideFooterOnKeyboard && isKeyboardOpen))
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: footer!,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
