import 'package:flutter/widgets.dart';

import '../../ac_phone_util.dart';
import '../../domain/ac_phone_country.dart';
import '../../domain/ac_phone_data.dart';
import '../../domain/ac_phone_masked.dart';

/// A [TextEditingController] for entering the national part of a phone
/// number under a fixed [ACPhoneCountry] mask.
///
/// The controller keeps [text] formatted according to
/// [ACPhoneCountry.nationalMask]. Reformatting is performed only via the
/// public entry points — [setPhoneNumber] and the [country] setter.
/// Direct assignments to [text] are considered out-of-contract and do not
/// trigger re-masking.
class ACNationalPhoneEditingController extends TextEditingController {
  /// Creates a controller for entering the national part of a phone number.
  ///
  /// [country] is required and provides the mask via
  /// [ACPhoneCountry.nationalMask].
  /// [initialPhoneNumber] is the national part as a raw or partially-formatted
  /// string; a leading country code prefix (matching [ACPhoneCountry.phoneCode])
  /// is stripped automatically.
  ACNationalPhoneEditingController({
    required ACPhoneCountry country,
    String? initialPhoneNumber,
  })  : _country = country,
        super(text: '') {
    if (initialPhoneNumber != null) {
      setPhoneNumber(initialPhoneNumber);
    }
  }

  ACPhoneCountry _country;

  /// The current country used to format [text].
  ACPhoneCountry get country => _country;

  /// Assigns a new [ACPhoneCountry] and reformats [text] under the new
  /// [ACPhoneCountry.nationalMask].
  ///
  /// Existing digits are preserved and truncated to the new mask length.
  /// Assigning the same country is a no-op and does not notify listeners.
  set country(ACPhoneCountry value) {
    if (value == _country) {
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
  /// Returns an empty string when no digits have been entered.
  String get rawPhoneNumber {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return '';
    }
    return '${_country.phoneCode}$digits';
  }

  /// Parsed phone data via [ACPhoneUtil.findPhone], or `null` if the current
  /// [rawPhoneNumber] cannot be recognized.
  ACPhoneData? get phoneData =>
      ACPhoneUtil.instance.findPhone(phoneNumber: rawPhoneNumber);

  /// Whether [rawPhoneNumber] passes [ACPhoneUtil.phoneIsValid].
  bool get isValid =>
      ACPhoneUtil.instance.phoneIsValid(phoneNumber: rawPhoneNumber);

  /// Programmatically sets the national part of the phone number.
  ///
  /// If [input] starts with a country-code prefix matching the current
  /// [country] (e.g. `+7` for RU), the prefix is stripped before digits
  /// are extracted. Otherwise any leading `+` is ignored as a non-digit
  /// character. Digits are truncated to the mask length.
  void setPhoneNumber(String input) {
    var working = input;
    final countryDigits = _country.phoneCode.replaceAll(RegExp(r'\D'), '');

    if (working.startsWith('+') && countryDigits.isNotEmpty) {
      final afterPlus = working.substring(1);
      final afterPlusDigits = afterPlus.replaceAll(RegExp(r'\D'), '');
      if (afterPlusDigits.startsWith(countryDigits)) {
        // Strip the '+' and the country-code digits from the original input,
        // preserving any formatting characters that follow.
        var stripped = afterPlus;
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
    final maxDigits = _countHashes(_country.nationalMask);
    final digits = allDigits.length > maxDigits
        ? allDigits.substring(0, maxDigits)
        : allDigits;

    text = ACPhoneMasked.setMask(
      _country.nationalMask,
      rawPhone: digits,
    ).maskedPhone;
  }

  int _countHashes(String mask) => '#'.allMatches(mask).length;
}
