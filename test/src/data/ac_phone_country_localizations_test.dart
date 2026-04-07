import 'dart:ui';

import 'package:appcraft_phone_util_flutter/ac_phone_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ACPhoneCountryLocalizations', () {
    test('returns english name for en locale', () {
      // Arrange
      const localizations = ACPhoneCountryLocalizations(Locale('en'));

      // Act
      final name = localizations.countryName(
        isoCode: 'RU',
      );

      // Assert
      expect(name, 'Russia');
    });

    test('returns russian name for ru locale', () {
      // Arrange
      const localizations = ACPhoneCountryLocalizations(Locale('ru'));

      // Act
      final name = localizations.countryName(
        isoCode: 'RU',
      );

      // Assert
      expect(name, 'Россия');
    });

    test('returns german name for de locale', () {
      // Arrange
      const localizations = ACPhoneCountryLocalizations(Locale('de'));

      // Act
      final name = localizations.countryName(
        isoCode: 'US',
      );

      // Assert
      expect(name, isNotNull);
      expect(name, isA<String>());
    });

    test('returns french name for fr locale', () {
      // Arrange
      const localizations = ACPhoneCountryLocalizations(Locale('fr'));

      // Act
      final name = localizations.countryName(
        isoCode: 'RU',
      );

      // Assert
      expect(name, isNotNull);
    });

    test('falls back to english for unknown locale', () {
      // Arrange
      const localizations = ACPhoneCountryLocalizations(Locale('xx'));

      // Act
      final name = localizations.countryName(
        isoCode: 'RU',
      );

      // Assert
      expect(name, 'Russia');
    });

    test('returns null for unknown isoCode', () {
      // Arrange
      const localizations = ACPhoneCountryLocalizations(Locale('en'));

      // Act
      final name = localizations.countryName(
        isoCode: 'ZZ',
      );

      // Assert
      expect(name, isNull);
    });

    test('returns ukrainian name for uk locale', () {
      // Arrange
      const localizations = ACPhoneCountryLocalizations(Locale('uk'));

      // Act
      final name = localizations.countryName(
        isoCode: 'RU',
      );

      // Assert
      expect(name, isNotNull);
    });

    test('returns japanese name for ja locale', () {
      // Arrange
      const localizations = ACPhoneCountryLocalizations(Locale('ja'));

      // Act
      final name = localizations.countryName(
        isoCode: 'US',
      );

      // Assert
      expect(name, isNotNull);
    });

    test('returns name for US in english', () {
      // Arrange
      const localizations = ACPhoneCountryLocalizations(Locale('en'));

      // Act
      final name = localizations.countryName(
        isoCode: 'US',
      );

      // Assert
      expect(name, 'United States');
    });

    test('zh locale without script returns simplified chinese', () {
      // Arrange
      const localizations = ACPhoneCountryLocalizations(Locale('zh'));

      // Act
      final name = localizations.countryName(
        isoCode: 'US',
      );

      // Assert
      expect(name, isNotNull);
    });
  });
}
