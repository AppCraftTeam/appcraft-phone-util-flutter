import 'package:appcraft_phone_util_flutter/src/presentation/src/ac_phone_editing_controller.dart';
import 'package:appcraft_phone_util_flutter/src/presentation/src/ac_phone_input_formatter.dart';
import 'package:flutter/material.dart';
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

    group('trunk-prefix replacement', () {
      test('89008007060 без formateера → text 79008007060, country=RU', () {
        // Arrange
        final controller = ACPhoneEditingController();

        // Act
        controller.setPhoneNumber('89008007060');

        // Assert
        expect(controller.text, '79008007060');
        expect(controller.country?.isoCode, 'RU');
        expect(controller.rawPhoneNumber, '+79008007060');

        // Cleanup
        controller.dispose();
      });

      testWidgets(
        '89008007060 с ACPhoneInputFormatter российской маски → +7 (900) 800-70-60, isValid',
        (tester) async {
          // Arrange
          final controller = ACPhoneEditingController();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: TextField(
                  controller: controller,
                  inputFormatters: [
                    ACPhoneInputFormatter(mask: '+# (###) ###-##-##'),
                  ],
                ),
              ),
            ),
          );

          // Act
          await tester.enterText(find.byType(TextField), '89008007060');
          await tester.pumpAndSettle();

          // Assert
          expect(controller.text, '+7 (900) 800-70-60');
          expect(controller.country?.isoCode, 'RU');
          expect(controller.isValid, isTrue);

          // Cleanup
          controller.dispose();
        },
      );

      test('87009998877 → 77009998877, country=KZ', () {
        // Arrange
        final controller = ACPhoneEditingController();

        // Act
        controller.setPhoneNumber('87009998877');

        // Assert
        expect(controller.text, '77009998877');
        expect(controller.country?.isoCode, 'KZ');

        // Cleanup
        controller.dispose();
      });
    });

    group('no-op when prefix matches', () {
      test('+79009998877 не переписывается, text остаётся +79009998877', () {
        // Arrange
        final controller = ACPhoneEditingController();

        // Act
        controller.setPhoneNumber('+79009998877');

        // Assert
        expect(controller.text, '+79009998877');
        expect(controller.country?.isoCode, 'RU');

        // Cleanup
        controller.dispose();
      });

      test(
        'счётчик notifyListeners после setPhoneNumber(+79...) не содержит лишних rewrite-уведомлений',
        () {
          // Arrange
          final controller = ACPhoneEditingController();
          var notifyCount = 0;
          void listener() {
            notifyCount++;
          }

          controller.addListener(listener);

          // Act
          controller.setPhoneNumber('+79009998877');

          // Assert
          expect(
            notifyCount,
            1,
            reason:
                'Прямая установка text через setPhoneNumber должна вызвать ровно одно уведомление — без доп. rewrite-подмены',
          );

          // Cleanup
          controller.removeListener(listener);
          controller.dispose();
        },
      );

      test(
        'добавление цифры в конец валидного +79009998877 не вызывает дополнительный rewrite',
        () {
          // Arrange
          final controller = ACPhoneEditingController(
            initialPhoneNumber: '+79009998877',
          );
          var notifyCount = 0;
          controller.addListener(() => notifyCount++);

          // Act
          controller.text = '+790099988771';

          // Assert
          expect(
            notifyCount,
            1,
            reason:
                'Добавление корректной цифры не должно триггерить повторный rewrite — только исходное уведомление от text=',
          );

          // Cleanup
          controller.dispose();
        },
      );

      test(
        'удаление цифры в середине +7 (900) 800-70-60 не триггерит дополнительный rewrite',
        () {
          // Arrange
          final controller = ACPhoneEditingController();
          controller.text = '+7 (900) 800-70-60';
          var notifyCount = 0;
          controller.addListener(() => notifyCount++);

          // Act
          controller.text = '+7 (900) 80-70-60';

          // Assert
          expect(
            notifyCount,
            1,
            reason:
                'При удалении цифры из корректно отформатированного номера rewrite не должен срабатывать (firstNDigit=7 уже совпадает с codeDigits)',
          );
          expect(
            controller.text,
            '+7 (900) 80-70-60',
            reason: 'text не должен быть подменён',
          );

          // Cleanup
          controller.dispose();
        },
      );
    });

    group('cursor preservation', () {
      test(
        'курсор в середине +8 (900) 800-70-60 сохраняет digit-count после rewrite',
        () {
          // Arrange
          final controller = ACPhoneEditingController();

          // Act
          // Устанавливаем текст с курсором в середине: offset=5 → после символов '+', '8', ' ', '(', '9'.
          // До курсора 2 цифры: '8', '9'. Listener синхронно делает rewrite '+8...' → '+7 (900) 800-70-60'.
          controller.value = const TextEditingValue(
            text: '+8 (900) 800-70-60',
            selection: TextSelection.collapsed(offset: 5),
          );

          // Assert
          expect(controller.text, '+7 (900) 800-70-60');
          expect(
            controller.selection.baseOffset,
            5,
            reason:
                'До rewrite перед курсором было 2 цифры (8, 9). После rewrite '
                'перед курсором тоже должно быть 2 цифры (7, 9). Позиция 5: '
                '+[7]_[(][9] → offset 5 сразу после 9.',
          );

          // Cleanup
          controller.dispose();
        },
      );

      test(
        'rewrite в начале текста — курсор остаётся после первой цифры',
        () {
          // Arrange
          final controller = ACPhoneEditingController();

          // Act
          // До курсора (offset=1) 1 цифра ('8'). После rewrite '89008007060' → '79008007060'
          // курсор должен встать также после 1 цифры → offset 1.
          controller.value = const TextEditingValue(
            text: '89008007060',
            selection: TextSelection.collapsed(offset: 1),
          );

          // Assert
          expect(controller.text, '79008007060');
          expect(controller.selection.baseOffset, 1);

          // Cleanup
          controller.dispose();
        },
      );
    });

    group('partial input', () {
      test(
        'одиночные символы не детектируют страну и не триггерят rewrite',
        () {
          // Проверяем, что для неполных вводов (когда findPhone возвращает null)
          // rewrite не срабатывает: текст остаётся прежним, country=null.
          // Одиночный '+' здесь — это forward-typing (_lastText='' → '+'),
          // авто-очистка срабатывает только при удалении (wasDeletion=true)
          // и покрыта отдельно в группе 'plus auto-removal (Bug 2)'.
          for (final input in ['8', '7', '+7', '+']) {
            // Arrange
            final controller = ACPhoneEditingController();

            // Act
            controller.setPhoneNumber(input);

            // Assert
            expect(
              controller.text,
              input,
              reason: 'text не должен быть подменён для input "$input"',
            );
            expect(
              controller.country,
              isNull,
              reason: 'country должен быть null для input "$input"',
            );

            // Cleanup
            controller.dispose();
          }
        },
      );

      test(
        'переход 8 → 89 — rewrite срабатывает только на 89',
        () {
          // Arrange
          final controller = ACPhoneEditingController();

          // Act + Assert: шаг 1 — одиночная '8', страна не детектируется
          controller.setPhoneNumber('8');
          expect(controller.text, '8');
          expect(controller.country, isNull);

          // Act + Assert: шаг 2 — '89', детектируется RU и срабатывает
          // trunk-prefix replacement '8' → '7'
          controller.setPhoneNumber('89');
          expect(
            controller.text,
            '79',
            reason:
                'На 89 детектируется RU и срабатывает trunk-prefix replacement',
          );
          expect(controller.country?.isoCode, 'RU');

          // Cleanup
          controller.dispose();
        },
      );
    });

    group('re-entry guard', () {
      test('rewrite не вызывает бесконечный цикл listener\'а', () {
        // Arrange
        final controller = ACPhoneEditingController();
        var notifyCount = 0;
        controller.addListener(() => notifyCount++);

        // Act
        // setPhoneNumber('89008007060') триггерит:
        // (1) notify от text=, rewrite внутри listener'а,
        // (2) notify от программного value= при rewrite.
        controller.setPhoneNumber('89008007060');

        // Assert
        expect(
          notifyCount,
          lessThanOrEqualTo(2),
          reason:
              'Максимум 2 уведомления: от пользовательского setPhoneNumber и '
              'от rewrite-подмены value. Больше — значит re-entry guard '
              'пропускает бесконечную рекурсию.',
        );
        expect(
          controller.text,
          '79008007060',
          reason: 'rewrite всё равно должен сработать (не блокируется)',
        );

        // Cleanup
        controller.dispose();
      });
    });

    group('setPhoneNumber and paste', () {
      test('setPhoneNumber(89008007060) → text = 79008007060', () {
        // Arrange
        final controller = ACPhoneEditingController();

        // Act
        controller.setPhoneNumber('89008007060');

        // Assert
        expect(controller.text, '79008007060');
        expect(controller.country?.isoCode, 'RU');

        // Cleanup
        controller.dispose();
      });

      test(
        'paste через TextEditingValue эмулирует ввод 89008007060 → text = 79008007060',
        () {
          // Arrange
          final controller = ACPhoneEditingController();

          // Act
          // Эмулирует paste через прямую установку value:
          // курсор в конце (offset=11).
          controller.value = const TextEditingValue(
            text: '89008007060',
            selection: TextSelection.collapsed(offset: 11),
          );

          // Assert
          expect(controller.text, '79008007060');
          expect(controller.country?.isoCode, 'RU');

          // Cleanup
          controller.dispose();
        },
      );
    });

    group('multi-digit phoneCode', () {
      test(
        '+380501234567 (Украина) → text не переписывается, country=UA',
        () {
          // Arrange
          final controller = ACPhoneEditingController();

          // Act
          controller.setPhoneNumber('+380501234567');

          // Assert
          expect(
            controller.text,
            '+380501234567',
            reason:
                'phoneCode UA = +380, первые 3 digit текста = "380" '
                'совпадают — rewrite не вызывается',
          );
          expect(controller.country?.isoCode, 'UA');

          // Cleanup
          controller.dispose();
        },
      );
    });

    group('plus auto-removal (Bug 2)', () {
      test('+7 без цифр после удаления последней цифры → text очищается до пустого', () {
        // Arrange
        final controller = ACPhoneEditingController(
          initialPhoneNumber: '+7',
        );

        // Act — эмулируем backspace на цифре 7 (курсор в конце)
        controller.value = const TextEditingValue(
          text: '+',
          selection: TextSelection.collapsed(offset: 1),
        );

        // Assert — + должен автоматически удалиться
        expect(controller.text, isEmpty);

        // Cleanup
        controller.dispose();
      });

      test('+ без цифр и с маской-разделителями → text очищается до пустого', () {
        // Arrange
        final controller = ACPhoneEditingController(
          initialPhoneNumber: '+79008007060',
        );

        // Act — эмулируем состояние "только + с пробелом" (возможно после formatter)
        controller.value = const TextEditingValue(
          text: '+ ',
          selection: TextSelection.collapsed(offset: 2),
        );

        // Assert
        expect(controller.text, isEmpty);

        // Cleanup
        controller.dispose();
      });

      test('+79008007060 остаётся без изменений — есть цифры', () {
        // Регрессионный тест: логика автоудаления + не должна
        // срабатывать, пока в тексте есть цифры.
        // Arrange
        final controller = ACPhoneEditingController();

        // Act
        controller.value = const TextEditingValue(
          text: '+79008007060',
          selection: TextSelection.collapsed(offset: 12),
        );

        // Assert
        expect(controller.text, '+79008007060');
        expect(controller.country?.isoCode, 'RU');

        // Cleanup
        controller.dispose();
      });
    });
  });
}
