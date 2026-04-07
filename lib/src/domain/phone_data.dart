import '../../phone_util.dart';

class PhoneData {
  const PhoneData({
    required this.phoneNumberMasked,
    required this.country,
  });

  final String phoneNumberMasked;
  final PhoneCountry country;

  String get rawPhoneNumber =>
    phoneNumberMasked
      .replaceAll(RegExp('[^0-9+]'), '');

  String get regionCode {
    final components = phoneNumberMasked.split(' ');
    return components[1]
      .replaceAll(RegExp('[^0-9+]'), '');
  }
}
