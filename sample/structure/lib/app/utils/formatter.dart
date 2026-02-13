import 'package:dlibphonenumber/phone_number_util.dart';
import 'package:intl/intl.dart';

import 'import.dart';

extension StringFormatting on String {
  String format({
    String currencyCode = 'EUR',
    String locale = 'en_US',
    int decimalDigits = 2,
    bool hideZeroDecimal = true,
  }) {
    if (isEmpty) return this;

    try {
      final value = double.parse(this);

      final bool shouldHideDecimal = hideZeroDecimal && value % 1 == 0;

      final formatter = NumberFormat.currency(
        locale: locale,
        name: currencyCode,
        decimalDigits: shouldHideDecimal ? 0 : decimalDigits,
        symbol: NumberFormat.simpleCurrency(
          name: currencyCode,
          locale: locale,
        ).currencySymbol,
      );

      return formatter.format(value);
    } catch (_) {
      return this;
    }
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalDigits;
  final bool useCommas;

  DecimalTextInputFormatter({
    required this.decimalDigits,
    this.useCommas = false,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // ❌ Reject invalid characters (only digits and '.')
    final regex = RegExp(r'^[0-9]*\.?[0-9]*$');
    if (!regex.hasMatch(newValue.text)) {
      return oldValue;
    }

    String value = newValue.text.replaceAll(',', '');
    if (value.startsWith('.')) value = '0$value';

    // ❌ Prevent multiple dots
    if (value.indexOf('.') != value.lastIndexOf('.')) {
      return oldValue;
    }

    // ✅ Restrict decimal places
    if (value.contains('.')) {
      final parts = value.split('.');
      if (parts.length > 1 && parts[1].length > decimalDigits) {
        value = '${parts[0]}.${parts[1].substring(0, decimalDigits)}';
      }
    }

    // ✅ Handle integer part + commas if needed
    final parts = value.split('.');
    String intPart = parts[0].isEmpty ? '0' : parts[0];
    if (useCommas) intPart = _formatWithCommas(intPart);

    final newText = parts.length > 1 ? '$intPart.${parts[1]}' : intPart;

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  String _formatWithCommas(String digits) {
    final buffer = StringBuffer();
    int count = 0;
    for (int i = digits.length - 1; i >= 0; i--) {
      buffer.write(digits[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write(',');
    }
    return buffer.toString().split('').reversed.join('');
  }
}

class PriceInputFormatter extends DecimalTextInputFormatter {
  PriceInputFormatter() : super(decimalDigits: 2, useCommas: false);
}

class PoundsInputFormatter extends DecimalTextInputFormatter {
  PoundsInputFormatter() : super(decimalDigits: 2, useCommas: false);
}

class PhoneNumberFormatter extends TextInputFormatter {
  final String countryCode;

  PhoneNumberFormatter(this.countryCode);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    try {
      final phoneUtil = PhoneNumberUtil.instance;

      // 1️⃣ Get max length from example number
      final examplePhoneNumber = phoneUtil.getExampleNumber(countryCode);
      final maxLength =
          examplePhoneNumber?.nationalNumber.toString().length ?? 15;

      // 2️⃣ Keep only digits
      final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

      // 3️⃣ Block input if exceeding max length
      if (digitsOnly.length > maxLength) {
        return oldValue;
      }

      // ✅ Return plain digits only (no formatting)
      return TextEditingValue(
        text: digitsOnly,
        selection: TextSelection.collapsed(offset: digitsOnly.length),
      );
    } catch (_) {
      return oldValue;
    }
  }
}

String currentDateTime(BuildContext context) {
  final now = DateTime.now();
  final locale = Localizations.localeOf(context).toString();

  final date = DateFormat('dd MMM, yyyy', locale).format(now);
  final time = DateFormat.jm(locale).format(now);

  return '$date • $time';
}
