import 'ac_phone_country.dart';

/// Contains parsed phone number data with the matched country.
class ACPhoneData {
  /// Creates an [ACPhoneData] with the given [phoneNumberMasked] and [country].
  const ACPhoneData({
    required this.phoneNumberMasked,
    required this.country,
  });

  /// The phone number with formatting mask applied.
  final String phoneNumberMasked;

  /// The matched [ACPhoneCountry] for this phone number.
  final ACPhoneCountry country;

  /// Returns the raw phone number (digits and '+' only).
  String get rawPhoneNumber =>
    phoneNumberMasked
      .replaceAll(RegExp('[^0-9+]'), '');

  /// Returns the region code extracted from the masked phone number.
  String get regionCode {
    final components = phoneNumberMasked.split(' ');
    return components[1]
      .replaceAll(RegExp('[^0-9+]'), '');
  }
}
