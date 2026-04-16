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
        'после 1 цифры в пустом вводе курсор в конце +7 (без trailing разделителей)',
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

          // Assert — после trim-фикса Bug 4 trailing разделители ' (' обрезаны
          expect(result.text, '+7');
          expect(result.selection.baseOffset, 2);
        },
      );
    });

    group('trailing separators trimmed (Bug 4 fix)', () {
      test(
        '1 цифра 7 → text без trailing ( и пробела',
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

          // Assert — trailing разделители ' (' обрезаны
          expect(result.text, '+7');
          expect(result.selection.baseOffset, 2);
        },
      );

      test(
        '4 цифры 7900 → text +7 (900 без trailing )',
        () {
          // Arrange
          final formatter = ACPhoneInputFormatter(
            mask: '+# (###) #-##-##',
          );
          // Эмулируем ручной ввод 4 цифр последовательно, финальное состояние:
          const oldValue = TextEditingValue(
            text: '+7 (90',
            selection: TextSelection.collapsed(offset: 6),
          );
          const newValue = TextEditingValue(
            text: '+7 (900',
            selection: TextSelection.collapsed(offset: 7),
          );

          // Act
          final result = formatter.formatEditUpdate(oldValue, newValue);

          // Assert — trailing ')' должен быть обрезан
          expect(result.text, '+7 (900');
          expect(result.selection.baseOffset, 7);
        },
      );

      test(
        'backspace после 4 цифр успешно удаляет последнюю цифру',
        () {
          // Arrange — пользователь видит +7 (900 (после фикса trim) и жмёт backspace
          final formatter = ACPhoneInputFormatter(
            mask: '+# (###) ###-##-##',
          );
          const oldValue = TextEditingValue(
            text: '+7 (900',
            selection: TextSelection.collapsed(offset: 7),
          );
          // Framework предлагает удалить последний символ (цифра 0) — offset 6
          const newValue = TextEditingValue(
            text: '+7 (90',
            selection: TextSelection.collapsed(offset: 6),
          );

          // Act
          final result = formatter.formatEditUpdate(oldValue, newValue);

          // Assert — цифра реально удалилась (digits сократились с 4 до 3)
          final digitCount = result.text.replaceAll(RegExp(r'\D'), '').length;
          expect(
            digitCount,
            3,
            reason: 'после backspace должна остаться 3 цифры, а не 4 (не залипать)',
          );
          // И текст короче, чем был
          expect(result.text.length, lessThan(oldValue.text.length));
        },
      );
    });

    group('no stuck deletion (Bug 4 regression)', () {
      test(
        'ввод 1 цифры и backspace возвращает пустое поле',
        () {
          // Arrange
          final formatter = ACPhoneInputFormatter(
            mask: '+# (###) ###-##-##',
          );
          // Шаг 1: ввод одной цифры
          const step1Old = TextEditingValue.empty;
          const step1New = TextEditingValue(
            text: '7',
            selection: TextSelection.collapsed(offset: 1),
          );
          final step1Result = formatter.formatEditUpdate(step1Old, step1New);
          // После фикса ожидаем '+7' (без trailing разделителей)

          // Act: backspace в конце
          final step2New = TextEditingValue(
            text: step1Result.text.substring(
              0,
              step1Result.selection.baseOffset - 1,
            ),
            selection: TextSelection.collapsed(
              offset: step1Result.selection.baseOffset - 1,
            ),
          );
          final step2Result = formatter.formatEditUpdate(step1Result, step2New);

          // Assert — поле должно полностью очиститься (digits.isEmpty → TextEditingValue.empty)
          expect(step2Result.text, isEmpty);
        },
      );
    });
  });
}
