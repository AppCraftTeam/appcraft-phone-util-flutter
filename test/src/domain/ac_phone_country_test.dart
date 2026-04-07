import 'package:appcraft_phone_util_flutter/ac_phone_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ACPhoneCountry', () {
    test('creates object with all required fields', () {
      // Arrange & Act
      const country = ACPhoneCountry(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: ['+8 (9'],
      );

      // Assert
      expect(country.name, 'Russia');
      expect(country.isoCode, 'RU');
      expect(country.phoneCode, '+7');
      expect(country.mask, '+# (###) ###-##-##');
      expect(country.alternativePhoneCodes, ['+8 (9']);
    });

    test('two objects with same fields are equal', () {
      // Arrange
      const countryA = ACPhoneCountry(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );
      const countryB = ACPhoneCountry(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );

      // Act & Assert
      expect(countryA, equals(countryB));
    });

    test('two objects with different fields are not equal', () {
      // Arrange
      const countryA = ACPhoneCountry(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );
      const countryB = ACPhoneCountry(
        name: 'United States',
        isoCode: 'US',
        phoneCode: '+1',
        mask: '+# (###) ### ####',
        alternativePhoneCodes: [],
      );

      // Act & Assert
      expect(countryA, isNot(equals(countryB)));
    });

    test('two objects with different names are not equal', () {
      // Arrange
      const countryA = ACPhoneCountry(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );
      const countryB = ACPhoneCountry(
        name: 'Different',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );

      // Act & Assert
      expect(countryA, isNot(equals(countryB)));
    });

    test('equal objects have same hashCode', () {
      // Arrange
      const countryA = ACPhoneCountry(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );
      const countryB = ACPhoneCountry(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );

      // Act & Assert
      expect(countryA.hashCode, equals(countryB.hashCode));
    });

    test('different objects have different hashCode', () {
      // Arrange
      const countryA = ACPhoneCountry(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );
      const countryB = ACPhoneCountry(
        name: 'United States',
        isoCode: 'US',
        phoneCode: '+1',
        mask: '+# (###) ### ####',
        alternativePhoneCodes: [],
      );

      // Act & Assert
      expect(countryA.hashCode, isNot(equals(countryB.hashCode)));
    });

    test('alternativePhoneCodes empty list comparison', () {
      // Arrange
      const countryA = ACPhoneCountry(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );
      const countryB = ACPhoneCountry(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );

      // Act & Assert
      expect(countryA, equals(countryB));
    });

    test('alternativePhoneCodes non-empty list comparison equal', () {
      // Arrange
      const countryA = ACPhoneCountry(
        name: 'Northern Mariana Islands',
        isoCode: 'MP',
        phoneCode: '+1',
        mask: '+# (###) ### ####',
        alternativePhoneCodes: ['+1 (670)'],
      );
      const countryB = ACPhoneCountry(
        name: 'Northern Mariana Islands',
        isoCode: 'MP',
        phoneCode: '+1',
        mask: '+# (###) ### ####',
        alternativePhoneCodes: ['+1 (670)'],
      );

      // Act & Assert
      expect(countryA, equals(countryB));
    });

    test('alternativePhoneCodes different lists are not equal', () {
      // Arrange
      const countryA = ACPhoneCountry(
        name: 'Test',
        isoCode: 'TE',
        phoneCode: '+1',
        mask: '+# (###) ### ####',
        alternativePhoneCodes: ['+1 (670)'],
      );
      const countryB = ACPhoneCountry(
        name: 'Test',
        isoCode: 'TE',
        phoneCode: '+1',
        mask: '+# (###) ### ####',
        alternativePhoneCodes: ['+1 (684)'],
      );

      // Act & Assert
      expect(countryA, isNot(equals(countryB)));
    });

    test('potentialPhoneCodes returns phoneCode digits when no alternatives', () {
      // Arrange
      const country = ACPhoneCountry(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );

      // Act
      final codes = country.potentialPhoneCodes;

      // Assert
      expect(codes, contains('7'));
      expect(codes.length, 1);
    });

    test('potentialPhoneCodes returns alternative codes digits when present', () {
      // Arrange
      const country = ACPhoneCountry(
        name: 'Northern Mariana Islands',
        isoCode: 'MP',
        phoneCode: '+1',
        mask: '+# (###) ### ####',
        alternativePhoneCodes: ['+1 (670)'],
      );

      // Act
      final codes = country.potentialPhoneCodes;

      // Assert
      expect(codes, contains('1670'));
    });

    test('telMask removes phone code prefix and parentheses', () {
      // Arrange
      const country = ACPhoneCountry(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );

      // Act
      final result = country.telMask;

      // Assert
      expect(result, '### ###-##-##');
    });

    test('copyWith returns new object with replaced fields', () {
      // Arrange
      const original = ACPhoneCountry(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );

      // Act
      final copy = original.copyWith(
        name: 'Updated Russia',
      );

      // Assert
      expect(copy.name, 'Updated Russia');
      expect(copy.isoCode, 'RU');
      expect(copy.phoneCode, '+7');
      expect(copy.mask, '+# (###) ###-##-##');
      expect(copy.alternativePhoneCodes, <String>[]);
    });

    test('copyWith without arguments returns equal object', () {
      // Arrange
      const original = ACPhoneCountry(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );

      // Act
      final copy = original.copyWith();

      // Assert
      expect(copy, equals(original));
    });
  });
}
