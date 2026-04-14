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
/// [setPhoneNumber] accepts a full phone number (e.g. `+79009998877`) and
/// auto-detects [country] via [ACPhoneUtil.findPhone]; unrecognized input
/// clears [country] and stores only digits.
///
/// Reformatting is performed only via the public entry points —
/// [setPhoneNumber] and the [country] setter. Direct assignments to [text]
/// are considered out-of-contract and do not trigger re-masking.
class ACNationalPhoneEditingController extends TextEditingController {
  /// Creates a controller for entering the national part of a phone number.
  ///
  /// [country] is optional; when `null`, the controller has no active mask
  /// and stores only raw digits until a country is assigned or a recognizable
  /// phone number is provided via [setPhoneNumber].
  ///
  /// When [initialPhoneNumber] is provided, it is interpreted as a full phone
  /// number (for example, `+79009998877`) and is passed to [setPhoneNumber].
  /// If the number is recognized via [ACPhoneUtil.findPhone], the controller's
  /// [country] is set from the detected country, overriding the [country]
  /// argument passed to the constructor. If the number is not recognized,
  /// [country] becomes `null` and only digits are stored in [text].
  ACNationalPhoneEditingController({
    ACPhoneCountry? country,
    String? initialPhoneNumber,
  })  : _country = country,
        super(text: '') {
    if (initialPhoneNumber != null) {
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

  /// Programmatically sets the phone number from a full (international) [input].
  ///
  /// The [input] is expected to be a full phone number, for example
  /// `+79009998877`. The controller delegates recognition to
  /// [ACPhoneUtil.findPhone]:
  ///
  /// - If the number is recognized, [country] is updated to the detected
  ///   country and [text] is set to the national part formatted under
  ///   [ACPhoneCountry.nationalMask].
  /// - If the number is not recognized, [country] becomes `null` and only
  ///   the digits extracted from [input] are stored in [text], without any
  ///   mask or truncation.
  /// - If [input] is empty, [country] becomes `null` and [text] is cleared.
  void setPhoneNumber(String input) {
    if (input.isEmpty) {
      _country = null;
      text = '';
      return;
    }

    final phoneData = input.startsWith('+')
        ? ACPhoneUtil.instance.findPhone(phoneNumber: input)
        : null;

    if (phoneData != null) {
      _country = phoneData.country;
      final fullDigits = phoneData.rawPhoneNumber.replaceAll(RegExp(r'\D'), '');
      final codeDigits =
          phoneData.country.phoneCode.replaceAll(RegExp(r'\D'), '');
      final nationalDigits = fullDigits.startsWith(codeDigits)
          ? fullDigits.substring(codeDigits.length)
          : fullDigits;
      text = ACPhoneMasked.setMask(
        phoneData.country.nationalMask,
        rawPhone: nationalDigits,
      ).maskedPhone;
      return;
    }

    _country = null;
    text = input.replaceAll(RegExp(r'\D'), '');
  }

  int _countHashes(String mask) => '#'.allMatches(mask).length;
}
