import 'package:appcraft_phone_util_flutter/ac_phone_util.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

TextEditingValue _formatFromEmpty(
  TextInputFormatter formatter,
  String text,
) =>
    formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      ),
    );

void main() {
  group('ACPhoneInputFormatter', () {
    group("given mask '### ###-##-##' when input digits", () {
      test('formats digits into national mask with cursor at the end', () {
        // Arrange
        final formatter = ACPhoneInputFormatter(mask: '### ###-##-##');

        // Act
        final result = _formatFromEmpty(formatter, '9009998877');

        // Assert
        expect(result.text, '900 999-88-77');
        expect(
          result.selection,
          TextSelection.collapsed(offset: result.text.length),
        );
      });
    });

    group("given mask '+# (###) ###-##-##' when input full number digits", () {
      test('formats 11 digits into full international mask', () {
        // Arrange
        final formatter =
            ACPhoneInputFormatter(mask: '+# (###) ###-##-##');

        // Act
        final result = _formatFromEmpty(formatter, '79009998877');

        // Assert
        expect(result.text, '+7 (900) 999-88-77');
      });
    });

    group('given mask when input empty', () {
      test('returns TextEditingValue.empty', () {
        // Arrange
        final formatter =
            ACPhoneInputFormatter(mask: '+# (###) ###-##-##');

        // Act
        final result = _formatFromEmpty(formatter, '');

        // Assert
        expect(result, TextEditingValue.empty);
      });
    });

    group('given mask when pasted with separators', () {
      test('strips non-digits and formats according to mask', () {
        // Arrange
        final formatter =
            ACPhoneInputFormatter(mask: '+# (###) ###-##-##');

        // Act
        final result = _formatFromEmpty(formatter, '+7-(900) 999-88-77');

        // Assert
        expect(result.text, '+7 (900) 999-88-77');
      });
    });

    group('given mask when input exceeds mask length', () {
      test('truncates digits to mask length', () {
        // Arrange
        final formatter = ACPhoneInputFormatter(mask: '###');

        // Act
        final result = _formatFromEmpty(formatter, '12345');

        // Assert
        expect(result.text, '123');
      });
    });

    group('given mask when cursor in middle and deletion', () {
      test('places cursor near edit point within text bounds', () {
        // Arrange
        final formatter = ACPhoneInputFormatter(mask: '### ###-##-##');
        const oldText = '900 999-88-77';
        final oldValue = TextEditingValue(
          text: oldText,
          selection: const TextSelection.collapsed(offset: 5),
        );
        // Emulate deletion of one digit around the cursor.
        const newText = '900 99-88-77';
        const newValue = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: 4),
        );

        // Act
        final result = formatter.formatEditUpdate(oldValue, newValue);

        // Assert
        final offset = result.selection.baseOffset;
        expect(offset, greaterThanOrEqualTo(0));
        expect(offset, lessThanOrEqualTo(result.text.length));
        // Digits before edit in oldValue up to cursor 5 = "900 9" -> 4 digits.
        // After deletion of one digit, cursor should correspond to 3 digits
        // worth of formatted output.
        final digitsBeforeCursor = result.text
            .substring(0, offset)
            .replaceAll(RegExp(r'\D'), '')
            .length;
        expect(digitsBeforeCursor, 3);
      });
    });

    group('given empty mask when any input', () {
      test('returns empty text with zero cursor offset', () {
        // Arrange
        final formatter = ACPhoneInputFormatter(mask: '');

        // Act
        final result = _formatFromEmpty(formatter, '123');

        // Assert
        expect(result.text, '');
        expect(result.selection, const TextSelection.collapsed(offset: 0));
      });
    });
  });
}
