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
      test('returns newValue unchanged (safe passthrough)', () {
        // Arrange
        final formatter = ACPhoneInputFormatter(mask: '');
        const newValue = TextEditingValue(
          text: '123abc',
          selection: TextSelection.collapsed(offset: 6),
        );
        const oldValue = TextEditingValue.empty;

        // Act
        final result = formatter.formatEditUpdate(oldValue, newValue);

        // Assert
        expect(result.text, '123abc');
        expect(result.selection.baseOffset, 6);
      });
    });

    group('cursor after mask separators (Bug 1)', () {
      test(
        'удаление ( из +7 (900) 999-88-77 — курсор не прыгает к началу скобки',
        () {
          // Arrange
          final formatter = ACPhoneInputFormatter(
            mask: '+# (###) ###-##-##',
          );
          const oldValue = TextEditingValue(
            text: '+7 (900) 999-88-77',
            selection: TextSelection.collapsed(offset: 4),
          );
          // Эмуляция: пользователь нажал backspace, находясь сразу после `(`.
          // Framework предлагает removeAt(3) → text без `(`.
          const newValue = TextEditingValue(
            text: '+7 900) 999-88-77',
            selection: TextSelection.collapsed(offset: 3),
          );

          // Act
          final result = formatter.formatEditUpdate(oldValue, newValue);

          // Assert: текст восстанавливается маской до полной формы
          expect(result.text, '+7 (900) 999-88-77');
          // Курсор не должен «прыгать» к позиции 2 (сразу после `7`).
          // После первой цифры стоят разделители ` (`, значит логичная
          // позиция для продолжения ввода — offset 4 (сразу после `(`),
          // т.е. сразу перед следующим digit-слотом.
          expect(
            result.selection.baseOffset,
            4,
            reason:
                'курсор должен приземлиться перед следующим digit-слотом (offset 4), '
                'а не сразу после первой цифры (offset 2)',
          );
        },
      );

      test(
        'после 1 цифры в пустом вводе курсор в конце, не перед открывающей скобкой',
        () {
          // Arrange
          final formatter = ACPhoneInputFormatter(
            mask: '+# (###) ###-##-##',
          );
          const oldValue = TextEditingValue.empty;
          const newValue = TextEditingValue(
            text: '7',
            selection: TextSelection.collapsed(offset: 1),
          );

          // Act
          final result = formatter.formatEditUpdate(oldValue, newValue);

          // Assert
          expect(result.text, '+7 (');
          expect(result.selection.baseOffset, 4);
        },
      );
    });
  });
}
