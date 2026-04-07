import 'dart:ui';

import 'package:appcraft_phone_util_flutter/ac_phone_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ACPhoneUtil', () {
    final util = ACPhoneUtil.instance;

    group('getCountries', () {
      test('returns non-empty list', () {
        // Act
        final countries = util.getCountries();

        // Assert
        expect(countries, isNotEmpty);
      });

      test('returns countries with valid fields', () {
        // Act
        final countries = util.getCountries();
        final first = countries.first;

        // Assert
        expect(first.name, isNotEmpty);
        expect(first.isoCode, isNotEmpty);
        expect(first.phoneCode, isNotEmpty);
        expect(first.mask, isNotEmpty);
      });

      test('returns localized names when locale is provided', () {
        // Arrange
        const locale = Locale('ru');

        // Act
        final countries = util.getCountries(
          locale: locale,
        );
        final russia = countries.firstWhere(
          (c) => c.isoCode == 'RU',
        );

        // Assert
        expect(russia.name, 'Россия');
      });

      test('returns english names for en locale', () {
        // Arrange
        const locale = Locale('en');

        // Act
        final countries = util.getCountries(
          locale: locale,
        );
        final russia = countries.firstWhere(
          (c) => c.isoCode == 'RU',
        );

        // Assert
        expect(russia.name, 'Russia');
      });

      test('filters countries by search string', () {
        // Arrange
        const search = 'Russia';

        // Act
        final countries = util.getCountries(
          search: search,
        );

        // Assert
        expect(countries, isNotEmpty);
        for (final country in countries) {
          expect(
            country.name.toLowerCase(),
            contains('russia'),
          );
        }
      });

      test('search is case insensitive', () {
        // Act
        final lower = util.getCountries(
          search: 'russia',
        );
        final upper = util.getCountries(
          search: 'RUSSIA',
        );

        // Assert
        expect(lower.length, equals(upper.length));
      });

      test('returns empty list for non-existent search', () {
        // Act
        final countries = util.getCountries(
          search: 'ZZZZZZNONEXISTENT',
        );

        // Assert
        expect(countries, isEmpty);
      });
    });

    group('findPhone', () {
      test('returns ACPhoneData for valid Russian number', () {
        // Act
        final result = util.findPhone(
          phoneNumber: '+79161234567',
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.country.isoCode, 'RU');
        expect(result.country.phoneCode, '+7');
      });

      test('returns formatted masked number for Russian phone', () {
        // Act
        final result = util.findPhone(
          phoneNumber: '+79161234567',
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.phoneNumberMasked, contains('916'));
      });

      test('returns ACPhoneData for valid US number', () {
        // Act
        final result = util.findPhone(
          phoneNumber: '+12125551234',
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.country.phoneCode, '+1');
      });

      test('returns null for empty string', () {
        // Act
        final result = util.findPhone(
          phoneNumber: '',
        );

        // Assert
        expect(result, isNull);
      });

      test('returns null for non-numeric string', () {
        // Act
        final result = util.findPhone(
          phoneNumber: 'abc',
        );

        // Assert
        expect(result, isNull);
      });

      test('handles number without plus prefix', () {
        // Act
        final result = util.findPhone(
          phoneNumber: '79161234567',
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.country.isoCode, 'RU');
      });
    });

    group('phoneIsValid', () {
      test('returns true for valid Russian number', () {
        // Act
        final isValid = util.phoneIsValid(
          phoneNumber: '+79161234567',
        );

        // Assert
        expect(isValid, isTrue);
      });

      test('returns true for valid US number', () {
        // Act
        final isValid = util.phoneIsValid(
          phoneNumber: '+12125551234',
        );

        // Assert
        expect(isValid, isTrue);
      });

      test('returns false for empty string', () {
        // Act
        final isValid = util.phoneIsValid(
          phoneNumber: '',
        );

        // Assert
        expect(isValid, isFalse);
      });

      test('returns false for too short number', () {
        // Act
        final isValid = util.phoneIsValid(
          phoneNumber: '+7916',
        );

        // Assert
        expect(isValid, isFalse);
      });

      test('returns false for non-numeric string', () {
        // Act
        final isValid = util.phoneIsValid(
          phoneNumber: 'not a phone',
        );

        // Assert
        expect(isValid, isFalse);
      });

      test('returns false for too long number', () {
        // Act
        final isValid = util.phoneIsValid(
          phoneNumber: '+791612345678901234',
        );

        // Assert
        expect(isValid, isFalse);
      });
    });

    group('singleton', () {
      test('instance is not null', () {
        // Assert
        expect(ACPhoneUtil.instance, isNotNull);
      });

      test('instance is same object', () {
        // Act & Assert
        expect(
          identical(ACPhoneUtil.instance, ACPhoneUtil.instance),
          isTrue,
        );
      });
    });
  });
}
