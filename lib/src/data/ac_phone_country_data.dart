import 'package:flutter/foundation.dart';

/// Raw phone country data entry used for building the countries list.
class ACPhoneCountryData {
  /// Creates an [ACPhoneCountryData] with the given [name], [isoCode],
  /// [phoneCode], [mask] and [alternativePhoneCodes].
  const ACPhoneCountryData({
    required this.name,
    required this.isoCode,
    required this.phoneCode,
    required this.mask,
    required this.alternativePhoneCodes,
  });

  /// Example: Россия
  final String name;

  /// Example: RU
  final String isoCode;

  /// Example: +7
  final String phoneCode;

  /// Example: +# (###) ###-##-##
  final String mask;

  /// Example: [+1 (670), +1 (684)]
  final List<String> alternativePhoneCodes;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is ACPhoneCountryData &&
        name == other.name &&
        isoCode == other.isoCode &&
        phoneCode == other.phoneCode &&
        mask == other.mask &&
        listEquals(alternativePhoneCodes, other.alternativePhoneCodes);

  @override
  int get hashCode => Object.hash(
    name,
    isoCode,
    phoneCode,
    mask,
    Object.hashAll(alternativePhoneCodes),
  );
}
