// ignore_for_file: avoid_catches_without_on_clauses

import 'dart:math' as math;
import 'dart:ui';

import 'data/ac_phone_countries.dart';
import 'data/ac_phone_country_localizations.dart';
import 'domain/ac_phone_country.dart';
import 'domain/ac_phone_data.dart';

/// Main utility class for phone number parsing, validation and formatting.
class ACPhoneUtil {
  const ACPhoneUtil._();

  /// Singleton instance of [ACPhoneUtil].
  static const instance = ACPhoneUtil._();
  static const int _maxLengthPhoneCode = 4;

  /// Returns a list of [ACPhoneCountry] optionally localized by [locale]
  /// and filtered by [search] string.
  List<ACPhoneCountry> getCountries({
    Locale? locale,
    String? search,
  }) {
    var countries = ACPhoneCountries.instance.all;

    if (locale != null) {
      final localizations = ACPhoneCountryLocalizations(locale);
      countries = countries
        .map((country) => country.copyWith(
          name: localizations.countryName(
            isoCode: country.isoCode,
          ),
        ))
        .toList();
    }

    if (search != null) {
      countries = countries
        .where((country) => country.name.toLowerCase()
          .contains(search.toLowerCase()))
        .toList();
    }

    return countries;
  }

  /// Parses a [phoneNumber] string and returns [ACPhoneData] with
  /// the matched country and formatted number, or `null` if no match found.
  ACPhoneData? findPhone({
    required String phoneNumber,
  }) {
    final phoneNumberSanitized = _sanitize(phoneNumber);
    if (phoneNumberSanitized.isEmpty) return null;

    // 1) Get potential phone code
    final potentialPhoneCode = _getPotentialPhoneCode(
      phoneNumberSanitized: phoneNumberSanitized,
    );

    // 2) Parse country from potential phone code
    final phoneNumberCountry = _parseCountry(
      potentialPhoneCode: potentialPhoneCode,
    );

    if (phoneNumberCountry == null) return null;

    // 3) Actual phone code
    final phoneNumberWithActualPhoneCodeSanitized = _replaceOnActualPhoneCode(
      actualPhoneCode: phoneNumberCountry.phoneCode,
      phoneNumberSanitized: phoneNumberSanitized,
    );

    // 4) Mask
    final result = _applyMask(
      mask: phoneNumberCountry.mask,
      phoneNumberSanitized: phoneNumberWithActualPhoneCodeSanitized,
    );

    // 5) Result
    return ACPhoneData(
      phoneNumberMasked: result,
      country: phoneNumberCountry,
    );
  }

  /// Returns `true` if [phoneNumber] is a valid phone number
  /// matching a known country mask.
  bool phoneIsValid({
    required String phoneNumber,
  }) {
    try {
      final phone = findPhone(phoneNumber: phoneNumber);
      if (phone == null) return false;

      int sanitizedLength(String phone) =>
        phone
          .replaceAll('+', '')
          .replaceAll('(', '')
          .replaceAll(')', '')
          .replaceAll(' ', '')
          .replaceAll('-', '')
          .length;

      return sanitizedLength(phoneNumber) ==
        sanitizedLength(phone.country.mask);
    } catch (_) {
      return false;
    }
  }

  /// Sanitize string for numbers
  String _sanitize(String string) =>
    string.replaceAll(RegExp('[^0-9]'), '');

  /// Getting potential phone code from sanitized phone number and sanitized phone codes from constant
  String _getPotentialPhoneCode({
    required String phoneNumberSanitized,
  }) =>
      phoneNumberSanitized.substring(
        0,
        math.min(
          phoneNumberSanitized.length,
          _maxLengthPhoneCode,
        ),
      );

  ACPhoneCountry? _parseCountry({
    required String potentialPhoneCode,
  }) {
    for (var i = potentialPhoneCode.length; i >= 0; i--) {
      final potentialPhoneCodeSubstring = potentialPhoneCode.substring(0, i);
      final country = ACPhoneCountries.instance.hashedCountries[potentialPhoneCodeSubstring];

      if (country != null) return country;
      continue;
    }

    return null;
  }

  /// Replacement on finding phone code for crutching numbers
  String _replaceOnActualPhoneCode({
    required String actualPhoneCode,
    required String phoneNumberSanitized,
  }) {
    actualPhoneCode = _sanitize(actualPhoneCode);
    final phoneNumberSanitizedList = phoneNumberSanitized.split('');

    for (var i = 0; i < actualPhoneCode.length; i++) {
      phoneNumberSanitizedList[i] = actualPhoneCode[i];
    }

    return phoneNumberSanitizedList.join('');
  }

  /// Main method for applying mask on number
  String _applyMask({
    required String mask,
    required String phoneNumberSanitized,
  }) {
    var result = '';
    var phoneNumberIndex = 0;

    for (var i = 0; i < mask.length; i++) {
      if (phoneNumberIndex >= phoneNumberSanitized.length) break;

      final currentMaskChar = mask[i];
      final currentPhoneNumberChar = phoneNumberSanitized[phoneNumberIndex];

      if (currentMaskChar == '#') {
        result = '$result$currentPhoneNumberChar';
        phoneNumberIndex++;
        continue;
      }

      if (int.tryParse(currentMaskChar) != null) {
        result = '$result$currentMaskChar';
        phoneNumberIndex++;
        continue;
      }

      // ignore: use_string_buffers
      result = '$result$currentMaskChar';
    }

    return result;
  }
}
