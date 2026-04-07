import 'package:equatable/equatable.dart';

class PhoneCountry with EquatableMixin {
  const PhoneCountry({
    required this.name,
    required this.isoCode,
    required this.phoneCode,
    required this.mask,
    required this.alternativePhoneCodes
  });

  // Example: Россия
  final String name;

  // Example: RU
  final String isoCode;

  // Example: +7
  final String phoneCode;

  // Example: +# (###) ###-##-##
  final String mask;

  // Example: [+1 (670), +1 (684)]
  final List<String> alternativePhoneCodes;

  Set<String> get potentialPhoneCodes {
    final result = <String>{};

    if (alternativePhoneCodes.isEmpty) {
      result.add(
        phoneCode
          .replaceAll(RegExp('[^0-9]'), '')
        );
    }

    for (final code in alternativePhoneCodes) {
      result.add(
        code.replaceAll(RegExp('[^0-9]'), '')
      );
    }

    return result;
  }

  // Example: ### ###-##-##
  String get telMask =>
    mask
      .replaceAll(RegExp(r'^\+[#]*\s'), '')
      .replaceAll('(', '')
      .replaceAll(')', '');

  @override
  List<Object?> get props => [
    name,
    isoCode,
    phoneCode,
    mask,
    alternativePhoneCodes
  ];

  PhoneCountry copyWith({
    String? name,
    String? isoCode,
    String? phoneCode,
    String? mask,
    List<String>? alternativePhoneCodes,
  }) => PhoneCountry(
    name: name ?? this.name,
    isoCode: isoCode ?? this.isoCode,
    phoneCode: phoneCode ?? this.phoneCode,
    mask: mask ?? this.mask,
    alternativePhoneCodes: alternativePhoneCodes ?? this.alternativePhoneCodes,
  );
}