import 'package:appcraft_phone_util_flutter/ac_phone_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ACPhoneCountries', () {
    test('instance is not null', () {
      // Act & Assert
      expect(ACPhoneCountries.instance, isNotNull);
    });

    test('instance is singleton', () {
      // Act & Assert
      expect(
        identical(
          ACPhoneCountries.instance,
          ACPhoneCountries.instance,
        ),
        isTrue,
      );
    });

    test('all countries list is not empty', () {
      // Act
      final countries = ACPhoneCountries.instance.all;

      // Assert
      expect(countries, isNotEmpty);
    });

    test('all countries have valid fields', () {
      // Act
      final countries = ACPhoneCountries.instance.all;

      // Assert
      for (final country in countries) {
        expect(country.name, isNotEmpty);
        expect(country.isoCode, isNotEmpty);
        expect(country.phoneCode, isNotEmpty);
        expect(country.mask, isNotEmpty);
      }
    });

    test('hashedCountries is not empty', () {
      // Act
      final hashed = ACPhoneCountries.instance.hashedCountries;

      // Assert
      expect(hashed, isNotEmpty);
    });

    test('hashedCountries lookup by phone code returns country', () {
      // Act — '1' is the US phone code (no alternative codes, so bare digit)
      final country = ACPhoneCountries.instance.hashedCountries['1'];

      // Assert
      expect(country, isNotNull);
      expect(country, isA<ACPhoneCountry>());
      expect(country!.phoneCode, '+1');
    });

    test('hashedCountries lookup for alternative code returns country', () {
      // Act — 1670 is Northern Mariana Islands alternative code
      final country = ACPhoneCountries.instance.hashedCountries['1670'];

      // Assert
      expect(country, isNotNull);
      expect(country!.isoCode, 'MP');
    });

    test('hashedCountries lookup for non-existent code returns null', () {
      // Act
      final country = ACPhoneCountries.instance.hashedCountries['9999'];

      // Assert
      expect(country, isNull);
    });

    test('all countries list contains Russia', () {
      // Act
      final russia = ACPhoneCountries.instance.all.where(
        (c) => c.isoCode == 'RU',
      );

      // Assert
      expect(russia, isNotEmpty);
      expect(russia.first.phoneCode, '+7');
    });

    test('all countries list contains United States', () {
      // Act
      final us = ACPhoneCountries.instance.all.where(
        (c) => c.isoCode == 'US',
      );

      // Assert
      expect(us, isNotEmpty);
      expect(us.first.phoneCode, '+1');
    });
  });
}
