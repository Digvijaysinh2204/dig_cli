import '../utils/import.dart';
import 'custom_back_button.dart';

class AppBarWrapper extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWrapper({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.appBarColor,
    this.statusBarDarkIcons = false,
    this.centerTitle = false,
    this.showBackButton = true,
    this.backButtonPressed,
    this.backButtonColor,
    this.backButtonBackgroundColor,
    this.leadingWidth,
  });

  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool statusBarDarkIcons;
  final Color? appBarColor;
  final bool centerTitle;

  final bool showBackButton;
  final void Function()? backButtonPressed;
  final Color? backButtonColor;
  final Color? backButtonBackgroundColor;
  final double? leadingWidth;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: leadingWidth ?? 60,
      titleSpacing: 10,
      elevation: 0,
      centerTitle: centerTitle,
      backgroundColor: appBarColor ?? AppColor.k161A25,
      shadowColor: AppColor.k161A25,
      surfaceTintColor: AppColor.k161A25,
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      title: title,
      actions: actions,
      leading:
          leading?.paddingOnly(left: 20) ??
          (showBackButton
              ? CustomBackButton(
                  onPressed:
                      backButtonPressed ?? () => Get.back(closeOverlays: true),
                  color: backButtonBackgroundColor,
                  iconColor: backButtonColor,
                ).paddingOnly(left: 20)
              : null),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: statusBarDarkIcons
            ? Brightness.dark
            : Brightness.light,
        statusBarBrightness: statusBarDarkIcons
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }
}
