import '../utils/import.dart';
import 'font_family.dart';

class AppTextStyle {
  static TextStyle _base({
    required double size,
    required String fontFamily,
    Color color = Colors.black,
    double? height,
    FontWeight? weight,
    TextOverflow? overflow,
    TextDecoration? decoration,
    double? letterSpacing,
    TextDecorationStyle? decorationStyle,
    Color? decorationColor,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontSize: size,
      fontFamily: fontFamily,
      color: color,
      height: height,
      overflow: overflow,
      decoration: decoration,
      letterSpacing: letterSpacing,
      fontWeight: weight,
      fontStyle: fontStyle,
      decorationStyle: decorationStyle,
      decorationColor: decorationColor,
    );
  }

  static TextStyle regular({
    required double size,
    Color color = Colors.black,
    double? height,
    FontWeight fontWeight = FontWeight.w400,
    TextOverflow? overflow,
    TextDecoration? decoration,
    Color? decorationColor,
  }) => _base(
    size: size,
    fontFamily: FontFamily.regular.value,
    color: color,
    height: height,
    weight: fontWeight,
    overflow: overflow,
    decoration: decoration,
    decorationColor: decorationColor,
  );

  static TextStyle medium({
    required double size,
    Color color = Colors.black,
    double? height,
    FontWeight fontWeight = FontWeight.w500,
    TextOverflow? overflow,
    TextDecoration? decoration,
    Color? decorationColor,
  }) => _base(
    size: size,
    fontFamily: FontFamily.medium.value,
    color: color,
    height: height,
    weight: fontWeight,
    overflow: overflow,
    decoration: decoration,
    decorationColor: decorationColor,
  );

  static TextStyle semiBold({
    required double size,
    Color color = Colors.black,
    double? height,
    FontWeight fontWeight = FontWeight.w600,
    TextOverflow? overflow,
    TextDecoration? decoration,
    Color? decorationColor,
  }) => _base(
    size: size,
    fontFamily: FontFamily.semiBold.value,
    color: color,
    height: height,
    weight: fontWeight,
    overflow: overflow,
    decoration: decoration,
    decorationColor: decorationColor,
  );

  static TextStyle bold({
    required double size,
    Color color = Colors.black,
    double? height,
    FontWeight fontWeight = FontWeight.w700,
    TextOverflow? overflow,
    TextDecoration? decoration,
    Color? decorationColor,
  }) => _base(
    size: size,
    fontFamily: FontFamily.bold.value,
    color: color,
    height: height,
    weight: fontWeight,
    overflow: overflow,
    decoration: decoration,
    decorationColor: decorationColor,
  );

  static TextStyle appBarTitle({
    double size = 18,
    Color color = AppColor.kWhite,
  }) => semiBold(size: size, color: color);
}
