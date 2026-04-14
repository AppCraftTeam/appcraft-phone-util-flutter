import 'package:appcraft_phone_util_flutter/ac_phone_util.dart';
import 'package:appcraft_phone_util_flutter/src/data/ac_phone_countries.dart';
import 'package:flutter_test/flutter_test.dart';

int _countHashes(String s) => s.split('').where((c) => c == '#').length;

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

  group('nationalMask', () {
    test('returns mask without country-code prefix, separators preserved', () {
      // Arrange
      const country = ACPhoneCountry(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );

      // Act
      final result = country.nationalMask;

      // Assert
      expect(result, '(###) ###-##-##');
    });

    test('does not start with plus sign', () {
      // Arrange
      const country = ACPhoneCountry(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );

      // Act
      final result = country.nationalMask;

      // Assert
      expect(result.startsWith('+'), isFalse);
    });

    test('for all countries in ACPhoneCountries.all does not contain plus', () {
      // Arrange
      final countries = ACPhoneCountries.instance.all;

      // Act & Assert
      for (final country in countries) {
        expect(
          country.nationalMask.contains('+'),
          isFalse,
          reason: 'nationalMask contains "+" for ${country.isoCode}',
        );
      }
    });
  });

  group('rawMask', () {
    test('removes parentheses and hyphens, only spaces as separators', () {
      // Arrange
      const country = ACPhoneCountry(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );

      // Act
      final result = country.rawMask;

      // Assert
      expect(result, '+# ### ### ## ##');
    });

    test('for all countries preserves # count and has no (, ), -', () {
      // Arrange
      final countries = ACPhoneCountries.instance.all;

      // Act & Assert
      for (final country in countries) {
        expect(
          _countHashes(country.mask),
          _countHashes(country.rawMask),
          reason: 'hash count mismatch for ${country.isoCode}',
        );
        expect(
          country.rawMask.contains('('),
          isFalse,
          reason: 'rawMask contains "(" for ${country.isoCode}',
        );
        expect(
          country.rawMask.contains(')'),
          isFalse,
          reason: 'rawMask contains ")" for ${country.isoCode}',
        );
        expect(
          country.rawMask.contains('-'),
          isFalse,
          reason: 'rawMask contains "-" for ${country.isoCode}',
        );
      }
    });
  });

  group('rawNationalMask', () {
    test('removes parentheses, hyphens and country-code prefix', () {
      // Arrange
      const country = ACPhoneCountry(
        name: 'Russia',
        isoCode: 'RU',
        phoneCode: '+7',
        mask: '+# (###) ###-##-##',
        alternativePhoneCodes: [],
      );

      // Act
      final result = country.rawNationalMask;

      // Assert
      expect(result, '### ### ## ##');
    });

    test('invariants hold for all countries in ACPhoneCountries.all', () {
      // Arrange
      final countries = ACPhoneCountries.instance.all;

      // Act & Assert
      for (final country in countries) {
        final maskHashes = _countHashes(country.mask);
        final nationalHashes = _countHashes(country.nationalMask);
        final rawNationalHashes = _countHashes(country.rawNationalMask);
        final phoneCodeDigits =
            country.phoneCode.replaceAll(RegExp('[^0-9]'), '').length;

        expect(
          nationalHashes,
          rawNationalHashes,
          reason:
              'nationalMask/rawNationalMask hash count mismatch for ${country.isoCode}',
        );
        if (country.mask.startsWith('+')) {
          expect(
            maskHashes - nationalHashes,
            phoneCodeDigits,
            reason:
                'mask - nationalMask hashes != phoneCode digits for ${country.isoCode}',
          );
        } else {
          expect(
            maskHashes - nationalHashes,
            0,
            reason:
                'mask without "+" prefix: nationalMask must equal mask for ${country.isoCode}',
          );
        }
        expect(
          country.rawNationalMask.contains('('),
          isFalse,
          reason: 'rawNationalMask contains "(" for ${country.isoCode}',
        );
        expect(
          country.rawNationalMask.contains(')'),
          isFalse,
          reason: 'rawNationalMask contains ")" for ${country.isoCode}',
        );
        expect(
          country.rawNationalMask.contains('-'),
          isFalse,
          reason: 'rawNationalMask contains "-" for ${country.isoCode}',
        );
        expect(
          country.rawNationalMask.startsWith('+'),
          isFalse,
          reason: 'rawNationalMask starts with "+" for ${country.isoCode}',
        );
      }
    });
  });
}
