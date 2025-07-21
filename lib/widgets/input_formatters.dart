import 'package:flutter/services.dart';

// Input formatter for card number: 1234-5678-9012-3456
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      buffer.write(digitsOnly[i]);
      if ((i + 1) % 4 == 0 && i != digitsOnly.length - 1 && i < 15) {
        buffer.write('-');
      }
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

// Input formatter for expiry date: MM/YY
class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length > 4) digitsOnly = digitsOnly.substring(0, 4);
    String formatted = '';
    if (digitsOnly.length >= 2) {
      formatted = digitsOnly.substring(0, 2);
      if (digitsOnly.length > 2) {
        formatted += '/${digitsOnly.substring(2)}';
      }
    } else {
      formatted = digitsOnly;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
