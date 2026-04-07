import 'package:appcraft_phone_util_flutter/ac_phone_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ACPhoneMasked', () {
    test('setMask applies mask to raw phone digits', () {
      // Arrange
      const mask = '+# (###) ###-##-##';
      const rawPhone = '79161234567';

      // Act
      final masked = ACPhoneMasked.setMask(
        mask,
        rawPhone: rawPhone,
      );

      // Assert
      expect(masked.maskedPhone, '+7 (916) 123-45-67');
    });

    test('setMask strips non-digit characters from rawPhone', () {
      // Arrange
      const mask = '+# (###) ###-##-##';
      const rawPhone = '+7 (916) 123-45-67';

      // Act
      final masked = ACPhoneMasked.setMask(
        mask,
        rawPhone: rawPhone,
      );

      // Assert
      expect(masked.maskedPhone, '+7 (916) 123-45-67');
    });

    test('setMask with US format', () {
      // Arrange
      const mask = '+# (###) ### ####';
      const rawPhone = '12125551234';

      // Act
      final masked = ACPhoneMasked.setMask(
        mask,
        rawPhone: rawPhone,
      );

      // Assert
      expect(masked.maskedPhone, '+1 (212) 555 1234');
    });

    test('setMask with fewer digits than mask includes trailing literal chars', () {
      // Arrange
      const mask = '+# (###) ###-##-##';
      const rawPhone = '7916';

      // Act
      final masked = ACPhoneMasked.setMask(
        mask,
        rawPhone: rawPhone,
      );

      // Assert
      // After placing 4 digits, the algorithm writes literal ') ' before hitting next '#' and breaking
      expect(masked.maskedPhone, '+7 (916) ');
    });

    test('setMask with empty rawPhone returns prefix before first placeholder', () {
      // Arrange
      const mask = '+# (###) ###-##-##';
      const rawPhone = '';

      // Act
      final masked = ACPhoneMasked.setMask(
        mask,
        rawPhone: rawPhone,
      );

      // Assert
      // The algorithm writes '+' (literal) then hits '#' with no digits and breaks
      expect(masked.maskedPhone, '+');
    });

    test('maskedPhone field is accessible', () {
      // Arrange & Act
      final masked = ACPhoneMasked.setMask(
        '+# (###) ###-##-##',
        rawPhone: '79161234567',
      );

      // Assert
      expect(masked.maskedPhone, isA<String>());
      expect(masked.maskedPhone.isNotEmpty, isTrue);
    });
  });
}
