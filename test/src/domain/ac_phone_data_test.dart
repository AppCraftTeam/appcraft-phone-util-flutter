import 'package:appcraft_phone_util_flutter/ac_phone_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ACPhoneData', () {
    test('creates object with country and phoneNumberMasked', () {
      // Arrange
      const country = ACPhoneCountry(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );

      // Act
      const phoneData = ACPhoneData(
        phoneNumberMasked: '+7 (916) 123-45-67',
        country: country,
      );

      // Assert
      expect(phoneData.phoneNumberMasked, '+7 (916) 123-45-67');
      expect(phoneData.country, country);
    });

    test('rawPhoneNumber returns digits and plus only', () {
      // Arrange
      const country = ACPhoneCountry(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );
      const phoneData = ACPhoneData(
        phoneNumberMasked: '+7 (916) 123-45-67',
        country: country,
      );

      // Act
      final raw = phoneData.rawPhoneNumber;

      // Assert
      expect(raw, '+79161234567');
    });

    test('regionCode returns second component digits', () {
      // Arrange
      const country = ACPhoneCountry(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );
      const phoneData = ACPhoneData(
        phoneNumberMasked: '+7 (916) 123-45-67',
        country: country,
      );

      // Act
      final region = phoneData.regionCode;

      // Assert
      expect(region, '916');
    });

    test('rawPhoneNumber strips all formatting characters', () {
      // Arrange
      const country = ACPhoneCountry(
        name: 'United States',
        isoCode: 'US',
        phoneCode: '+1',
        mask: '+# (###) ### ####',
        alternativePhoneCodes: [],
      );
      const phoneData = ACPhoneData(
        phoneNumberMasked: '+1 (212) 555 1234',
        country: country,
      );

      // Act
      final raw = phoneData.rawPhoneNumber;

      // Assert
      expect(raw, '+12125551234');
    });

    test('regionCode for US number', () {
      // Arrange
      const country = ACPhoneCountry(
        name: 'United States',
        isoCode: 'US',
        phoneCode: '+1',
        mask: '+# (###) ### ####',
        alternativePhoneCodes: [],
      );
      const phoneData = ACPhoneData(
        phoneNumberMasked: '+1 (212) 555 1234',
        country: country,
      );

      // Act
      final region = phoneData.regionCode;

      // Assert
      expect(region, '212');
    });
  });
}
