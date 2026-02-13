import '../utils/import.dart';

class LocalizedContent {
  final String en;
  final String el;

  const LocalizedContent({required this.en, required this.el});

  /// Get text based on current locale
  String text(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    switch (locale) {
      case 'el':
        return el;
      case 'en':
      default:
        return en;
    }
  }
}
