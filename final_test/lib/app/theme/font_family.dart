enum FontFamily { regular, medium, semiBold, bold, italic }

extension FontFamilyExtension on FontFamily {
  String get value {
    switch (this) {
      case FontFamily.regular:
        return 'Regular';
      case FontFamily.medium:
        return 'Medium';
      case FontFamily.semiBold:
        return 'SemiBold';
      case FontFamily.bold:
        return 'Bold';
      case FontFamily.italic:
        return 'Italic';
    }
  }
}
