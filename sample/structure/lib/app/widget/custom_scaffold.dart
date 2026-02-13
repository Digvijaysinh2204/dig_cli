import '../utils/import.dart';
import 'app_bar_wrapper.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.isSafeAreaTop = true,
    this.isSafeAreaBottom = true,
    this.isAppBar = true,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backButtonPressed,
    this.backgroundColor,
    this.appBarColor,
    this.backButtonColor,
    this.backButtonBackgroundColor,
    this.statusBarDarkIcons = false,
    this.appBarHeight,
    this.centerTitle = false,
    this.resizeToAvoidBottomInset,
  });

  final Widget body;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final bool isAppBar;
  final bool isSafeAreaTop;
  final bool isSafeAreaBottom;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final void Function()? backButtonPressed;
  final Color? backgroundColor;
  final Color? appBarColor;
  final Color? backButtonColor;
  final Color? backButtonBackgroundColor;
  final bool statusBarDarkIcons;
  final double? appBarHeight;
  final bool centerTitle;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: statusBarDarkIcons
            ? Brightness.dark
            : Brightness.light,
        statusBarBrightness: statusBarDarkIcons
            ? Brightness.light
            : Brightness.dark,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Material(
          color: Colors.white,
          child: Stack(
            children: [
              // If you want to a add bg image show add here and uncommit
              /*  const Positioned(
                bottom: 60,
                child: Opacity(
                  opacity: 0.05,
                  child: BackgroundWrapper(imagePath: ''),
                ),
              ),*/
              Scaffold(
                backgroundColor: backgroundColor ?? Colors.transparent,
                bottomNavigationBar: bottomNavigationBar,
                floatingActionButton: floatingActionButton,
                floatingActionButtonLocation: floatingActionButtonLocation,
                resizeToAvoidBottomInset: resizeToAvoidBottomInset ?? true,

                appBar: isAppBar
                    ? AppBarWrapper(
                        title: title,
                        actions: actions,
                        leading: leading,
                        showBackButton: showBackButton,
                        backButtonPressed: backButtonPressed,
                        backButtonColor: backButtonColor,
                        backButtonBackgroundColor: backButtonBackgroundColor,
                        appBarColor: appBarColor,
                        statusBarDarkIcons: statusBarDarkIcons,
                        centerTitle: centerTitle,
                      )
                    : null,

                body: SafeArea(
                  top: isSafeAreaTop,
                  bottom: isSafeAreaBottom,
                  child: body,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
