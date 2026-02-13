import 'package:flutter/cupertino.dart';

import '../utils/import.dart';

Future<void> showAdaptiveActionSheet({
  required BuildContext context,
  required String title,
  required List<AdaptiveAction> actions,
  bool titleCapitalize = false,
  String? message,
  VoidCallback? onCancel,
}) {
  if (GetPlatform.isIOS) {
    // ------------------ iOS ------------------
    return showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: CustomTextView(
          text: title,
          capitalize: titleCapitalize,
          textAlign: TextAlign.center,
          style: AppTextStyle.bold(
            size: 18,
            color: AppColor.kPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        message: message != null
            ? CustomTextView(
                text: message,
                style: AppTextStyle.regular(
                  size: 14,
                  color: AppColor.kPrimary,
                  fontWeight: FontWeight.w400,
                ),
              )
            : null,
        actions: actions
            .map(
              (a) => CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                  a.onPressed();
                },
                isDestructiveAction: a.isDestructive,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (a.iconWidget != null) ...[
                      a.iconWidget!,
                      const SizedBox(width: 8),
                    ] else if (a.icon != null) ...[
                      Icon(
                        a.icon,
                        size: 20,
                        color: a.isDestructive
                            ? AppColor.kPrimary
                            : AppColor.k030303,
                      ),
                      const SizedBox(width: 8),
                    ],
                    CustomTextView(
                      text: a.label,
                      style: a.isDestructive
                          ? AppTextStyle.bold(
                              size: 16,
                              color: AppColor.kPrimary,
                              fontWeight: FontWeight.w600,
                            )
                          : AppTextStyle.regular(
                              size: 16,
                              color: AppColor.k030303,
                              fontWeight: FontWeight.w500,
                            ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          child: CustomTextView(
            text: AppLocalizations.of(context)!.cancel,
            style: AppTextStyle.bold(
              size: 16,
              color: AppColor.kFF5757,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () {
            Get.back();
            if (onCancel != null) onCancel();
          },
        ),
      ),
    );
  } else {
    // ------------------ Android ------------------
    return showModalBottomSheet(
      context: context,
      elevation: 0,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColor.kWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            // Title
            if (title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomTextView(
                  text: title,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.bold(
                    size: 18,
                    color: AppColor.kPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (message != null) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: CustomTextView(
                  text: message,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.regular(
                    size: 14,
                    color: AppColor.kPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1),

            // Actions with divider
            ...List.generate(actions.length, (index) {
              final a = actions[index];
              return Column(
                children: [
                  CustomInkWell(
                    clickName: '',
                    onTap: () {
                      Get.back();
                      a.onPressed();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (a.iconWidget != null) ...[
                            a.iconWidget!,
                            const SizedBox(width: 8),
                          ] else if (a.icon != null) ...[
                            Icon(
                              a.icon,
                              size: 20,
                              color: a.isDestructive
                                  ? AppColor.kPrimary
                                  : AppColor.k030303,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: CustomTextView(
                              text: a.label,
                              overflow: TextOverflow.ellipsis,
                              style: a.isDestructive
                                  ? AppTextStyle.bold(
                                      size: 16,
                                      color: AppColor.kPrimary,
                                      fontWeight: FontWeight.w600,
                                    )
                                  : AppTextStyle.regular(
                                      size: 16,
                                      color: AppColor.k030303,
                                      fontWeight: FontWeight.w500,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                ],
              );
            }),
            const SizedBox(height: 10),
            SafeArea(
              child: CustomInkWell(
                clickName: '',
                onTap: () {
                  Get.back();
                  if (onCancel != null) onCancel();
                },
                child: Container(
                  color: AppColor.kWhite,
                  margin: const EdgeInsets.only(top: 8),
                  child: CustomTextView(
                    text: AppLocalizations.of(context)!.cancel,
                    style: AppTextStyle.bold(
                      size: 16,
                      color: AppColor.kFF5757,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class AdaptiveAction {
  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;
  final IconData? icon;
  final Widget? iconWidget;
  AdaptiveAction({
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
    this.icon,
    this.iconWidget,
  });
}
