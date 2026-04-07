import 'package:appcraft_phone_util_flutter/src/presentation/src/ac_phone_editing_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ACPhoneEditingController', () {
    group('constructor', () {
      test('creates with empty text by default', () {
        // Arrange & Act
        final controller = ACPhoneEditingController();

        // Assert
        expect(controller.text, isEmpty);

        // Cleanup
        controller.dispose();
      });

      test('creates with initialPhoneNumber in text', () {
        // Arrange & Act
        final controller = ACPhoneEditingController(
          initialPhoneNumber: '+79161234567',
        );

        // Assert
        expect(controller.text, '+79161234567');

        // Cleanup
        controller.dispose();
      });
    });

    group('phoneData', () {
      test('returns ACPhoneData for valid Russian number', () {
        // Arrange
        final controller = ACPhoneEditingController(
          initialPhoneNumber: '+79161234567',
        );

        // Act
        final phoneData = controller.phoneData;

        // Assert
        expect(phoneData, isNotNull);
        expect(phoneData!.country.isoCode, 'RU');
        expect(phoneData.country.phoneCode, '+7');

        // Cleanup
        controller.dispose();
      });

      test('returns null for empty input', () {
        // Arrange
        final controller = ACPhoneEditingController();

        // Act
        final phoneData = controller.phoneData;

        // Assert
        expect(phoneData, isNull);

        // Cleanup
        controller.dispose();
      });

      test('returns null for non-numeric input', () {
        // Arrange
        final controller = ACPhoneEditingController(
          initialPhoneNumber: 'abc',
        );

        // Act
        final phoneData = controller.phoneData;

        // Assert
        expect(phoneData, isNull);

        // Cleanup
        controller.dispose();
      });

      test('returns ACPhoneData for valid US number', () {
        // Arrange
        final controller = ACPhoneEditingController(
          initialPhoneNumber: '+12125551234',
        );

        // Act
        final phoneData = controller.phoneData;

        // Assert
        expect(phoneData, isNotNull);
        expect(phoneData!.country.phoneCode, '+1');

        // Cleanup
        controller.dispose();
      });
    });

    group('isValid', () {
      test('returns true for valid Russian number', () {
        // Arrange
        final controller = ACPhoneEditingController(
          initialPhoneNumber: '+79161234567',
        );

        // Act & Assert
        expect(controller.isValid, isTrue);

        // Cleanup
        controller.dispose();
      });

      test('returns false for too short number', () {
        // Arrange
        final controller = ACPhoneEditingController(
          initialPhoneNumber: '+7916',
        );

        // Act & Assert
        expect(controller.isValid, isFalse);

        // Cleanup
        controller.dispose();
      });

      test('returns false for empty input', () {
        // Arrange
        final controller = ACPhoneEditingController();

        // Act & Assert
        expect(controller.isValid, isFalse);

        // Cleanup
        controller.dispose();
      });
    });

    group('country', () {
      test('returns ACPhoneCountry for valid number', () {
        // Arrange
        final controller = ACPhoneEditingController(
          initialPhoneNumber: '+79161234567',
        );

        // Act
        final country = controller.country;

        // Assert
        expect(country, isNotNull);
        expect(country!.isoCode, 'RU');
        expect(country.phoneCode, '+7');

        // Cleanup
        controller.dispose();
      });

      test('returns null for empty input', () {
        // Arrange
        final controller = ACPhoneEditingController();

        // Act & Assert
        expect(controller.country, isNull);

        // Cleanup
        controller.dispose();
      });
    });

    group('rawPhoneNumber', () {
      test('returns digits and plus only for valid number', () {
        // Arrange
        final controller = ACPhoneEditingController(
          initialPhoneNumber: '+79161234567',
        );

        // Act
        final raw = controller.rawPhoneNumber;

        // Assert
        expect(raw, matches(RegExp(r'^[0-9+]+$')));

        // Cleanup
        controller.dispose();
      });

      test('returns empty string for empty input', () {
        // Arrange
        final controller = ACPhoneEditingController();

        // Act & Assert
        expect(controller.rawPhoneNumber, isEmpty);

        // Cleanup
        controller.dispose();
      });
    });

    group('setPhoneNumber', () {
      test('updates text with new phone number', () {
        // Arrange
        final controller = ACPhoneEditingController();

        // Act
        controller.setPhoneNumber('+79161234567');

        // Assert
        expect(controller.text, '+79161234567');

        // Cleanup
        controller.dispose();
      });

      test('updates phoneData after setting new number', () {
        // Arrange
        final controller = ACPhoneEditingController();

        // Act
        controller.setPhoneNumber('+79161234567');

        // Assert
        expect(controller.phoneData, isNotNull);
        expect(controller.phoneData!.country.isoCode, 'RU');

        // Cleanup
        controller.dispose();
      });

      test('clears phoneData when set to empty string', () {
        // Arrange
        final controller = ACPhoneEditingController(
          initialPhoneNumber: '+79161234567',
        );
        expect(controller.phoneData, isNotNull);

        // Act
        controller.setPhoneNumber('');

        // Assert
        expect(controller.phoneData, isNull);
        expect(controller.isValid, isFalse);

        // Cleanup
        controller.dispose();
      });
    });

    group('text changes', () {
      test('updates phoneData when text is changed directly', () {
        // Arrange
        final controller = ACPhoneEditingController();

        // Act
        controller.text = '+79161234567';

        // Assert
        expect(controller.phoneData, isNotNull);
        expect(controller.phoneData!.country.isoCode, 'RU');

        // Cleanup
        controller.dispose();
      });

      test('updates isValid when text changes from invalid to valid', () {
        // Arrange
        final controller = ACPhoneEditingController(
          initialPhoneNumber: '+7916',
        );
        expect(controller.isValid, isFalse);

        // Act
        controller.text = '+79161234567';

        // Assert
        expect(controller.isValid, isTrue);

        // Cleanup
        controller.dispose();
      });
    });
  });
}
