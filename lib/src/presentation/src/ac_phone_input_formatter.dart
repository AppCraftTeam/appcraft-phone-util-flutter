import 'package:flutter/services.dart';

import '../../domain/ac_phone_masked.dart';

/// A [TextInputFormatter] that formats phone number input by applying
/// a fixed mask.
///
/// The mask uses `#` as a digit placeholder; any other character is
/// preserved as a literal separator.
///
/// Example usage:
/// ```dart
/// TextField(
///   inputFormatters: [
///     ACPhoneInputFormatter(mask: '+# (###) ###-##-##'),
///   ],
/// )
/// ```
class ACPhoneInputFormatter extends TextInputFormatter {
  /// Creates an [ACPhoneInputFormatter] that applies [mask] to user input.
  ACPhoneInputFormatter({ required this.mask });

  /// The mask used for formatting. `#` is a digit placeholder.
  final String mask;

  static final _nonDigitRegExp = RegExp(r'\D');

  /// Formats the phone number input by extracting digits, applying the
  /// configured [mask], and repositioning the cursor near the edit point.
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (mask.isEmpty) {
      return newValue;
    }

    final digits = newValue.text.replaceAll(_nonDigitRegExp, '');

    if (digits.isEmpty) {
      return TextEditingValue.empty;
    }

    final digitsBeforeCursor = _countDigitsBeforeOffset(
      newValue.text,
      newValue.selection.baseOffset,
    );

    final formattedText = ACPhoneMasked.setMask(
      mask,
      rawPhone: digits,
    ).maskedPhone;

    final cursorOffset = _mapCursorPosition(
      formattedText,
      digitsBeforeCursor,
    );

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }

  int _countDigitsBeforeOffset(String text, int offset) {
    final safeOffset = offset.clamp(0, text.length);
    var count = 0;
    for (var i = 0; i < safeOffset; i++) {
      if (_isDigit(text[i])) {
        count++;
      }
    }
    return count;
  }

  int _mapCursorPosition(String formattedText, int digitCount) {
    if (digitCount <= 0) {
      return 0;
    }
    var count = 0;
    for (var i = 0; i < formattedText.length; i++) {
      if (_isDigit(formattedText[i])) {
        count++;
        if (count >= digitCount) {
          return i + 1;
        }
      }
    }
    return formattedText.length;
  }

  bool _isDigit(String char) =>
    char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
}
