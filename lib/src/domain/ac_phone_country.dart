import 'package:flutter/foundation.dart';

/// Represents a phone country with its code, mask and metadata.
class ACPhoneCountry {
  /// Creates an [ACPhoneCountry] with the given [name], [isoCode],
  /// [phoneCode], [mask] and [alternativePhoneCodes].
  const ACPhoneCountry({
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

  /// Returns the set of potential phone codes derived from
  /// [phoneCode] and [alternativePhoneCodes].
  Set<String> get potentialPhoneCodes {
    final result = <String>{};

    if (alternativePhoneCodes.isEmpty) {
      result.add(
        phoneCode
          .replaceAll(RegExp('[^0-9]'), ''),
      );
    }

    for (final code in alternativePhoneCodes) {
      result.add(
        code.replaceAll(RegExp('[^0-9]'), ''),
      );
    }

    return result;
  }

  /// National mask without the leading country-code prefix.
  /// Brackets and dashes are preserved.
  ///
  /// Example: `(###) ###-##-##` for mask `+# (###) ###-##-##`.
  String get nationalMask =>
    mask.replaceAll(RegExp(r'^\+[#]*\s'), '');

  /// Full mask with `(`, `)` and `-` removed; only spaces are used
  /// as separators between digit groups.
  ///
  /// Example: `+# ### ### ## ##` for mask `+# (###) ###-##-##`.
  String get rawMask =>
    mask
      .replaceAll('(', '')
      .replaceAll(')', '')
      .replaceAll('-', ' ');

  /// National mask with `(`, `)` and `-` removed; only spaces are used
  /// as separators between digit groups.
  ///
  /// Example: `### ### ## ##` for mask `+# (###) ###-##-##`.
  String get rawNationalMask =>
    nationalMask
      .replaceAll('(', '')
      .replaceAll(')', '')
      .replaceAll('-', ' ');

  /// Creates a copy of this [ACPhoneCountry] with the given fields replaced.
  ACPhoneCountry copyWith({
    String? name,
    String? isoCode,
    String? phoneCode,
    String? mask,
    List<String>? alternativePhoneCodes,
  }) => ACPhoneCountry(
    name: name ?? this.name,
    isoCode: isoCode ?? this.isoCode,
    phoneCode: phoneCode ?? this.phoneCode,
    mask: mask ?? this.mask,
    alternativePhoneCodes: alternativePhoneCodes ?? this.alternativePhoneCodes,
  );

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is ACPhoneCountry &&
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
