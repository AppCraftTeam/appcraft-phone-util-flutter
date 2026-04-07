import 'package:flutter_test/flutter_test.dart';
import 'package:appcraft_phone_util_flutter/src/data/ac_phone_country_data.dart';

void main() {
  group('ACPhoneCountryData', () {
    test('creates object with all required fields', () {
      // Arrange & Act
      const data = ACPhoneCountryData(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );

      // Assert
      expect(data.name, 'Russia');
      expect(data.isoCode, 'RU');
      expect(data.phoneCode, '+7');
      expect(data.mask, '+# (###) ###-##-##');
      expect(data.alternativePhoneCodes, <String>[]);
    });

    test('two objects with same fields are equal', () {
      // Arrange
      const dataA = ACPhoneCountryData(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );
      const dataB = ACPhoneCountryData(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );

      // Act & Assert
      expect(dataA, equals(dataB));
    });

    test('two objects with different fields are not equal', () {
      // Arrange
      const dataA = ACPhoneCountryData(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );
      const dataB = ACPhoneCountryData(
        name: 'United States',
        isoCode: 'US',
        phoneCode: '+1',
        mask: '+# (###) ### ####',
        alternativePhoneCodes: [],
      );

      // Act & Assert
      expect(dataA, isNot(equals(dataB)));
    });

    test('equal objects have same hashCode', () {
      // Arrange
      const dataA = ACPhoneCountryData(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );
      const dataB = ACPhoneCountryData(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );

      // Act & Assert
      expect(dataA.hashCode, equals(dataB.hashCode));
    });

    test('different objects have different hashCode', () {
      // Arrange
      const dataA = ACPhoneCountryData(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );
      const dataB = ACPhoneCountryData(
        name: 'United States',
        isoCode: 'US',
        phoneCode: '+1',
        mask: '+# (###) ### ####',
        alternativePhoneCodes: [],
      );

      // Act & Assert
      expect(dataA.hashCode, isNot(equals(dataB.hashCode)));
    });

    test('alternativePhoneCodes non-empty list comparison equal', () {
      // Arrange
      const dataA = ACPhoneCountryData(
        name: 'Test',
        isoCode: 'TE',
        phoneCode: '+1',
        mask: '+# (###) ### ####',
        alternativePhoneCodes: ['+1 (670)'],
      );
      const dataB = ACPhoneCountryData(
        name: 'Test',
        isoCode: 'TE',
        phoneCode: '+1',
        mask: '+# (###) ### ####',
        alternativePhoneCodes: ['+1 (670)'],
      );

      // Act & Assert
      expect(dataA, equals(dataB));
    });

    test('alternativePhoneCodes different lists are not equal', () {
      // Arrange
      const dataA = ACPhoneCountryData(
        name: 'Test',
        isoCode: 'TE',
        phoneCode: '+1',
        mask: '+# (###) ### ####',
        alternativePhoneCodes: ['+1 (670)'],
      );
      const dataB = ACPhoneCountryData(
        name: 'Test',
        isoCode: 'TE',
        phoneCode: '+1',
        mask: '+# (###) ### ####',
        alternativePhoneCodes: ['+1 (684)'],
      );

      // Act & Assert
      expect(dataA, isNot(equals(dataB)));
    });
  });
}
