import 'package:flutter/services.dart';

import '../../ac_phone_util.dart';
import '../../domain/ac_phone_country.dart';
import '../../domain/ac_phone_data.dart';
import '../../domain/ac_phone_masked.dart';

/// A [TextInputFormatter] that automatically formats phone number input
/// by applying a country-specific mask.
///
/// Supports two modes:
/// - **Auto-detect**: when [country] is `null`, the formatter uses
///   [ACPhoneUtil.findPhone] to detect the country from the entered digits.
/// - **Fixed country**: when [country] is provided, the formatter always
///   applies that country's mask regardless of the entered digits.
///
/// Example usage:
/// ```dart
/// TextField(
///   inputFormatters: [
///     ACPhoneInputFormatter(
///       onPhoneChanged: (data) => print(data?.phoneNumberMasked),
///     ),
///   ],
/// )
/// ```
class ACPhoneInputFormatter extends TextInputFormatter {
  /// Creates an [ACPhoneInputFormatter].
  ///
  /// If [country] is provided, the formatter uses that country's mask.
  /// Otherwise, the country is auto-detected from the phone digits.
  ///
  /// [onPhoneChanged] is called after each formatting with the resulting
  /// [ACPhoneData], or `null` if the input is empty or unrecognized.
  ACPhoneInputFormatter({
    this.country,
    this.onPhoneChanged,
  });

  /// Fixed country for mask. If `null`, auto-detection by phone code.
  final ACPhoneCountry? country;

  /// Callback invoked when the phone data changes after formatting.
  final ValueChanged<ACPhoneData?>? onPhoneChanged;

  static final _nonDigitRegExp = RegExp(r'\D');

  /// Formats the phone number input by extracting digits, applying the
  /// appropriate country mask, and repositioning the cursor.
  ///
  /// Returns a new [TextEditingValue] with the formatted text and
  /// adjusted cursor position.
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(_nonDigitRegExp, '');

    if (digits.isEmpty) {
      onPhoneChanged?.call(null);
      return TextEditingValue.empty;
    }

    // Count digits before cursor in the new (unformatted) value
    final digitsBeforeCursor = _countDigitsBeforeOffset(
      newValue.text,
      newValue.selection.baseOffset,
    );

    final String formattedText;
    ACPhoneData? phoneData;

    if (country != null) {
      // Fixed country mode: apply country mask directly
      final masked = ACPhoneMasked.setMask(
        country!.mask,
        rawPhone: digits,
      );
      formattedText = masked.maskedPhone;
      phoneData = ACPhoneData(
        phoneNumberMasked: formattedText,
        country: country!,
      );
    } else {
      // Auto-detect mode: use ACPhoneUtil to find country
      phoneData = ACPhoneUtil.instance.findPhone(
        phoneNumber: digits,
      );

      if (phoneData != null) {
        formattedText = phoneData.phoneNumberMasked;
      } else {
        // No country match — return digits as-is
        onPhoneChanged?.call(null);
        return TextEditingValue(
          text: digits,
          selection: TextSelection.collapsed(offset: digits.length),
        );
      }
    }

    onPhoneChanged?.call(phoneData);

    // Map cursor position: find the offset in formatted string that
    // corresponds to digitsBeforeCursor count of digit characters.
    final cursorOffset = _mapCursorPosition(
      formattedText,
      digitsBeforeCursor,
    );

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }

  /// Counts how many digit characters appear before [offset] in [text].
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

  /// Finds the position in [formattedText] after the [digitCount]-th digit.
  int _mapCursorPosition(String formattedText, int digitCount) {
    var count = 0;
    for (var i = 0; i < formattedText.length; i++) {
      if (_isDigit(formattedText[i])) {
        count++;
        if (count >= digitCount) {
          return i + 1;
        }
      }
    }
    // If fewer digits in formatted text than expected,
    // place cursor at the end.
    return formattedText.length;
  }

  /// Returns `true` if [char] is an ASCII digit (0-9).
  bool _isDigit(String char) =>
      char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
}
