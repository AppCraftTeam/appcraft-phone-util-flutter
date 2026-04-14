import 'package:flutter/widgets.dart';

import '../../ac_phone_util.dart';
import '../../domain/ac_phone_country.dart';
import '../../domain/ac_phone_data.dart';
import '../../domain/ac_phone_masked.dart';

/// A [TextEditingController] for entering the national part of a phone
/// number under an optional [ACPhoneCountry] mask.
///
/// When [country] is non-null the controller keeps [text] formatted according
/// to [ACPhoneCountry.nationalMask]. When [country] is `null` the controller
/// stores only raw digits in [text] without any mask or truncation, and
/// [rawPhoneNumber], [phoneData] and [isValid] behave as if no phone number
/// has been entered.
///
/// Reformatting is performed only via the public entry points —
/// [setPhoneNumber] and the [country] setter. Direct assignments to [text]
/// are considered out-of-contract and do not trigger re-masking.
class ACNationalPhoneEditingController extends TextEditingController {
  /// Creates a controller for entering the national part of a phone number.
  ///
  /// [country] is optional; when `null`, the controller has no active mask
  /// and stores only raw digits until a country is assigned.
  /// [initialPhoneNumber] is the national part as a raw or partially-formatted
  /// string; a leading country code prefix (matching [ACPhoneCountry.phoneCode])
  /// is stripped automatically. When [country] is `null` the
  /// [initialPhoneNumber] is ignored and [text] remains empty until a country
  /// is assigned.
  ACNationalPhoneEditingController({
    ACPhoneCountry? country,
    String? initialPhoneNumber,
  })  : _country = country,
        super(text: '') {
    if (initialPhoneNumber != null && country != null) {
      setPhoneNumber(initialPhoneNumber);
    }
  }

  ACPhoneCountry? _country;

  /// The current country used to format [text], or `null` when no mask is
  /// active.
  ACPhoneCountry? get country => _country;

  /// Assigns a new [ACPhoneCountry] (possibly `null`) and reformats [text]
  /// accordingly.
  ///
  /// Transitions:
  /// - non-null -> `null`: [text] is cleared.
  /// - `null` -> non-null: current digits from [text] are truncated to the
  ///   new mask length and formatted under [ACPhoneCountry.nationalMask].
  /// - non-null -> non-null (different): digits are preserved, truncated to
  ///   the new mask length and reformatted.
  ///
  /// Assigning the same country is a no-op and does not notify listeners.
  set country(ACPhoneCountry? value) {
    if (value == _country) {
      return;
    }

    if (value == null) {
      _country = null;
      text = '';
      return;
    }

    final allDigits = text.replaceAll(RegExp(r'\D'), '');
    final maxDigits = _countHashes(value.nationalMask);
    final digits = allDigits.length > maxDigits
        ? allDigits.substring(0, maxDigits)
        : allDigits;

    _country = value;
    text = ACPhoneMasked.setMask(
      value.nationalMask,
      rawPhone: digits,
    ).maskedPhone;
  }

  /// Full phone number: country code + national digits.
  ///
  /// Returns an empty string when [country] is `null` or no digits have been
  /// entered.
  String get rawPhoneNumber {
    final country = _country;
    if (country == null) {
      return '';
    }
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return '';
    }
    return '${country.phoneCode}$digits';
  }

  /// Parsed phone data via [ACPhoneUtil.findPhone], or `null` if [country]
  /// is `null` or the current [rawPhoneNumber] cannot be recognized.
  ACPhoneData? get phoneData {
    final raw = rawPhoneNumber;
    if (raw.isEmpty) {
      return null;
    }
    return ACPhoneUtil.instance.findPhone(phoneNumber: raw);
  }

  /// Whether [rawPhoneNumber] passes [ACPhoneUtil.phoneIsValid].
  ///
  /// Always `false` when [country] is `null` or no digits have been entered.
  bool get isValid {
    final raw = rawPhoneNumber;
    if (raw.isEmpty) {
      return false;
    }
    return ACPhoneUtil.instance.phoneIsValid(phoneNumber: raw);
  }

  /// Programmatically sets the national part of the phone number.
  ///
  /// When [country] is `null`, only digits are extracted from [input] and
  /// stored in [text] without any mask or truncation.
  ///
  /// Otherwise, if [input] starts with a country-code prefix matching the
  /// current [country] (e.g. `+7` for RU), the prefix is stripped before
  /// digits are extracted. Any leading `+` is ignored as a non-digit
  /// character. Digits are truncated to the mask length.
  void setPhoneNumber(String input) {
    final country = _country;
    if (country == null) {
      final digits = input.replaceAll(RegExp(r'\D'), '');
      text = digits;
      return;
    }

    var working = input;
    final countryDigits = country.phoneCode.replaceAll(RegExp(r'\D'), '');

    if (working.startsWith('+') && countryDigits.isNotEmpty) {
      final afterPlus = working.substring(1);
      final afterPlusDigits = afterPlus.replaceAll(RegExp(r'\D'), '');
      if (afterPlusDigits.startsWith(countryDigits)) {
        // Strip the '+' and the country-code digits from the original input,
        // preserving any formatting characters that follow.
        final stripped = afterPlus;
        var remaining = countryDigits.length;
        final buffer = StringBuffer();
        for (var i = 0; i < stripped.length; i++) {
          final ch = stripped[i];
          if (remaining > 0 && RegExp(r'\d').hasMatch(ch)) {
            remaining--;
            continue;
          }
          buffer.write(ch);
        }
        working = buffer.toString();
      }
    }

    final allDigits = working.replaceAll(RegExp(r'\D'), '');
    final maxDigits = _countHashes(country.nationalMask);
    final digits = allDigits.length > maxDigits
        ? allDigits.substring(0, maxDigits)
        : allDigits;

    text = ACPhoneMasked.setMask(
      country.nationalMask,
      rawPhone: digits,
    ).maskedPhone;
  }

  int _countHashes(String mask) => '#'.allMatches(mask).length;
}
