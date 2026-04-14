import 'package:appcraft_phone_util_flutter/ac_phone_util.dart';
import 'package:appcraft_phone_util_flutter/src/data/ac_phone_countries.dart';
import 'package:appcraft_phone_util_flutter/src/presentation/src/ac_national_phone_editing_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ru = ACPhoneCountries.instance.all.firstWhere(
    (c) => c.isoCode == 'RU',
  );
  final us = ACPhoneCountries.instance.all.firstWhere(
    (c) => c.isoCode == 'US',
  );

  group('ACNationalPhoneEditingController', () {
    group('constructor', () {
      test('init empty returns empty text and invalid state', () {
        // Arrange & Act
        final controller = ACNationalPhoneEditingController(country: ru);

        // Assert
        expect(controller.text, '');
        expect(controller.rawPhoneNumber, '');
        expect(controller.isValid, isFalse);

        // Cleanup
        controller.dispose();
      });

      test('init with national digits formats text and exposes raw phone', () {
        // Arrange & Act
        final controller = ACNationalPhoneEditingController(
          country: ru,
          initialPhoneNumber: '9009998877',
        );

        // Assert
        expect(controller.text, '(900) 999-88-77');
        expect(controller.rawPhoneNumber, '+79009998877');
        expect(controller.isValid, isTrue);

        // Cleanup
        controller.dispose();
      });

      test('init with full +7 number strips country prefix', () {
        // Arrange & Act
        final controller = ACNationalPhoneEditingController(
          country: ru,
          initialPhoneNumber: '+79009998877',
        );

        // Assert
        expect(controller.text, '(900) 999-88-77');
        expect(controller.rawPhoneNumber, '+79009998877');

        // Cleanup
        controller.dispose();
      });
    });

    group('setPhoneNumber', () {
      test('programmatic set formats text and notifies listeners', () {
        // Arrange
        final controller = ACNationalPhoneEditingController(country: ru);
        var notified = false;
        controller.addListener(() {
          notified = true;
        });

        // Act
        controller.setPhoneNumber('9009998877');

        // Assert
        expect(notified, isTrue);
        expect(controller.text, '(900) 999-88-77');

        // Cleanup
        controller.dispose();
      });

      test('ignores non-digit characters in input', () {
        // Arrange
        final controller = ACNationalPhoneEditingController(country: ru);

        // Act
        controller.setPhoneNumber('abc123def45');

        // Assert
        final digits = controller.text.replaceAll(RegExp(r'\D'), '');
        expect(digits, '12345');

        // Cleanup
        controller.dispose();
      });
    });

    group('country setter', () {
      test('changing country reformats text under new mask', () {
        // Arrange
        final controller = ACNationalPhoneEditingController(
          country: ru,
          initialPhoneNumber: '9009998877',
        );
        var notified = false;
        controller.addListener(() {
          notified = true;
        });

        // Act
        controller.country = us;

        // Assert
        expect(notified, isTrue);
        expect(controller.country.isoCode, 'US');
        expect(controller.rawPhoneNumber.startsWith('+1'), isTrue);
        final digits = controller.text.replaceAll(RegExp(r'\D'), '');
        expect(digits.length, lessThanOrEqualTo(10));
        expect(controller.text.contains('('), isTrue);

        // Cleanup
        controller.dispose();
      });

      test('assigning same country is a no-op and does not notify', () {
        // Arrange
        final controller = ACNationalPhoneEditingController(
          country: ru,
          initialPhoneNumber: '9009998877',
        );
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
    });

    group('isValid', () {
      test('returns false for partial national input', () {
        // Arrange
        final controller = ACNationalPhoneEditingController(
          country: ru,
          initialPhoneNumber: '900',
        );

        // Act & Assert
        expect(controller.isValid, isFalse);

        // Cleanup
        controller.dispose();
      });

      test('returns true for complete national input', () {
        // Arrange
        final controller = ACNationalPhoneEditingController(
          country: ru,
          initialPhoneNumber: '9009998877',
        );

        // Act & Assert
        expect(controller.isValid, isTrue);

        // Cleanup
        controller.dispose();
      });
    });

    group('paste with different country code', () {
      test('non-matching + prefix is treated as national digits and truncated',
          () {
        // Arrange
        final controller = ACNationalPhoneEditingController(country: ru);

        // Act
        controller.setPhoneNumber('+380501112233');

        // Assert
        final digits = controller.text.replaceAll(RegExp(r'\D'), '');
        expect(digits.length, 10);
        expect(controller.rawPhoneNumber.startsWith('+7'), isTrue);

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
