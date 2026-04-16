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

    var digits = newValue.text.replaceAll(_nonDigitRegExp, '');

    if (digits.isEmpty) {
      return TextEditingValue.empty;
    }

    var digitsBeforeCursor = _countDigitsBeforeOffset(
      newValue.text,
      newValue.selection.baseOffset,
    );

    // Backspace-through-separator: the framework proposed a shorter text but
    // the digit count is unchanged, meaning only a mask separator was
    // removed. Without intervention the mask re-adds the separator and the
    // keystroke appears ineffective. Manually drop the digit immediately
    // before the cursor so backspace on any character performs a real
    // deletion.
    final oldDigits = oldValue.text.replaceAll(_nonDigitRegExp, '');
    if (oldDigits.length == digits.length &&
        newValue.text.length < oldValue.text.length &&
        digitsBeforeCursor > 0) {
      final removeIndex = digitsBeforeCursor - 1;
      digits =
          digits.substring(0, removeIndex) + digits.substring(removeIndex + 1);
      digitsBeforeCursor -= 1;
      if (digits.isEmpty) {
        return TextEditingValue.empty;
      }
    }

    final rawFormatted = ACPhoneMasked.setMask(
      mask,
      rawPhone: digits,
    ).maskedPhone;

    // Trim trailing non-digit characters. Masks add placeholders/literals
    // after the last typed digit (e.g. `+7 (`), which causes a stuck-delete
    // UX: backspace erases a separator and the mask re-adds it. Trimming
    // keeps the cursor usable at the end for both typing and deletion.
    final formattedText = _trimTrailingNonDigits(rawFormatted);

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

  /// Returns the offset in [formattedText] right after the [digitCount]-th
  /// digit, or [String.length] if fewer digits are present.
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

  /// Trims trailing characters that are not digits.
  ///
  /// Ensures the last character of the returned string is a digit (or the
  /// string is empty), removing any separator padding the mask appended
  /// after the last typed digit.
  String _trimTrailingNonDigits(String source) {
    var end = source.length;
    while (end > 0 && !_isDigit(source[end - 1])) {
      end--;
    }
    return source.substring(0, end);
  }
}
