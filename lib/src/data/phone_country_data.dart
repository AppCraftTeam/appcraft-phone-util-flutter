import 'package:equatable/equatable.dart';

class PhoneCountryData extends Equatable {
  const PhoneCountryData({
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

  @override
  List<Object?> get props => [
    name,
    isoCode,
    phoneCode,
    mask,
    alternativePhoneCodes
  ];
}