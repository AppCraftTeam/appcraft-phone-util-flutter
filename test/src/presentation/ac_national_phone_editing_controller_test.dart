import 'package:appcraft_phone_util_flutter/ac_phone_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ru = ACPhoneCountries.instance.all.firstWhere(
    (c) => c.isoCode == 'RU',
  );
  final us = ACPhoneCountries.instance.all.firstWhere(
    (c) => c.isoCode == 'US',
  );

  group('ACNationalPhoneEditingController', () {
    group('setPhoneNumber', () {
      test('recognizes full RU number and formats national mask', () {
        // Arrange
        final controller = ACNationalPhoneEditingController(country: null);

        // Act
        controller.setPhoneNumber('+79009998877');

        // Assert
        expect(controller.country?.isoCode, 'RU');
        expect(controller.text, '(900) 999-88-77');
        expect(controller.rawPhoneNumber, '+79009998877');
        expect(controller.isValid, isTrue);

        // Cleanup
        controller.dispose();
      });

      test('recognizes full US number and formats under US national mask', () {
        // Arrange
        final controller = ACNationalPhoneEditingController(country: null);
        final expectedText = ACPhoneMasked.setMask(
          us.nationalMask,
          rawPhone: '4155551234',
        ).maskedPhone;

        // Act
        controller.setPhoneNumber('+14155551234');

        // Assert
        expect(controller.country?.isoCode, 'US');
        expect(controller.text, expectedText);
        expect(controller.rawPhoneNumber, '+14155551234');

        // Cleanup
        controller.dispose();
      });

      test('unrecognized input stores only digits and clears country', () {
        // Arrange
        final controller = ACNationalPhoneEditingController(country: ru);

        // Act
        controller.setPhoneNumber('abc123');

        // Assert
        expect(controller.country, isNull);
        expect(controller.text, '123');
        expect(controller.rawPhoneNumber, '');
        expect(controller.isValid, isFalse);

        // Cleanup
        controller.dispose();
      });

      test('empty input clears text and country', () {
        // Arrange
        final controller = ACNationalPhoneEditingController(country: ru);

        // Act
        controller.setPhoneNumber('');

        // Assert
        expect(controller.country, isNull);
        expect(controller.text, '');
        expect(controller.rawPhoneNumber, '');

        // Cleanup
        controller.dispose();
      });
    });

    group('constructor with initialPhoneNumber', () {
      test('initialPhoneNumber full RU number sets country and formats', () {
        // Arrange & Act
        final controller = ACNationalPhoneEditingController(
          initialPhoneNumber: '+79009998877',
        );

        // Assert
        expect(controller.country?.isoCode, 'RU');
        expect(controller.text, '(900) 999-88-77');
        expect(controller.rawPhoneNumber, '+79009998877');

        // Cleanup
        controller.dispose();
      });

      test('null country and null initialPhoneNumber yields empty state', () {
        // Arrange & Act
        final controller = ACNationalPhoneEditingController(
          country: null,
          initialPhoneNumber: null,
        );

        // Assert
        expect(controller.country, isNull);
        expect(controller.text, '');
        expect(controller.rawPhoneNumber, '');
        expect(controller.isValid, isFalse);

        // Cleanup
        controller.dispose();
      });

      test('only country provided yields empty text and invalid state', () {
        // Arrange & Act
        final controller = ACNationalPhoneEditingController(country: ru);

        // Assert
        expect(controller.country?.isoCode, 'RU');
        expect(controller.text, '');
        expect(controller.rawPhoneNumber, '');
        expect(controller.isValid, isFalse);

        // Cleanup
        controller.dispose();
      });
    });

    group('country setter', () {
      test('changing to other country reformats under new national mask', () {
        // Arrange
        final controller = ACNationalPhoneEditingController(country: null)
          ..setPhoneNumber('+79009998877');

        // Act
        controller.country = us;

        // Assert
        expect(controller.country?.isoCode, 'US');
        expect(controller.rawPhoneNumber.startsWith('+1'), isTrue);

        // Cleanup
        controller.dispose();
      });

      test('assigning same country is a no-op and does not notify', () {
        // Arrange
        final controller = ACNationalPhoneEditingController(country: null)
          ..setPhoneNumber('+79009998877');
        final textBefore = controller.text;
        var notified = false;
        controller.addListener(() {
          notified = true;
        });

        // Act
        controller.country = controller.country;

        // Assert
        expect(notified, isFalse);
        expect(controller.text, textBefore);

        // Cleanup
        controller.dispose();
      });

      test('setting country to null clears text and raw phone', () {
        // Arrange
        final controller = ACNationalPhoneEditingController(country: null)
          ..setPhoneNumber('+79009998877');

        // Act
        controller.country = null;

        // Assert
        expect(controller.country, isNull);
        expect(controller.text, '');
        expect(controller.rawPhoneNumber, '');

        // Cleanup
        controller.dispose();
      });

      test('setting country from null reformats stored digits', () {
        // Arrange
        final controller = ACNationalPhoneEditingController(country: null)
          ..setPhoneNumber('abc123');
        expect(controller.text, '123');
        expect(controller.country, isNull);

        // Act
        controller.country = ru;

        // Assert
        expect(controller.country?.isoCode, 'RU');
        final expectedText = ACPhoneMasked.setMask(
          ru.nationalMask,
          rawPhone: '123',
        ).maskedPhone;
        expect(controller.text, expectedText);

        // Cleanup
        controller.dispose();
      });
    });

    group('isValid transitions', () {
      test('partial number is invalid', () {
        // Arrange
        final controller = ACNationalPhoneEditingController(country: null);

        // Act
        controller.setPhoneNumber('+7900');

        // Assert
        expect(controller.isValid, isFalse);

        // Cleanup
        controller.dispose();
      });

      test('complete number is valid', () {
        // Arrange
        final controller = ACNationalPhoneEditingController(country: null);

        // Act
        controller.setPhoneNumber('+79009998877');

        // Assert
        expect(controller.isValid, isTrue);

        // Cleanup
        controller.dispose();
      });
    });

    group('dispose', () {
      test('dispose does not throw', () {
        // Arrange
        final controller = ACNationalPhoneEditingController(country: ru);

        // Act & Assert
        expect(controller.dispose, returnsNormally);
      });
    });
  });
}
