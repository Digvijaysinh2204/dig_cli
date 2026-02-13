import '../utils/import.dart';

class CustomTextView extends Text {
  CustomTextView({
    super.key,
    required String text,
    TextStyle? style,
    TextAlign textAlign = TextAlign.start,
    int? maxLines,
    TextOverflow? overflow,
    bool capitalize = false,
    bool capitalizeFirst = false,
    bool toUpperCase = false,
    bool toLowerCase = false,
  }) : super(
         _processText(
           text,
           capitalize: capitalize,
           capitalizeFirst: capitalizeFirst,
           toUpperCase: toUpperCase,
           toLowerCase: toLowerCase,
         ),
         style: style,
         maxLines: maxLines,
         textAlign: textAlign,
         overflow: overflow,
       );

  static String _processText(
    String text, {
    required bool capitalize,
    required bool capitalizeFirst,
    required bool toUpperCase,
    required bool toLowerCase,
  }) {
    final langCode = Get.find<LanguageService>().locale.languageCode;

    // ❌ If NOT English → return original text
    if (langCode != 'en') {
      return text;
    }

    // ✔ Apply transformations ONLY for English
    if (capitalize) return text.capitalize.toString();
    if (capitalizeFirst) return text.capitalizeFirst.toString();
    if (toUpperCase) return text.toUpperCase();
    if (toLowerCase) return text.toLowerCase();

    return text;
  }
}
